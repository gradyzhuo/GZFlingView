//
//  GZPoint+Extensions.swift
//  Flingy
//
//  Created by Grady Zhuo on 2014/9/21.
//  Copyright (c) 2014年 Grady Zhuo. All rights reserved.
//

import UIKit

extension CGPoint{
    
    var distance:CGFloat{
        get{
            return sqrt( self.x * self.x + self.y * self.y )
        }
    }
    
    mutating func offset(dx:CGFloat, dy:CGFloat) -> Void {
        self.x += dx
        self.y += dy
    }
    
    func pointByOffsetting(dx: CGFloat, dy:CGFloat) -> CGPoint {
        var copyPoint = CGPoint(x: self.x, y: self.y)
        copyPoint.x += dx
        copyPoint.y += dy
        return copyPoint
    }
    
    func pointByOffsetting(dx: Int, dy:Int) -> CGPoint {
        return self.pointByOffsetting(CGFloat(dx), dy: CGFloat(dy))
    }
    
    func pointByOffsetting(dx: Int, dy:CGFloat) -> CGPoint {
        return self.pointByOffsetting(CGFloat(dx), dy: dy)
    }
    
    func pointByOffsetting(dx: CGFloat, dy:Int) -> CGPoint {
        return self.pointByOffsetting(dx, dy: CGFloat(dy))
    }
    
    
    func velocityByTimeInterval(timeInterval:NSTimeInterval) -> CGFloat {
        return (self.distance/CGFloat(timeInterval))
    }
    
    
    
}
