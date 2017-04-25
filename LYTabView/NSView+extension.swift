//
//  NSView+extension.swift
//  LYTabView
//
//  Created by Lu Yibin on 16/4/11.
//  Copyright © 2016年 Lu Yibin. All rights reserved.
//

import Foundation
import Cocoa

extension NSAnimatablePropertyContainer {
    func animatorOrNot(_ needAnimator: Bool = true) -> Self {
        if needAnimator {
            return self.animator()
        }
        return self
    }
}
