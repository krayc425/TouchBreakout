//
//  CGVectorExtensions.swift
//  TouchBrickout
//
//  Created by 宋 奎熹 on 2017/11/21.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import SpriteKit

extension CGVector {
    
    var length: CGFloat {
        return sqrt(dx * dx + dy * dy)
    }
    
    mutating func extend(by ratio: CGFloat) {
        self.dx *= ratio
        self.dy *= ratio
    }
    
}
