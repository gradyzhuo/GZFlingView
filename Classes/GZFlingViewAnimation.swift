//
//  GZFlingViewAnimation.swift
//  Flingy
//
//  Created by Grady Zhuo on 2014/9/25.
//  Copyright (c) 2014年 Grady Zhuo. All rights reserved.
//

import Foundation


enum GZFlingViewAnimationState:Int{
    case Init = 0
}


let kGZFlingViewAnimationDuration:NSTimeInterval = 0.2

public class GZFlingViewAnimation {
    
    var flingView:GZFlingView!
    var beginLocation:CGPoint = CGPoint()
    
    init(){
        
    }
    
    
    func gesturePanning(#gesture:UIPanGestureRecognizer, translation:CGPoint){}
    func willBeginGesture(#gesture:UIPanGestureRecognizer){}
    func didEndGesture(#gesture:UIPanGestureRecognizer){}
    
    
    func prepare(#carryingView:GZFlingCarryingView, reuseIndex:Int){
        //pass
    }
    
    func willAppear(#carryingView:GZFlingCarryingView){
        //pass
    }
    
    func didAppear(#carryingView:GZFlingCarryingView){
        //pass
    }

    
    func shouldCancel(#direction:GZFlingViewSwipingDirection, translation:CGPoint)->Bool{return true}
    func showChoosenAnimation(#direction:GZFlingViewSwipingDirection, translation:CGPoint, completionHandler:((finished:Bool)->Void)){completionHandler(finished: true)}
    
    func showCancelAnimation(#direction:GZFlingViewSwipingDirection, translation:CGPoint,completionHandler:((finished:Bool)->Void)){completionHandler(finished: true)}
    
}



public class GZFlingViewAnimationTinder:GZFlingViewAnimation{
    
    var radomClosewise:CGFloat = -1
    
    var initalScaleValue : CGFloat = 0.90
    
    lazy var initalTranslationY : CGFloat = {
        var scale = 1-self.initalScaleValue
        return (self.flingView.bounds.height * scale )
    }()
    
    var privateInstance = PrivateInstance()
    
    lazy var initialTransforms : CGAffineTransform = {
        
        var transforms = CGAffineTransformMakeTranslation(0, self.initalTranslationY)
        
        return CGAffineTransformScale(transforms, self.initalScaleValue, self.initalScaleValue)
        
    }()
    
    lazy var maxWidthForFling:CGFloat = {
        return (UIScreen.mainScreen().bounds.width / 2) * (2/3)
    }()
    
    override func prepare(#carryingView: GZFlingCarryingView, reuseIndex: Int) {
        
        
        carryingView.layer.position = self.beginLocation
        carryingView.transform = self.initialTransforms

    }
    
    override func willAppear(#carryingView:GZFlingCarryingView){
        
        UIView.animateWithDuration(0.2, delay: 0.06, usingSpringWithDamping: 0.5, initialSpringVelocity: 15, options:  UIViewAnimationOptions.CurveEaseInOut , animations: {[weak self] () -> Void in
            
            carryingView.layer.position = self!.beginLocation
            carryingView.transform = CGAffineTransformIdentity
            
            
            }, completion: {[weak self] (finished:Bool)->Void in
                self!.privateInstance.previousTranslation = CGPoint()
        })

    }
    
    
    override func didAppear(#carryingView:GZFlingCarryingView){
        
//        UIView.animateWithDuration(0.15, animations: {[weak self] () -> Void in
//            carryingView.layer.position = self!.beginLocation
//            carryingView.transform = CGAffineTransformIdentity
//        })
        
        
        
    }
    
    override func willBeginGesture(#gesture: UIPanGestureRecognizer) {
        self.radomClosewise = self.getNewRandomClosewise()
    }
    
    override func gesturePanning(#gesture: UIPanGestureRecognizer, translation: CGPoint) {
        
        var carryingView = self.flingView.topCarryingView
        
        var percent = fabs(translation.x / self.maxWidthForFling)
        percent = min(percent, 1.0)
        
        carryingView.layer.position = self.beginLocation.pointByOffsetting(translation.x, dy: translation.y)
        carryingView.transform = CGAffineTransformMakeRotation(self.radomClosewise*fabs(translation.x)/100*0.1)
        
        var nextCarryingView:GZFlingCarryingView! = self.flingView.nextCarryingView(fromCarryingView: carryingView)

        var scaleAdder = (1-self.initalScaleValue) * percent
        var scale = self.initalScaleValue+scaleAdder
        
        var transformSubractor = self.initalTranslationY*percent
        
        var transform = CGAffineTransformMakeTranslation(0, max(self.initalTranslationY-transformSubractor, 0))
        transform = CGAffineTransformScale(transform, scale, scale)
        nextCarryingView.transform = transform
        
        
        
        self.privateInstance.previousTranslation = translation
    }
    
    override func didEndGesture(#gesture: UIPanGestureRecognizer) {
        
    }
    
    
    override func showCancelAnimation(#direction:GZFlingViewSwipingDirection, translation:CGPoint, completionHandler:((finished:Bool)->Void)){
        
        var currentCarryingView = self.flingView.topCarryingView
        var nextCarryingView:GZFlingCarryingView! = self.flingView.nextCarryingView(fromCarryingView: currentCarryingView)
        
        UIView.animateWithDuration(kGZFlingViewAnimationDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 15, options:  UIViewAnimationOptions.CurveEaseInOut | UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.BeginFromCurrentState , animations: {[weak self] () -> Void in
            
            currentCarryingView.layer.position = self!.beginLocation
            currentCarryingView.transform = CGAffineTransformIdentity
            nextCarryingView.transform = self!.initialTransforms
            
            
            }, completion: {[weak self] (finished:Bool)->Void in
                
//                self!.privateInstance.previousTranslation = CGPoint()
                
                completionHandler(finished: finished)
                
        })
    }
    
    override func showChoosenAnimation(#direction:GZFlingViewSwipingDirection, translation:CGPoint, completionHandler:((finished:Bool)->Void)){

        var currentCarryingView = self.flingView.topCarryingView
        var nextCarryingView:GZFlingCarryingView! = self.flingView.nextCarryingView(fromCarryingView: currentCarryingView)
        
        UIView.animateWithDuration(kGZFlingViewAnimationDuration, delay: 0, options: UIViewAnimationOptions.CurveEaseIn | UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.BeginFromCurrentState , animations:{ ()-> Void in

            currentCarryingView.layer.position.offset(dx: translation.x*2, dy: translation.y*2)
            currentCarryingView.transform = CGAffineTransformMakeRotation(self.radomClosewise * 0.25)
            currentCarryingView.alpha = 0
            
//            nextCarryingView.transform = CGAffineTransformIdentity
            
            }) {[weak self](finished:Bool)->Void in
                
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
    

    
    override func shouldCancel(#direction: GZFlingViewSwipingDirection, translation: CGPoint) -> Bool {
        
        //self.flingView.frame.width/6*2
        return !(fabs(translation.x) > self.maxWidthForFling )
    }
    
    
    struct PrivateInstance {
    
        var previousTranslation = CGPoint()
    
    }
    
}