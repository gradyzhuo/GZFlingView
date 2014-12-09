//
//  GZFlingViewAnimation.swift
//  Flingy
//
//  Created by Grady Zhuo on 2014/9/25.
//  Copyright (c) 2014年 Grady Zhuo. All rights reserved.
//

import UIKit


enum GZFlingViewAnimationState:Int{
    case Init = 0
}


let kGZFlingViewAnimationDuration:NSTimeInterval = 0.2

public class GZFlingViewAnimation {
    
    var flingView:GZFlingView!
    var beginLocation:CGPoint = CGPoint()
    
    init(){
        
    }
    
    var expectedMinSize:Int {
        return 0
    }
    
    func gesturePanning(#gesture:UIPanGestureRecognizer, currentNode:GZFlingNode, translation:CGPoint){}
    func willBeginGesture(#gesture:UIPanGestureRecognizer, currentNode:GZFlingNode){}
    func didEndGesture(#gesture:UIPanGestureRecognizer, currentNode:GZFlingNode){}
    
    
    func prepare(#node:GZFlingNode, reuseIndex:Int){
        //pass
    }
    
    func willAppear(#node:GZFlingNode){
        //pass
    }
    
    func didAppear(#node:GZFlingNode){
        //pass
    }

    
    func shouldCancel(#direction:GZFlingViewSwipingDirection, currentNode:GZFlingNode, translation:CGPoint)->Bool{return true}
    func showChoosenAnimation(#direction:GZFlingViewSwipingDirection, currentNode:GZFlingNode, translation:CGPoint, completionHandler:((finished:Bool)->Void)){completionHandler(finished: true)}
    
    func showCancelAnimation(#direction:GZFlingViewSwipingDirection, currentNode:GZFlingNode, translation:CGPoint,completionHandler:((finished:Bool)->Void)){completionHandler(finished: true)}
    
}



public class GZFlingViewAnimationTinder:GZFlingViewAnimation{
    
    var radomClosewise:CGFloat = -1
    
    var initalScaleValue : CGFloat = 0.95
    var secondInitalScaleValue : CGFloat = 0.975
    var targetScaleValue:CGFloat = 1.0
    
    lazy var initalTranslationY : CGFloat = {
        var scale = self.targetScaleValue-self.initalScaleValue
        return (self.flingView.bounds.height * scale )
    }()
    
    lazy var distanceY:CGFloat = {
        var scale = self.secondInitalScaleValue-self.initalScaleValue
        return (self.flingView.bounds.height * scale )
    }()
    
    var privateInstance = PrivateInstance()
    
    override var expectedMinSize:Int {
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
    
    override func prepare(#node:GZFlingNode, reuseIndex: Int) {
        
        var carryingView = node.carryingView
        
        carryingView.layer.position = self.beginLocation
        carryingView.transform = self.initialTransforms
        
    }
    
    override func willAppear(#node:GZFlingNode!){
        
        var carryingView = node.carryingView
        
        UIView.animateWithDuration(0.2, delay: 0.06, usingSpringWithDamping: 0.5, initialSpringVelocity: 15, options:  UIViewAnimationOptions.CurveEaseInOut , animations: {[weak self] () -> Void in
            
            

//            var nextCarryingView:GZFlingCarryingView! = node.nextNode.carryingView
            
            
            
            }, completion: {[weak self] (finished:Bool)->Void in
                
                if let weakSelf = self {
                    weakSelf.privateInstance.previousTranslation = CGPoint()
                }
                
        })

        
    }
    

    override func willBeginGesture(#gesture: UIPanGestureRecognizer, currentNode:GZFlingNode) {
        self.radomClosewise = self.getNewRandomClosewise()
    }
    
    override func gesturePanning(#gesture: UIPanGestureRecognizer, currentNode:GZFlingNode?, translation: CGPoint) {
        
        
        if let topNode = currentNode {
            
            var carryingView = topNode.carryingView
            
            var percent = fabs(translation.x / self.maxWidthForFling)
            percent = min(percent, 1.0)
            
            carryingView.layer.position = self.beginLocation.pointByOffsetting(translation.x, dy: translation.y)
            carryingView.transform = CGAffineTransformMakeRotation(self.radomClosewise*fabs(translation.x)/100*0.1)
            
            if let secondNode = topNode.nextNode {
                
                //最二層 到 最上層
                var nextCarryingView:GZFlingCarryingView = secondNode.carryingView
                
                //scaleAdder:計算要在初始化增加的scale的量
                var scaleAdder = (self.targetScaleValue - self.secondInitalScaleValue) * percent
                var scale = self.secondInitalScaleValue+scaleAdder
                
                var transformSubractor = self.secondDistanceY*percent
                
                var transform = CGAffineTransformMakeTranslation(0, max(self.secondInitalTranslationY-transformSubractor, 0))
                transform = CGAffineTransformScale(transform, scale, scale)
                nextCarryingView.transform = transform

                
                
            }
            
            
            if let lastNode = topNode.nextNode?.nextNode {
                
                //最底層 到 第二層
                
                var nextNextCarryingView:GZFlingCarryingView! = lastNode.carryingView//self.flingView.nextCarryingView(fromCarryingView: nextCarryingView)
                
                var nextScaleAdder = (self.secondInitalScaleValue-self.initalScaleValue) * percent
                var nextScale = self.initalScaleValue+nextScaleAdder
                
                var nextTransformSubractor = self.distanceY*percent
                
                var nextTransform = CGAffineTransformMakeTranslation(0, max(self.initalTranslationY-nextTransformSubractor, 0))
                nextTransform = CGAffineTransformScale(nextTransform, nextScale, nextScale)
                nextNextCarryingView.transform = nextTransform
                
                
            }
            
            
            
            
            
            self.privateInstance.previousTranslation = translation
        }
        
        if let carryingView = self.flingView.topCarryingView{
            
            
            
        }
        
//        var carryingView = self.flingView.topCarryingView
        
        
    }
    
    
    override func showCancelAnimation(#direction:GZFlingViewSwipingDirection, currentNode:GZFlingNode?, translation:CGPoint, completionHandler:((finished:Bool)->Void)){
        
        
        if let topNode = currentNode {
            
            UIView.animateWithDuration(kGZFlingViewAnimationDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 15, options:  UIViewAnimationOptions.CurveEaseInOut | UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.BeginFromCurrentState , animations: {[weak self] () -> Void in

                topNode.carryingView.layer.position = self!.beginLocation
                topNode.carryingView.transform = CGAffineTransformIdentity
                
                if let secondNode = topNode.nextNode {
                    secondNode.carryingView.transform = self!.secondInitialTransforms
                }

                if let lastNode = topNode.nextNode?.nextNode {
                    lastNode.carryingView.transform = self!.initialTransforms
                }
                
                
                
                }, completion: {[weak self] (finished:Bool)->Void in
                    
                    //                self!.privateInstance.previousTranslation = CGPoint()
                    
                    completionHandler(finished: finished)
                    
            })

        }else{
            completionHandler(finished: true)
        }
        
        
    }
    
    override func showChoosenAnimation(#direction:GZFlingViewSwipingDirection, currentNode:GZFlingNode?, translation:CGPoint, completionHandler:((finished:Bool)->Void)){

        if let topNode = currentNode {
            
            UIView.animateWithDuration(kGZFlingViewAnimationDuration, delay: 0, options: UIViewAnimationOptions.CurveEaseIn | UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.BeginFromCurrentState , animations:{[weak self] ()-> Void in
                
                topNode.carryingView.layer.position.offset(dx: translation.x*2, dy: translation.y*2)
                topNode.carryingView.transform = CGAffineTransformMakeRotation(self!.radomClosewise * 0.25)
                topNode.carryingView.alpha = 0
                
                
                }) {[weak self](finished:Bool)->Void in
                    
                    completionHandler(finished: finished)
            }
        
        }else{
            completionHandler(finished: true)
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
    

    
    override func shouldCancel(#direction: GZFlingViewSwipingDirection, currentNode:GZFlingNode,translation: CGPoint) -> Bool {
        
        //self.flingView.frame.width/6*2
        return !(fabs(translation.x) > self.maxWidthForFling )
    }
    
    
    struct PrivateInstance {
    
        var previousTranslation = CGPoint()
    
    }
    
}