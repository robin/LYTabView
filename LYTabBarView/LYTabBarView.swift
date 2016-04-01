//
//  LYTabBarView.swift
//  LYTabBarView
//
//  Created by Lu Yibin on 16/3/29.
//  Copyright © 2016年 Lu Yibin. All rights reserved.
//

import Foundation
import Cocoa

public class LYTabBarView: NSView {
    private let serialQueue = dispatch_queue_create("Operations.TabBarView.UpdaterQueue", DISPATCH_QUEUE_SERIAL)
    private var _needsUpdate = false

    var backgroundColor = NSColor(white: 0.73, alpha: 1)
    var borderColor = NSColor(white: 0.61, alpha: 1)
    var selectedBorderColor = NSColor(white: 0.71, alpha: 1)
    
    @IBOutlet var tabView : NSTabView? {
        didSet {
            self.needsUpdate = true
        }
    }

    private let stackView = NSStackView(frame: .zero)
    private var addTabButton : NSButton!
    private var addTabButtonHeightConstraint : NSLayoutConstraint?
    
    override public var intrinsicContentSize: NSSize {
        var height : CGFloat = 22;
        if let aTabView = self.tabViews().first {
            height = aTabView.intrinsicContentSize.height+2
        }
        if let constraint = addTabButtonHeightConstraint {
            constraint.active = false
            addTabButtonHeightConstraint = addTabButton.heightAnchor.constraintEqualToConstant(height)
            addTabButtonHeightConstraint?.active = true
        }
        return NSMakeSize(NSViewNoIntrinsicMetric, height)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)
        stackView.trailingAnchor.constraintEqualToAnchor(self.trailingAnchor).active = true
        stackView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        stackView.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor).active = true
        stackView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
        stackView.orientation = .Horizontal
        stackView.distribution = .FillEqually
        stackView.spacing = 1
        
        addTabButton = NSButton(frame: .zero)
        addTabButton.translatesAutoresizingMaskIntoConstraints = false
        addTabButton.setButtonType(.MomentaryChangeButton)
        addTabButton.image = NSImage(named: NSImageNameAddTemplate)
        addTabButton.bezelStyle = .ShadowlessSquareBezelStyle
        addTabButton.bordered = false
        addTabButton.imagePosition = .ImageOnly
        stackView.addView(addTabButton, inGravity: .Bottom)
        addTabButtonHeightConstraint = addTabButton.heightAnchor.constraintEqualToConstant(22)
        addTabButtonHeightConstraint?.active = true
        addTabButton.widthAnchor.constraintEqualToAnchor(addTabButton.heightAnchor).active = true
        addTabButton.target = self
        addTabButton.action = #selector(addNewTab)
    }
    
    private func createLYTabView(item : NSTabViewItem) -> LYTabView {
        let tabView = LYTabView(tabViewItem: item)
        tabView.tabBarView = self
        tabView.translatesAutoresizingMaskIntoConstraints = false
        tabView.backgroundColor = self.backgroundColor
        return tabView
    }
    
    func insertTabViewItem(item: NSTabViewItem, index: NSInteger) {
        let tabView = createLYTabView(item)
        stackView.insertView(tabView, atIndex: index, inGravity: .Center)
        if tabViews().count == 1 {
            self.invalidateIntrinsicContentSize()
        }
    }

    func tabViews() -> [LYTabView] {
        return self.stackView.viewsInGravity(.Center).flatMap { $0 as? LYTabView }
    }
    
    func shouldShowCloseButton(tabBarItem : NSTabViewItem) -> Bool {
        return true
    }
    
    var needsUpdate : Bool {
        get {
            return _needsUpdate
        }
        set(newState) {
            if !newState {
                _needsUpdate = newState
                return
            }
            dispatch_sync(serialQueue) {
                if !self.needsUpdate {
                    self._needsUpdate = true
                    NSOperationQueue.mainQueue().addOperationWithBlock({ 
                        self.update()
                    })
                }
            }
        }
    }
    
    func update() {
        guard self.needsUpdate else {
            return
        }
        _needsUpdate = false
        
        if let tabView = self.tabView {
            let tabItems = tabView.tabViewItems
            let tabViews = self.tabViews()
            for tabView in tabViews {
                if let tabItem = tabView.tabViewItem {
                    if tabItems.indexOf(tabItem) == nil {
                        self.stackView.removeView(tabView)
                    }
                }
            }
            
            var idx = 0
            let currentTabItems = self.tabViews().flatMap { $0.tabViewItem }
            for item in tabItems {
                if !currentTabItems.contains(item) {
                    self.insertTabViewItem(item, index: idx)
                }
                idx += 1
            }
            self.hidden = tabItems.count <= 1
            self.needsDisplay = true
        }
    }
    
    func updateTabState() {
        for v in self.tabViews() {
            v.needsDisplay = true
        }
        self.needsDisplay = true
    }
    
    func selectTabViewItem(tabViewItem : NSTabViewItem) {
        self.tabView?.selectTabViewItem(tabViewItem)
    }
    
    func selectedTabView() -> LYTabView? {
        if let selectedTabViewItem = self.tabView?.selectedTabViewItem {
            for tabView in self.tabViews() {
                if tabView.tabViewItem == selectedTabViewItem {
                    return tabView
                }
            }
        }
        return nil
    }
    
    func removeTabViewItem(tabviewItem : NSTabViewItem) {
        self.tabView?.removeTabViewItem(tabviewItem)
    }
    
    public override func drawRect(dirtyRect: NSRect) {
        self.borderColor.setFill()
        NSRectFill(self.bounds)
        let border = NSBezierPath(rect: self.bounds)
        borderColor.setStroke()
        border.stroke()
        if let selectedTabView = self.selectedTabView() {
            var rect = selectedTabView.frame
            rect.origin.y = 0
            rect.size.height = self.frame.size.height
            selectedBorderColor.setFill()
            NSRectFill(rect)
        }
        let rect = NSInsetRect(addTabButton.frame, 0, 0.5)
        self.backgroundColor.setFill()
        NSRectFill(rect)
    }
    
    @IBAction func addNewTab(sender:AnyObject?) {
        let item = NSTabViewItem()
        item.label = "Untitle"
        self.tabView?.addTabViewItem(item)
        selectTabViewItem(item)
    }
}

extension LYTabBarView : NSTabViewDelegate {
    public func tabViewDidChangeNumberOfTabViewItems(tabView: NSTabView) {
        self.needsUpdate = true
    }
    
    public func tabView(tabView: NSTabView, didSelectTabViewItem tabViewItem: NSTabViewItem?) {
        self.updateTabState()
    }
}