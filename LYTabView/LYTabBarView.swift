//
//  LYTabBarView.swift
//  LYTabBarView
//
//  Created by Lu Yibin on 16/3/29.
//  Copyright © 2016年 Lu Yibin. All rights reserved.
//

import Foundation
import Cocoa

@IBDesignable
public class LYTabBarView: NSView {
    private let serialQueue = dispatch_queue_create("Operations.TabBarView.UpdaterQueue", DISPATCH_QUEUE_SERIAL)
    private var _needsUpdate = false

    @IBOutlet public var delegate : NSTabViewDelegate?
    
    public var needAnimation : Bool = true
    public var isActive : Bool = true {
        didSet {
            self.needsDisplay = true
        }
    }
    public var hideIfOnlyOneTabExists : Bool = true {
        didSet {
            checkVisibilityAccordingToTabCount()
        }
    }
    
    public var hasBorder : Bool = false {
        didSet {
            self.needsDisplay = true
            self.needsLayout = true
            self.invalidateIntrinsicContentSize()
        }
    }

    public var paddingWindowButton : Bool = false {
        didSet {
            windowButtonPaddingView.hidden = !paddingWindowButton
            self.needsDisplay = true
        }
    }
    
    var backgroundColor : NSColor {
        if self.isRealActive {
            return NSColor(white: 0.73, alpha: 1)
        } else {
            return NSColor(white: 0.95, alpha: 1)
        }
    }
    
    var borderColor : NSColor {
        if self.isRealActive {
            return NSColor(white: 0.61, alpha: 1)
        } else {
            return NSColor(white: 0.86, alpha: 1)
        }
    }
    
    var selectedBorderColor : NSColor {
        if self.isRealActive {
            return NSColor(white: 0.71, alpha: 1)
        } else {
            return NSColor(white: 0.86, alpha: 1)
        }
    }
    
    public var showAddNewTabButton : Bool = true {
        didSet {
            addTabButton.hidden = !showAddNewTabButton
            self.needsUpdate = true
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
    
    public var addNewTabButtonAction : Selector? {
        set(newAction) {
            if let action = newAction {
                addTabButton.action = action
            } else {
                addTabButton.action = nil
            }
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
    
    private var isRealActive : Bool {
        if let window = self.window {
            return (window.keyWindow || window.mainWindow || (window.isKindOfClass(NSPanel) && NSApp.active)) && isActive
        }
        return false
    }
    
    @IBOutlet var tabView : NSTabView? {
        didSet {
            self.needsUpdate = true
        }
    }

    let stackView = NSStackView(frame: .zero)
    private let outterStackView = NSStackView(frame: .zero)
    private var addTabButton : NSButton!
    private var addTabButtonHeightConstraint : NSLayoutConstraint?
    private let windowButtonPaddingView : NSView = NSView(frame: .zero)
    private var windowButtonPaddingViewWidthConstraint : NSLayoutConstraint?
    
    override public var intrinsicContentSize: NSSize {
        var height : CGFloat = 22;
        if let aTabView = self.tabItemViews().first {
            height = aTabView.intrinsicContentSize.height + (hasBorder ? 2 : 0)
        }
        return NSMakeSize(NSViewNoIntrinsicMetric, height)
    }
    
    private func setupViews() {
        outterStackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(outterStackView)
        outterStackView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        outterStackView.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor).active = true
        outterStackView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
        outterStackView.trailingAnchor.constraintEqualToAnchor(self.trailingAnchor).active = true
        outterStackView.orientation = .Horizontal
        outterStackView.distribution = .Fill
        outterStackView.spacing = 1
        outterStackView.setHuggingPriority(NSLayoutPriorityDefaultLow, forOrientation: .Horizontal)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        outterStackView.addView(stackView, inGravity: .Center)
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
            outterStackView.addView(addTabButton, inGravity: .Bottom)
        }
        
        windowButtonPaddingView.translatesAutoresizingMaskIntoConstraints = false
        outterStackView.addView(windowButtonPaddingView, inGravity: .Top)
        windowButtonPaddingViewWidthConstraint = windowButtonPaddingView.widthAnchor.constraintEqualToConstant(68)
        windowButtonPaddingViewWidthConstraint?.active =  true
        windowButtonPaddingView.hidden = !paddingWindowButton
    }
    
    public override func viewDidMoveToWindow() {
        if let window = self.window {
            var width : CGFloat = 68
            if let lastButton = window.standardWindowButton(.ZoomButton), let firstButton = window.standardWindowButton(.CloseButton) {
                width = firstButton.frame.origin.x + lastButton.frame.origin.x + lastButton.frame.size.width
            }

            if let constraint = windowButtonPaddingViewWidthConstraint {
                constraint.constant = width
            }

        }
    }
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    required public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupViews()
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
            if let constraint = addTabButtonHeightConstraint, let aTabView = self.tabItemViews().first {
                let height = aTabView.intrinsicContentSize.height
                constraint.active = false
                addTabButtonHeightConstraint = addTabButton.heightAnchor.constraintEqualToConstant(height)
                addTabButtonHeightConstraint?.active = true
            }
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
    
    func removeAllTabViewItemExcept(tabViewItem: NSTabViewItem) {
        for tabItemView in self.tabItemViews() {
            if tabItemView.tabViewItem != tabViewItem {
                self.stackView.removeView(tabItemView)
                self.tabView?.removeTabViewItem(tabItemView.tabViewItem)
            }
        }
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
            checkVisibilityAccordingToTabCount()
            self.needsDisplay = true
        }
    }
    
    func updateTabState() {
        for v in self.tabItemViews() {
            v.needsDisplay = true
        }
        self.needsDisplay = true
    }
    
    func checkVisibilityAccordingToTabCount() {
        let count = tabViewItems.count
        if hideIfOnlyOneTabExists {
            self.animatorOrNot().hidden = count <= 1
        } else {
            self.animatorOrNot().hidden = count < 1
        }
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
        let yBorder : CGFloat = hasBorder ? -0.5 : 0.5
        for tabView in self.tabItemViews() {
            var rect = NSInsetRect(tabView.frame, -0.5, yBorder)
            if self.selectedTabView() == tabView {
                rect = NSInsetRect(tabView.frame, 1, yBorder)
                selectedBorderColor.setStroke()
            } else {
                borderColor.setStroke()
            }
            let border = NSBezierPath(rect: rect)
            border.lineWidth = 1
            border.stroke()
        }
        let rect = addTabButton.frame
        let border = NSBezierPath(rect: NSInsetRect(rect, -0.5, yBorder))
        borderColor.setStroke()
        border.stroke()
        NSRectFill(rect)
        
        if paddingWindowButton {
            let paddingRect = NSRect(x: 0, y: 0, width: self.windowButtonPaddingView.frame.size.width, height: self.frame.size.height)
            NSColor.clearColor().setFill()
            NSRectFill(paddingRect)
        }
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
    
    public override func prepareForInterfaceBuilder() {
        var ibTabItem = NSTabViewItem()
        ibTabItem.label = "Tab"
        self.addTabViewItem(ibTabItem)
        ibTabItem = NSTabViewItem()
        ibTabItem.label = "Bar"
        self.addTabViewItem(ibTabItem)
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