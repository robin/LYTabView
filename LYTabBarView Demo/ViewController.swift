//
//  ViewController.swift
//  LYTabBarView Demo
//
//  Created by Lu Yibin on 16/3/29.
//  Copyright © 2016年 Lu Yibin. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var tabView: NSTabView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let item = NSTabViewItem()
        item.label = "Test"
        self.tabView.addTabViewItem(item)
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

