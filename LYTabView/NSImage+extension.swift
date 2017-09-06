//
//  NSImage+extension.swift
//  LYTabBarView
//
//  Created by Lu Yibin on 16/3/31.
//  Copyright © 2016年 Lu Yibin. All rights reserved.
//

import Foundation
import Cocoa

extension NSImage {
    public func scaleToSize(_ size: CGSize) -> NSImage {
        let scaledImage = NSImage(size: size)
        let rect = NSRect(origin: CGPoint(x: 0, y: 0), size: size)
        scaledImage.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .high
        self.draw(in: rect, from: NSRect.zero, operation: .sourceOver, fraction: 1.0)
        scaledImage.unlockFocus()
        return scaledImage
    }
}
