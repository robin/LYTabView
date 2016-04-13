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
    
    public var delegate : NSTabViewDelegate? {
        get {
            return tabBarView.delegate
        }
        set(newDelegate) {
            tabBarView.delegate = newDelegate
        }
    }
    
    func setupViews() {
        tabView.delegate = tabBarView
        tabView.tabViewType = .NoTabsNoBorder
        tabBarView.tabView = tabView
        
        tabView.translatesAutoresizingMaskIntoConstraints = false
        tabBarView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(tabBarView)
        self.addSubview(tabView)
        
        tabView.setContentHuggingPriority(NSLayoutPriorityDefaultLow, forOrientation: .Vertical)
        
        tabBarView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        tabBarView.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor).active = true
        tabBarView.bottomAnchor.constraintEqualToAnchor(tabView.topAnchor).active = true
        tabBarView.trailingAnchor.constraintEqualToAnchor(self.trailingAnchor).active = true
        
        tabView.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor).active = true
        tabView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
        tabView.trailingAnchor.constraintEqualToAnchor(self.trailingAnchor).active = true
    }
    
    required public init?(coder: NSCoder) {
        tabView = NSTabView(coder: coder)!
        tabBarView = LYTabBarView(coder: coder)!
        super.init(coder: coder)
        setupViews()
    }
    
    required public override init(frame frameRect: NSRect) {
        tabView = NSTabView(frame: frameRect)
        tabBarView = LYTabBarView(frame: frameRect)
        super.init(frame: frameRect)
        setupViews()
    }
}