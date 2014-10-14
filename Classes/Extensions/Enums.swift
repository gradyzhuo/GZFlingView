//
//  Enums.swift
//  Flingy
//
//  Created by Grady Zhuo on 2014/9/21.
//  Copyright (c) 2014年 Grady Zhuo. All rights reserved.
//

import UIKit

//public typealias GZFlingViewSwipingDirection = GZFlingView.SwipingDirection
//public typealias GZFlingViewAnimationType = GZFlingView.AnimationType

public enum GZFlingViewSwipingDirection:Int{
    
    case Left = -1
    case Right = 1
    case Undefined = 2
    
    public var description:String{
        get{
            
            switch self {
            case .Left: return "Left"
            case .Right: return "Right"
            case .Undefined: return "Undefined"
            }
            
        }
    }
    
}
