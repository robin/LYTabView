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
    var tabViewItem : NSTabViewItem?
    
    var title : NSString {
        get {
            return titleView.stringValue
        }
        set(newTitle) {
            titleView.stringValue = newTitle as String
        }
    }
    
    func setupViews() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.editable = false

        stackView.orientation = .Horizontal
        self.addSubview(stackView)
        stackView.trailingAnchor.constraintEqualToAnchor(self.trailingAnchor).active = true
        stackView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        stackView.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor).active = true
        stackView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
        stackView.addView(titleView, inGravity: .Center)
    }
    
    override var intrinsicContentSize: NSSize {
        return titleView.intrinsicContentSize
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
}