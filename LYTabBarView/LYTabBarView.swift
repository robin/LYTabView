//
//  LYTabBarView.swift
//  LYTabBarView
//
//  Created by Lu Yibin on 16/3/29.
//  Copyright © 2016年 Lu Yibin. All rights reserved.
//

import Foundation
import Cocoa

public class LYTabBarView: NSView {
    private let serialQueue = dispatch_queue_create("Operations.TabBarView.UpdaterQueue", DISPATCH_QUEUE_SERIAL)
    private var _needsUpdate = false
    @IBOutlet var tabView : NSTabView? {
        didSet {
            self.needsUpdate = true
        }
    }

    let stackView : NSStackView
    
    override public var intrinsicContentSize: NSSize {
        return NSMakeSize(NSViewNoIntrinsicMetric, 22)
    }
    
    required public init?(coder: NSCoder) {
        stackView = NSStackView(frame: .zero)
        super.init(coder: coder)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)
        stackView.trailingAnchor.constraintEqualToAnchor(self.trailingAnchor).active = true
        stackView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        stackView.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor).active = true
        stackView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
        stackView.orientation = .Horizontal
    }
    
    func insertTabViewItem(item: NSTabViewItem, index: NSInteger) {
        let tabView = LYTabView(tabViewItem: item)
        tabView.translatesAutoresizingMaskIntoConstraints = false
        stackView.insertView(tabView, atIndex: index, inGravity: .Center)
    }
    
    var needsUpdate : Bool {
        get {
            return _needsUpdate
        }
        set(newState) {
            if !newState {
                _needsUpdate = newState
                return
            }
            dispatch_sync(serialQueue) {
                if !self.needsUpdate {
                    self._needsUpdate = true
                    NSOperationQueue.mainQueue().addOperationWithBlock({ 
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
            let tabItems = tabView.tabViewItems
            let tabViews = self.stackView.viewsInGravity(.Center).flatMap { $0 as? LYTabView }
            for tabView in tabViews {
                if let tabItem = tabView.tabViewItem {
                    if tabItems.indexOf(tabItem) == nil {
                        self.stackView.removeView(tabView)
                    }
                }
            }
            
            var idx = 0
            let currentTabItems = self.stackView.viewsInGravity(.Center).flatMap { ($0 as? LYTabView)?.tabViewItem }
            for item in tabItems {
                if !currentTabItems.contains(item) {
                    self.insertTabViewItem(item, index: idx)
                }
                idx += 1
            }
        }
    }
}

extension LYTabBarView : NSTabViewDelegate {
    public func tabViewDidChangeNumberOfTabViewItems(tabView: NSTabView) {
        self.needsUpdate = true
    }
}