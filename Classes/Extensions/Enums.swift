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
    
    case Left = 0
    case Right = 1
    case Undefined = 2
    
    init(rawValue:Int){
        
        switch rawValue {
            
        case 0 :
            self = .Left
        case 1 :
            self = .Right
        default:
            self = .Undefined
            
        }
        
    }
    
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


public enum GZFlingViewAnimationType:Int {
    case None
    case Default
    case Tinder
    
    static var radomClosewise:CGFloat = -1
    
    static var lastTranslation:CGPoint = CGPointZero
    
    var animation:GZFlingViewAnimation {
        
        switch self {
            
        case .Tinder, .Default :
            return GZFlingViewAnimationTinder()
        case .None :
            return GZFlingViewAnimation()
            
        }
        
        
    }
    
    static func getNewRandomClosewise() -> CGFloat{
        var random = arc4random()%10
        
        switch random {
            
        case 0: fallthrough
        case 1:
            GZFlingViewAnimationType.radomClosewise = 1
            
        default:
            GZFlingViewAnimationType.radomClosewise = -1
            
        }
        
        return GZFlingViewAnimationType.radomClosewise
        
    }
    
    
}
