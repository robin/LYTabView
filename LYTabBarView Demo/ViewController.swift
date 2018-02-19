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
        addViewWithLabel("Tab", aTabBarView: self.tabBarView, fromTabView: true)
        addViewWithLabel("View", aTabBarView: self.tabBarView, fromTabView: true)
        self.tabBarView.minTabHeight = 28
        self.tabBarView.minTabItemWidth = 120
        
        
        
        tabView21.tabBarView.hideIfOnlyOneTabExists = false
        tabView22.tabBarView.hideIfOnlyOneTabExists = false
        tabView23.tabBarView.hideIfOnlyOneTabExists = false
        tabView24.tabBarView.hideIfOnlyOneTabExists = false
        tabView25.tabBarView.hideIfOnlyOneTabExists = false
        addViewWithLabel("Tab with long title", aTabBarView: tabView21.tabBarView)
        addViewWithLabel("Tab with different height", aTabBarView: tabView22.tabBarView)
        addViewWithLabel("Tab", aTabBarView: tabView23.tabBarView)
        addViewWithLabel("Tab", aTabBarView: tabView24.tabBarView)
        addViewWithLabel("Tab", aTabBarView: tabView25.tabBarView)

        tabView22.tabBarView.minTabHeight = 28

        [self.tabBarView, tabView21.tabBarView,
         tabView22.tabBarView, tabView23.tabBarView,
         tabView24.tabBarView, tabView25.tabBarView].forEach { (tabBarView) in
            tabBarView?.addNewTabButtonAction = #selector(addNewTab)
        }
        self.tabBarView.addNewTabButtonTarget = self
        
        self.tabBarView.showCloseButton = false
        
        
    }

    override func viewWillAppear() {
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func addViewWithLabel(_ label: String, aTabBarView: LYTabBarView, fromTabView: Bool = false) {
        let item = NSTabViewItem()
        item.label = label
        if let labelViewController = self.storyboard?.instantiateController(withIdentifier:
            NSStoryboard.SceneIdentifier(rawValue: "labelViewController")) {
            (labelViewController as AnyObject).setTitle(label)
            item.view = (labelViewController as AnyObject).view
        }
        if fromTabView {
            tabView.tabView.addTabViewItem(item)
        } else {
            aTabBarView.addTabViewItem(item, animated: true)
        }
    }

    @IBAction func toggleAddNewTabButton(_ sender: AnyObject?) {
        tabBarView.showAddNewTabButton = !tabBarView.showAddNewTabButton
    }

    @IBAction func addNewTab(_ sender: AnyObject?) {
        if let tabBarView = (sender as? LYTabBarView) ?? self.tabBarView {
            let count = tabBarView.tabViewItems.count
            let label = "Untitled \(count)"
            addViewWithLabel(label, aTabBarView: tabBarView)
        }
    }

    @IBAction func performCloseTab(_ sender: AnyObject?) {
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
                window.styleMask.remove(.fullSizeContentView)
                tabBarView.paddingWindowButton = false
            } else {
                window.titlebarAppearsTransparent = true
                window.titleVisibility = .hidden
                _ = window.styleMask.update(with: .fullSizeContentView)
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
