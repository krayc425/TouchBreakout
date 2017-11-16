//
//  NSColorExtensions.swift
//  TouchBreakout
//
//  Created by 宋 奎熹 on 2017/11/16.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import Cocoa

extension NSColor {
    
    static func blockColors() -> [NSColor] {
        return [
            NSColor(red: 239.0/255.0, green: 112.0/255.0, blue: 99.0/255.0, alpha: 1.0),
            NSColor(red: 244.0/255.0, green: 173.0/255.0, blue: 95.0/255.0, alpha: 1.0),
            NSColor(red: 249.0/255.0, green: 214.0/255.0, blue: 107.0/255.0, alpha: 1.0),
            NSColor(red: 155.0/255.0, green: 222.0/255.0, blue: 118.0/255.0, alpha: 1.0),
            NSColor(red: 112.0/255.0, green: 188.0/255.0, blue: 244.0/255.0, alpha: 1.0),
            NSColor(red: 204.0/255.0, green: 148.0/255.0, blue: 226.0/255.0, alpha: 1.0),
            NSColor(red: 164.0/255.0, green: 164.0/255.0, blue: 167.0/255.0, alpha: 1.0),
            NSColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        ]
    }
    
    static var paddle: NSColor {
        return NSColor(red: 80.0/255.0, green: 170.0/255.0, blue: 214.0/255.0, alpha: 1.0)
    }
    
}
