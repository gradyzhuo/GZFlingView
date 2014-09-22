//
//  GZFlingChooseView.swift
//  GZKit
//
//  Created by Grady Zhuo on 2014/9/14.
//  Copyright (c) 2014年 Grady Zhuo. All rights reserved.
//

import UIKit

 class GZFlingView: UIView, UIGestureRecognizerDelegate {
    
    //MARK: - Properties Declare
    /**
        (readonly)
    */
      var topCarryingView : GZFlingCarryingView!{
        get{
            return self.nodesQueue.currentNode!.carryingView
        }
    }
    
    /**
        (readonly)
    */
     var nextCarryingView : GZFlingCarryingView!{
        get{
            return self.nodesQueue.currentNode!.nextNode!.carryingView
        }
    }
    
    /**
        (readonly)
    */
    var direction:GZFlingViewSwipingDirection{
        get{
            return PrivateInstance.direction
        }
    }
    
    @IBOutlet  var dataSource: AnyObject?
    @IBOutlet  var delegate: AnyObject?
    
    var isEnded:Bool{
        get{
            return PrivateInstance.arriveEnd || PrivateInstance.overEnd
        }
    }
    
    private var nodesQueue = GZFlingNodesQueue()
    private var swipingAnimationType:GZFlingViewAnimationType = .Tinder
    
    
    override init() {
        super.init()
        self.initialize()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initialize()
    }
    
    func initialize(){
        self.prepareGestures()
        PrivateInstance.beginLocation = self.bounds.center
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.nodesQueue.size == 0 {
            
            if self.dataSource == nil {
                return
            }
            
            var numberOfCarryingViews:Int = self.dataSource!.numberOfCarryingViewsForReusingInFlingView(self)
            
            for index in 0..<numberOfCarryingViews {
                
                if let carryingView = self.dataSource?.flingView(self, carryingViewForReusingAtIndex: index) {
                    
                    self.addSubview(carryingView)
                    self.sendSubviewToBack(carryingView)
                    
                    carryingView.frame = self.bounds
                    carryingView.flingIndex = index
//                    var delegate = self.delegate as GZFlingViewDelegate
//                    
//                    if delegate.respondsToSelector("flingView:willShowCarryingView:atFlingIndex:") {
//                        self.delegate?.flingView!(self, willShowCarryingView: carryingView, atFlingIndex: PrivateInstance.counter)
//                    }
                    self.askDelegateForNeedShow(self.delegate as GZFlingViewDelegate, forCarryingView: carryingView, atIndex: index)
                    
                    
                    self.nodesQueue += GZFlingNode(carryingView: carryingView)
                    
                }

                PrivateInstance.counter++
                
            }

            self.tellDelegateDidShow(carryingView: self.nodesQueue.frontNode.carryingView, atFlingIndex: 0)
            
        }
        
    }
    
    
    func tellDelegateWillShow(#carryingView:GZFlingCarryingView, atFlingIndex index:Int){
        
        if let delegateObject: AnyObject = self.delegate {
            
            var delegate = delegateObject as GZFlingViewDelegate
            
            if delegate.respondsToSelector("flingView:willShowCarryingView:atFlingIndex:") {
                delegate.flingView!(self, willShowCarryingView: carryingView, atFlingIndex: index)
            }
            
            
            PrivateInstance.predictEndIndex = index
            
        }
        
    }
    
    func tellDelegateDidShow(#carryingView:GZFlingCarryingView, atFlingIndex index:Int){
        
        PrivateInstance.topIndex = index
        
        if let delegateObject: AnyObject = self.delegate {
            
            var delegate = delegateObject as GZFlingViewDelegate
            
            if PrivateInstance.arriveEnd && delegate.respondsToSelector("flingView:didArriveEndIndex:") {
                delegate.flingView!(self, didArriveEndIndex: index)
            }
            
            if delegate.respondsToSelector("flingView:didShowCarryingView:atFlingIndex:") {
                delegate.flingView!(self, didShowCarryingView: carryingView, atFlingIndex: index)
            }
            
        }
        
    }
    
    
    
    func askDelegateForNeedShow(delegate:GZFlingViewDelegate, forCarryingView carryView:GZFlingCarryingView, atIndex index:Int){
        
        var selectorForCheck = Selector("flingView:shouldNeedShowCarryingViewAtFlingIndex:")
        
        if delegate.respondsToSelector(selectorForCheck) && delegate.flingView!(self, shouldNeedShowCarryingViewAtFlingIndex: index) {

            
            
            selectorForCheck = Selector("flingView:prepareCarryingView:atFlingIndex:")
            
            if delegate.respondsToSelector(selectorForCheck) {
                
                carryView.flingIndex = index
                carryView.relocation(center: PrivateInstance.beginLocation, prepareForShow: true)
                
                
                self.tellDelegateWillShow(carryingView: carryView, atFlingIndex: index)
                
                delegate.flingView!(self, prepareCarryingView: carryView, atFlingIndex: index)

            }

        }else{
            
            carryView.flingIndex = index
            carryView.relocation(center:PrivateInstance.beginLocation, prepareForShow: false)
            
        }

    }
    
    func prepareGestures(){
        var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "viewDidPan:")
        panGestureRecognizer.delegate = self
        self.addGestureRecognizer(panGestureRecognizer)
    }
    
    
     func choose(direction:GZFlingViewSwipingDirection){
        
        if PrivateInstance.overEnd  {
            return
        }
        
        PrivateInstance.gestruBeginReset()
        
        var translation:CGPoint?
        switch direction {
            
        case .Left:
            translation = CGPoint(x: -100, y: 50)
            
        case .Right:
            translation = CGPoint(x: 100, y: -50)
            
        case .Undefined:
            translation = CGPoint(x: 0, y: 0)
            
        }
        
        PrivateInstance.direction = direction
        self.showChoosenAnimation(direction, translation: translation!)
        
        
        
    }
    
    
    func showChoosenAnimation(direction:GZFlingViewSwipingDirection, translation:CGPoint){
        
        var currentCarryingView = (self.nodesQueue.currentNode?.carryingView)!
        var nextCarryingView = self.nodesQueue.next().carryingView
        
        
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.AllowAnimatedContent | UIViewAnimationOptions.CurveEaseInOut | UIViewAnimationOptions.OverrideInheritedDuration , animations:{ [weak self] ()-> Void in
            
            var weakSelf = self!
            
            weakSelf.swipingAnimationType.completionAnimation(carryingView: currentCarryingView, direction:direction, translation: translation)
            
            }) {[weak self] (finished:Bool)->Void in
                
                
                var weakSelf = self!
                
                var selectorForCheck:Selector!
                
                
                weakSelf.tellDelegateDidShow(carryingView: nextCarryingView, atFlingIndex: nextCarryingView.flingIndex)
                
                if let delegate : GZFlingViewDelegate = weakSelf.delegate as? GZFlingViewDelegate {
                    
                    selectorForCheck = Selector("flingView:didChooseCarryingView:atFlingIndex:")
                    
                    if delegate.respondsToSelector(selectorForCheck) {
                        delegate.flingView!(weakSelf, didChooseCarryingView: currentCarryingView, atFlingIndex: currentCarryingView.flingIndex)
                    }
                    
                    weakSelf.askDelegateForNeedShow(delegate, forCarryingView: currentCarryingView, atIndex: PrivateInstance.counter++)
                    
//                    if currentCarryingView.flingIndex <= PrivateInstance.endIndex {
//                        
//                        if delegate.respondsToSelector("flingView:didArriveEndIndex:") {
//                            delegate.flingView!(weakSelf, didArriveEndIndex: PrivateInstance.endIndex)
//                            
//                        }
//                        
//                    }
//                    else if nextCarryingView.flingIndex <= PrivateInstance.endIndex {
//                        
//                        if delegate.respondsToSelector("flingView:willArriveEndIndex:") {
//                            
//                            delegate.flingView!(weakSelf, willArriveEndIndex: PrivateInstance.endIndex)
//                            
//                        }
//                        
//                    }
                    
                    
                    
                }
                
        }

    }
    
    func cancel(translation:CGPoint){
        
        var time = NSTimeInterval(0.4)
        var velocity = translation.velocityByTimeInterval(time)/15
        
        UIView.animateWithDuration(time, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: UIViewAnimationOptions.AllowAnimatedContent | UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.BeginFromCurrentState | UIViewAnimationOptions.CurveEaseInOut, animations: {[weak self] () -> Void in
            
            var weakSelf = self!
            weakSelf.reset()
            
            
            }, completion: {[weak self] (finished:Bool)->Void in
                
                var weakSelf = self!
                
                if let delegate : GZFlingViewDelegate = weakSelf.delegate as? GZFlingViewDelegate {
                    
                    if delegate.respondsToSelector("flingView:didCancelChooseCarryingView:atFlingIndex:") {
                        delegate.flingView!(weakSelf, didCancelChooseCarryingView: weakSelf.topCarryingView, atFlingIndex: weakSelf.topCarryingView.flingIndex)
                    }
                    
                }

                
            })
        
    }
    
    func viewDidPan(gesture: UIPanGestureRecognizer){
        
        var translation = gesture.translationInView(self)
        
        switch(gesture.state){
            
        case .Began:
            PrivateInstance.gestruBeginReset()
            
            
        case .Ended:

            PrivateInstance.direction = GZFlingViewSwipingDirection(rawValue: Int(translation.x > 0))
            
            if fabs(translation.x) > self.frame.width/6*2   {
                self.showChoosenAnimation(self.direction, translation: translation)
            }else{
                self.cancel(translation)
            }
            
        case .Changed:
            
            if let beginLocation = PrivateInstance.beginLocation {
                self.swipingAnimationType.choosingClosure(carryingView: self.topCarryingView, beginLocation: PrivateInstance.beginLocation!, translation: translation)
                
                if let delegate:GZFlingViewDelegate = self.delegate as? GZFlingViewDelegate {
                    
                    if delegate.respondsToSelector("flingView:didSwipeCarryingView:withContentOffset:") {
                        delegate.flingView!(self, didSwipeCarryingView: self.topCarryingView, withContentOffset: translation)
                    }

                }
                
                
             }
            
        default:
            () //nothing to do
        }
    }
    
    func reset(){
        self.swipingAnimationType.cancelAnimation(carryingView: self.topCarryingView, beginLocation: PrivateInstance.beginLocation!)
    }
    
    
    //MARK: Gesture Recognizer Delegate
    
    
    override  func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return !PrivateInstance.overEnd  && self.dataSource != nil
    }
    
    
    private struct PrivateInstance {
        static var beginLocation:CGPoint?
        static var counter:Int = 0
        
        static var clockwise:CGFloat = -1
        static var direction:GZFlingViewSwipingDirection = .Undefined
        
        static var predictEndIndex = 0
        
        static var topIndex:Int = -1
        
        static var overEnd:Bool {
            get{
                return PrivateInstance.predictEndIndex != -1 && PrivateInstance.topIndex > PrivateInstance.predictEndIndex
            }
        }
        
        static var arriveEnd:Bool{
            get{
                return PrivateInstance.predictEndIndex != -1 && PrivateInstance.topIndex == PrivateInstance.predictEndIndex

            }
        }
        
        
        static func gestruBeginReset(){
            GZFlingViewAnimationType.getNewRandomClosewise()
            
        }
        
        static func reset(){
            PrivateInstance.topIndex = -1
            PrivateInstance.counter = 0
        }
        
    }
}

@objc protocol GZFlingViewDelegate : NSObjectProtocol {
    optional func flingView(flingView:GZFlingView, didChooseCarryingView carryingView:GZFlingCarryingView, atFlingIndex index:Int)->Void
    optional func flingView(flingView:GZFlingView, didCancelChooseCarryingView carryingView:GZFlingCarryingView, atFlingIndex index:Int)->Void
    
    optional func flingView(flingView:GZFlingView, shouldNeedShowCarryingViewAtFlingIndex index:Int)->Bool
    optional func flingView(flingView:GZFlingView, prepareCarryingView carryingView:GZFlingCarryingView, atFlingIndex index:Int)->Void
    
    optional func flingView(flingView:GZFlingView, willShowCarryingView carryingView:GZFlingCarryingView, atFlingIndex index:Int)->Void
    optional func flingView(flingView:GZFlingView, didShowCarryingView carryingView:GZFlingCarryingView, atFlingIndex index:Int)->Void
    
    optional func flingView(flingView:GZFlingView, didSwipeCarryingView carryingView:GZFlingCarryingView, withContentOffset contentOffset:CGPoint)->Void
    
    optional func flingView(flingView:GZFlingView, willArriveEndIndex index:Int)->Void
    optional func flingView(flingView:GZFlingView, didArriveEndIndex index:Int)->Void
    
}

@objc protocol GZFlingViewDatasource : NSObjectProtocol{
    func numberOfCarryingViewsForReusingInFlingView(flingView:GZFlingView) -> Int
    func flingView(flingView:GZFlingView, carryingViewForReusingAtIndex reuseIndex:Int) -> GZFlingCarryingView
}

