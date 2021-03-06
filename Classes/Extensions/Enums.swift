//
//  Enums.swift
//  GZFlingViewDemo
//
//  Created by Grady Zhuo on 12/11/14.
//  Copyright (c) 2014 Grady Zhuo. All rights reserved.
//

import Foundation

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
