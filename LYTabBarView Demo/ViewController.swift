//
//  ViewController.swift
//  LYTabBarView Demo
//
//  Created by Lu Yibin on 16/3/29.
//  Copyright © 2016年 Lu Yibin. All rights reserved.
//

import Cocoa
import LYTabView

class ViewController: NSViewController {

    @IBOutlet weak var tabView: LYTabView!
    @IBOutlet weak var tabView21: LYTabView!
    @IBOutlet weak var tabView22: LYTabView!
    @IBOutlet weak var tabView23: LYTabView!
    @IBOutlet weak var tabView24: LYTabView!
    @IBOutlet weak var tabView25: LYTabView!
   var tabBarView: LYTabBarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tabBarView = tabView.tabBarView
        addViewWithLabel("Tab", aTabBarView: self.tabBarView)
        addViewWithLabel("View", aTabBarView: self.tabBarView)
        
        tabView21.tabBarView.hideIfOnlyOneTabExists = false
        tabView22.tabBarView.hideIfOnlyOneTabExists = false
        tabView23.tabBarView.hideIfOnlyOneTabExists = false
        tabView24.tabBarView.hideIfOnlyOneTabExists = false
        tabView25.tabBarView.hideIfOnlyOneTabExists = false
        addViewWithLabel("Tab", aTabBarView: tabView21.tabBarView)
        addViewWithLabel("Tab", aTabBarView: tabView22.tabBarView)
        addViewWithLabel("Tab", aTabBarView: tabView23.tabBarView)
        addViewWithLabel("Tab", aTabBarView: tabView24.tabBarView)
        addViewWithLabel("Tab", aTabBarView: tabView25.tabBarView)

        [self.tabBarView, tabView21.tabBarView,
         tabView22.tabBarView, tabView23.tabBarView,
         tabView24.tabBarView, tabView25.tabBarView].forEach { (tabBarView) in
            tabBarView?.addNewTabButtonTarget = self
            tabBarView?.addNewTabButtonAction = #selector(addNewTab)
        }
    }
    
    override func viewWillAppear() {
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func addViewWithLabel(_ label:String, aTabBarView : LYTabBarView) {
        let item = NSTabViewItem()
        item.label = label
        if let labelViewController = self.storyboard?.instantiateController(withIdentifier: "labelViewController") {
            (labelViewController as AnyObject).setTitle(label)
            item.view = (labelViewController as AnyObject).view
        }
        aTabBarView.addTabViewItem(item, animated: true)
    }

    @IBAction func toggleAddNewTabButton(_ sender:AnyObject?) {
        tabBarView.showAddNewTabButton = !tabBarView.showAddNewTabButton
    }
    
    @IBAction func addNewTab(_ sender:AnyObject?) {
        let count = self.tabBarView.tabViewItems.count
        let label = "Untitled \(count)"
        if let tbView = sender as? LYTabBarView {
            addViewWithLabel(label, aTabBarView: tbView)
        }
    }
    
    @IBAction func performCloseTab(_ sender:AnyObject?) {
        if tabBarView.tabViewItems.count > 1 {
            tabBarView.closeCurrentTab(sender)
        } else {
            self.view.window?.performClose(sender)
        }
    }
    
    @IBAction func toggleTitleBar(_ sender: AnyObject?) {
        if let window = self.view.window {
            if window.titlebarAppearsTransparent {
                window.titlebarAppearsTransparent = false
                window.titleVisibility = .visible
                window.styleMask.remove(NSFullSizeContentViewWindowMask)
                tabBarView.paddingWindowButton = false
            }
            else
            {
                window.titlebarAppearsTransparent = true
                window.titleVisibility = .hidden
                _ = window.styleMask.update(with: NSFullSizeContentViewWindowMask)
                tabBarView.paddingWindowButton = true
            }
        }
    }
    
    @IBAction func toggleBorder(_ sender: AnyObject?) {
        switch tabBarView.borderStyle {
        case .none:
            tabBarView.borderStyle = .top
        case .top:
            tabBarView.borderStyle = .bottom
        case .bottom:
            tabBarView.borderStyle = .both
        case .both:
            tabBarView.borderStyle = .none
        }
    }
    
    @IBAction func toggleActivity(_ sender: AnyObject?) {
        tabBarView.isActive = !tabBarView.isActive
    }
}

