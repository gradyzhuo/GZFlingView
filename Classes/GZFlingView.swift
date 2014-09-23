//
//  GZFlingChooseView.swift
//  GZKit
//
//  Created by Grady Zhuo on 2014/9/14.
//  Copyright (c) 2014年 Grady Zhuo. All rights reserved.
//

import UIKit

public class GZFlingView: UIView {

    //MARK: - Properties Declare
    /**
        (readonly)
    */
    public  var topCarryingView : GZFlingCarryingView!{
        get{
            return self.nodesQueue.currentNode!.carryingView
        }
    }
    
    /**
        (readonly)
    */
    public var nextCarryingView : GZFlingCarryingView!{
        get{
            return self.nodesQueue.currentNode!.nextNode!.carryingView
        }
    }
    
    /**
        (readonly)
    */
    public var direction:GZFlingViewSwipingDirection{
        get{
            return PrivateInstance.direction
        }
    }
    
    @IBOutlet public var dataSource: AnyObject?
    @IBOutlet public var delegate: AnyObject?
    
    public var isEnded:Bool{
        get{
            return PrivateInstance.arriveEnd || PrivateInstance.overEnd
        }
    }
    
    public var contentOffset:CGPoint{
        
        get{
            return PrivateInstance.translation
        }
    }
    
    
    private var nodesQueue = GZFlingNodesQueue()
    private var swipingAnimationType:GZFlingViewAnimationType = .Tinder
    
    
    
    //MARK: - Public Methods
    
    public override init() {
        super.init()
        self.initialize()
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initialize()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.nodesQueue.size == 0 {
            
            self.reloadData()
            
        }
        
    }

    
    public func choose(direction:GZFlingViewSwipingDirection){
        
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
    
    
    public func reloadData(){
        
        if self.dataSource == nil {
            return
        }
        
        PrivateInstance.reset()
        self.nodesQueue.reset()
        
        var numberOfCarryingViews:Int = self.dataSource!.numberOfCarryingViewsForReusingInFlingView(self)
        
        for index in 0..<numberOfCarryingViews {
            
            if let carryingView = self.dataSource?.flingView(self, carryingViewForReusingAtIndex: index) {
                
                self.addSubview(carryingView)
                self.sendSubviewToBack(carryingView)
                
                carryingView.frame = self.bounds
                carryingView.flingIndex = index
                
                self.askDelegateForNeedShow(self.delegate as GZFlingViewDelegate, forCarryingView: carryingView, atIndex: index)
                
                
                self.nodesQueue += GZFlingNode(carryingView: carryingView)
                
            }
            
            PrivateInstance.counter++
            
        }
        
        self.tellDelegateDidShow(carryingView: self.nodesQueue.frontNode.carryingView, atFlingIndex: 0)
        
    }
    
    // MARK: - Private Methods
    
    func initialize(){
        self.prepareGestures()
        PrivateInstance.beginLocation = self.bounds.center
    }
    
    
    func prepareGestures(){
        var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "viewDidPan:")
        panGestureRecognizer.delegate = self
        self.addGestureRecognizer(panGestureRecognizer)
    }
    
    
    func showChoosenAnimation(direction:GZFlingViewSwipingDirection, translation:CGPoint){
        
        var currentCarryingView = (self.nodesQueue.currentNode?.carryingView)!
        var nextCarryingView = self.nodesQueue.next().carryingView
        
        
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.LayoutSubviews | UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.AllowAnimatedContent | UIViewAnimationOptions.CurveEaseInOut | UIViewAnimationOptions.OverrideInheritedDuration , animations:{ [weak self] ()-> Void in
            
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
                    
                    weakSelf.swipingAnimationType.completionHandler(carryingView: currentCarryingView, beginLocation: PrivateInstance.beginLocation!)
                    
                    weakSelf.askDelegateForNeedShow(delegate, forCarryingView: currentCarryingView, atIndex: PrivateInstance.counter)
                    PrivateInstance.counter++
                }
                
        }

    }
    
    func showCancelAnimation(direction:GZFlingViewSwipingDirection, beginLocation:CGPoint, translation:CGPoint){
        
        self.tellDelegateWillCancelChoosingCarryingView(carryingView: self.topCarryingView)
        
        var time = NSTimeInterval(0.4)
        var velocity = translation.velocityByTimeInterval(time)/15
        
        UIView.animateWithDuration(time, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: UIViewAnimationOptions.AllowAnimatedContent | UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.BeginFromCurrentState | UIViewAnimationOptions.CurveEaseInOut | UIViewAnimationOptions.LayoutSubviews , animations: {[weak self] () -> Void in
            
            self!.swipingAnimationType.cancelAnimation(carryingView: self!.topCarryingView, beginLocation: beginLocation)
            
            }, completion: {[weak self] (finished:Bool)->Void in

                
                self!.tellDelegateDidCancelChoosingCarryingView(carryingView: self!.topCarryingView)
                
                
        })
    }
    
    
    
}

//MARK: - Gesture Support
extension GZFlingView : UIGestureRecognizerDelegate {
    
    func viewDidPan(gesture: UIPanGestureRecognizer){
        
        var translation = gesture.translationInView(self)
        PrivateInstance.translation = translation
        
        
        switch(gesture.state){
            
        case .Began:
            PrivateInstance.gestruBeginReset()
            
            
        case .Ended:
            
            PrivateInstance.direction = GZFlingViewSwipingDirection(rawValue: Int(translation.x > 0))
            
            if fabs(translation.x) > self.frame.width/6*2   {
                self.showChoosenAnimation(self.direction, translation: translation)
            }else{
                self.showCancelAnimation(self.direction, beginLocation: PrivateInstance.beginLocation!, translation: translation)
            }
            
        case .Changed:
            
            if let beginLocation = PrivateInstance.beginLocation {
                
                self.swipingAnimationType.choosingClosure(carryingView: self.topCarryingView, beginLocation: PrivateInstance.beginLocation!, translation: translation)
                
                self.tellDelegateDidDrag(carryingView: self.topCarryingView, contentOffset: translation)
                
                
            }
            
        default:
            self.showCancelAnimation(self.direction, beginLocation: PrivateInstance.beginLocation!, translation: translation)
        }
    }
    
    
    //MARK: Gesture Recognizer Delegate
    override public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return !PrivateInstance.overEnd  && self.dataSource != nil
    }
}


//MARK: - Delegate Method Support
extension GZFlingView {
    
    func tellDelegateDidEndDragging(#carryingView:GZFlingCarryingView){
        if let delegate:GZFlingViewDelegate = self.delegate as? GZFlingViewDelegate {
            
            if delegate.respondsToSelector("flingViewDidEndDragging:withDraggingCarryingView:") {
                delegate.flingViewDidEndDragging!(self, withDraggingCarryingView: carryingView)
            }
            
        }
    }
    
    func tellDelegateWillCancelChoosingCarryingView(#carryingView:GZFlingCarryingView){
        if let delegate : GZFlingViewDelegate = self.delegate as? GZFlingViewDelegate {
            
            if delegate.respondsToSelector("flingView:willCancelChooseCarryingView:atFlingIndex:") {
                delegate.flingView!(self, willCancelChooseCarryingView: carryingView, atFlingIndex: carryingView.flingIndex)
            }
            
        }
    }
    
    func tellDelegateDidCancelChoosingCarryingView(#carryingView:GZFlingCarryingView){
        if let delegate : GZFlingViewDelegate = self.delegate as? GZFlingViewDelegate {
            
            if delegate.respondsToSelector("flingView:didCancelChooseCarryingView:atFlingIndex:") {
                delegate.flingView!(self, didCancelChooseCarryingView: carryingView, atFlingIndex: carryingView.flingIndex)
            }
            
        }
    }
    
    func tellDelegateDidDrag(#carryingView:GZFlingCarryingView, contentOffset:CGPoint){
        
        if let delegate:GZFlingViewDelegate = self.delegate as? GZFlingViewDelegate {
            
            if delegate.respondsToSelector("flingView:didDragCarryingView:withContentOffset:") {
                delegate.flingView!(self, didDragCarryingView: carryingView, withContentOffset: contentOffset)
            }
            
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
            
            if PrivateInstance.arriveEnd && delegate.respondsToSelector("flingView:willArriveEndIndex:") {
                delegate.flingView!(self, willArriveEndIndex: index)
            }else if PrivateInstance.overEnd && delegate.respondsToSelector("flingView:didArriveEndIndex:") {
                delegate.flingView!(self, didArriveEndIndex: index)
            }else{
                if delegate.respondsToSelector("flingView:didShowCarryingView:atFlingIndex:") {
                    delegate.flingView!(self, didShowCarryingView: carryingView, atFlingIndex: index)
                }
            }
            
        }
        
    }
    
    func askDelegateForNeedShow(delegate:GZFlingViewDelegate, forCarryingView carryView:GZFlingCarryingView, atIndex index:Int){
        
        var selectorForCheck = Selector("flingView:shouldNeedShowCarryingViewAtFlingIndex:")
        
        if delegate.respondsToSelector(selectorForCheck) && delegate.flingView!(self, shouldNeedShowCarryingViewAtFlingIndex: index) {
            
            
            
            selectorForCheck = Selector("flingView:prepareCarryingView:atFlingIndex:")
            
            if delegate.respondsToSelector(selectorForCheck) {
                
                carryView.flingIndex = index
                
                carryView.prepareForShow()
                
                self.tellDelegateWillShow(carryingView: carryView, atFlingIndex: index)
                
                delegate.flingView!(self, prepareCarryingView: carryView, atFlingIndex: index)
                
            }
            
        }else{
            
            carryView.flingIndex = index
            carryView.reset()
            
        }
        
    }

}

//MARK: - Private Instance Extension for Store Private Info
extension GZFlingView {
    
    private struct PrivateInstance {
        static var beginLocation:CGPoint?
        static var counter:Int = 0
        
        static var clockwise:CGFloat = -1
        static var direction:GZFlingViewSwipingDirection = .Undefined
        
        static var predictEndIndex = 0
        
        static var topIndex:Int = -1
        
        static var translation:CGPoint = CGPointZero
        
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
            PrivateInstance.translation = CGPointZero
        }
        
    }
    
}


//MARK:- Delegate Methods Declare
@objc public protocol GZFlingViewDelegate : NSObjectProtocol {
    optional func flingView(flingView:GZFlingView, willChooseCarryingView carryingView:GZFlingCarryingView, atFlingIndex index:Int)->Void
    optional func flingView(flingView:GZFlingView, didChooseCarryingView carryingView:GZFlingCarryingView, atFlingIndex index:Int)->Void
    
    optional func flingView(flingView:GZFlingView, willCancelChooseCarryingView carryingView:GZFlingCarryingView, atFlingIndex index:Int)->Void
    optional func flingView(flingView:GZFlingView, didCancelChooseCarryingView carryingView:GZFlingCarryingView, atFlingIndex index:Int)->Void
    
    optional func flingView(flingView:GZFlingView, shouldNeedShowCarryingViewAtFlingIndex index:Int)->Bool
    optional func flingView(flingView:GZFlingView, prepareCarryingView carryingView:GZFlingCarryingView, atFlingIndex index:Int)->Void
    
    optional func flingView(flingView:GZFlingView, willShowCarryingView carryingView:GZFlingCarryingView, atFlingIndex index:Int)->Void
    optional func flingView(flingView:GZFlingView, didShowCarryingView carryingView:GZFlingCarryingView, atFlingIndex index:Int)->Void
    
    optional func flingView(flingView:GZFlingView, didDragCarryingView carryingView:GZFlingCarryingView, withContentOffset contentOffset:CGPoint)->Void
    
    optional func flingViewWillEndDragging(flingView:GZFlingView, withDraggingCarryingView carryingView:GZFlingCarryingView) -> Void
    optional func flingViewDidEndDragging(flingView:GZFlingView, withDraggingCarryingView carryingView:GZFlingCarryingView) -> Void
    
    optional func flingView(flingView:GZFlingView, willArriveEndIndex index:Int)->Void
    optional func flingView(flingView:GZFlingView, didArriveEndIndex index:Int)->Void
    
}

//MARK:- Datasource Methods Declare

@objc public protocol GZFlingViewDatasource : NSObjectProtocol{
    func numberOfCarryingViewsForReusingInFlingView(flingView:GZFlingView) -> Int
    func flingView(flingView:GZFlingView, carryingViewForReusingAtIndex reuseIndex:Int) -> GZFlingCarryingView
}

