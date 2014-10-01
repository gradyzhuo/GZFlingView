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
            return self.nodesQueue.currentNode?.carryingView
        }
    }
    
    /**
        (readonly)
    */
    public var nextCarryingView : GZFlingCarryingView!{
        get{
            return self.nodesQueue.currentNode?.nextNode?.carryingView
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
    
    public var carryingViews:[GZFlingCarryingView]{
        get{
            
            
            
            return []
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
    
    public var animation:GZFlingViewAnimation = GZFlingViewAnimationTinder()
    private var nodesQueue = GZFlingNodesQueue()
    
    
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
        
//        PrivateInstance.beginLocation = self.bounds.center
        self.animation.beginLocation = self.bounds.center
        
        if self.nodesQueue.size == 0 {
            
            self.reloadData()
            
        }
        
    }

    //FMIXME: when add subview and setting autolayout, it'll be crash on iOS7.
    
    override public func layoutSublayersOfLayer(layer: CALayer!) {
        
        self.layoutSubviews()
        super.layoutSublayersOfLayer(layer)
    }
    
    
    public func nextCarryingView(fromCarryingView carryingView:GZFlingCarryingView) -> GZFlingCarryingView? {
        var node = self.nodeByCarryingView(carryingView)
        return node?.nextNode.carryingView
    }
    
    public func choose(direction:GZFlingViewSwipingDirection){
        
        if PrivateInstance.overEnd  {
            return
        }
        
        var translation:CGPoint?
        switch direction {
            
        case .Left:
            translation = CGPoint(x: -100, y: 0)
            
        case .Right:
            translation = CGPoint(x: 100, y: -0)
        
//        case .Top:
//            translation = CGPoint(x: 0, y: -100)
//        
//        case .Bottom:
//            translation = CGPoint(x: 0, y: 100)
            
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
                
                self.animation.prepare(carryingView: carryingView, reuseIndex: index)
                self.askDatasourceForNeedShow(forCarryingView: carryingView, atIndex: index)
                
                
                self.nodesQueue += GZFlingNode(carryingView: carryingView)
                
            }
            
            PrivateInstance.counter++
            
        }
        
        if numberOfCarryingViews > 0 {
            self.tellDelegateWillShow(carryingView: self.nodesQueue.frontNode.carryingView, atFlingIndex: 0)
            self.tellDelegateDidShow(carryingView: self.nodesQueue.frontNode.carryingView, atFlingIndex: 0)
        }
        
        
        
    }
    
    // MARK: - Private Methods
    
    func initialize(){
        self.prepareGestures()
        self.animation.flingView = self
    }
    
    
    func prepareGestures(){
        var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "viewDidPan:")
        panGestureRecognizer.delegate = self
        self.addGestureRecognizer(panGestureRecognizer)
    }
    
    private func nodeByCarryingView(carryingView:GZFlingCarryingView) -> GZFlingNode?{
        var resultNode:GZFlingNode? = nil
        self.nodesQueue.enumerateObjectsUsingBlock { (node:GZFlingNode, idx, isEnded) -> Void in
            if node.carryingView == carryingView {
                resultNode = node
            }
        }
        return resultNode
    }
    
    func showChoosenAnimation(direction:GZFlingViewSwipingDirection, translation:CGPoint){
        
        var currentCarryingView = (self.nodesQueue.currentNode?.carryingView)!
        var nextCarryingView = self.nodesQueue.currentNode.nextNode.carryingView
        
        
        self.tellDelegateWillShow(carryingView: nextCarryingView, atFlingIndex: nextCarryingView.flingIndex)

        self.animation.showChoosenAnimation(direction: direction, translation: translation, completionHandler: {[weak self] (finished) -> Void in
            
            var weakSelf = self!
            
            weakSelf.tellDelegateDidChooseCarryingView(carryingView: currentCarryingView)
            
            weakSelf.askDatasourceForNeedShow(forCarryingView: currentCarryingView, atIndex: PrivateInstance.counter)
            weakSelf.animation.reset(currentCarryingView: currentCarryingView)
            
            weakSelf.tellDelegateDidShow(carryingView: nextCarryingView, atFlingIndex: nextCarryingView.flingIndex)
            
            
            
//
            
            PrivateInstance.counter++
        })
        
        PrivateInstance.topIndex = nextCarryingView.flingIndex
        
        self.nodesQueue.next()
        
//        PrivateInstance.topIndex = 
        
        

    }
    
    func showCancelAnimation(direction:GZFlingViewSwipingDirection, translation:CGPoint){
        
        self.tellDelegateWillCancelChoosingCarryingView(carryingView: self.topCarryingView)
        
        self.animation.showCancelAnimation(direction: direction, translation: translation, completionHandler: {[weak self] (finished) -> Void in
            
            self!.animation.reset()
            
            self!.tellDelegateDidCancelChoosingCarryingView(carryingView: self!.topCarryingView)
        })
        
//        var time = NSTimeInterval(0.4)
//        var velocity = translation.velocityByTimeInterval(time)/15
//        
//        UIView.animateWithDuration(time, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: UIViewAnimationOptions.AllowAnimatedContent | UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.BeginFromCurrentState | UIViewAnimationOptions.CurveEaseInOut , animations: {[weak self] () -> Void in
//            
//            self!.swipingAnimationType.animation.cancelAnimation(flingView:self!, carryingView: self!.topCarryingView, beginLocation: beginLocation)
//            
//            }, completion: {[weak self] (finished:Bool)->Void in
//
//                
//                self!.tellDelegateDidCancelChoosingCarryingView(carryingView: self!.topCarryingView)
//                
//                
//        })
    }
    
    
}

//MARK: - Gesture Support
extension GZFlingView : UIGestureRecognizerDelegate {
    
    func viewDidPan(gesture: UIPanGestureRecognizer){
        
        var translation = gesture.translationInView(self)
        PrivateInstance.translation = translation

        if gesture.state == .Ended {
            
            PrivateInstance.direction = GZFlingViewSwipingDirection(rawValue: Int(translation.x > 0))
            
            if self.animation.shouldCancel(direction: PrivateInstance.direction, translation: translation){
                self.showCancelAnimation(self.direction, translation: translation)
            }else{
                self.showChoosenAnimation(self.direction, translation: translation)
            }
            
        }else if gesture.state == .Changed {
            
            self.animation.gesturePanning(carryingView: self.topCarryingView, translation: translation)
            self.tellDelegateDidDrag(carryingView: self.topCarryingView, contentOffset: translation)

        }
        
    }
    
    
    //MARK: Gesture Recognizer Delegate
    override public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.nodesQueue.size != 0 && !PrivateInstance.overEnd  && self.dataSource != nil
    }
}


//MARK: - Delegate Method Support
extension GZFlingView {
    
    func tellDelegateDidEndDragging(#carryingView:GZFlingCarryingView){
        
        if let delegateMethod = self.delegate?.flingViewDidEndDragging {
            delegateMethod(self, withDraggingCarryingView: carryingView)
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
    
    func tellDelegateDidChooseCarryingView(#carryingView:GZFlingCarryingView){
        if let delegate : GZFlingViewDelegate = self.delegate as? GZFlingViewDelegate {
            

            if delegate.respondsToSelector("flingView:didChooseCarryingView:atFlingIndex:") {
                delegate.flingView!(self, didChooseCarryingView: carryingView, atFlingIndex: carryingView.flingIndex)
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
        
        if self.isEnded {
            return
        }
        
        if let delegateObject: AnyObject = self.delegate {
            
            var delegate = delegateObject as GZFlingViewDelegate
            
            if delegate.respondsToSelector("flingView:willShowCarryingView:atFlingIndex:") {
                delegate.flingView!(self, willShowCarryingView: carryingView, atFlingIndex: index)
            }
            
        }
        
    }
    
    func tellDelegateDidShow(#carryingView:GZFlingCarryingView, atFlingIndex index:Int){
        
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
    
    
    
    func askDatasourceForNeedShow(forCarryingView carryView:GZFlingCarryingView, atIndex index:Int){
        
        if let dataSource : GZFlingViewDatasource = self.dataSource as? GZFlingViewDatasource {
            
            if dataSource.respondsToSelector("flingView:shouldNeedShowCarryingViewAtFlingIndex:") && dataSource.flingView!(self, shouldNeedShowCarryingViewAtFlingIndex: index) {
                
                
                if dataSource.respondsToSelector("flingView:prepareCarryingView:atFlingIndex:") {
                    
                    carryView.flingIndex = index
                    
                    carryView.prepareForShow()
                    
                    dataSource.flingView!(self, prepareCarryingView: carryView, atFlingIndex: index)
                    
                    PrivateInstance.predictEndIndex = index
                    
                }
                
            }else{
                
                carryView.flingIndex = index
                carryView.reset()
                
            }

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
    
    optional func flingView(flingView:GZFlingView, shouldNeedShowCarryingViewAtFlingIndex index:Int)->Bool
    optional func flingView(flingView:GZFlingView, prepareCarryingView carryingView:GZFlingCarryingView, atFlingIndex index:Int)->Void
}

