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
    func insertView(_ aView: NSView,atIndex index: Int, inGravity gravity: NSStackViewGravity, animated: Bool, completionHandler: (() -> Void)?) {
        self.insertView(aView, at: index, in: gravity)
        if animated {
            NSAnimationContext.runAnimationGroup({ (context) in
                    context.duration = 0.3
                    context.allowsImplicitAnimation = true
                    self.window?.layoutIfNeeded()
                }, completionHandler: completionHandler)
        }
    }
    
    func addView(_ aView: NSView,inGravity gravity: NSStackViewGravity, animated: Bool, completionHandler: (() -> Void)?) {
        self.addView(aView, in: gravity)
        if animated {
            aView.setFrameOrigin(NSPoint(x: NSMaxX(self.frame), y: self.frame.origin.y))
            NSAnimationContext.runAnimationGroup({ (context) in
                context.duration = 0.3
                context.allowsImplicitAnimation = true
                self.window?.layoutIfNeeded()
                }, completionHandler: completionHandler)
        }
    }
    
    func removeView(_ aView: NSView, animated: Bool, completionHandler: (() -> Void)?) {
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
