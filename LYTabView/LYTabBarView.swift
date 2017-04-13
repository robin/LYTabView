//
//  LYTabBarView.swift
//  LYTabBarView
//
//  Created by Lu Yibin on 16/3/29.
//  Copyright © 2016年 Lu Yibin. All rights reserved.
//

import Foundation
import Cocoa


enum BarStatus {
    case active
    case windowInactive
    case inactive
}

typealias ColorConfig = [BarStatus:NSColor]

@IBDesignable
open class LYTabBarView: NSView {
    fileprivate let serialQueue = DispatchQueue(label: "Operations.TabBarView.UpdaterQueue")
    fileprivate var _needsUpdate = false

    @IBOutlet open var delegate : NSTabViewDelegate?

    public enum BoderStyle {
        case none
        case top
        case bottom
        case both

        func borderOffset(width:CGFloat = 1) -> CGFloat {
            switch self {
            case .none:
                return 0
            case .top, .bottom:
                return width
            case .both:
                return width * 2
            }
        }

        var alignment : NSLayoutAttribute {
            switch self {
            case .none, .both:
                return .centerY
            case .top:
                return .bottom
            case .bottom:
                return .top
            }
        }
    }
    
    open var needAnimation : Bool = true
    open var isActive : Bool = true {
        didSet {
            
            self.needsDisplay = true
            for view in self.tabItemViews() {
                view.updateColors()
                view.needsDisplay = true
            }
        }
    }
    open var hideIfOnlyOneTabExists : Bool = true {
        didSet {
            checkVisibilityAccordingToTabCount()
        }
    }

    open var borderStyle : BoderStyle = .none {
        didSet {
            self.outterStackView.alignment = borderStyle.alignment
            self.invalidateIntrinsicContentSize()
            self.needsDisplay = true
            self.needsLayout = true
        }
    }

    open var paddingWindowButton : Bool = false {
        didSet {
            windowButtonPaddingView.isHidden = !paddingWindowButton
            self.needsDisplay = true
        }
    }
    
    var status : BarStatus {
        let isWindowActive = self.isWindowActive
        if self.isActive && isWindowActive {
            return .active
        } else if !isWindowActive {
            return .windowInactive
        } else {
            return .inactive
        }
    }
    
    var backgroundColor : ColorConfig = [
        .active : NSColor(white: 0.77, alpha: 1),
        .windowInactive : NSColor(white: 0.86, alpha: 1),
        .inactive : NSColor(white: 0.70, alpha: 1)
    ]
    
    var borderColor : ColorConfig = [
        .active : NSColor(white: 0.72, alpha: 1),
        .windowInactive : NSColor(white: 0.86, alpha: 1),
        .inactive : NSColor(white: 0.71, alpha: 1)
    ]
    
    var selectedBorderColor : ColorConfig = [
        .active : NSColor(white: 0.71, alpha: 1),
        .windowInactive : NSColor(white: 0.86, alpha: 1),
        .inactive : NSColor(white: 0.71, alpha: 1)
    ]
    
    open var showAddNewTabButton : Bool = true {
        didSet {
            addTabButton.isHidden = !showAddNewTabButton
            self.needsUpdate = true
        }
    }
    
    open var addNewTabButtonTarget : AnyObject?
    
    open var addNewTabButtonAction : Selector?
    
    open var tabViewItems : [NSTabViewItem] {
        get {
            return self.tabView?.tabViewItems ?? []
        }
    }
    
    var isWindowActive : Bool {
        if let window = self.window {
            if let _ = window as? NSPanel {
                return NSApp.isActive
            } else {
                return window.isKeyWindow || window.isMainWindow
            }
        }
        return false
    }
    
    @IBOutlet var tabView : NSTabView? {
        didSet {
            self.needsUpdate = true
        }
    }

    let stackView = NSStackView(frame: .zero)
    fileprivate let outterStackView = NSStackView(frame: .zero)
    fileprivate var addTabButton : NSButton!
    fileprivate var addTabButtonHeightConstraint : NSLayoutConstraint?
    fileprivate let windowButtonPaddingView : NSView = NSView(frame: .zero)
    fileprivate var windowButtonPaddingViewWidthConstraint : NSLayoutConstraint?
    
    override open var intrinsicContentSize: NSSize {
        var height : CGFloat = 22;
        if let aTabView = self.tabItemViews().first {
            height = aTabView.intrinsicContentSize.height + borderStyle.borderOffset()
        }
        return NSMakeSize(NSViewNoIntrinsicMetric, height)
    }
    
    fileprivate func setupViews() {
        outterStackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(outterStackView)
        outterStackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        outterStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        outterStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        outterStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        outterStackView.orientation = .horizontal
        outterStackView.distribution = .fill
        outterStackView.alignment = borderStyle.alignment
        outterStackView.spacing = 1
        outterStackView.setHuggingPriority(NSLayoutPriorityDefaultLow, for: .horizontal)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        outterStackView.addView(stackView, in: .center)
        stackView.orientation = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 1
        stackView.setHuggingPriority(NSLayoutPriorityDefaultLow, for: .horizontal)
        
        addTabButton = NSButton(frame: .zero)
        addTabButton.translatesAutoresizingMaskIntoConstraints = false
        addTabButton.setButtonType(.momentaryChange)
        addTabButton.image = NSImage(named: NSImageNameAddTemplate)
        addTabButton.bezelStyle = .shadowlessSquare
        addTabButton.isBordered = false
        addTabButton.imagePosition = .imageOnly
        addTabButton.target = self
        addTabButton.action = #selector(addNewTab)
        addTabButtonHeightConstraint = addTabButton.heightAnchor.constraint(equalToConstant: 22)
        addTabButtonHeightConstraint?.isActive = true
        addTabButton.widthAnchor.constraint(equalTo: addTabButton.heightAnchor).isActive = true
        if showAddNewTabButton {
            outterStackView.addView(addTabButton, in: .bottom)
        }
        
        windowButtonPaddingView.translatesAutoresizingMaskIntoConstraints = false
        outterStackView.addView(windowButtonPaddingView, in: .top)
        windowButtonPaddingViewWidthConstraint = windowButtonPaddingView.widthAnchor.constraint(equalToConstant: 68)
        windowButtonPaddingViewWidthConstraint?.isActive =  true
        windowButtonPaddingView.isHidden = !paddingWindowButton
    }
    
    open override func viewDidMoveToWindow() {
        if let window = self.window {
            var width : CGFloat = 68
            if let lastButton = window.standardWindowButton(.zoomButton), let firstButton = window.standardWindowButton(.closeButton) {
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
        NotificationCenter.default.removeObserver(self)
    }
    
    public func removeTabViewItem(_ tabviewItem : NSTabViewItem, animated : Bool = false) {
        if let tabItemView = self.itemViewForItem(tabviewItem) {
            self.stackView.removeView(tabItemView, animated: true, completionHandler: {
                self.needsUpdate = true
            })
        }
        self.tabView?.removeTabViewItem(tabviewItem)
    }
    
    func removeAllTabViewItemExcept(_ tabViewItem: NSTabViewItem) {
        for tabItemView in self.tabItemViews() {
            if tabItemView.tabViewItem != tabViewItem {
                self.stackView.removeView(tabItemView)
                self.tabView?.removeTabViewItem(tabItemView.tabViewItem)
            }
        }
    }
    
    func tabItemViews() -> [LYTabItemView] {
        return self.stackView.views(in: .center).flatMap { $0 as? LYTabItemView }
    }
    
    func shouldShowCloseButton(_ tabBarItem : NSTabViewItem) -> Bool {
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
            serialQueue.sync {
                if !self.needsUpdate {
                    self._needsUpdate = true
                    OperationQueue.main.addOperation({
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
                    if tabItems.index(of: tabItem) == nil {
                        self.stackView.removeView(tabView)
                    }
                }
            }
            
            var idx = 0
            let currentTabItems = self.tabItemViews().flatMap { $0.tabViewItem }
            for item in tabItems {
                if !currentTabItems.contains(item) {
                    self.insertTabItemView(item, index: idx)
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
            self.animatorOrNot().isHidden = count <= 1
        } else {
            self.animatorOrNot().isHidden = count < 1
        }
    }
    
    func selectTabViewItem(_ tabViewItem : NSTabViewItem) {
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
    
    open override func viewWillMove(toWindow newWindow: NSWindow?) {
        NotificationCenter.default.addObserver(self, selector: #selector(windowStatusDidChange), name: NSNotification.Name.NSWindowDidBecomeKey, object: newWindow)
        NotificationCenter.default.addObserver(self, selector: #selector(windowStatusDidChange), name: NSNotification.Name.NSWindowDidResignKey, object: newWindow)
    }
    
    func windowStatusDidChange(_ notification : Notification) {
        self.needsDisplay = true
        self.stackView.needsDisplay = true
        for itemViews in self.tabItemViews() {
            itemViews.updateColors()
        }
    }
    
    open override func draw(_ dirtyRect: NSRect) {
        let status = self.status
        self.borderColor[status]!.setFill()
        NSRectFill(self.bounds)
        let rect = addTabButton.frame
        self.backgroundColor[status]!.setFill()
        NSRectFill(rect)
        
        if paddingWindowButton {
            let paddingRect = NSRect(x: 0, y: 0, width: self.windowButtonPaddingView.frame.size.width, height: self.frame.size.height)
            NSColor.clear.setFill()
            NSRectFill(paddingRect)
        }
    }
    
    @IBAction public func closeCurrentTab(_ sender:AnyObject?) {
        if let selectedView = selectedTabView() {
            removeTabViewItem(selectedView.tabViewItem, animated: true)
        }
    }

    func addNewTab(_ sender:AnyObject?) {
        if let target = self.addNewTabButtonTarget, let action = self.addNewTabButtonAction {
            DispatchQueue.main.async {
                _=target.perform(action, with: self)
            }
        }
    }

    private func moveTo(_ dragTabItemView : LYTabItemView, position : NSInteger, movingItemView : LYTabItemView) {
        self.stackView.removeView(dragTabItemView)
        self.stackView.insertView(dragTabItemView, at: position, in: .center)
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
    
    func handleDraggingTab(_ dragRect : NSRect, dragTabItemView : LYTabItemView) {
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
            for itemView in self.tabItemViews().reversed() {
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
    
    func updateTabViewForMovedTabItem(_ tabItem : NSTabViewItem) {
        for (idx, itemView) in self.tabItemViews().enumerated() {
            if itemView.tabViewItem == tabItem {
                self.tabView?.removeTabViewItem(tabItem)
                self.tabView?.insertTabViewItem(tabItem, at: idx)
            }
        }
        self.tabView?.selectTabViewItem(tabItem)
    }
    
    private func createLYTabItemView(_ item : NSTabViewItem) -> LYTabItemView {
        let tabView = LYTabItemView(tabViewItem: item)
        tabView.tabBarView = self
        tabView.translatesAutoresizingMaskIntoConstraints = false
        return tabView
    }
    
    private func itemViewForItem(_ item: NSTabViewItem) -> LYTabItemView? {
        for tabItemView in self.tabItemViews() {
            if tabItemView.tabViewItem == item {
                return tabItemView
            }
        }
        return nil
    }

    public func addTabViewItem(_ item: NSTabViewItem, animated : Bool = false) {
        self.tabView?.addTabViewItem(item)
        self.insertTabItemView(item, index: self.tabItemViews().count, animated:animated)
    }

    func resetHeight() {
        if tabItemViews().count == 1 {
            if let constraint = addTabButtonHeightConstraint, let aTabView = self.tabItemViews().first {
                let height = aTabView.intrinsicContentSize.height
                constraint.isActive = false
                addTabButtonHeightConstraint = addTabButton.heightAnchor.constraint(equalToConstant: height)
                addTabButtonHeightConstraint?.isActive = true
            }
            self.invalidateIntrinsicContentSize()
        }
    }

    private func insertTabItemView(_ item: NSTabViewItem, index: NSInteger, animated: Bool = false) {
        let tabView = createLYTabItemView(item)
        stackView.insertView(tabView, atIndex: index, inGravity: .center, animated: animated, completionHandler: {
            self.needsUpdate = true
        })
        resetHeight()
    }
    
    open override func prepareForInterfaceBuilder() {
        var ibTabItem = NSTabViewItem()
        ibTabItem.label = "Tab"
        self.addTabViewItem(ibTabItem)
        ibTabItem = NSTabViewItem()
        ibTabItem.label = "Bar"
        self.addTabViewItem(ibTabItem)
    }
}

extension LYTabBarView : NSTabViewDelegate {
    public func tabViewDidChangeNumberOfTabViewItems(_ tabView: NSTabView) {
        self.needsUpdate = true
        self.delegate?.tabViewDidChangeNumberOfTabViewItems?(tabView)
    }
    
    public func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        self.updateTabState()
        self.delegate?.tabView?(tabView, didSelect: tabViewItem)
    }
    
    public func tabView(_ tabView: NSTabView, willSelect tabViewItem: NSTabViewItem?) {
        self.delegate?.tabView?(tabView, willSelect: tabViewItem)
    }
    
    public func tabView(_ tabView: NSTabView, shouldSelect tabViewItem: NSTabViewItem?) -> Bool {
        if let rslt = self.delegate?.tabView?(tabView, shouldSelect: tabViewItem) {
            return rslt
        }
        return true
    }
}
