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

    var backgroundColor = NSColor(calibratedRed: 0.77, green: 0.77, blue: 0.77, alpha: 1)
    var borderColor = NSColor.headerColor()
    var selectedBorderColor = NSColor(calibratedRed: 0.73, green: 0.73, blue: 0.73, alpha: 1)
    
    @IBOutlet var tabView : NSTabView? {
        didSet {
            self.needsUpdate = true
        }
    }

    let stackView : NSStackView
    
    override public var intrinsicContentSize: NSSize {
        if let aTabView = self.tabViews().first {
            return NSMakeSize(NSViewNoIntrinsicMetric, aTabView.intrinsicContentSize.height+2)
        }
        return NSMakeSize(NSViewNoIntrinsicMetric, 22)
    }
    
    required public init?(coder: NSCoder) {
        stackView = NSStackView(frame: .zero)
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
    }
    
    func insertTabViewItem(item: NSTabViewItem, index: NSInteger) {
        let tabView = LYTabView(tabViewItem: item)
        tabView.translatesAutoresizingMaskIntoConstraints = false
        tabView.backgroundColor = self.backgroundColor
        stackView.insertView(tabView, atIndex: index, inGravity: .Center)
        if stackView.views.count == 1 {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    func tabViews() -> [LYTabView] {
        return self.stackView.viewsInGravity(.Center).flatMap { $0 as? LYTabView }
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
        }
    }
    
    func updateTabState() {
        for v in self.tabViews() {
            v.needsDisplay = true
        }
    }
    
    public override func drawRect(dirtyRect: NSRect) {
        self.borderColor.setFill()
        NSRectFill(self.bounds)
        let border = NSBezierPath(rect: self.bounds)
        borderColor.setStroke()
        border.stroke()
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