//
//  LYTabBarCellView.swift
//  LYTabBarView
//
//  Created by Lu Yibin on 16/3/30.
//  Copyright © 2016年 Lu Yibin. All rights reserved.
//

import Foundation
import Cocoa

class LYTabItemView: NSButton {
    fileprivate let titleView = NSTextField(frame: .zero)
    fileprivate var closeButton: LYHoverButton!

    public var showCloseButton: Bool = true
    
    var tabBarView: LYTabBarView!
    var tabLabelObserver: NSKeyValueObservation?
    var tabViewItem: NSTabViewItem? {
        didSet {
            setupTitleAccordingToItem()
        }
    }
    var drawBorder = false {
        didSet {
            self.needsDisplay = true
        }
    }

    // hover effect
    private var hovered = false
    private var trackingArea: NSTrackingArea?

    // style
    var xpadding: CGFloat = 4
    var ypadding: CGFloat = 2
    var closeButtonSize = NSSize(width: 16, height: 16)
    var backgroundColor: ColorConfig = [
        .active: NSColor(white: 0.07, alpha: 1),
        .windowInactive: NSColor(white: 0.94, alpha: 1),
        .inactive: NSColor(white: 0.70, alpha: 1)
    ]

    var hoverBackgroundColor: ColorConfig = [
        .active: NSColor(white: 0.75, alpha: 1),
        .windowInactive: NSColor(white: 0.94, alpha: 1),
        .inactive: NSColor(white: 0.68, alpha: 1)
    ]

    @objc dynamic private var realBackgroundColor = NSColor(white: 0.73, alpha: 1) {
        didSet {
            needsDisplay = true
        }
    }
    var selectedBackgroundColor: ColorConfig = [
        .active: NSColor(white: 0.86, alpha: 1),
        .windowInactive: NSColor(white: 0.96, alpha: 1),
        .inactive: NSColor(white: 0.76, alpha: 1)
    ]

    var selectedTextColor: ColorConfig = [
        .active: NSColor.textColor,
        .windowInactive: NSColor(white: 0.4, alpha: 1),
        .inactive: NSColor(white: 0.4, alpha: 1)
    ]

    var unselectedForegroundColor = NSColor(white: 0.4, alpha: 1)
    var closeButtonHoverBackgroundColor = NSColor(white: 0.55, alpha: 0.3)

    override var title: String {
        get {
            return titleView.stringValue
        }
        set(newTitle) {
            titleView.stringValue = newTitle as String
            self.invalidateIntrinsicContentSize()
        }
    }

    var isMoving = false

    private var shouldDrawInHighLight: Bool {
        if let tabViewItem = self.tabViewItem {
            return tabViewItem.tabState == .selectedTab && !isDragging
        }
        return false
    }

    private var needAnimation: Bool {
        return self.tabBarView.needAnimation
    }

    override static func defaultAnimation(forKey key: NSAnimatablePropertyKey) -> Any? {
        if key.rawValue == "realBackgroundColor" {
            return CABasicAnimation()
        }
        return super.defaultAnimation(forKey: key) as AnyObject?
    }

    // Drag and Drop
    var dragOffset: CGFloat?
    var isDragging = false
    var draggingView: NSImageView?
    var draggingViewLeadingConstraint: NSLayoutConstraint?

    func setupViews() {
        self.isBordered = false
        let lowerPriority = NSLayoutConstraint.Priority(rawValue: NSLayoutConstraint.Priority.defaultLow.rawValue-10)
        self.setContentHuggingPriority(lowerPriority, for: .horizontal)

        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.isEditable = false
        titleView.alignment = .center
        titleView.isBordered = false
        titleView.drawsBackground = false
        self.addSubview(titleView)
        let padding = xpadding*2+closeButtonSize.width
        titleView.trailingAnchor
            .constraint(greaterThanOrEqualTo: self.trailingAnchor, constant: -padding).isActive = true
        titleView.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: padding).isActive = true
        titleView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        titleView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        titleView.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor, constant: ypadding).isActive = true
        titleView.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: -ypadding).isActive = true
        titleView.setContentHuggingPriority(lowerPriority, for: .horizontal)
        titleView.setContentCompressionResistancePriority(NSLayoutConstraint.Priority.defaultLow, for: .horizontal)
        titleView.lineBreakMode = .byTruncatingTail

        closeButton = LYTabCloseButton(frame: .zero)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.hoverBackgroundColor = closeButtonHoverBackgroundColor
        closeButton.target = self
        closeButton.action = #selector(closeTab)
        closeButton.heightAnchor.constraint(equalToConstant: closeButtonSize.height).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: closeButtonSize.width).isActive = true
        closeButton.isHidden = true
        self.addSubview(closeButton)
        closeButton.trailingAnchor
            .constraint(greaterThanOrEqualTo: self.titleView.leadingAnchor, constant: -xpadding).isActive = true
        closeButton.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor, constant: ypadding).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: xpadding).isActive = true
        closeButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        closeButton.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: -ypadding).isActive = true

        let menu = NSMenu()
        let addMenuItem = NSMenuItem(title: NSLocalizedString("New Tab", comment: "New Tab"),
                                     action: #selector(addNewTab), keyEquivalent: "")
        addMenuItem.target = self
        menu.addItem(addMenuItem)
        let closeMenuItem = NSMenuItem(title: NSLocalizedString("Close Tab", comment: "Close Tab"),
                                       action: #selector(closeTab), keyEquivalent: "")
        closeMenuItem.target = self
        menu.addItem(closeMenuItem)
        let closeOthersMenuItem = NSMenuItem(title: NSLocalizedString("Close other Tabs",
                                                                      comment: "Close other Tabs"),
                                             action: #selector(closeOtherTabs), keyEquivalent: "")
        closeOthersMenuItem.target = self
        menu.addItem(closeOthersMenuItem)

        let closeToRightMenuItem = NSMenuItem(title: "Close Tabs to the Right",
                                              action: #selector(closeToRight),
                                              keyEquivalent: "")
        closeToRightMenuItem.target = self
        menu.addItem(closeToRightMenuItem)

        menu.delegate = self
        self.menu = menu
    }

    func setupTitleAccordingToItem() {
        if let item = self.tabViewItem {
            tabLabelObserver = item.observe(\.label) { _, _ in
                if let item = self.tabViewItem {
                    self.title = item.label
                }
            }
            self.title = item.label
        }
    }

    override var intrinsicContentSize: NSSize {
        var size = titleView.intrinsicContentSize
        size.height += ypadding * 2
        if let minHeight = self.tabBarView.minTabHeight, size.height < minHeight {
            size.height = minHeight
        }
        size.width += xpadding * 3 + closeButtonSize.width
        return size
    }

    convenience init(tabViewItem: NSTabViewItem) {
        self.init(frame: .zero)
        self.tabViewItem = tabViewItem
        setupTitleAccordingToItem()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupViews()
    }

    override func draw(_ dirtyRect: NSRect) {
        let status = self.tabBarView.status
        if shouldDrawInHighLight {
            selectedBackgroundColor[status]!.setFill()
            titleView.textColor = selectedTextColor[status]!
        } else {
            self.realBackgroundColor.setFill()
            titleView.textColor = unselectedForegroundColor
        }
        self.bounds.fill()
        if self.drawBorder {
            let boderFrame = self.bounds.insetBy(dx: 1, dy: -1)
            self.tabBarView.borderColor[status]!.setStroke()
            let path = NSBezierPath(rect: boderFrame)
            path.stroke()
        }
    }

    override func mouseDown(with theEvent: NSEvent) {
        if let tabViewItem = self.tabViewItem {
            self.tabBarView.selectTabViewItem(tabViewItem)
        }
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()

        if let trackingArea = self.trackingArea {
            self.removeTrackingArea(trackingArea)
        }

        let options: NSTrackingArea.Options = [.mouseMoved, .mouseEnteredAndExited, .activeAlways, .inVisibleRect]
        self.trackingArea = NSTrackingArea(rect: self.bounds, options: options, owner: self, userInfo: nil)
        self.addTrackingArea(self.trackingArea!)
    }

    override func mouseEntered(with theEvent: NSEvent) {
        if hovered {
            return
        }
        hovered = true
        let status = self.tabBarView.status
        if !shouldDrawInHighLight {
            self.animatorOrNot(needAnimation).realBackgroundColor = hoverBackgroundColor[status]!
        }
        closeButton.animatorOrNot(needAnimation).isHidden = !showCloseButton
    }

    override func mouseExited(with theEvent: NSEvent) {
        if !hovered {
            return
        }
        hovered = false
        let status = self.tabBarView.status
        if !shouldDrawInHighLight {
            self.animatorOrNot(needAnimation).realBackgroundColor = backgroundColor[status]!
        }
        closeButton.animatorOrNot(needAnimation).isHidden = true
    }

    override func mouseDragged(with theEvent: NSEvent) {
        if !isDragging {
            setupDragAndDrop(theEvent)
        }
    }

    func updateColors() {
        let status = self.tabBarView.status
        if hovered {
            self.realBackgroundColor = hoverBackgroundColor[status]!
        } else {
            self.realBackgroundColor = backgroundColor[status]!
        }
    }

    override func viewDidMoveToWindow() {
        self.updateColors()
    }

    @IBAction func addNewTab(_ sender: AnyObject?) {
        if let target = self.tabBarView.addNewTabButtonTarget, let action = self.tabBarView.addNewTabButtonAction {
            _ = target.perform(action, with: self)
        }
    }

    @IBAction func closeTab(_ sender: AnyObject?) {
        if let tabViewItem = self.tabViewItem {
            self.tabBarView.removeTabViewItem(tabViewItem, animated: true)
        }
    }

    @IBAction func closeOtherTabs(_ send: AnyObject?) {
        if let tabViewItem = self.tabViewItem {
            self.tabBarView.removeAllTabViewItemExcept(tabViewItem)
        }
    }

    @IBAction func closeToRight(_ sender: Any) {
        if let tabViewItem = self.tabViewItem {
            self.tabBarView.removeFrom(tabViewItem)
        }
    }
}

extension LYTabItemView: NSPasteboardItemDataProvider {
    func pasteboard(_ pasteboard: NSPasteboard?,
                    item: NSPasteboardItem,
                    provideDataForType type: NSPasteboard.PasteboardType) {
    }
}

extension LYTabItemView: NSDraggingSource {
    func setupDragAndDrop(_ theEvent: NSEvent) {
        let pasteItem = NSPasteboardItem()
        let dragItem = NSDraggingItem(pasteboardWriter: pasteItem)
        var draggingRect = self.frame
        draggingRect.size.width = 1
        draggingRect.size.height = 1
        let dummyImage = NSImage(size: NSSize(width: 1, height: 1))
        dragItem.setDraggingFrame(draggingRect, contents: dummyImage)
        let draggingSession = self.beginDraggingSession(with: [dragItem], event: theEvent, source: self)
        draggingSession.animatesToStartingPositionsOnCancelOrFail = true
    }

    func draggingSession(_ session: NSDraggingSession,
                         sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        if context == .withinApplication {
            return .move
        }
        return NSDragOperation()
    }

    func ignoreModifierKeys(for session: NSDraggingSession) -> Bool {
        return true
    }

    func draggingSession(_ session: NSDraggingSession, willBeginAt screenPoint: NSPoint) {
        dragOffset = self.frame.origin.x - screenPoint.x
        closeButton.isHidden = true
        let dragRect = self.bounds
        let image = NSImage(data: self.dataWithPDF(inside: dragRect))
        self.draggingView = NSImageView(frame: dragRect)
        if let draggingView = self.draggingView {
            draggingView.image = image
            draggingView.translatesAutoresizingMaskIntoConstraints = false
            self.tabBarView.addSubview(draggingView)
            draggingView.topAnchor.constraint(equalTo: self.tabBarView.topAnchor).isActive = true
            draggingView.bottomAnchor.constraint(equalTo: self.tabBarView.bottomAnchor).isActive = true
            draggingView.widthAnchor.constraint(equalToConstant: self.frame.width)
            self.draggingViewLeadingConstraint = draggingView.leadingAnchor
                .constraint(equalTo: self.tabBarView.tabContainerView.leadingAnchor, constant: self.frame.origin.x)
            self.draggingViewLeadingConstraint?.isActive = true
        }
        isDragging = true
        self.titleView.isHidden = true
        self.needsDisplay = true
    }

    func draggingSession(_ session: NSDraggingSession, movedTo screenPoint: NSPoint) {
        if let constraint = self.draggingViewLeadingConstraint,
            let offset = self.dragOffset, let draggingView = self.draggingView {
            var constant = screenPoint.x + offset
            let min: CGFloat = 0
            if constant < min {
                constant = min
            }
            let max = self.tabBarView.tabContainerView.frame.size.width - self.frame.size.width
            if constant > max {
                constant = max
            }
            constraint.constant = constant

            self.tabBarView.handleDraggingTab(draggingView.frame, dragTabItemView: self)
        }
    }

    func draggingSession(_ session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
        dragOffset = nil
        isDragging = false
        closeButton.isHidden = !showCloseButton
        self.titleView.isHidden = false
        self.draggingView?.removeFromSuperview()
        self.draggingViewLeadingConstraint = nil
        self.needsDisplay = true
        if let tabViewItem = self.tabViewItem {
            self.tabBarView.updateTabViewForMovedTabItem(tabViewItem)
        }
    }
}

extension LYTabItemView: NSMenuDelegate {
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(addNewTab) {
            return (self.tabBarView.addNewTabButtonTarget != nil) && (self.tabBarView.addNewTabButtonAction != nil)
        }
        if menuItem.action == #selector(closeToRight) {
            if let tabItem = self.tabViewItem,
                let tabView = self.tabViewItem?.tabView {
                return tabItem != tabView.tabViewItems.last
            }
            return false
        }
        return true
    }
}
