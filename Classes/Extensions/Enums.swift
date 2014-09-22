//
//  Enums.swift
//  Flingy
//
//  Created by Grady Zhuo on 2014/9/21.
//  Copyright (c) 2014年 Grady Zhuo. All rights reserved.
//

import UIKit

public typealias GZFlingViewSwipingDirection = GZFlingView.SwipingDirection
public typealias GZFlingViewAnimationType = GZFlingView.AnimationType

public extension GZFlingView {
    
    public enum SwipingDirection:Int{
        
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
    
    
    public enum AnimationType:Int {
        case None
        case Tinder
        
        
        static var radomClosewise:CGFloat = -1
        
        var choosingClosure:(carryingView:GZFlingCarryingView, beginLocation:CGPoint, translation:CGPoint)->Void{
            get{
                switch self {
                case .None:
                    return { (carryingView:GZFlingCarryingView, beginLocation:CGPoint, translation:CGPoint)->Void in return }
                case .Tinder:
                    
                    return {(carryingView:GZFlingCarryingView, beginLocation:CGPoint, translation:CGPoint)->Void in
                        
                        carryingView.center = beginLocation.pointByOffsetting(translation.x, dy: translation.y)
                        carryingView.transform = CGAffineTransformMakeRotation(GZFlingViewAnimationType.radomClosewise*fabs(translation.x)/100*0.1)
                        
                    }
                }
            }
        }
        
        var cancelAnimation:(carryingView:GZFlingCarryingView, beginLocation:CGPoint) -> Void {
            get{
                switch self {
                case .None:
                    return { (carryingView:GZFlingCarryingView, beginLocation:CGPoint)->Void in return }
                case .Tinder:
                    return { (carryingView:GZFlingCarryingView, beginLocation:CGPoint)->Void in
                        carryingView.center = beginLocation
                        carryingView.transform = CGAffineTransformIdentity
                    }
                }
            }
        }
        
        var completionAnimation:(carryingView:GZFlingCarryingView, direction:GZFlingViewSwipingDirection, translation:CGPoint) -> Void {
            get{
                
                switch self {
                case .None:
                    return { (carryingView:GZFlingCarryingView, direction:GZFlingViewSwipingDirection, translation:CGPoint)->Void in return }
                case .Tinder:
                    
                    return {(carryingView:GZFlingCarryingView, direction:GZFlingViewSwipingDirection,translation:CGPoint)->Void in
                        
                        carryingView.center.offset(translation.x, dy: translation.y)
                        carryingView.transform = CGAffineTransformMakeRotation(GZFlingViewAnimationType.radomClosewise * 0.25)
                        carryingView.alpha = 0
                        
                    }
                }
                
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
    
    
}