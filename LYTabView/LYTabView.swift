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
        tabView.tabViewType = .noTabsNoBorder
        tabBarView.tabView = tabView
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true

        
        tabView.translatesAutoresizingMaskIntoConstraints = false
        tabBarView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addView(tabBarView, in: .center)
        stackView.addView(tabView, in: .center)
        stackView.orientation = .vertical
        stackView.distribution = .fill
        stackView.alignment = .centerX
        stackView.spacing = 0
        stackView.leadingAnchor.constraint(equalTo: tabBarView.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: tabBarView.trailingAnchor).isActive = true
        
        stackView.leadingAnchor.constraint(equalTo:tabView.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo:tabView.trailingAnchor).isActive = true

        tabView.setContentHuggingPriority(NSLayoutPriorityDefaultLow-10, for: .vertical)
        tabBarView.setContentCompressionResistancePriority(NSLayoutPriorityDefaultHigh, for: .vertical)
        tabBarView.setContentHuggingPriority(NSLayoutPriorityDefaultHigh, for: .vertical)
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
    public func addTabViewItem(_ tabViewItem: NSTabViewItem) {
        self.tabView.addTabViewItem(tabViewItem)
    }
    
    public func insertTabViewItem(_ tabViewItem: NSTabViewItem, atIndex index: Int) {
        self.tabView.insertTabViewItem(tabViewItem, at: index)
    }
    
    public func removeTabViewItem(_ tabViewItem: NSTabViewItem) {
        self.tabView.removeTabViewItem(tabViewItem)
    }
    
    public func indexOfTabViewItem(_ tabViewItem: NSTabViewItem) -> Int {
        return self.tabView.indexOfTabViewItem(tabViewItem)
    }
    
    public func indexOfTabViewItemWithIdentifier(_ identifier: AnyObject) -> Int {
        return self.tabView.indexOfTabViewItem(withIdentifier: identifier)
    }
    
    public func tabViewItemAtIndex(_ index: Int) -> NSTabViewItem {
        return self.tabView.tabViewItem(at: index)
    }
    
    public func selectFirstTabViewItem(_ sender: AnyObject?) {
        self.tabView.selectFirstTabViewItem(sender)
    }
    
    public func selectLastTabViewItem(_ sender: AnyObject?) {
        self.tabView.selectLastTabViewItem(sender)
    }
    
    public func selectNextTabViewItem(_ sender: AnyObject?) {
        self.tabView.selectNextTabViewItem(sender)
    }
    
    public func selectPreviousTabViewItem(_ sender: AnyObject?) {
        self.tabView.selectPreviousTabViewItem(sender)
    }
    
    public func selectTabViewItem(_ tabViewItem: NSTabViewItem?) {
        self.tabView.selectTabViewItem(tabViewItem)
    }
    
    public func selectTabViewItemAtIndex(_ index: Int) {
        self.tabView.selectTabViewItem(at: index)
    }
    
    public func selectTabViewItemWithIdentifier(_ identifier: AnyObject) {
        self.tabView.selectTabViewItem(withIdentifier: identifier)
    }
    
    public func takeSelectedTabViewItemFromSender(_ sender: AnyObject?) {
        self.tabView.takeSelectedTabViewItemFromSender(sender)
    }
}
