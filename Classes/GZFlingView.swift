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
    public  var topCarryingView : GZFlingCarryingView?{
        get{
            return self.nodesQueue.frontNode?.carryingView //self.nodesQueue.currentNode?.carryingView
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
    
    public var panGestureRecognizer:UIPanGestureRecognizer{
        return PrivateInstance.panGestureRecognizer
    }
    
    @IBOutlet public weak var dataSource: AnyObject?
    @IBOutlet public weak var delegate: AnyObject?
    
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

//    //FMIXME: when add subview and setting autolayout, it'll be crash on iOS7.
//    
//    override public func layoutSublayersOfLayer(layer: CALayer!) {
//        
//        self.layoutSubviews()
//        super.layoutSublayersOfLayer(layer)
//    }
    
    
    public func nextCarryingView(fromCarryingView carryingView:GZFlingCarryingView) -> GZFlingCarryingView? {
        var node = self.nodeByCarryingView(carryingView)
        return node?.nextNode.carryingView
    }
    
    public func choose(direction:GZFlingViewSwipingDirection, completionHandelr:((finished:Bool) -> Void)?){
        
        if PrivateInstance.overEnd || self.topCarryingView == nil  {
            return
        }
        
        var translation:CGPoint?
        switch direction {
            
        case .Left:
            translation = CGPoint(x: -200, y: 0)
            
        case .Right:
            translation = CGPoint(x: 200, y: -0)
        
//        case .Top:
//            translation = CGPoint(x: 0, y: -100)
//        
//        case .Bottom:
//            translation = CGPoint(x: 0, y: 100)
            
        case .Undefined:
            translation = CGPoint(x: 0, y: 0)
            
        }
        
        PrivateInstance.direction = direction
        self.showChoosenAnimation(direction, translation: translation!, completionHandelr: completionHandelr)
        
    }
    
    
    public func reloadData(){
        
        if self.dataSource == nil {
            return
        }
        
        PrivateInstance.reset()
        self.nodesQueue.reset()
        
        var numberOfCarryingViews:Int = self.dataSource!.numberOfCarryingViewsForReusingInFlingView(self)
        
        for index in 0..<numberOfCarryingViews {
            
            if let carryingView = self.dataSource?.carryingViewForReusingAtIndexInFlingView(self, carryingViewForReusingAtIndex: index) {
                

                if self.askDatasourceShouldEnd(atIndex: index) && index == 0{
                    break
                }
                
                
                self.addSubview(carryingView)
                
                carryingView.frame = self.bounds
                carryingView.flingIndex = index
                carryingView.flingView = self
                carryingView.layer.shouldRasterize = true
                
                self.askDatasourceForNeedShow(forCarryingView: carryingView, atIndex: index)
                self.nodesQueue += GZFlingNode(carryingView: carryingView)
                
                PrivateInstance.counter++
                
            }
            
        }
        
        if self.nodesQueue.size > 0 {
            
            self.animation.willAppear(carryingView: self.topCarryingView)
            self.animation.didAppear(carryingView: self.topCarryingView)
            
            
            self.tellDelegateWillShow(carryingView: self.topCarryingView, atFlingIndex: 0)
            self.tellDelegateDidShow(carryingView: self.topCarryingView, atFlingIndex: 0)
            
        }
        
        
        
        
        
    }
    
    // MARK: - Private Methods
    
    func initialize(){
        self.prepareGestures()
        self.animation.flingView = self
        self.animation.nodesQueue = self.nodesQueue
    }
    
    
    func prepareGestures(){
        self.panGestureRecognizer.addTarget(self, action: "viewDidPan:")
        self.panGestureRecognizer.delegate = self
        self.addGestureRecognizer(panGestureRecognizer)
    }
    
    private func nodeByCarryingView(carryingView:GZFlingCarryingView) -> GZFlingNode?{
        var resultNode:GZFlingNode? = nil
        self.nodesQueue.enumerateObjectsUsingBlock { (node:GZFlingNode, idx, isEnded:UnsafeMutablePointer<Bool>) -> Void in
            if node.carryingView == carryingView {
                resultNode = node
                isEnded.memory = true
            }
        }
        return resultNode
    }
    
    func showChoosenAnimation(direction:GZFlingViewSwipingDirection, translation:CGPoint,completionHandelr:((finished:Bool) -> Void)?){
        
        var currentCarryingView = (self.nodesQueue.currentNode?.carryingView)!
        var nextCarryingView = self.nodesQueue.currentNode.nextNode.carryingView
        
        self.tellDelegateWillShow(carryingView: nextCarryingView, atFlingIndex: nextCarryingView.flingIndex)
        
        var velocity = self.panGestureRecognizer.velocityInView(self)
        
        if CGPointEqualToPoint(velocity, CGPointZero) {
            self.animation.willAppear(carryingView: nextCarryingView)
        }
        
        self.animation.showChoosenAnimation(direction: direction, translation: translation, completionHandler: {[weak self] (finished) -> Void in
            
            if let weakSelf = self {
                
                weakSelf.tellDelegateDidChooseCarryingView(carryingView: currentCarryingView)
                
                if !weakSelf.askDatasourceShouldEnd(atIndex: PrivateInstance.counter) {
                    weakSelf.askDatasourceForNeedShow(forCarryingView: currentCarryingView, atIndex: PrivateInstance.counter)
                    weakSelf.tellDelegateDidShow(carryingView: nextCarryingView, atFlingIndex: nextCarryingView.flingIndex)
                }
                
                
                
                
                if CGPointEqualToPoint(velocity, CGPointZero) {
                    weakSelf.animation.didAppear(carryingView: nextCarryingView)
                }
                
                PrivateInstance.counter++
                
                if let handler = completionHandelr {
                    handler(finished: finished)
                }

            }
            
            
        })
        
        PrivateInstance.topIndex = nextCarryingView.flingIndex
        
        self.nodesQueue.next()

        
        

    }
    
    func showCancelAnimation(direction:GZFlingViewSwipingDirection, translation:CGPoint){
        
        self.tellDelegateWillCancelChoosingCarryingView(carryingView: self.topCarryingView)
        
        self.animation.showCancelAnimation(direction: direction, translation: translation, completionHandler: {[weak self] (finished) -> Void in
            
            if let weakSelf = self{
                weakSelf.tellDelegateDidCancelChoosingCarryingView(carryingView: weakSelf.topCarryingView)
            }
            
        })
        
    }
    
    
}

//MARK: - Gesture Support
extension GZFlingView : UIGestureRecognizerDelegate {
    
    func viewDidPan(gesture: UIPanGestureRecognizer){
        
        var translation = gesture.translationInView(self)
        PrivateInstance.translation = translation
        
        
        if gesture.state == .Changed {
            self.animation.gesturePanning(gesture: gesture, translation: translation)
            
            self.tellDelegateDidDrag(carryingView: self.topCarryingView, contentOffset: translation)
        }
        else if gesture.state == .Ended && !PrivateInstance.overEnd {
            
            self.tellDelegateDidEndDragging(carryingView: self.topCarryingView)
            
            if translation.x > 0 {
                PrivateInstance.direction = GZFlingViewSwipingDirection.Right
            }else if translation.x <= 0 {
                PrivateInstance.direction = GZFlingViewSwipingDirection.Left
            }
            
            if self.animation.shouldCancel(direction: PrivateInstance.direction, translation: translation){
                self.showCancelAnimation(self.direction, translation: translation)
            }else{
                self.showChoosenAnimation(self.direction, translation: translation, completionHandelr: nil)
            }
            
        }
        
    }
    
    
    //MARK: Gesture Recognizer Delegate
    override public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        var should = self.nodesQueue.size != 0 && !PrivateInstance.overEnd  && self.dataSource != nil
        
        if should {
            self.animation.willBeginGesture(gesture: gestureRecognizer as UIPanGestureRecognizer)
            self.tellDelegateWillBeginDragging(carryingView: self.topCarryingView)
        }
        
        
        return should
    }
}


//MARK: - Delegate Method Support
extension GZFlingView {
    
    func tellDelegateDidEndDragging(#carryingView:GZFlingCarryingView!){
    
        self.animation.didEndGesture(gesture: self.panGestureRecognizer)
        
        if let delegateMethod = self.delegate?.flingViewDidEndDragging {
            delegateMethod(self, withDraggingCarryingView: carryingView)
        }
        
    }
    
    func tellDelegateWillCancelChoosingCarryingView(#carryingView:GZFlingCarryingView!){
        
        if let delegateMethod = self.delegate?.flingViewWillCancelChooseCarryingView {
            
            delegateMethod(self, willCancelChooseCarryingView: carryingView, atFlingIndex: carryingView.flingIndex)
            
        }

    }
    
    func tellDelegateDidCancelChoosingCarryingView(#carryingView:GZFlingCarryingView!){
        
        if let delegateMethod = self.delegate?.flingViewDidCancelChooseCarryingView {
            
            delegateMethod(self, didCancelChooseCarryingView: carryingView, atFlingIndex: carryingView.flingIndex)

            
        }
        
    }
    
    func tellDelegateDidChooseCarryingView(#carryingView:GZFlingCarryingView!){
        
        if let delegateMethod = self.delegate?.flingViewDidChooseCarryingView {
            
            delegateMethod(self, didChooseCarryingView: carryingView, atFlingIndex: carryingView.flingIndex)
            
        }

    }
    
    func tellDelegateWillBeginDragging(#carryingView:GZFlingCarryingView!){
        
        if let delegateMethod = self.delegate?.flingViewWillBeginDraggingCarryingView {
            delegateMethod(self, withCarryingView: carryingView)
        }
        
    }
    
    func tellDelegateDidDrag(#carryingView:GZFlingCarryingView!, contentOffset:CGPoint){
        
        
        if let delegateMethod = self.delegate?.flingViewDidDragCarryingView {
            delegateMethod(self, withDraggingCarryingView: carryingView, withContentOffset: contentOffset)
        }
        
    }
    
    func tellDelegateWillShow(#carryingView:GZFlingCarryingView!, atFlingIndex index:Int){
        
        if self.isEnded {
            return
        }
        
        if let delegateMethod = self.delegate?.flingViewWillShowCarryingView {
            delegateMethod(self, willShowCarryingView: carryingView, atFlingIndex: index)
            
        }
        

        
    }
    
    func shouldTellDelegateDidArriveOrOverEnd(atFlingIndex index:Int)->Bool{
        var didArriveEnd = false
        
        if PrivateInstance.arriveEnd {
            
            didArriveEnd = true
            
            if let delegateMethod = self.delegate?.flingViewWillArriveEndIndex  {
                delegateMethod(self, atIndex: index)
            }
            
        }else if PrivateInstance.overEnd {
            
            didArriveEnd = true
            
            if let delegateMethod = self.delegate?.flingViewDidArriveEndIndex {
                delegateMethod(self, atIndex: index)
            }
            
        }
        return didArriveEnd
    }
    
    func tellDelegateDidShow(#carryingView:GZFlingCarryingView!, atFlingIndex index:Int){
        
        if !self.shouldTellDelegateDidArriveOrOverEnd(atFlingIndex: index){
            if let delegateMethod = self.delegate?.flingViewDidShowCarryingView {
                delegateMethod(self, didShowCarryingView: carryingView, atFlingIndex: index)
            }
        }
        
    }
    
    func askDatasourceShouldEnd(atIndex index:Int)->Bool{
        
        var shouldEnd = false
        
        if let shouldEndMethod = self.dataSource?.flingViewShouldEnd {
            
            shouldEnd = shouldEndMethod(self, atFlingIndex: index)
            
            PrivateInstance.predictEndIndex = shouldEnd ? PrivateInstance.predictEndIndex : index
            
        }
        
        return shouldEnd
        
    }
    
    func askDatasourceForNeedShow(forCarryingView carryingView:GZFlingCarryingView!, atIndex index:Int){
        
        self.sendSubviewToBack(carryingView)
        
        carryingView.flingIndex = index
        
        self.animation.prepare(carryingView: carryingView, reuseIndex: index)
        
        carryingView.alpha = 1.0
        carryingView.prepareForReuse()
        
        
        if let prepareMethod = self.dataSource?.flingViewPrepareCarryingView {
            prepareMethod(self, preparingCarryingView: carryingView, atFlingIndex: index)
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
        
        static var panGestureRecognizer = UIPanGestureRecognizer()
        
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
    optional func flingViewWillChooseCarryingView(flingView:GZFlingView, willChooseCarryingView carryingView:GZFlingCarryingView, atFlingIndex index:Int)->Void
    optional func flingViewDidChooseCarryingView(flingView:GZFlingView, didChooseCarryingView carryingView:GZFlingCarryingView, atFlingIndex index:Int)->Void
    
    optional func flingViewWillCancelChooseCarryingView(flingView:GZFlingView, willCancelChooseCarryingView carryingView:GZFlingCarryingView, atFlingIndex index:Int)->Void
    optional func flingViewDidCancelChooseCarryingView(flingView:GZFlingView, didCancelChooseCarryingView carryingView:GZFlingCarryingView, atFlingIndex index:Int)->Void
    
    
    optional func flingViewWillShowCarryingView(flingView:GZFlingView, willShowCarryingView carryingView:GZFlingCarryingView, atFlingIndex index:Int)->Void
    optional func flingViewDidShowCarryingView(flingView:GZFlingView, didShowCarryingView carryingView:GZFlingCarryingView, atFlingIndex index:Int)->Void
    
    optional func flingViewWillBeginDraggingCarryingView(flingView:GZFlingView, withCarryingView carryingView:GZFlingCarryingView)->Void
    optional func flingViewDidDragCarryingView(flingView:GZFlingView, withDraggingCarryingView carryingView:GZFlingCarryingView, withContentOffset contentOffset:CGPoint)->Void
    
    optional func flingViewWillEndDragging(flingView:GZFlingView, withDraggingCarryingView carryingView:GZFlingCarryingView) -> Void
    optional func flingViewDidEndDragging(flingView:GZFlingView, withDraggingCarryingView carryingView:GZFlingCarryingView) -> Void
    
    optional func flingViewWillArriveEndIndex(flingView:GZFlingView, atIndex index:Int)->Void
    optional func flingViewDidArriveEndIndex(flingView:GZFlingView, atIndex index:Int)->Void
    
}

//MARK:- Datasource Methods Declare

@objc public protocol GZFlingViewDatasource : NSObjectProtocol{
    func numberOfCarryingViewsForReusingInFlingView(flingView:GZFlingView) -> Int
    func carryingViewForReusingAtIndexInFlingView(flingView:GZFlingView, carryingViewForReusingAtIndex reuseIndex:Int) -> GZFlingCarryingView
    
    optional func flingViewShouldEnd(flingView:GZFlingView, atFlingIndex index:Int)->Bool
    optional func flingViewPrepareCarryingView(flingView:GZFlingView, preparingCarryingView carryingView:GZFlingCarryingView, atFlingIndex index:Int)->Void
}

