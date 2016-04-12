//
//  LYTabBarCellView.swift
//  LYTabBarView
//
//  Created by Lu Yibin on 16/3/30.
//  Copyright © 2016年 Lu Yibin. All rights reserved.
//

import Foundation
import Cocoa

class LYTabItemView: NSView {
    private let titleView = NSTextField(frame: .zero)
    private var closeButton : LYHoverButton!

    var tabBarView : LYTabBarView!
    var tabViewItem : NSTabViewItem!
    var drawBorder = false {
        didSet {
            self.needsDisplay = true
        }
    }

    // hover effect
    private var hovered = false
    private var trackingArea : NSTrackingArea?

    // style
    var xpadding : CGFloat = 4
    var ypadding : CGFloat = 2
    var closeButtonSize = NSSize(width: 16, height: 16)
    var backgroundColor = NSColor(white: 0.73, alpha: 1)
    var hoverBackgroundColor = NSColor(white: 0.70, alpha: 1)
    dynamic private var realBackgroundColor = NSColor(white: 0.73, alpha: 1) {
        didSet {
            needsDisplay = true
        }
    }
    var selectedBackgroundColor = NSColor(white: 0.83, alpha: 1)
    var unselectedForegroundColor = NSColor(white: 0.4, alpha: 1)
    var closeButtonHoverBackgroundColor = NSColor(white: 0.55, alpha: 0.3)
    
    var title : NSString {
        get {
            return titleView.stringValue
        }
        set(newTitle) {
            titleView.stringValue = newTitle as String
            self.invalidateIntrinsicContentSize()
        }
    }
    
    var isMoving = false
    
    private var shouldDrawInHighLight : Bool {
        return tabViewItem.tabState == .SelectedTab && !isDragging
    }
    
    private var needAnimation : Bool {
        return self.tabBarView.needAnimation
    }
    
    override static func defaultAnimationForKey(key: String) -> AnyObject? {
        if key == "realBackgroundColor" {
            return CABasicAnimation()
        }
        return super.defaultAnimationForKey(key)
    }

    // Drag and Drop
    var dragOffset : CGFloat?
    var isDragging = false
    var draggingView : NSImageView?
    var draggingViewLeadingConstraint : NSLayoutConstraint?
    
    func setupViews() {
        self.setContentHuggingPriority(240, forOrientation: .Vertical)
        
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.editable = false
        titleView.alignment = .Center
        titleView.bordered = false
        titleView.drawsBackground = false
        self.addSubview(titleView)
        let padding = xpadding*2+closeButtonSize.width
        titleView.trailingAnchor.constraintGreaterThanOrEqualToAnchor(self.trailingAnchor, constant: -padding).active = true
        titleView.leadingAnchor.constraintGreaterThanOrEqualToAnchor(self.leadingAnchor, constant: padding).active = true
        titleView.centerXAnchor.constraintEqualToAnchor(self.centerXAnchor).active = true
        titleView.topAnchor.constraintEqualToAnchor(self.topAnchor, constant: ypadding).active = true
        titleView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor, constant: -ypadding).active = true
        
        closeButton = LYTabCloseButton(frame: .zero)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.hoverBackgroundColor = closeButtonHoverBackgroundColor
        closeButton.target = self
        closeButton.action = #selector(closeTab)
        closeButton.heightAnchor.constraintEqualToConstant(closeButtonSize.height).active = true
        closeButton.widthAnchor.constraintEqualToConstant(closeButtonSize.width).active = true
        closeButton.hidden = true
        self.addSubview(closeButton)
        closeButton.trailingAnchor.constraintGreaterThanOrEqualToAnchor(self.titleView.leadingAnchor, constant: -xpadding).active = true
        closeButton.topAnchor.constraintEqualToAnchor(self.topAnchor, constant: ypadding).active = true
        closeButton.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor, constant: xpadding).active = true
        closeButton.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor, constant: -ypadding).active = true
        
    }
    
    override var intrinsicContentSize: NSSize {
        var size = titleView.intrinsicContentSize
        size.height += ypadding * 2
        size.width += xpadding * 3 + closeButtonSize.width
        return size
    }
    
    convenience init(tabViewItem : NSTabViewItem) {
        self.init(frame: .zero)
        self.tabViewItem = tabViewItem
        if let tabViewItem = self.tabViewItem {
            self.title = tabViewItem.label
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupViews()
    }
    
    override func drawRect(dirtyRect: NSRect) {
        if shouldDrawInHighLight {
            selectedBackgroundColor.setFill()
            titleView.textColor = NSColor.textColor()
        } else {
            self.realBackgroundColor.setFill()
            titleView.textColor = unselectedForegroundColor
        }
        NSRectFill(self.bounds)
        if self.drawBorder {
            let boderFrame = NSInsetRect(self.bounds, 1, -1)
            self.tabBarView.borderColor.setStroke()
            let path = NSBezierPath(rect: boderFrame)
            path.stroke()
        }
        super.drawRect(dirtyRect)
    }
    
    override func mouseDown(theEvent: NSEvent) {
        self.tabBarView.selectTabViewItem(self.tabViewItem)
        
        // setup drag and drop
        setupDragAndDrop(theEvent)
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        
        if let trackingArea = self.trackingArea {
            self.removeTrackingArea(trackingArea)
        }
        
        let options : NSTrackingAreaOptions = [.MouseMoved, .MouseEnteredAndExited, .ActiveAlways, .InVisibleRect]
        self.trackingArea = NSTrackingArea(rect: self.bounds, options: options, owner: self, userInfo: nil)
        self.addTrackingArea(self.trackingArea!)
    }
    
    override func mouseEntered(theEvent: NSEvent) {
        if hovered {
            return
        }
        hovered = true
        if !shouldDrawInHighLight {
            self.animatorOrNot(needAnimation).realBackgroundColor = hoverBackgroundColor
        }
        closeButton.animatorOrNot(needAnimation).hidden = false
    }
    
    override func mouseExited(theEvent: NSEvent) {
        if !hovered {
            return
        }
        hovered = false
        if !shouldDrawInHighLight {
            self.animatorOrNot(needAnimation).realBackgroundColor = backgroundColor
        }
        closeButton.animatorOrNot(needAnimation).hidden = true
    }

    @IBAction func closeTab(sender:AnyObject?) {
        self.tabBarView.removeTabViewItem(self.tabViewItem)
    }
}

extension LYTabItemView : NSPasteboardItemDataProvider {
    func pasteboard(pasteboard: NSPasteboard?, item: NSPasteboardItem, provideDataForType type: String) {
    }
}

extension LYTabItemView : NSDraggingSource {
    func setupDragAndDrop(theEvent: NSEvent) {
        let pasteItem = NSPasteboardItem()
        let dragItem = NSDraggingItem(pasteboardWriter: pasteItem)
        var draggingRect = self.frame
        draggingRect.size.width = 1
        draggingRect.size.height = 1
        let dummyImage = NSImage(size: NSSize(width: 1, height: 1))
        dragItem.setDraggingFrame(draggingRect, contents: dummyImage)
        let draggingSession = self.beginDraggingSessionWithItems([dragItem], event: theEvent, source: self)
        draggingSession.animatesToStartingPositionsOnCancelOrFail = true
    }
    
    func draggingSession(session: NSDraggingSession, sourceOperationMaskForDraggingContext context: NSDraggingContext) -> NSDragOperation {
        if context == .WithinApplication {
            return .Move
        }
        return .None
    }
    
     func ignoreModifierKeysForDraggingSession(session: NSDraggingSession) -> Bool {
        return true
    }
    
    func draggingSession(session: NSDraggingSession, willBeginAtPoint screenPoint: NSPoint) {
        dragOffset = self.frame.origin.x - screenPoint.x
        closeButton.hidden = true
        let dragRect = NSInsetRect(self.frame, -1, -1)
        let image = NSImage(data: self.tabBarView.dataWithPDFInsideRect(dragRect))
        self.draggingView = NSImageView(frame: dragRect)
        if let draggingView = self.draggingView {
            draggingView.image = image
            draggingView.translatesAutoresizingMaskIntoConstraints = false
            self.tabBarView.addSubview(draggingView)
            draggingView.topAnchor.constraintEqualToAnchor(self.tabBarView.topAnchor).active = true
            draggingView.bottomAnchor.constraintEqualToAnchor(self.tabBarView.bottomAnchor).active = true
            draggingView.widthAnchor.constraintEqualToConstant(self.frame.width)
            self.draggingViewLeadingConstraint = draggingView.leadingAnchor.constraintEqualToAnchor(self.tabBarView.leadingAnchor, constant: self.frame.origin.x)
            self.draggingViewLeadingConstraint?.active = true
        }
        isDragging = true
        self.titleView.hidden = true
        self.needsDisplay = true
    }
    
    func draggingSession(session: NSDraggingSession, movedToPoint screenPoint: NSPoint) {
        if let constraint = self.draggingViewLeadingConstraint, let offset = self.dragOffset, let draggingView = self.draggingView {
            var constant = screenPoint.x + offset
            if constant < 0 {
                constant = 0
            }
            let max = self.tabBarView.frame.size.width - self.frame.size.width
            if constant > max {
                constant = max
            }
            constraint.constant = constant
            
            self.tabBarView.handleDraggingTab(draggingView.frame, dragTabItemView: self)
        }
    }
    
    func draggingSession(session: NSDraggingSession, endedAtPoint screenPoint: NSPoint, operation: NSDragOperation) {
        dragOffset = nil
        isDragging = false
        closeButton.hidden = false
        self.titleView.hidden = false
        self.draggingView?.removeFromSuperview()
        self.draggingViewLeadingConstraint = nil
        self.needsDisplay = true
        self.tabBarView.updateTabViewForMovedTabItem(self.tabViewItem)
    }
}
