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

    // hover effect
    private var hovered = false
    private var trackingArea : NSTrackingArea?

    // style
    var xpadding : CGFloat = 4
    var ypadding : CGFloat = 2
    var closeButtonSize = NSSize(width: 16, height: 16)
    private static let closeImage = NSImage(named: NSImageNameStopProgressTemplate)?.scaleToSize(CGSize(width:8, height:8))
    var backgroundColor = NSColor(white: 0.73, alpha: 1)
    var selectedBackgroundColor = NSColor(white: 0.83, alpha: 1)
    var unselectedForegroundColor = NSColor(calibratedRed: 0.4, green: 0.4, blue: 0.4, alpha: 1)
    var closeButtonHoverBackgroundColor = NSColor(white: 0.65, alpha: 0.6)
    
    var title : NSString {
        get {
            return titleView.stringValue
        }
        set(newTitle) {
            titleView.stringValue = newTitle as String
            self.invalidateIntrinsicContentSize()
        }
    }
    
    func setupViews() {
        self.setContentHuggingPriority(240, forOrientation: .Vertical)

        
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.editable = false
        titleView.alignment = .Center
        titleView.bordered = false
        titleView.drawsBackground = false
        self.addSubview(titleView)
        titleView.trailingAnchor.constraintGreaterThanOrEqualToAnchor(self.trailingAnchor, constant: xpadding).active = true
        titleView.leadingAnchor.constraintGreaterThanOrEqualToAnchor(self.leadingAnchor, constant: xpadding*2+closeButtonSize.width).active = true
        titleView.centerXAnchor.constraintEqualToAnchor(self.centerXAnchor).active = true
        titleView.topAnchor.constraintEqualToAnchor(self.topAnchor, constant: ypadding).active = true
        titleView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor, constant: -ypadding).active = true
        
        closeButton = LYHoverButton(frame: .zero)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.hoverBackgroundColor = closeButtonHoverBackgroundColor
        closeButton.setButtonType(.MomentaryPushInButton)
        closeButton.bezelStyle = .ShadowlessSquareBezelStyle
        closeButton.image = LYTabItemView.closeImage
        closeButton.bordered = false
        closeButton.imagePosition = .ImageOnly
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
        switch tabViewItem.tabState {
        case .SelectedTab:
            selectedBackgroundColor.setFill()
            titleView.textColor = NSColor.textColor()
        default:
            backgroundColor.setFill()
            titleView.textColor = unselectedForegroundColor
        }
        NSRectFill(self.bounds)
        super.drawRect(dirtyRect)
    }
    
    override func mouseDown(theEvent: NSEvent) {
        self.tabBarView.selectTabViewItem(self.tabViewItem)
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        
        if let trackingArea = self.trackingArea {
            self.removeTrackingArea(trackingArea)
        }
        
        let options : NSTrackingAreaOptions = [.EnabledDuringMouseDrag, .MouseEnteredAndExited, .ActiveAlways]
        self.trackingArea = NSTrackingArea(rect: self.bounds, options: options, owner: self, userInfo: nil)
        self.addTrackingArea(self.trackingArea!)
    }
    
    override func mouseEntered(theEvent: NSEvent) {
        if hovered {
            return
        }
        hovered = true
        closeButton.hidden = false
    }
    
    override func mouseExited(theEvent: NSEvent) {
        if !hovered {
            return
        }
        hovered = false
        closeButton.hidden = true
    }

    @IBAction func closeTab(sender:AnyObject?) {
        self.tabBarView.removeTabViewItem(self.tabViewItem)
    }
}