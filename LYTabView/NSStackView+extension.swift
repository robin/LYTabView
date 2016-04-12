//
//  NSStackView+extension.swift
//  LYTabView
//
//  Created by Lu Yibin on 16/4/12.
//  Copyright © 2016年 Lu Yibin. All rights reserved.
//

import Foundation
import Cocoa

extension NSStackView {
    func insertView(aView: NSView,atIndex index: Int, inGravity gravity: NSStackViewGravity, animated: Bool, completionHandler: (() -> Void)?) {
        self.insertView(aView, atIndex: index, inGravity: gravity)
        if animated {
            NSAnimationContext.runAnimationGroup({ (context) in
                    context.duration = 0.3
                    context.allowsImplicitAnimation = true
                    self.window?.layoutIfNeeded()
                }, completionHandler: completionHandler)
        }
    }
    
    func addView(aView: NSView,inGravity gravity: NSStackViewGravity, animated: Bool, completionHandler: (() -> Void)?) {
        self.addView(aView, inGravity: gravity)
        if animated {
            NSAnimationContext.runAnimationGroup({ (context) in
                context.duration = 0.3
                context.allowsImplicitAnimation = true
                self.window?.layoutIfNeeded()
                }, completionHandler: completionHandler)
        }
    }
    
    func removeView(aView: NSView, animated: Bool, completionHandler: (() -> Void)?) {
        self.removeView(aView)
        if animated {
            NSAnimationContext.runAnimationGroup({ (context) in
                context.duration = 0.3
                context.allowsImplicitAnimation = true
                self.window?.layoutIfNeeded()
                }, completionHandler: completionHandler)            
        }
    }
}