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

    @IBOutlet weak var tabBarView: LYTabBarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let item = NSTabViewItem()
        item.label = "Test"
        self.tabBarView.addTabViewItem(item)

        self.tabBarView.addNewTabButtonTarget = self
        self.tabBarView.addNewTabButtonAction = #selector(addNewTab)
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func toggleAddNewTabButton(sender:AnyObject?) {
        tabBarView.showAddNewTabButton = !tabBarView.showAddNewTabButton
    }
    
    @IBAction func addNewTab(sender:AnyObject?) {
        let item = NSTabViewItem()
        item.label = "Untitle"
        self.tabBarView.addTabViewItem(item, animated: true)
    }
    
    @IBAction func performCloseTab(sender:AnyObject?) {
        if tabBarView.tabViewItems.count > 1 {
            tabBarView.closeCurrentTab(sender)
        } else {
            self.view.window?.performClose(sender)
        }
    }
}

