//
//  GZFlingViewAnimation.swift
//  Flingy
//
//  Created by Grady Zhuo on 2014/9/25.
//  Copyright (c) 2014年 Grady Zhuo. All rights reserved.
//

import Foundation

let kGZFlingViewAnimationDuration:NSTimeInterval = 0.3

public class GZFlingViewAnimation {
    
    var flingView:GZFlingView!
    var beginLocation:CGPoint = CGPoint()
    
    init(){
        self.reset()
    }
    
    init(flingView:GZFlingView){
        self.flingView = flingView
        self.reset()
    }
    
    func prepare(#carryingView:GZFlingCarryingView, reuseIndex:Int){}
    
    func shouldCancel(#direction:GZFlingViewSwipingDirection, translation:CGPoint)->Bool{return true}
    
    func gesturePanning(#carryingView:GZFlingCarryingView, translation:CGPoint){}
    
    func showChoosenAnimation(#direction:GZFlingViewSwipingDirection, translation:CGPoint, completionHandler:((finished:Bool)->Void)){completionHandler(finished: true)}
    
    func showCancelAnimation(#direction:GZFlingViewSwipingDirection, translation:CGPoint,completionHandler:((finished:Bool)->Void)){completionHandler(finished: true)}
    
    
    func reset(){}
    func reset(currentCarryingView carryingView:GZFlingCarryingView){self.reset()}
}



public class GZFlingViewAnimationTinder:GZFlingViewAnimation{
    
    var radomClosewise:CGFloat = -1
    
    override func prepare(#carryingView: GZFlingCarryingView, reuseIndex: Int) {
        carryingView.layer.position = self.beginLocation
        carryingView.alpha = 0
    }
    
    override func gesturePanning(#carryingView:GZFlingCarryingView, translation:CGPoint){
        carryingView.layer.position = self.beginLocation.pointByOffsetting(translation.x, dy: translation.y)
        carryingView.transform = CGAffineTransformMakeRotation(self.radomClosewise*fabs(translation.x)/100*0.1)
    }
    
    
    override func showCancelAnimation(#direction:GZFlingViewSwipingDirection, translation:CGPoint, completionHandler:((finished:Bool)->Void)){
        
        var currentCarryingView = self.flingView.topCarryingView
        
        var time = kGZFlingViewAnimationDuration
        var velocity = translation.velocityByTimeInterval(kGZFlingViewAnimationDuration)/15
        
        UIView.animateWithDuration(time, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 15, options: UIViewAnimationOptions.AllowAnimatedContent | UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.BeginFromCurrentState | UIViewAnimationOptions.CurveEaseInOut , animations: {[weak self] () -> Void in
            
            currentCarryingView.layer.position = self!.beginLocation
            currentCarryingView.transform = CGAffineTransformIdentity

            
            }, completion: {[weak self] (finished:Bool)->Void in
                
                completionHandler(finished: finished)
                
        })
    }
    
    override func showChoosenAnimation(#direction:GZFlingViewSwipingDirection, translation:CGPoint, completionHandler:((finished:Bool)->Void)){

        var currentCarryingView = self.flingView.topCarryingView
        var nextCarryingView = self.flingView.nextCarryingView(fromCarryingView: currentCarryingView)

        var time = NSTimeInterval(0.4)
        var velocity = translation.velocityByTimeInterval(kGZFlingViewAnimationDuration)/15
        
        UIView.animateWithDuration(kGZFlingViewAnimationDuration, delay: 0, options: UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.AllowAnimatedContent | UIViewAnimationOptions.CurveEaseInOut | UIViewAnimationOptions.OverrideInheritedDuration , animations:{ ()-> Void in

            currentCarryingView.layer.position.offset(translation.x*2, dy: translation.y*2)
            currentCarryingView.transform = CGAffineTransformMakeRotation(self.radomClosewise * 0.25)
            currentCarryingView.alpha = 0
            
            }) {(finished:Bool)->Void in
                
                println("showChoosenAnimation finished: \(finished)")
                
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
    
    override func reset(currentCarryingView carryingView:GZFlingCarryingView){
        self.reset()
        
        carryingView.layer.position = self.beginLocation
        carryingView.transform = CGAffineTransformIdentity
        
    }
    
    override func shouldCancel(#direction: GZFlingViewSwipingDirection, translation: CGPoint) -> Bool {
        
        return !(fabs(translation.x) > self.flingView.frame.width/6*2)
    }
    
}