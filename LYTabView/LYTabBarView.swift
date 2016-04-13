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

    @IBOutlet public var delegate : NSTabViewDelegate?
    
    public var needAnimation = true

    var backgroundColor : NSColor {
        if self.isWindowActive() {
            return NSColor(white: 0.73, alpha: 1)
        } else {
            return NSColor(white: 0.95, alpha: 1)
        }
    }
    
    var borderColor : NSColor {
        if self.isWindowActive() {
            return NSColor(white: 0.61, alpha: 1)
        } else {
            return NSColor(white: 0.86, alpha: 1)
        }
    }
    
    var selectedBorderColor : NSColor {
        if self.isWindowActive() {
            return NSColor(white: 0.71, alpha: 1)
        } else {
            return NSColor(white: 0.86, alpha: 1)
        }
    }
    
    public var showAddNewTabButton = true {
        didSet {
            if showAddNewTabButton && addTabButton.superview == nil {
                stackView.addView(addTabButton, inGravity: .Bottom)
            } else if !showAddNewTabButton && addTabButton.superview != nil {
                addTabButton.removeFromSuperview()
            }
        }
    }
    
    public var addNewTabButtonTarget : AnyObject? {
        set(newTarget) {
            addTabButton.target = newTarget
        }
        get {
            return addTabButton.target
        }
    }
    
    public var addNewTabButtonAction : Selector {
        set(newAction) {
            addTabButton.action = newAction
        }
        get {
            return addTabButton.action
        }
    }
    
    public var tabViewItems : [NSTabViewItem] {
        get {
            return self.tabView?.tabViewItems ?? []
        }
    }
    
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
        if let aTabView = self.tabItemViews().first {
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
        stackView.setHuggingPriority(NSLayoutPriorityDefaultLow, forOrientation: .Horizontal)
        
        addTabButton = NSButton(frame: .zero)
        addTabButton.translatesAutoresizingMaskIntoConstraints = false
        addTabButton.setButtonType(.MomentaryChangeButton)
        addTabButton.image = NSImage(named: NSImageNameAddTemplate)
        addTabButton.bezelStyle = .ShadowlessSquareBezelStyle
        addTabButton.bordered = false
        addTabButton.imagePosition = .ImageOnly
        addTabButtonHeightConstraint = addTabButton.heightAnchor.constraintEqualToConstant(22)
        addTabButtonHeightConstraint?.active = true
        addTabButton.widthAnchor.constraintEqualToAnchor(addTabButton.heightAnchor).active = true
        if showAddNewTabButton {
            stackView.addView(addTabButton, inGravity: .Bottom)
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    public func addTabViewItem(item: NSTabViewItem, animated : Bool = false) {
        let tabView = createLYTabItemView(item)
        stackView.addView(tabView, inGravity: .Center, animated: animated) { 
            self.needsUpdate = true
        }
        self.tabView?.addTabViewItem(item)
        if tabItemViews().count == 1 {
            self.invalidateIntrinsicContentSize()
        }
        selectTabViewItem(item)
    }

    public func removeTabViewItem(tabviewItem : NSTabViewItem, animated : Bool = false) {
        if let tabItemView = self.itemViewForItem(tabviewItem) {
            self.stackView.removeView(tabItemView, animated: true, completionHandler: {
                self.needsUpdate = true
            })
        }
        self.tabView?.removeTabViewItem(tabviewItem)
    }
    
    func tabItemViews() -> [LYTabItemView] {
        return self.stackView.viewsInGravity(.Center).flatMap { $0 as? LYTabItemView }
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
            let tabItemViews = self.tabItemViews()
            for tabView in tabItemViews {
                if let tabItem = tabView.tabViewItem {
                    if tabItems.indexOf(tabItem) == nil {
                        self.stackView.removeView(tabView)
                    }
                }
            }
            
            var idx = 0
            let currentTabItems = self.tabItemViews().flatMap { $0.tabViewItem }
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
        for v in self.tabItemViews() {
            v.needsDisplay = true
        }
        self.needsDisplay = true
    }
    
    func selectTabViewItem(tabViewItem : NSTabViewItem) {
        self.tabView?.selectTabViewItem(tabViewItem)
    }
    
    func selectedTabView() -> LYTabItemView? {
        if let selectedTabViewItem = self.tabView?.selectedTabViewItem {
            for tabView in self.tabItemViews() {
                if tabView.tabViewItem == selectedTabViewItem {
                    return tabView
                }
            }
        }
        return nil
    }
    
    func isWindowActive() -> Bool {
        if let window = self.window {
            return window.keyWindow || window.mainWindow || (window.isKindOfClass(NSPanel) && NSApp.active)
        }
        return false
    }
    
    public override func viewWillMoveToWindow(newWindow: NSWindow?) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(windowStatusDidChange), name: NSWindowDidBecomeKeyNotification, object: newWindow)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(windowStatusDidChange), name: NSWindowDidResignKeyNotification, object: newWindow)
    }
    
    func windowStatusDidChange(notification : NSNotification) {
        self.needsDisplay = true
        self.stackView.needsDisplay = true
        for itemViews in self.tabItemViews() {
            itemViews.updateColors()
        }
    }
    
    public override func drawRect(dirtyRect: NSRect) {
        self.backgroundColor.setFill()
        NSRectFill(self.bounds)
        var border = NSBezierPath(rect: NSInsetRect(self.bounds, 0, 0))
        borderColor.setStroke()
        border.stroke()
        for tabView in self.tabItemViews() {
            let rect = NSInsetRect(tabView.frame, -1, -1)
            if self.selectedTabView() == tabView {
                selectedBorderColor.setStroke()
            } else {
                borderColor.setStroke()
            }
            border = NSBezierPath(rect: rect)
            border.stroke()
        }
        let rect = NSInsetRect(addTabButton.frame, 0, 0.5)
        self.backgroundColor.setFill()
        NSRectFill(rect)
        border = NSBezierPath(rect: NSInsetRect(rect, -1, -1))
        borderColor.setStroke()
        border.stroke()
    }
    
    @IBAction public func closeCurrentTab(sender:AnyObject?) {
        if let selectedView = selectedTabView() {
            removeTabViewItem(selectedView.tabViewItem, animated: true)
        }
    }

    private func moveTo(dragTabItemView : LYTabItemView, position : NSInteger, movingItemView : LYTabItemView) {
        self.stackView.removeView(dragTabItemView)
        self.stackView.insertView(dragTabItemView, atIndex: position, inGravity: .Center)
        if needAnimation {
            NSAnimationContext.runAnimationGroup({ (context) in
                let origFrame = movingItemView.frame
                self.stackView.layoutSubtreeIfNeeded()
                let toFrame = movingItemView.frame
                movingItemView.frame = origFrame
                movingItemView.animator().frame = toFrame
                movingItemView.drawBorder = true
                movingItemView.isMoving = true
                }, completionHandler: {
                    movingItemView.isMoving = false
                    movingItemView.drawBorder = false
            })
        }
    }
    
    func handleDraggingTab(dragRect : NSRect, dragTabItemView : LYTabItemView) {
        var idx = 0
        var moved = false
        for itemView in self.tabItemViews() {
            if itemView != dragTabItemView && !itemView.isMoving {
                let midx = NSMidX(itemView.frame)
                if (midx > NSMinX(dragRect)){
                    moveTo(dragTabItemView, position: idx, movingItemView: itemView)
                    moved = true
                    break
                }
                idx += 1
            } else if itemView == dragTabItemView {
                break
            }
        }
        if !moved {
            idx = self.tabItemViews().count - 1
            for itemView in self.tabItemViews().reverse() {
                if itemView != dragTabItemView && !itemView.isMoving {
                    let midx = NSMidX(itemView.frame)
                    if (midx <= NSMaxX(dragRect)){
                        moveTo(dragTabItemView, position: idx, movingItemView: itemView)
                        break
                    }
                    idx -= 1
                } else if itemView == dragTabItemView {
                    break
                }
            }
        }
    }
    
    func updateTabViewForMovedTabItem(tabItem : NSTabViewItem) {
        for (idx, itemView) in self.tabItemViews().enumerate() {
            if itemView.tabViewItem == tabItem {
                self.tabView?.removeTabViewItem(tabItem)
                self.tabView?.insertTabViewItem(tabItem, atIndex: idx)
            }
        }
        self.tabView?.selectTabViewItem(tabItem)
    }
    
    private func createLYTabItemView(item : NSTabViewItem) -> LYTabItemView {
        let tabView = LYTabItemView(tabViewItem: item)
        tabView.tabBarView = self
        tabView.translatesAutoresizingMaskIntoConstraints = false
        return tabView
    }
    
    private func itemViewForItem(item: NSTabViewItem) -> LYTabItemView? {
        for tabItemView in self.tabItemViews() {
            if tabItemView.tabViewItem == item {
                return tabItemView
            }
        }
        return nil
    }
    
    private func insertTabViewItem(item: NSTabViewItem, index: NSInteger, animated: Bool = false) {
        let tabView = createLYTabItemView(item)
        stackView.insertView(tabView, atIndex: index, inGravity: .Center, animated: animated, completionHandler: {
            self.needsUpdate = true
        })
        if tabItemViews().count == 1 {
            self.invalidateIntrinsicContentSize()
        }
    }
}

extension LYTabBarView : NSTabViewDelegate {
    public func tabViewDidChangeNumberOfTabViewItems(tabView: NSTabView) {
        self.needsUpdate = true
        self.delegate?.tabViewDidChangeNumberOfTabViewItems?(tabView)
    }
    
    public func tabView(tabView: NSTabView, didSelectTabViewItem tabViewItem: NSTabViewItem?) {
        self.updateTabState()
        self.delegate?.tabView?(tabView, didSelectTabViewItem: tabViewItem)
    }
    
    public func tabView(tabView: NSTabView, willSelectTabViewItem tabViewItem: NSTabViewItem?) {
        self.delegate?.tabView?(tabView, willSelectTabViewItem: tabViewItem)
    }
    
    public func tabView(tabView: NSTabView, shouldSelectTabViewItem tabViewItem: NSTabViewItem?) -> Bool {
        if let rslt = self.delegate?.tabView?(tabView, shouldSelectTabViewItem: tabViewItem) {
            return rslt
        }
        return true
    }
}