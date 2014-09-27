//
//  GZFlingViewAnimation.swift
//  Flingy
//
//  Created by Grady Zhuo on 2014/9/25.
//  Copyright (c) 2014年 Grady Zhuo. All rights reserved.
//

import Foundation

public class GZFlingViewAnimation {
    
    var flingView:GZFlingView!
    
    init(){
        self.reset()
    }
    
    init(flingView:GZFlingView){
        self.flingView = flingView
        self.reset()
    }
    
    func dragGestureFrameAnimation(carryingView:GZFlingCarryingView, beginLocation:CGPoint, translation:CGPoint){}
    
    func showChoosenAnimation(#direction:GZFlingViewSwipingDirection, translation:CGPoint, completionHandler:((finished:Bool)->Void)){completionHandler(finished: true)}
    
    func showCancelAnimation(#direction:GZFlingViewSwipingDirection, beginLocation:CGPoint, translation:CGPoint,completionHandler:((finished:Bool)->Void)){completionHandler(finished: true)}
    
    
    func reset(){}
    func reset(currentCarryingView carryingView:GZFlingCarryingView, beginLocation:CGPoint){self.reset()}
}



public class GZFlingViewAnimationTinder:GZFlingViewAnimation{
    
    var radomClosewise:CGFloat = -1
    
    override func dragGestureFrameAnimation(carryingView:GZFlingCarryingView, beginLocation:CGPoint, translation:CGPoint){
        carryingView.layer.position = beginLocation.pointByOffsetting(translation.x, dy: translation.y)
        carryingView.transform = CGAffineTransformMakeRotation(self.radomClosewise*fabs(translation.x)/100*0.1)
    }
    
    
    override func showCancelAnimation(#direction:GZFlingViewSwipingDirection, beginLocation:CGPoint, translation:CGPoint, completionHandler:((finished:Bool)->Void)){
        
        var currentCarryingView = self.flingView.topCarryingView
        
        var time = NSTimeInterval(0.4)
        var velocity = translation.velocityByTimeInterval(time)/15
        
        UIView.animateWithDuration(time, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: UIViewAnimationOptions.AllowAnimatedContent | UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.BeginFromCurrentState | UIViewAnimationOptions.CurveEaseInOut , animations: {[weak self] () -> Void in
            
            currentCarryingView.layer.position = beginLocation
            currentCarryingView.transform = CGAffineTransformIdentity

            
            }, completion: {[weak self] (finished:Bool)->Void in
                
                completionHandler(finished: finished)
        })
    }
    
    override func showChoosenAnimation(#direction:GZFlingViewSwipingDirection, translation:CGPoint, completionHandler:((finished:Bool)->Void)){
        
        var currentCarryingView = self.flingView.topCarryingView
        var nextCarryingView = self.flingView.nextCarryingView(fromCarryingView: currentCarryingView)
        
//        self.flingView.tellDelegateWillShow(carryingView: currentCarryingView, atFlingIndex: nextCarryingView.flingIndex)
        
        var time = NSTimeInterval(0.4)
        var velocity = translation.velocityByTimeInterval(time)/15
        
        UIView.animateWithDuration(time, delay: 0, options: UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.AllowAnimatedContent | UIViewAnimationOptions.CurveEaseInOut | UIViewAnimationOptions.OverrideInheritedDuration , animations:{ ()-> Void in

            currentCarryingView.layer.position.offset(translation.x*2, dy: translation.y*2)
            currentCarryingView.transform = CGAffineTransformMakeRotation(self.radomClosewise * 0.25)
            currentCarryingView.alpha = 0
            
            }) {(finished:Bool)->Void in
                
                completionHandler(finished: finished)
                
        }
        
    }

    
    func getNewRandomClosewise() -> CGFloat{
        var random = arc4random()%10
        
        var radomClosewise = -1
        
        switch random {

        case 0,1,3:
            radomClosewise = 1
            
        default:
            radomClosewise = -1
        }
        
        return CGFloat(radomClosewise)
        
    }
    
    override func reset(){
        self.radomClosewise = self.getNewRandomClosewise()
    }
    
    override func reset(currentCarryingView carryingView:GZFlingCarryingView, beginLocation:CGPoint){
        self.reset()
        
        carryingView.layer.position = beginLocation
        carryingView.transform = CGAffineTransformIdentity
        
    }
    
}