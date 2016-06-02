//
//  LYTabView.swift
//  LYTabView
//
//  Created by Lu Yibin on 16/4/13.
//  Copyright © 2016年 Lu Yibin. All rights reserved.
//

import Foundation
import Cocoa

public class LYTabView: NSView {
    public let tabBarView : LYTabBarView
    public let tabView : NSTabView
    let stackView : NSStackView
    
    public var delegate : NSTabViewDelegate? {
        get {
            return tabBarView.delegate
        }
        set(newDelegate) {
            tabBarView.delegate = newDelegate
        }
    }
    
    public var numberOfTabViewItems: Int { return self.tabView.numberOfTabViewItems }
    public var tabViewItems: [NSTabViewItem] { return self.tabView.tabViewItems }
    public var selectedTabViewItem: NSTabViewItem? { return self.tabView.selectedTabViewItem }
    
    func setupViews() {
        tabView.delegate = tabBarView
        tabView.tabViewType = .NoTabsNoBorder
        tabBarView.tabView = tabView
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)
        stackView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        stackView.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor).active = true
        stackView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
        stackView.trailingAnchor.constraintEqualToAnchor(self.trailingAnchor).active = true

        
        tabView.translatesAutoresizingMaskIntoConstraints = false
        tabBarView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addView(tabBarView, inGravity: .Center)
        stackView.addView(tabView, inGravity: .Center)
        stackView.orientation = .Vertical
        stackView.distribution = .Fill
        stackView.alignment = .CenterX
        stackView.spacing = 0
        stackView.leadingAnchor.constraintEqualToAnchor(tabBarView.leadingAnchor).active = true
        stackView.trailingAnchor.constraintEqualToAnchor(tabBarView.trailingAnchor).active = true
        
        tabView.setContentHuggingPriority(NSLayoutPriorityDefaultLow-10, forOrientation: .Vertical)
        tabBarView.setContentCompressionResistancePriority(NSLayoutPriorityDefaultHigh, forOrientation: .Vertical)
        tabBarView.setContentHuggingPriority(NSLayoutPriorityDefaultHigh, forOrientation: .Vertical)
    }
    
    required public init?(coder: NSCoder) {
        tabView = NSTabView(coder: coder)!
        tabBarView = LYTabBarView(coder: coder)!
        stackView = NSStackView(frame:.zero)
        super.init(coder: coder)
        setupViews()
    }
    
    required public override init(frame frameRect: NSRect) {
        tabView = NSTabView(frame: .zero)
        tabBarView = LYTabBarView(frame: .zero)
        stackView = NSStackView(frame: frameRect)
        super.init(frame: frameRect)
        setupViews()
    }
}

public extension LYTabView {
    public func addTabViewItem(tabViewItem: NSTabViewItem) {
        self.tabView.addTabViewItem(tabViewItem)
    }
    
    public func insertTabViewItem(tabViewItem: NSTabViewItem, atIndex index: Int) {
        self.tabView.insertTabViewItem(tabViewItem, atIndex: index)
    }
    
    public func removeTabViewItem(tabViewItem: NSTabViewItem) {
        self.tabView.removeTabViewItem(tabViewItem)
    }
    
    public func indexOfTabViewItem(tabViewItem: NSTabViewItem) -> Int {
        return self.tabView.indexOfTabViewItem(tabViewItem)
    }
    
    public func indexOfTabViewItemWithIdentifier(identifier: AnyObject) -> Int {
        return self.tabView.indexOfTabViewItemWithIdentifier(identifier)
    }
    
    public func tabViewItemAtIndex(index: Int) -> NSTabViewItem {
        return self.tabView.tabViewItemAtIndex(index)
    }
    
    public func selectFirstTabViewItem(sender: AnyObject?) {
        self.tabView.selectFirstTabViewItem(sender)
    }
    
    public func selectLastTabViewItem(sender: AnyObject?) {
        self.tabView.selectLastTabViewItem(sender)
    }
    
    public func selectNextTabViewItem(sender: AnyObject?) {
        self.tabView.selectNextTabViewItem(sender)
    }
    
    public func selectPreviousTabViewItem(sender: AnyObject?) {
        self.tabView.selectPreviousTabViewItem(sender)
    }
    
    public func selectTabViewItem(tabViewItem: NSTabViewItem?) {
        self.tabView.selectTabViewItem(tabViewItem)
    }
    
    public func selectTabViewItemAtIndex(index: Int) {
        self.tabView.selectTabViewItemAtIndex(index)
    }
    
    public func selectTabViewItemWithIdentifier(identifier: AnyObject) {
        self.tabView.selectTabViewItemWithIdentifier(identifier)
    }
    
    public func takeSelectedTabViewItemFromSender(sender: AnyObject?) {
        self.tabView.takeSelectedTabViewItemFromSender(sender)
    }
}