//
//  LYTabBarCellView.swift
//  LYTabBarView
//
//  Created by Lu Yibin on 16/3/30.
//  Copyright © 2016年 Lu Yibin. All rights reserved.
//

import Foundation
import Cocoa

class LYTabView: NSView {
    private let stackView = NSStackView(frame: .zero)
    private let titleView = NSTextField(frame: .zero)

    var tabBarView : LYTabBarView!
    var tabViewItem : NSTabViewItem!
    var closeButton : LYHoverButton?
        
    // style
    var padding : CGFloat = 2
    var closeButtonSize = NSSize(width: 16, height: 16)
    private static let closeImage = NSImage(named: NSImageNameStopProgressTemplate)?.scaleToSize(CGSize(width:8, height:8))
    var backgroundColor = NSColor.clearColor()
    var selectedBackgroundColor = NSColor(calibratedRed: 0.85, green: 0.85, blue: 0.85, alpha: 1)
    var unselectedForegroundColor = NSColor(calibratedRed: 0.4, green: 0.4, blue: 0.4, alpha: 1)
    
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

        stackView.setContentHuggingPriority(240, forOrientation: .Vertical)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.orientation = .Horizontal
        stackView.distribution = .Fill
        stackView.spacing = 0
        self.addSubview(stackView)
        stackView.trailingAnchor.constraintEqualToAnchor(self.trailingAnchor, constant: padding).active = true
        stackView.topAnchor.constraintEqualToAnchor(self.topAnchor, constant: padding).active = true
        stackView.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor, constant: padding).active = true
        stackView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor, constant: -padding).active = true
        
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.editable = false
        titleView.alignment = .Center
        titleView.bordered = false
        titleView.drawsBackground = false
        stackView.addView(titleView, inGravity: .Center)
        
        closeButton = LYHoverButton(frame: .zero)
        if let closeButton = self.closeButton {
            closeButton.hoverBackgroundColor = NSColor.lightGrayColor()
            closeButton.setButtonType(.MomentaryPushInButton)
            closeButton.bezelStyle = .ShadowlessSquareBezelStyle
            closeButton.image = LYTabView.closeImage
            closeButton.bordered = false
            closeButton.imagePosition = .ImageOnly
            closeButton.target = self
            closeButton.action = #selector(closeTab)
            closeButton.heightAnchor.constraintEqualToConstant(closeButtonSize.height).active = true
            closeButton.widthAnchor.constraintEqualToConstant(closeButtonSize.width).active = true
            stackView.addView(closeButton, inGravity: .Top)
        }
    }
    
    override var intrinsicContentSize: NSSize {
        var size = titleView.intrinsicContentSize
        size.height += padding * 2
        size.width += padding * 2 + closeButtonSize.width
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
    
    @IBAction func closeTab(sender:AnyObject?) {
        self.tabBarView.removeTabViewItem(self.tabViewItem)
    }
}