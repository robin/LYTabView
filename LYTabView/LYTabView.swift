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