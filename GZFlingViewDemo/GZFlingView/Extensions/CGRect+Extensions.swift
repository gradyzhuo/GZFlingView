//
//  CGRect+Extensions.swift
//  Flingy
//
//  Created by Grady Zhuo on 2014/9/21.
//  Copyright (c) 2014年 Grady Zhuo. All rights reserved.
//

import UIKit

extension CGRect {
    
    var center : CGPoint {
        get{
            return CGPointMake(self.midX, self.midY)
        }
    }
    
    func rectByOffsetDelta(delta : CGPoint) -> CGRect {
        return self.offsetBy(dx: delta.x, dy: delta.y)
    }
    
}