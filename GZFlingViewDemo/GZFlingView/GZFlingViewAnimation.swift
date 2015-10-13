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
    var nodesQueue:GZFlingNodesQueue!
    
    init(){
        
    }
    
    
    func gesturePanning(gesture gesture:UIPanGestureRecognizer, translation:CGPoint){}
    func willBeginGesture(gesture gesture:UIPanGestureRecognizer){}
    func didEndGesture(gesture gesture:UIPanGestureRecognizer){}
    
    
    func prepare(carryingView carryingView:GZFlingCarryingView, reuseIndex:Int){
        //pass
    }
    
    func willAppear(carryingView carryingView:GZFlingCarryingView!){
        //pass
    }
    
    func didAppear(carryingView carryingView:GZFlingCarryingView!){
        //pass
    }

    
    func shouldCancel(direction direction:GZFlingViewSwipingDirection, translation:CGPoint)->Bool{return true}
    func showChoosenAnimation(direction direction:GZFlingViewSwipingDirection, translation:CGPoint, completionHandler:((finished:Bool)->Void)){completionHandler(finished: true)}
    
    func showCancelAnimation(direction direction:GZFlingViewSwipingDirection, translation:CGPoint,completionHandler:((finished:Bool)->Void)){completionHandler(finished: true)}
    
}



public class GZFlingViewAnimationTinder:GZFlingViewAnimation{
    
    public internal(set) var radomClosewise:CGFloat = -1
    
    public var initalScaleValue : CGFloat = 0.95
    public var secondInitalScaleValue : CGFloat = 0.975
    public var targetScaleValue:CGFloat = 1.0
    
    lazy var initalTranslationY : CGFloat = {
        var scale = self.targetScaleValue-self.initalScaleValue
        return (self.flingView.bounds.height * scale )
    }()
    
    lazy var distanceY:CGFloat = {
        var scale = self.secondInitalScaleValue-self.initalScaleValue
        return (self.flingView.bounds.height * scale )
    }()
    
    var privateInstance = PrivateInstance()
    
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
    
    override func prepare(carryingView carryingView: GZFlingCarryingView, reuseIndex: Int) {
        
        
        carryingView.layer.position = self.beginLocation
        carryingView.transform = self.initialTransforms
        
    }
    
    override func willAppear(carryingView carryingView:GZFlingCarryingView!){
        
        UIView.animateWithDuration(0.2, delay: 0.06, usingSpringWithDamping: 0.5, initialSpringVelocity: 15, options:  UIViewAnimationOptions.CurveEaseInOut , animations: {[weak self] () -> Void in
            
            
            if let weakSelf = self {
                carryingView.transform = CGAffineTransformIdentity
                
                let nextCarryingView:GZFlingCarryingView! = weakSelf.flingView.nextCarryingView(fromCarryingView: carryingView)
                
                nextCarryingView.transform = weakSelf.secondInitialTransforms
            }
            
            
            
            
            }, completion: {[weak self] (finished:Bool)->Void in
                
                if let weakSelf = self {
                    weakSelf.privateInstance.previousTranslation = CGPoint()
                }
                
        })

        
    }
    
    
    override func didAppear(carryingView carryingView:GZFlingCarryingView!){
        
        
    }
    
    override func willBeginGesture(gesture gesture: UIPanGestureRecognizer) {
        self.radomClosewise = self.getNewRandomClosewise()
    }
    
    override func gesturePanning(gesture gesture: UIPanGestureRecognizer, translation: CGPoint) {
        
        guard let carryingView = self.flingView.topCarryingView else {
            return
        }
        
        var percent = fabs(translation.x / self.maxWidthForFling)
        percent = min(percent, 1.0)
        
        carryingView.layer.position = self.beginLocation.pointByOffsetting(translation.x, dy: translation.y)
        
        
        let scaleTransform = CGAffineTransformMakeScale(self.targetScaleValue, self.targetScaleValue)
        carryingView.transform = CGAffineTransformRotate(scaleTransform, self.radomClosewise*fabs(translation.x)/100*0.1)
        
        //最二層 到 最上層
        
        let nextCarryingView:GZFlingCarryingView! = self.nodesQueue.currentNode.nextNode.carryingView
        
        //scaleAdder:計算要在初始化增加的scale的量
        let scaleAdder = (self.targetScaleValue - self.secondInitalScaleValue) * percent
        let scale = self.secondInitalScaleValue + scaleAdder
        
        let transformSubractor = self.secondDistanceY * percent
        
        var transform = CGAffineTransformMakeTranslation(0, max(self.secondInitalTranslationY-transformSubractor, 0))
        transform = CGAffineTransformScale(transform, scale, scale)
        nextCarryingView.transform = transform
        
        
        //最底層 到 第二層
        
        let nextNextCarryingView:GZFlingCarryingView! = self.nodesQueue.currentNode.nextNode.nextNode.carryingView//self.flingView.nextCarryingView(fromCarryingView: nextCarryingView)
        
        let nextScaleAdder = (self.secondInitalScaleValue-self.initalScaleValue) * percent
        let nextScale = self.initalScaleValue+nextScaleAdder
        
        let nextTransformSubractor = self.distanceY*percent
        
        var nextTransform = CGAffineTransformMakeTranslation(0, max(self.initalTranslationY-nextTransformSubractor, 0))
        nextTransform = CGAffineTransformScale(nextTransform, nextScale, nextScale)
        nextNextCarryingView.transform = nextTransform
        
        self.privateInstance.previousTranslation = translation
        
    }
    
    override func didEndGesture(gesture gesture: UIPanGestureRecognizer) {
        
    }
    
    
    override func showCancelAnimation(direction direction:GZFlingViewSwipingDirection, translation:CGPoint, completionHandler:((finished:Bool)->Void)){
        
        if let currentCarryingView = self.flingView.topCarryingView {
//            var currentCarryingView = self.flingView.topCarryingView
            let nextCarryingView:GZFlingCarryingView! = self.nodesQueue.currentNode.nextNode.carryingView//self.flingView.nextCarryingView(fromCarryingView: currentCarryingView)
            let nextNextCarryingView:GZFlingCarryingView! = self.nodesQueue.currentNode.nextNode.nextNode.carryingView//self.flingView.nextCarryingView(fromCarryingView: nextCarryingView)
            
            UIView.animateWithDuration(kGZFlingViewAnimationDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 15, options:  [UIViewAnimationOptions.CurveEaseInOut, UIViewAnimationOptions.AllowUserInteraction, UIViewAnimationOptions.BeginFromCurrentState] , animations: {[weak self] () -> Void in
                
                if let weakSefl = self {
                    
                    currentCarryingView.layer.position = weakSefl.beginLocation
                    currentCarryingView.transform = CGAffineTransformIdentity
                    
                    nextCarryingView.transform = weakSefl.secondInitialTransforms
                    
                    nextNextCarryingView.transform = weakSefl.initialTransforms
                    
                }
                
                
                
            }, completion: {(finished:Bool)->Void in
                    
                    completionHandler(finished: finished)
                    
            })

        }
        
    }
    
    override func showChoosenAnimation(direction direction:GZFlingViewSwipingDirection, translation:CGPoint, completionHandler:((finished:Bool)->Void)){

        if let currentCarryingView = self.flingView.topCarryingView {
            
            UIView.animateWithDuration(kGZFlingViewAnimationDuration, delay: 0, options: [UIViewAnimationOptions.CurveEaseIn, UIViewAnimationOptions.AllowUserInteraction, UIViewAnimationOptions.BeginFromCurrentState] , animations:{[weak self] ()-> Void in
                
                if let weakSelf = self {
                    
                    currentCarryingView.layer.position.offset(dx: translation.x*2, dy: translation.y*2)
                    currentCarryingView.transform = CGAffineTransformMakeRotation(weakSelf.radomClosewise * 0.25)
                    currentCarryingView.alpha = 0
                    
                }
                
                
                }) {(finished:Bool)->Void in
                    
                    completionHandler(finished: finished)
                    
            }

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
    

    
    override func shouldCancel(direction direction: GZFlingViewSwipingDirection, translation: CGPoint) -> Bool {
        
        //self.flingView.frame.width/6*2
        return !(fabs(translation.x) > self.maxWidthForFling )
    }
    
    
    struct PrivateInstance {
    
        var previousTranslation = CGPoint()
    
    }
    
}