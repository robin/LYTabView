//
//  HoverButton.swift
//  LYTabBarView
//
//  Created by Lu Yibin on 16/3/31.
//  Copyright © 2016年 Lu Yibin. All rights reserved.
//

import Foundation
import Cocoa

class LYHoverButton: NSButton {
    var hoverBackgroundColor : NSColor?
    private var backgroundColor : CGColor?
    
    private var hovered = false
    private var trackingArea : NSTrackingArea?
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        
        if let trackingArea = self.trackingArea {
            self.removeTrackingArea(trackingArea)
        }

        let options : NSTrackingAreaOptions = [.EnabledDuringMouseDrag, .MouseEnteredAndExited, .ActiveInActiveApp]
        self.trackingArea = NSTrackingArea(rect: self.bounds, options: options, owner: self, userInfo: nil)
        self.addTrackingArea(self.trackingArea!)
    }
    
    override func mouseEntered(theEvent: NSEvent) {
        if hovered {
            return
        }
        hovered = true
        if self.backgroundColor == nil {
            self.backgroundColor = self.layer?.backgroundColor ?? NSColor.clearColor().CGColor
        }
        if let layer = self.layer {
            if let color = self.hoverBackgroundColor {
                layer.backgroundColor = color.CGColor
            }
        }
    }
    
    override func mouseExited(theEvent: NSEvent) {
        if !hovered {
            return
        }
        hovered = false
        if let layer = self.layer {
            if let color = self.backgroundColor {
                layer.backgroundColor = color
            }
        }
    }
}