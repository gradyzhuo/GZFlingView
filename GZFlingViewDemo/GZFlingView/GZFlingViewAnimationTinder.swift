//
//  GZFlingViewAnimationTinder.swift
//  GZFlingViewDemo
//
//  Created by Grady Zhuo on 10/13/15.
//  Copyright © 2015 Grady Zhuo. All rights reserved.
//

import UIKit

/** 
    GZFlingViewAnimationTinder : Fling animation like tinder
 */
public class GZFlingViewAnimationTinder:GZFlingViewAnimation{
    
    internal var radomClosewise:CGFloat = -1
    internal var previousTranslation = CGPoint()
    
    public var initalScaleValue : CGFloat = 0.95
    public var secondInitalScaleValue : CGFloat = 0.975
    public var targetScaleValue:CGFloat = 1.0
    
    internal lazy var initalTranslationY : CGFloat = {
        var scale = self.targetScaleValue-self.initalScaleValue
        return (self.flingView.bounds.height * scale )
    }()
    
    internal lazy var distanceY:CGFloat = {
        var scale = self.secondInitalScaleValue-self.initalScaleValue
        return (self.flingView.bounds.height * scale )
    }()
    
    override public var expectedMinSize:Int {
        return 4
    }
    
    lazy var initialTransforms : CGAffineTransform = {
        
        var transforms = CGAffineTransformMakeTranslation(0, self.initalTranslationY)
        
        return CGAffineTransformScale(transforms, self.initalScaleValue, self.initalScaleValue)
        
    }()
    
    
    lazy var secondInitalTranslationY : CGFloat = {
        var scale = self.targetScaleValue-(self.secondInitalScaleValue)
        return (self.flingView.bounds.height * scale )
    }()
    
    lazy var secondDistanceY:CGFloat = {
        var scale = self.targetScaleValue-self.secondInitalScaleValue
        return (self.flingView.bounds.height * scale )
    }()
    
    lazy var secondInitialTransforms : CGAffineTransform = {
        
        var transforms = CGAffineTransformMakeTranslation(0, self.secondInitalTranslationY)
        
        return CGAffineTransformScale(transforms, self.secondInitalScaleValue, self.secondInitalScaleValue)
        
    }()
    
    
    lazy var maxWidthForFling:CGFloat = {
        return (UIScreen.mainScreen().bounds.width / 2) * (2/3)
    }()
    
    override public func prepare(node node:GZFlingNode) {
        
        let carryingView = node.carryingView
        
        carryingView.layer.position = self.beginLocation
        carryingView.transform = self.initialTransforms
        
        self.radomClosewise = self.getNewRandomClosewise()
        
    }
    
    override public func willAppear(node node:GZFlingNode!){
        
        UIView.animateWithDuration(0.2, delay: 0.06, usingSpringWithDamping: 0.5, initialSpringVelocity: 15, options:  UIViewAnimationOptions.CurveEaseInOut , animations: {[weak self] () -> Void in
            
            if let weakSelf = self {
                
                if let topNode = node {
                    
                    topNode.carryingView.transform = CGAffineTransformIdentity
                    
                    if let secondNode = topNode.nextNode {
                        
                        secondNode.carryingView.transform = weakSelf.secondInitialTransforms
                        
                        
                        
                    }
                    
                    
                    
                }
                
                
            }
            
            
            }, completion: {[weak self] (finished:Bool)->Void in
                
                if let weakSelf = self {
                    weakSelf.previousTranslation = CGPoint()
                }
                
            })
        
        
    }
    
    public override func willBeginGesture(gestureInfo gestureInfo:GZFlingViewAnimationGestureInfo, currentNode:GZFlingNode?) {
        self.radomClosewise = self.getNewRandomClosewise()
    }
    
    public override func gesturePanning(gestureInfo gestureInfo:GZFlingViewAnimationGestureInfo, currentNode:GZFlingNode?) {
        
        if let topNode = currentNode {
            
            let carryingView = topNode.carryingView
            
            var percent = fabs(gestureInfo.translation.x / self.maxWidthForFling)
            percent = min(percent, 1.0)
            
            carryingView.layer.position = self.beginLocation.pointByOffsetting(gestureInfo.translation.x, dy: gestureInfo.translation.y)
            carryingView.transform = CGAffineTransformMakeRotation(self.radomClosewise*fabs(gestureInfo.translation.x)/100*0.1)
            
            if let secondNode = topNode.nextNode {
                
                //最二層 到 最上層
                let nextCarryingView:GZFlingCarryingView = secondNode.carryingView
                
                //scaleAdder:計算要在初始化增加的scale的量
                let scaleAdder = (self.targetScaleValue - self.secondInitalScaleValue) * percent
                let scale = self.secondInitalScaleValue+scaleAdder
                
                let transformSubractor = self.secondDistanceY*percent
                
                var transform = CGAffineTransformMakeTranslation(0, max(self.secondInitalTranslationY-transformSubractor, 0))
                transform = CGAffineTransformScale(transform, scale, scale)
                nextCarryingView.transform = transform
                
                
                
            }
            
            
            if let lastNode = topNode.nextNode?.nextNode {
                
                //最底層 到 第二層
                
                let nextNextCarryingView:GZFlingCarryingView! = lastNode.carryingView//self.flingView.nextCarryingView(fromCarryingView: nextCarryingView)
                
                let nextScaleAdder = (self.secondInitalScaleValue-self.initalScaleValue) * percent
                let nextScale = self.initalScaleValue+nextScaleAdder
                
                let nextTransformSubractor = self.distanceY*percent
                
                var nextTransform = CGAffineTransformMakeTranslation(0, max(self.initalTranslationY-nextTransformSubractor, 0))
                nextTransform = CGAffineTransformScale(nextTransform, nextScale, nextScale)
                nextNextCarryingView.transform = nextTransform
                
                
            }
            
            
            
            
            
            self.previousTranslation = gestureInfo.translation
        }
        
    }
    
    
    public override func showRestoreAnimation(direction direction:GZFlingViewSwipingDirection, currentNode:GZFlingNode?, gestureInfo:GZFlingViewAnimationGestureInfo, completionHandler:((finished:Bool)->Void)){
        
        
        if let topNode = currentNode {
            
            UIView.animateWithDuration(kGZFlingViewAnimationDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 15, options:  [UIViewAnimationOptions.CurveEaseInOut, UIViewAnimationOptions.AllowUserInteraction, UIViewAnimationOptions.BeginFromCurrentState] , animations: {[unowned self] () -> Void in
                
                topNode.carryingView.layer.position = self.beginLocation
                topNode.carryingView.transform = CGAffineTransformIdentity
                
                if let secondNode = topNode.nextNode {
                    secondNode.carryingView.transform = self.secondInitialTransforms
                }
                
                if let lastNode = topNode.nextNode?.nextNode {
                    lastNode.carryingView.transform = self.initialTransforms
                }
                
                
                
                }, completion: {(finished:Bool)->Void in
                    
                    //                self!.privateInstance.previousTranslation = CGPoint()
                    
                    completionHandler(finished: finished)
                    
            })
            
        }else{
            completionHandler(finished: true)
        }
        
        
    }
    
    public override func showChoosenAnimation(direction direction:GZFlingViewSwipingDirection, currentNode:GZFlingNode?, gestureInfo:GZFlingViewAnimationGestureInfo, completionHandler:((finished:Bool)->Void)){
        
        guard let topNode = currentNode else {
            completionHandler(finished: true)
            return
        }
        
        UIView.animateWithDuration(kGZFlingViewAnimationDuration, delay: 0, options: [.CurveEaseIn, .AllowUserInteraction, .LayoutSubviews, .BeginFromCurrentState] , animations:{[unowned self] ()-> Void in
            
            topNode.carryingView.layer.position.offset(dx: gestureInfo.translation.x*2, dy: gestureInfo.translation.y*2)
            topNode.carryingView.transform = CGAffineTransformMakeRotation(self.radomClosewise * 0.25)
            topNode.carryingView.alpha = 0
            
            }) {(finished:Bool)->Void in
                completionHandler(finished: finished)
        }
        
    }
    
    
    func getNewRandomClosewise() -> CGFloat{
        let random = arc4random()%10
        
        var radomClosewise = -1
        
        switch random {
            
        case 0,1,3:
            radomClosewise = 1
            
        default:
            radomClosewise = -1
        }
        
        return CGFloat(radomClosewise)
        
    }
    
    
    
    public override func shouldCancel(direction direction: GZFlingViewSwipingDirection, currentNode:GZFlingNode?, gestureInfo:GZFlingViewAnimationGestureInfo) -> Bool {

        //self.flingView.frame.width/6*2
        return !(fabs(gestureInfo.translation.x) > self.maxWidthForFling || fabs(gestureInfo.velocity.x) > 650.0 )
    }
    
}