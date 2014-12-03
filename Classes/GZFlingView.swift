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
            return self.reusedNodesQueue.frontNode?.carryingView //self.reusedNodesQueue.currentNode?.carryingView
        }
    }
    
    /**
        (readonly)
    */
    public var nextCarryingView : GZFlingCarryingView!{
        get{
            return self.reusedNodesQueue.currentNode?.nextNode?.carryingView
        }
    }
    
    /**
        (readonly)
    */
    public var direction:GZFlingViewSwipingDirection{
        get{
            return self.privateInstance.direction
        }
    }
    
    public var panGestureRecognizer:UIPanGestureRecognizer{
        return self.privateInstance.panGestureRecognizer
    }
    
    @IBOutlet public weak var dataSource: AnyObject?
    @IBOutlet public weak var delegate: AnyObject?
    
    public var isEnded:Bool{
        get{
            return self.privateInstance.arriveEnd(currentNode: self.reusedNodesQueue.frontNode!) || self.privateInstance.overEnd(currentNode: self.reusedNodesQueue.frontNode!)
        }
    }
    
    public var contentOffset:CGPoint{
        
        get{
            return self.privateInstance.translation
        }
    }
    
    public var animation:GZFlingViewAnimation = GZFlingViewAnimationTinder()

    private var reusedNodesQueue = GZFlingNodesQueue()
    private var privateInstance = PrivateInstance()
    
    var countOfCarryingViews:Int{
        return self.reusedNodesQueue.size
    }
    
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
        
        self.animation.beginLocation = self.bounds.center
        
        if self.reusedNodesQueue.size == 0 {
            
            self.reloadData()
            
        }
        
    }

    //FIXME: when add subview and setting autolayout, it'll be crashed on iOS7.
    
    override public func layoutSublayersOfLayer(layer: CALayer!) {
        
        if SYSTEM_VERSION_LESS_THAN("8.0"){
            self.layoutSubviews()
        }
        
        super.layoutSublayersOfLayer(layer)
    }
    
    
    public func choose(direction:GZFlingViewSwipingDirection, completionHandler:((finished:Bool) -> Void)?){
        
        if self.privateInstance.overEnd(atIndex: self.reusedNodesQueue.frontNode!.flingIndex) || self.topCarryingView == nil  {
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
        
        self.privateInstance.direction = direction
        self.showChoosenAnimation(direction, translation: translation!, completionHandelr: completionHandler!)
        
    }
    
    
    public func reloadData(){
        
        if self.dataSource == nil {
            return
        }
        
        self.privateInstance.reset()
        self.reusedNodesQueue.reset()
        
        var numberOfCarryingViews:Int = (self.dataSource?.numberOfCarryingViewsForReusingInFlingView(self)) ?? 0
        
        for index in 0 ..< numberOfCarryingViews {
            
            if let carryingView = self.dataSource?.carryingViewForReusingAtIndexInFlingView(self, carryingViewForReusingAtIndex: index) {

                self.addSubview(carryingView)
                
                carryingView.frame = self.bounds
                carryingView.flingIndex = index
                carryingView.flingView = self
                carryingView.alpha = 0.0
                
                var node = GZFlingNode(carryingView: carryingView)
                self.reusedNodesQueue += node
                
                self.askDatasourceShouldNeedShow(forNode: node, atIndex: index)
                
            }
            
        }
        
        self.askDatasourceShouldEnd(atIndex: numberOfCarryingViews)
        self.privateInstance.counter = numberOfCarryingViews

        
        if !self.isEnded {
            
            self.animation.willAppear(node: self.reusedNodesQueue.frontNode!)
            self.animation.didAppear(node: self.reusedNodesQueue.frontNode!)
            
            
            self.tellDelegateWillShow(node: self.reusedNodesQueue.frontNode, atFlingIndex: self.reusedNodesQueue.frontNode!.flingIndex)
            self.tellDelegateDidShow(node: self.reusedNodesQueue.frontNode, atFlingIndex: self.reusedNodesQueue.frontNode!.flingIndex)
            
        }
        
        
        
        
        
    }
    
    // MARK: - Private Methods
    
    func initialize(){
        self.prepareGestures()
        self.animation.flingView = self
    }
    
    
    func prepareGestures(){
        self.panGestureRecognizer.addTarget(self, action: "viewDidPan:")
        self.panGestureRecognizer.delegate = self
        self.addGestureRecognizer(panGestureRecognizer)
    }

    
    func showChoosenAnimation(direction:GZFlingViewSwipingDirection, translation:CGPoint,completionHandelr:((finished:Bool) -> Void) = {(finished:Bool)->Void in }){
        
        var currentNode = self.reusedNodesQueue.currentNode
        var nextNode = currentNode.nextNode
        
        self.tellDelegateWillShow(node: currentNode.nextNode, atFlingIndex: nextNode.flingIndex)
        
        var velocity = self.panGestureRecognizer.velocityInView(self)
        
        if CGPointEqualToPoint(velocity, CGPointZero) {
            self.animation.willAppear(node: currentNode)
        }

        
        println("weakSelf.privateInstance.counter:\(self.privateInstance.counter)")
        
        self.animation.showChoosenAnimation(direction: direction, currentNode:currentNode, translation: translation, completionHandler: {[weak self] (finished) -> Void in

            var weakSelf = self!
            weakSelf.tellDelegateDidChoose(node: currentNode)
            
            weakSelf.tellDelegateDidShow(node: nextNode, atFlingIndex: nextNode.flingIndex)
            
            
            if CGPointEqualToPoint(velocity, CGPointZero) {
                weakSelf.animation.didAppear(node: nextNode)
            }
            
            weakSelf.privateInstance.counter++
            weakSelf.askDatasourceShouldNeedShow(forNode: currentNode, atIndex: weakSelf.privateInstance.counter)
            
            
            
            completionHandelr(finished: finished)
            
        })
        
//        self.privateInstance.topIndex = nextCarryingView.flingIndex
        
        self.reusedNodesQueue.next()

    }
    
    func showCancelAnimation(direction:GZFlingViewSwipingDirection, translation:CGPoint){
        
        var topNode = self.reusedNodesQueue.frontNode!
        
        self.tellDelegateWillCancelChoosing(node: topNode)
        
        self.animation.showCancelAnimation(direction: direction, currentNode:topNode, translation: translation, completionHandler: {[weak self] (finished) -> Void in
            
            if let weakSelf = self {
                weakSelf.tellDelegateDidCancelChoosing(node: topNode)
            }
            

        })
        
    }
    
    
}

//MARK: - Gesture Support
extension GZFlingView : UIGestureRecognizerDelegate {
    
    func viewDidPan(gesture: UIPanGestureRecognizer){
        
        var translation = gesture.translationInView(self)
        self.privateInstance.translation = translation
        
        var topNode = self.reusedNodesQueue.frontNode!
        
        if gesture.state == .Changed {
            self.animation.gesturePanning(gesture: gesture, currentNode:topNode, translation: translation)
            self.tellDelegateDidDrag(node:topNode , contentOffset: translation)
        }
        else if gesture.state == .Ended && !self.privateInstance.overEnd(atIndex: topNode.flingIndex) {
            
            self.tellDelegateDidEndDragging(node: topNode)
            
            if translation.x > 0 {
                self.privateInstance.direction = GZFlingViewSwipingDirection.Right
            }else if translation.x <= 0 {
                self.privateInstance.direction = GZFlingViewSwipingDirection.Left
            }
            
            if self.animation.shouldCancel(direction: self.privateInstance.direction, currentNode:topNode, translation: translation){
                self.showCancelAnimation(self.direction, translation: translation)
            }else{
                
                self.showChoosenAnimation(self.direction, translation: translation, completionHandelr: { (finished) -> Void in
                    
                })
            }
            
        }
        
    }
    
    
    //MARK: Gesture Recognizer Delegate
    override public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        var should = self.reusedNodesQueue.size != 0 && !self.privateInstance.overEnd(atIndex: self.reusedNodesQueue.frontNode!.flingIndex)  && self.dataSource != nil
        
        if should {
            var frontNode = self.reusedNodesQueue.frontNode!
            self.animation.willBeginGesture(gesture: gestureRecognizer as UIPanGestureRecognizer, currentNode:frontNode)
            self.tellDelegateWillBeginDragging(node: frontNode)
//            self.tellDelegateWillBeginDragging(carryingView: self.topCarryingView)
        }
        
        
        return should
    }
}


//MARK: - Delegate Method Support
extension GZFlingView {
    
    func tellDelegateDidEndDragging(#node:GZFlingNode!){
    
        self.animation.didEndGesture(gesture: self.panGestureRecognizer, currentNode:node)
        
        if let delegateMethod = self.delegate?.flingViewDidEndDragging {
            delegateMethod(self, withDraggingCarryingView: node.carryingView)
        }
        
    }
    
    func tellDelegateWillCancelChoosing(#node:GZFlingNode!){
        
        if let delegateMethod = self.delegate?.flingViewWillCancelChoose {
            
            delegateMethod(self, willCancelChooseCarryingView: node.carryingView, atFlingIndex: node.flingIndex)
            
        }

    }
    
    func tellDelegateDidCancelChoosing(#node:GZFlingNode!){
        
        if let delegateMethod = self.delegate?.flingViewDidCancelChooseCarryingView {
            
            delegateMethod(self, didCancelChooseCarryingView: node.carryingView, atFlingIndex: node.flingIndex)

            
        }
        
    }
    
    func tellDelegateDidChoose(#node:GZFlingNode!){
        
        if let delegateMethod = self.delegate?.flingViewDidChooseCarryingView {
            
            delegateMethod(self, didChooseCarryingView: node.carryingView, atFlingIndex: node.flingIndex)
            
        }
        
        self.tellDelegateDidArriveOrOverEnd(atFlingIndex: node.flingIndex)

    }
    
    func tellDelegateWillBeginDragging(#node:GZFlingNode!){
        
        if let delegateMethod = self.delegate?.flingViewWillBeginDraggingCarryingView {
            delegateMethod(self, withCarryingView: node.carryingView)
        }
        
    }
    
    func tellDelegateDidDrag(#node:GZFlingNode!, contentOffset:CGPoint){
        
        
        if let delegateMethod = self.delegate?.flingViewDidDragCarryingView {
            delegateMethod(self, withDraggingCarryingView: node.carryingView, withContentOffset: contentOffset)
        }
        
    }
    
    
    func tellDelegateWillShow(#node:GZFlingNode!, atFlingIndex index:Int){
        
        if let delegateMethod = self.delegate?.flingViewWillShowCarryingView {
            delegateMethod(self, willShowCarryingView: node.carryingView, atFlingIndex: index)
            
        }
        
    }
    
    
    func tellDelegateDidArriveOrOverEnd(atFlingIndex index:Int){

        println("tellDelegateDidArriveOrOverEnd:\(index)")
        
        if self.privateInstance.arriveEnd(atIndex: index) {
            
            if let delegateMethod = self.delegate?.flingViewWillArriveEndIndex  {
                delegateMethod(self, atIndex: index)
            }
            
        }else if self.privateInstance.overEnd(atIndex: index) {
            
            if let delegateMethod = self.delegate?.flingViewDidArriveEndIndex {
                delegateMethod(self, atIndex: index)
            }
            
        }

    }
    
    func tellDelegateDidShow(#node:GZFlingNode!, atFlingIndex index:Int){
        
        if let delegateMethod = self.delegate?.flingViewDidShowCarryingView {
            delegateMethod(self, didShowCarryingView: node.carryingView, atFlingIndex: index)
        }
        
    }
    
    func askDatasourceShouldEnd(atIndex index:Int)->Bool{
        
        if self.privateInstance.predictEndIndex != -1 {
            return true
        }
        
        var shouldEnd = false
        
        if let shouldEndMethod = self.dataSource?.flingViewShouldEnd {
            
            shouldEnd = shouldEndMethod(self, atFlingIndex: index)
            
//            self.privateInstance.predictEndIndex = shouldEnd ? index : -1
            
        }
        
        
        if shouldEnd && self.privateInstance.predictEndIndex == -1 {
            self.privateInstance.predictEndIndex = index
        }
        println("index:\(index) result:\(shouldEnd)")
        
        return shouldEnd
        
    }
    
    func askDatasourceShouldNeedShow(forNode node:GZFlingNode!, atIndex index:Int){
        
        var carryingView = node.carryingView
        carryingView.flingIndex = index
        self.sendSubviewToBack(carryingView)
        
        if self.askDatasourceShouldEnd(atIndex: index) {
            return
        }
        
        println("node:\(node) self.privateInstance.endNode:\(self.privateInstance.predictEndIndex)")
        
        
        self.animation.prepare(node: node, reuseIndex: index)
        carryingView.prepareForReuse()
        
        carryingView.alpha = 1.0
        
        if let prepareMethod = self.dataSource?.flingViewPrepareCarryingView {
            prepareMethod(self, preparingCarryingView: carryingView, atFlingIndex: index)
        }
        
        
    }


}

//MARK: - Private Instance Extension for Store Private Info
//extension GZFlingView {
//    
//    
//}


private struct PrivateInstance {
    var beginLocation:CGPoint?
    var counter:Int = 0
    
    var clockwise:CGFloat = -1
    var direction:GZFlingViewSwipingDirection = .Undefined
    
//    var endNode:GZFlingNode?
    var predictEndIndex:Int = -1
    
    var translation:CGPoint = CGPointZero
    
    var panGestureRecognizer = UIPanGestureRecognizer()
    
    func overEnd(#currentNode:GZFlingNode)->Bool {
        return self.overEnd(atIndex: currentNode.flingIndex)
    }
    
    func overEnd(#atIndex:Int)->Bool {
        
        println("isoverEnd? atIndex:\(atIndex) self.predictEndIndex:\(self.predictEndIndex)")
        
        return self.predictEndIndex != -1 && atIndex > self.predictEndIndex
    }
    
    func arriveEnd(#currentNode:GZFlingNode)->Bool{
        return self.arriveEnd(atIndex: currentNode.flingIndex)
    }
    
    func arriveEnd(#atIndex:Int)->Bool{
        return self.predictEndIndex != -1 && atIndex == self.predictEndIndex
    }
    
    
    
    mutating func reset(){
        println("reset!")
        self.predictEndIndex = -1
        self.counter = 0
        self.translation = CGPointZero
    }
    
    init(){
        
    }
    
}

//MARK:- Delegate Methods Declare
@objc public protocol GZFlingViewDelegate : NSObjectProtocol {
    optional func flingViewWillChooseCarryingView(flingView:GZFlingView, willChooseCarryingView carryingView:GZFlingCarryingView, atFlingIndex index:Int)->Void
    optional func flingViewDidChooseCarryingView(flingView:GZFlingView, didChooseCarryingView carryingView:GZFlingCarryingView, atFlingIndex index:Int)->Void
    
    optional func flingViewWillCancelChoose(flingView:GZFlingView, willCancelChooseCarryingView carryingView:GZFlingCarryingView, atFlingIndex index:Int)->Void
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

