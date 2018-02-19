//
//  LYTabBarView.swift
//  LYTabBarView
//
//  Created by Lu Yibin on 16/3/29.
//  Copyright © 2016年 Lu Yibin. All rights reserved.
//

import Foundation
import Cocoa

public enum BarStatus {
    case active
    case windowInactive
    case inactive
}

public typealias ColorConfig = [BarStatus: NSColor]

@IBDesignable
public class LYTabBarView: NSView {
    private let serialQueue = DispatchQueue(label: "Operations.TabBarView.UpdaterQueue")
    private var _needsUpdate = false

    @IBOutlet public weak var delegate: NSTabViewDelegate?

    public enum BoderStyle {
        case none
        case top
        case bottom
        case both

        func borderOffset(width: CGFloat = 1) -> CGFloat {
            switch self {
            case .none:
                return 0
            case .top, .bottom:
                return width
            case .both:
                return width * 2
            }
        }

        var alignment: NSLayoutConstraint.Attribute {
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

    public var needAnimation: Bool = true
    public var isActive: Bool = true {
        didSet {
            self.needsDisplay = true
            for view in self.tabItemViews() {
                view.updateColors()
                view.needsDisplay = true
            }
        }
    }
    public var hideIfOnlyOneTabExists: Bool = true {
        didSet {
            checkVisibilityAccordingToTabCount()
        }
    }

    public var borderStyle: BoderStyle = .none {
        didSet {
            self.outterStackView.alignment = borderStyle.alignment
            self.invalidateIntrinsicContentSize()
            self.needsDisplay = true
            self.needsLayout = true
        }
    }

    public var paddingWindowButton: Bool = false {
        didSet {
            windowButtonPaddingView.isHidden = !paddingWindowButton
            self.needsDisplay = true
        }
    }

    public var minTabItemWidth: CGFloat = 100 {
        didSet {
            if let constraint = minViewWidthConstraint {
                constraint.constant = self.minViewWidth
                self.needsLayout = true
            }
        }
    }

    public var minTabHeight: CGFloat? {
        didSet {
            resetHeight()
        }
    }
    
    public var showCloseButton: Bool = true 

    var status: BarStatus {
        let isWindowActive = self.isWindowActive
        if self.isActive && isWindowActive {
            return .active
        } else if !isWindowActive {
            return .windowInactive
        } else {
            return .inactive
        }
    }

    public var backgroundColor: ColorConfig = [
        .active: NSColor(white: 0.77, alpha: 1),
        .windowInactive: NSColor(white: 0.86, alpha: 1),
        .inactive: NSColor(white: 0.70, alpha: 1)
    ]

    public var borderColor: ColorConfig = [
        .active: NSColor(white: 0.72, alpha: 1),
        .windowInactive: NSColor(white: 0.86, alpha: 1),
        .inactive: NSColor(white: 0.71, alpha: 1)
    ]

    public var selectedBorderColor: ColorConfig = [
        .active: NSColor(white: 0.71, alpha: 1),
        .windowInactive: NSColor(white: 0.86, alpha: 1),
        .inactive: NSColor(white: 0.71, alpha: 1)
    ]
    
    public var backgroundItemColor: ColorConfig = [
        .active: NSColor(white: 0.77, alpha: 1),
        .windowInactive: NSColor(white: 0.86, alpha: 1),
        .inactive: NSColor(white: 0.70, alpha: 1)
    ]
    
    public var hoverItemBackgroundColor: ColorConfig = [
        .active: NSColor(white: 0.75, alpha: 1),
        .windowInactive: NSColor(white: 0.94, alpha: 1),
        .inactive: NSColor(white: 0.68, alpha: 1)
    ]
    
    public var selectedBackgroundColor: ColorConfig = [
        .active: NSColor(white: 0.86, alpha: 1),
        .windowInactive: NSColor(white: 0.96, alpha: 1),
        .inactive: NSColor(white: 0.76, alpha: 1)
    ]
    
    public var selectedTextColor: ColorConfig = [
        .active: NSColor.textColor,
        .windowInactive: NSColor(white: 0.4, alpha: 1),
        .inactive: NSColor(white: 0.4, alpha: 1)
    ]
    
    public var unselectedForegroundColor = NSColor(white: 0.4, alpha: 1)
    public var closeButtonHoverBackgroundColor = NSColor(white: 0.55, alpha: 0.3)

    public var showAddNewTabButton: Bool = true {
        didSet {
            addTabButton.isHidden = !showAddNewTabButton
            self.needsUpdate = true
        }
    }

    public weak var addNewTabButtonTarget: AnyObject?

    public var addNewTabButtonAction: Selector?

    public var tabViewItems: [NSTabViewItem] {
        return self.tabView?.tabViewItems ?? []
    }

    private var packedTabViewItems: [NSTabViewItem] = [NSTabViewItem]()
    private var lastUnpackedItem: NSTabViewItem {
        return self.tabViewItems[self.tabItemViews().count-1]
    }

    private var hasPackedTabViewItems: Bool {
        return !packedTabViewItems.isEmpty
    }

    private var isWindowActive: Bool {
        if let window = self.window {
            if (window as? NSPanel) != nil {
                return NSApp.isActive
            } else {
                return window.isKeyWindow || window.isMainWindow
            }
        }
        return false
    }

    @IBOutlet public var tabView: NSTabView? {
        didSet {
            self.needsUpdate = true
        }
    }

    let tabContainerView = NSStackView(frame: .zero)
    private var buttonHeight: CGFloat {
        if let tabItemView = self.tabItemViews().first {
            return tabItemView.frame.size.height
        }
        return 20
    }
    private let outterStackView = NSStackView(frame: .zero)
    private var addTabButton: NSButton!
    private var packedTabButton: NSButton!
    private var buttonHeightConstraints = [NSLayoutConstraint]()
    private let windowButtonPaddingView: NSView = NSView(frame: .zero)
    private var windowButtonPaddingViewWidthConstraint: NSLayoutConstraint?
    private var minViewWidthConstraint: NSLayoutConstraint?
    private var minViewWidth: CGFloat {
        return minTabItemWidth + 2 * buttonHeight
    }

    override open var intrinsicContentSize: NSSize {
        var height: CGFloat = buttonHeight
        if let aTabView = self.tabItemViews().first {
            height = aTabView.intrinsicContentSize.height + borderStyle.borderOffset()
        }
        return NSSize(width: NSView.noIntrinsicMetric, height: height)
    }

    private func buildBarButton(image: NSImage?, action: Selector?) -> NSButton {
        let button = NSButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonType(.momentaryChange)
        button.image = image
        button.bezelStyle = .shadowlessSquare
        button.isBordered = false
        button.imagePosition = .imageOnly
        button.target = self
        button.action = action
        let constraint = button.heightAnchor.constraint(equalToConstant: buttonHeight)
        constraint.isActive = true
        buttonHeightConstraints.append(constraint)
        button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true
        return button
    }

    private func setupViews() {
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
        outterStackView.setHuggingPriority(NSLayoutConstraint.Priority.defaultLow, for: .horizontal)
        minViewWidthConstraint = outterStackView.widthAnchor.constraint(greaterThanOrEqualToConstant: self.minViewWidth)
        minViewWidthConstraint?.isActive = true

        tabContainerView.translatesAutoresizingMaskIntoConstraints = false
        outterStackView.addView(tabContainerView, in: .center)
        tabContainerView.orientation = .horizontal
        tabContainerView.distribution = .fillEqually
        tabContainerView.spacing = 1
        tabContainerView.setHuggingPriority(NSLayoutConstraint.Priority.defaultLow, for: .horizontal)
        tabContainerView.setHuggingPriority(NSLayoutConstraint.Priority.defaultLow, for: .vertical)

        packedTabButton = buildBarButton(image: NSImage(named: NSImage.Name.rightFacingTriangleTemplate),
                                         action: #selector(showPackedList))
        addTabButton = buildBarButton(image: NSImage(named: NSImage.Name.addTemplate),
                                      action: #selector(addNewTab))

        outterStackView.addView(packedTabButton, in: .bottom)
        outterStackView.addView(addTabButton, in: .bottom)
        packedTabButton.isHidden = true
        addTabButton.isHidden = !showAddNewTabButton

        windowButtonPaddingView.translatesAutoresizingMaskIntoConstraints = false
        outterStackView.addView(windowButtonPaddingView, in: .top)
        windowButtonPaddingViewWidthConstraint = windowButtonPaddingView.widthAnchor.constraint(equalToConstant: 68)
        windowButtonPaddingViewWidthConstraint?.isActive =  true
        windowButtonPaddingView.isHidden = !paddingWindowButton

        // Listen to bound changes
        self.postsBoundsChangedNotifications = true
        self.postsFrameChangedNotifications = true
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(boundDidChangeNotification),
                                               name: NSView.boundsDidChangeNotification,
                                               object: self)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(boundDidChangeNotification),
                                               name: NSView.frameDidChangeNotification,
                                               object: self)
    }

    open override func viewDidMoveToWindow() {
        if let window = self.window {
            var width: CGFloat = 68
            if let lastButton = window.standardWindowButton(.zoomButton),
                let firstButton = window.standardWindowButton(.closeButton) {
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

    private func removeTabItemView(tabItemView: LYTabItemView, animated: Bool ) {
        self.tabContainerView.removeView(tabItemView, animated: animated) {
            self.needsUpdate = true
        }
        popFirstPackedItem()
    }

    private func removePackedTabItem(at: Int) {
        packedTabViewItems.remove(at: at)
        if packedTabViewItems.isEmpty {
            packedTabButton.isHidden = true
        }
    }

    public func removeTabViewItem(_ tabviewItem: NSTabViewItem, animated: Bool = false) {
        if let index = self.packedTabViewItems.index(of: tabviewItem) {
            removePackedTabItem(at: index)
        }
        self.tabView?.removeTabViewItem(tabviewItem)
    }

    public func removeAllTabViewItemExcept(_ tabViewItem: NSTabViewItem) {
        for tabItem in self.tabViewItems where tabItem != tabViewItem {
            self.tabView?.removeTabViewItem(tabItem)
        }
    }

    func removeFrom(_ tabViewItem: NSTabViewItem) {
        if let index = self.tabViewItems.index(of: tabViewItem) {
            let dropItems = self.tabViewItems.dropFirst(index+1)
            for tabItem in dropItems {
                self.tabView?.removeTabViewItem(tabItem)
            }
        }
    }

    private func tabItemViews() -> [LYTabItemView] {
        return self.tabContainerView.views(in: .center).flatMap { $0 as? LYTabItemView }
    }

    private func shouldShowCloseButton(_ tabBarItem: NSTabViewItem) -> Bool {
        return true
    }

    var needsUpdate: Bool {
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
            let lastTabItem = self.tabItemViews().last?.tabViewItem
            let tabItemViews = self.tabItemViews()
            self.packedTabViewItems.removeAll()
            for (idx, item) in tabView.tabViewItems.enumerated() {
                if idx < tabItemViews.count {
                    tabItemViews[idx].tabViewItem = item
                } else {
                    self.insertTabItem(item, index: idx)
                }
            }
            for itemView in self.tabItemViews().dropFirst(tabView.tabViewItems.count) {
                itemView.removeFromSuperview()
            }
            if let lastItem = lastTabItem, self.packedTabViewItems.contains(lastItem) {
                self.tabItemViews().last?.tabViewItem = lastTabItem
            }
            packedTabButton.isHidden = !self.hasPackedTabViewItems
            checkVisibilityAccordingToTabCount()
            updateTabState()
        }
    }

    func updateTabState() {
        if let item = self.tabView?.selectedTabViewItem {
            if self.selectedTabView() == nil {
                self.tabItemViews().last?.tabViewItem = item
            }
        }
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

    func selectTabViewItem(_ tabViewItem: NSTabViewItem) {
        self.tabView?.selectTabViewItem(tabViewItem)
    }

    func selectedTabView() -> LYTabItemView? {
        if let selectedTabViewItem = self.tabView?.selectedTabViewItem {
            for tabView in self.tabItemViews() where tabView.tabViewItem == selectedTabViewItem {
                return tabView
            }
        }
        return nil
    }

    open override func viewWillMove(toWindow newWindow: NSWindow?) {
        NotificationCenter.default.addObserver(self, selector: #selector(windowStatusDidChange),
                                               name: NSWindow.didBecomeKeyNotification,
                                               object: newWindow)
        NotificationCenter.default.addObserver(self, selector: #selector(windowStatusDidChange),
                                               name: NSWindow.didResignKeyNotification,
                                               object: newWindow)
    }

    @objc private func windowStatusDidChange(_ notification: Notification) {
        self.needsDisplay = true
        self.tabContainerView.needsDisplay = true
        for itemViews in self.tabItemViews() {
            itemViews.updateColors()
        }
    }

    open override func draw(_ dirtyRect: NSRect) {
        let status = self.status
        self.borderColor[status]!.setFill()
        self.bounds.fill()
        self.backgroundColor[status]!.setFill()
        for button in [packedTabButton, addTabButton] {
            if let rect = button?.frame {
                rect.fill()
            }
        }

        if paddingWindowButton {
            let paddingRect = NSRect(x: 0, y: 0,
                                     width: self.windowButtonPaddingView.frame.size.width,
                                     height: self.frame.size.height)
            NSColor.clear.setFill()
            paddingRect.fill()
        }
    }

    @IBAction public func closeCurrentTab(_ sender: AnyObject?) {
        if let item = self.tabView?.selectedTabViewItem {
            removeTabViewItem(item, animated: true)
        }
    }

    @objc private func addNewTab(_ sender: AnyObject?) {
        if let action = self.addNewTabButtonAction {
            DispatchQueue.main.async {
                NSApplication.shared.sendAction(action, to: self.addNewTabButtonTarget, from: self)
            }
        }
    }

    @objc private func selectPackedItem(_ sender: AnyObject) {
        if let item = sender as? NSMenuItem, let tabItem = item.representedObject as? NSTabViewItem {
            self.tabView?.selectTabViewItem(tabItem)
            item.state = .on
        }
    }

    @objc private func showPackedList(_ sender: AnyObject?) {
        let menu = NSMenu()
        let selectedItem = self.tabView?.selectedTabViewItem
        var itemsInMenu = [lastUnpackedItem]
        itemsInMenu.append(contentsOf: self.packedTabViewItems)
        for item in itemsInMenu {
            let menuItem = NSMenuItem(title: item.label, action: nil, keyEquivalent: "")
            if item == selectedItem {
                menuItem.state = .on
            }
            menuItem.representedObject = item
            menuItem.target = self
            menuItem.action = #selector(selectPackedItem)
            menu.addItem(menuItem)
        }
        if let event = self.window?.currentEvent {
            NSMenu.popUpContextMenu(menu, with: event, for: self.packedTabButton)
        }
    }

    private func moveTo(_ dragTabItemView: LYTabItemView, position: NSInteger, movingItemView: LYTabItemView) {
        self.tabContainerView.removeView(dragTabItemView)
        self.tabContainerView.insertView(dragTabItemView, at: position, in: .center)
        if needAnimation {
            NSAnimationContext.runAnimationGroup({ (_) in
                let origFrame = movingItemView.frame
                self.tabContainerView.layoutSubtreeIfNeeded()
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

    func handleDraggingTab(_ dragRect: NSRect, dragTabItemView: LYTabItemView) {
        var idx = 0
        var moved = false
        for itemView in self.tabItemViews() {
            if itemView != dragTabItemView && !itemView.isMoving {
                let midx = itemView.frame.midX
                if midx > dragRect.minX {
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
                    let midx = itemView.frame.midX
                    if midx <= dragRect.maxX {
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

    func updateTabViewForMovedTabItem(_ tabItem: NSTabViewItem) {
        for (idx, itemView) in self.tabItemViews().enumerated() where itemView.tabViewItem == tabItem {
            self.tabView?.selectTabViewItem(at: 0)
            self.tabView?.removeTabViewItem(tabItem)
            self.tabView?.insertTabViewItem(tabItem, at: idx)
        }
        self.tabView?.selectTabViewItem(tabItem)
    }

    private func createLYTabItemView(_ item: NSTabViewItem) -> LYTabItemView {
        let tabItemView = LYTabItemView(tabViewItem: item)
        tabItemView.tabBarView = self
        tabItemView.showCloseButton = self.showCloseButton
        tabItemView.backgroundColor = self.backgroundColor
        tabItemView.hoverBackgroundColor = self.hoverItemBackgroundColor
        tabItemView.selectedTextColor = self.selectedTextColor
        tabItemView.selectedBackgroundColor = self.selectedBackgroundColor
        tabItemView.unselectedForegroundColor = self.unselectedForegroundColor
        tabItemView.closeButtonHoverBackgroundColor = self.closeButtonHoverBackgroundColor
            
        tabItemView.translatesAutoresizingMaskIntoConstraints = false
        tabItemView.setContentCompressionResistancePriority(NSLayoutConstraint.Priority.defaultLow, for: .horizontal)
        return tabItemView
    }

    private func itemViewForItem(_ item: NSTabViewItem) -> LYTabItemView? {
        for tabItemView in self.tabItemViews() where tabItemView.tabViewItem == item {
            return tabItemView
        }
        return nil
    }

    public func addTabViewItem(_ item: NSTabViewItem, animated: Bool = false) {
        self.tabView?.addTabViewItem(item)
        self.insertTabItem(item, index: self.tabItemViews().count + self.packedTabViewItems.count, animated: animated)
    }

    private func resetHeight() {
        if let aTabView = self.tabItemViews().first {
            let height = aTabView.intrinsicContentSize.height
            for constraint in buttonHeightConstraints {
                constraint.constant = height
            }
        }
    }

    private func needPackItem(addtion: Int = 0) -> Bool {
        let buttonsWidth: CGFloat = (showAddNewTabButton ? 2 : 1) * self.buttonHeight
        let width = (self.frame.size.width - buttonsWidth)/CGFloat(self.tabItemViews().count+addtion)
        return width < self.minTabItemWidth
    }

    private func packLastTab() {
        guard let lastTabView = self.tabItemViews().last else {
            return
        }
        self.insertToPackedItems(self.lastUnpackedItem, index: 0)
        self.tabContainerView.removeView(lastTabView)
        updateTabState()
    }

    private func popFirstPackedItem() {
        if let lastTabViewItem = self.tabItemViews().last?.tabViewItem,
            hasPackedTabViewItems {
            let lastUnpackedItem = self.lastUnpackedItem
            let item = packedTabViewItems[0]
            removePackedTabItem(at: 0)
            self.tabItemViews().last?.tabViewItem = lastUnpackedItem
            self.insertTabItem(item, index: self.tabItemViews().count)
            if self.packedTabViewItems.contains(lastTabViewItem) {
                self.tabItemViews().last?.tabViewItem = lastTabViewItem
            }
            updateTabState()
        }
    }

    private func insertToPackedItems(_ item: NSTabViewItem, index: NSInteger ) {
        self.packedTabViewItems.insert(item, at: index)
    }

    private func insertTabItem(_ item: NSTabViewItem, index: NSInteger, animated: Bool = false) {
        let needPack = needPackItem(addtion: 1)
        if needPack || (hasPackedTabViewItems && index > self.tabItemViews().count) {
            packedTabButton.isHidden = false
            if index >= self.tabItemViews().count {
                self.insertToPackedItems(item, index: index - self.tabItemViews().count)
                return
            }
            packLastTab()
        }
        let tabView = createLYTabItemView(item)
        tabContainerView.insertView(tabView,
                                    atIndex: index,
                                    inGravity: .center,
                                    animated: animated,
                                    completionHandler: nil)
        if tabItemViews().count == 1 {
            resetHeight()
        }
    }

    final private func adjustPackedItem() {
        if needPackItem() {
            if self.tabItemViews().count > 1 {
                packedTabButton.isHidden = false
                packLastTab()
            }
        } else if hasPackedTabViewItems && !needPackItem(addtion: 1) {
            popFirstPackedItem()
        }
    }

    @objc private func boundDidChangeNotification(notification: Notification) {
        guard self.tabItemViews().last != nil, !self.tabContainerView.isHidden && self.tabViewItems.count > 1 else {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.adjustPackedItem()
        }
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

extension LYTabBarView: NSTabViewDelegate {
    public func tabViewDidChangeNumberOfTabViewItems(_ tabView: NSTabView) {
        self.needsUpdate = true
        updateTabState()
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
