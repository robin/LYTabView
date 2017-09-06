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
    var hoverBackgroundColor: NSColor?
    var backgroundColor = NSColor.clear

    var hovered = false
    private var trackingArea: NSTrackingArea?

    override func updateTrackingAreas() {
        super.updateTrackingAreas()

        if let trackingArea = self.trackingArea {
            self.removeTrackingArea(trackingArea)
        }

        let options: NSTrackingArea.Options = [.enabledDuringMouseDrag, .mouseEnteredAndExited, .activeAlways]
        self.trackingArea = NSTrackingArea(rect: self.bounds, options: options, owner: self, userInfo: nil)
        self.addTrackingArea(self.trackingArea!)
    }

    override func mouseEntered(with theEvent: NSEvent) {
        if hovered {
            return
        }
        hovered = true
        needsDisplay = true
    }

    override func mouseExited(with theEvent: NSEvent) {
        if !hovered {
            return
        }
        hovered = false
        needsDisplay = true
    }
}
