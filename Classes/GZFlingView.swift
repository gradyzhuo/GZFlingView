//
//  GZFlingChooseView.swift
//  GZKit
//
//  Created by Grady Zhuo on 2014/9/14.
//  Copyright (c) 2014年 Grady Zhuo. All rights reserved.
//

import UIKit

public enum GZFlingViewSwipingDirection:Int{
    
    case Left = -1
    case Right = 1
    case Undefined = 2
    
    public var description:String{
        get{
            
            switch self {
            case .Left: return "Left"
            case .Right: return "Right"
            case .Undefined: return "Undefined"
            }
            
        }
    }
    
}

public class GZFlingView: UIView {
 
    private let kGZFlingViewReusePoolReservedSize = 3
    
    //MARK: - Properties Declare
    
    /**
        (readonly)
    */
    public  var topCarryingView : GZFlingCarryingView!{
        get{
            return self.visibleNodesQueue.frontNode?.carryingView//self.reusedNodesQueue.frontNode?.carryingView //self.reusedNodesQueue.currentNode?.carryingView
        }
    }
    
    /**
        (readonly)
    */
    public var nextCarryingView : GZFlingCarryingView!{
        get{
            return self.visibleNodesQueue.currentNode?.nextNode?.carryingView
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
    
    @IBOutlet public var dataSource: GZFlingViewDatasource!{
        didSet{
            
            if dataSource != nil {
                self.reloadData(needLayout: false)
            }

        }
    }
    @IBOutlet public var delegate: GZFlingViewDelegate!
    
    public var isEnded:Bool{
        get{
            //檢查現在的Node，如果nil就代表結束了
            return self.visibleNodesQueue.currentNode == nil
        }
    }
    
    public var contentOffset:CGPoint{
        
        get{
            return self.privateInstance.translation
        }
    }
    
    public var animation:GZFlingViewAnimation = GZFlingViewAnimationTinder()
    private var privateInstance = PrivateInstance()
    
    //MARK: - V2.0 改版
    //MARK: 為了做一個Pool 去 reuse
    private var reusedNodesPool = GZFlingNodesQueue()
    //MARK: 現在畫面中在進行的Queue
    private var visibleNodesQueue = GZFlingNodesQueue()
    private var isLayouted:Bool = false
    
    //MARK: -
    
    
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
        
        self.relayout()
        
    }

    //FIXME: when add subview and setting autolayout, it'll be crashed on iOS7.
    
    override public func layoutSublayersOfLayer(layer: CALayer!) {
        
//        if SYSTEM_VERSION_LESS_THAN("8.0"){
//            self.layoutSubviews()
//        }
        
        super.layoutSublayersOfLayer(layer)
    }
    
    
    public func choose(direction:GZFlingViewSwipingDirection, completionHandler:(finished:Bool) -> Void = {(finished:Bool) -> Void in return}) {
        
        if self.isEnded {
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
        self.showChoosenAnimation(direction, translation: translation!, completionHandelr: completionHandler)
        
    }
    
    
    public func reloadData(){
        self.reloadData(needLayout:true)
    }
    
    func prepareGestures(){
        self.panGestureRecognizer.addTarget(self, action: "viewDidPan:")
        self.panGestureRecognizer.delegate = self
        self.addGestureRecognizer(panGestureRecognizer)
    }

    
    func showChoosenAnimation(direction:GZFlingViewSwipingDirection, translation:CGPoint,completionHandelr:(finished:Bool) -> Void){
        
        /**/
        var currentNode:GZFlingNode! = nil
        if self.visibleNodesQueue.size != 0 {
            currentNode = self.visibleNodesQueue.pop()
        }
        
        //馬上回收
        self.reusedNodesPool.push(node: currentNode)
        
        /**/
        
        var nextNode = self.visibleNodesQueue.currentNode
        
        self.tellDelegateWillShow(node: nextNode)

        var velocity = self.panGestureRecognizer.translationInView(self)
        
        if CGPointEqualToPoint(velocity, CGPointZero) {
            self.animation.willAppear(node: nextNode)
        }

        self.animation.showChoosenAnimation(direction: direction, currentNode:currentNode, translation: translation, completionHandler: {[weak self] (finished) -> Void in

            currentNode.carryingView.removeFromSuperview()
            
            if let weakSelf = self {
                
                if weakSelf.isEnded {
                    return
                }
                
                weakSelf.tellDelegateDidChoose(node: currentNode)
                weakSelf.tellDelegateDidShow(node: nextNode)
    
                if CGPointEqualToPoint(velocity, CGPointZero) {
                    weakSelf.animation.didAppear(node: nextNode!)
                }
                
                weakSelf.askDatasourceToContinue()
                
            }
            
            completionHandelr(finished: finished)
            
            
        })

    }
    
    func showCancelAnimation(direction:GZFlingViewSwipingDirection, translation:CGPoint){
        
        var topNode = self.visibleNodesQueue.frontNode!
        
        self.tellDelegateWillCancelChoosing(node: topNode)
        
        self.animation.showCancelAnimation(direction: direction, currentNode:topNode, translation: translation, completionHandler: {[weak self] (finished) -> Void in
            
            if let weakSelf = self {
                weakSelf.tellDelegateDidCancelChoosing(node: topNode)
            }
            

        })
        
    }
    
    
}


// MARK: - Private Methods

private extension GZFlingView {
    
    //因為Extension 指定為Private 所以裡面都不用設private
    
    func initialize(){
        self.prepareGestures()
        self.animation.flingView = self
        //        self.reloadData()
    }
    
    func relayoutIfNeeded(){
        
        self.relayout(true)
        
    }
    
    func relayout(){
        
        self.relayout(false)
        
    }
    
    func relayout(force:Bool){
        
        if force || !self.isLayouted {

            // reset
            self.visibleNodesQueue.clear({ (node) -> Void in
                node.carryingView.removeFromSuperview()
            })
            
            self.reusedNodesPool.enumerateObjectsUsingBlock({ (node, idx, isEnded) -> Void in
                var carryingView = node.carryingView
                carryingView.frame = self.bounds
            })
            
            
            //重新安排及AddSubview
            for index in 0 ..< self.animation.expectedMinSize{
                
                //將Node的CarryingView經由Datasource，交由外部進行處理
                var shouldContinue = self.askDatasourceToContinue()
                if !shouldContinue {
                    break
                }
                
            }
            
            var topNode = self.visibleNodesQueue.frontNode
            
            
            self.tellDelegateWillShow(node: topNode)
            
            self.animation.willAppear(node: topNode)
            self.animation.didAppear(node: topNode)
            
            self.tellDelegateDidShow(node: topNode)
            
        }
        
        self.isLayouted = true
        
    }

    
    func reloadData(#needLayout:Bool){
        
        self.reusedNodesPool.clear()
        
        var minQueueSize = self.animation.expectedMinSize + kGZFlingViewReusePoolReservedSize
        
        for index in 0 ..< minQueueSize {
            
            if let carryingView = self.dataSource?.carryingViewForReusingAtIndexInFlingView(self, carryingViewForReusingAtIndex: index) {
                
                //prepare carryingView
                carryingView.flingView = self
                carryingView.alpha = 0.0
                carryingView.flingIndex = index
                
                var node = GZFlingNode(carryingView: carryingView)
                
                self.reusedNodesPool.push(node: node)

            }
            
            
        }
        
        
//        println("size:\(self.reusedNodesPool.size)")

        
        if needLayout {
            self.relayoutIfNeeded()
        }
        
        
        
        
//        println("reloadData")
        
        //        if self.dataSource == nil {
        //            return
        //        }
        //
        //        self.privateInstance.reset()
        //        self.reusedNodesQueue.reset()
        //
        //
        //
        //        var numberOfCarryingViews:Int = (self.dataSource?.numberOfCarryingViewsForReusingInFlingView(self)) ?? 0
        //
        //        for index in 0 ..< numberOfCarryingViews {
        //
        //            if let carryingView = self.dataSource?.carryingViewForReusingAtIndexInFlingView(self, carryingViewForReusingAtIndex: index) {
        //
        //                self.addSubview(carryingView)
        //
        //                carryingView.frame = self.bounds
        //                carryingView.flingIndex = index
        //                carryingView.flingView = self
        //                carryingView.alpha = 0.0
        //
        //                var node = GZFlingNode(carryingView: carryingView)
        //                self.reusedNodesQueue += node
        //
        //                self.askDatasourceShouldNeedShow(forNode: node, atIndex: index)
        //
        //            }
        //
        //        }
        //
        //        self.askDatasourceShouldEnd(atIndex: numberOfCarryingViews)
        //        self.privateInstance.counter = numberOfCarryingViews
        //
        //
        //        if !self.isEnded {
        //
        //            self.animation.willAppear(node: self.reusedNodesQueue.frontNode!)
        //            self.animation.didAppear(node: self.reusedNodesQueue.frontNode!)
        //
        //
        //            self.tellDelegateWillShow(node: self.reusedNodesQueue.frontNode, atFlingIndex: self.reusedNodesQueue.frontNode!.flingIndex)
        //            self.tellDelegateDidShow(node: self.reusedNodesQueue.frontNode, atFlingIndex: self.reusedNodesQueue.frontNode!.flingIndex)
        //            
        //        }
        //        
        
    }
    
    
}


//MARK: - Gesture Support
extension GZFlingView : UIGestureRecognizerDelegate {
    
    func viewDidPan(gesture: UIPanGestureRecognizer){
        
        var translation = gesture.translationInView(self)
        self.privateInstance.translation = translation
        
        var topNode = self.visibleNodesQueue.frontNode!
        
        if gesture.state == .Changed {
            self.animation.gesturePanning(gesture: gesture, currentNode:topNode, translation: translation)
            self.tellDelegateDidDrag(node:topNode , contentOffset: translation)
        }
        else if gesture.state == .Ended {
            
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
        
        
        var frontNode = self.visibleNodesQueue.currentNode
        var should = !self.isEnded && self.dataSource != nil
        
        if should {
            
            self.animation.willBeginGesture(gesture: gestureRecognizer as UIPanGestureRecognizer, currentNode:frontNode)
            self.tellDelegateWillBeginDragging(node: frontNode)
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
    
    
    func tellDelegateWillShow(#node:GZFlingNode!){
        
        if node == nil {
            return
        }
        
        if node.nextNode == nil {
            self.tellDelegateWillArriveEnd(atFlingIndex: node.flingIndex)
        }
        
        if let delegateMethod = self.delegate?.flingViewWillShowCarryingView {
            delegateMethod(self, willShowCarryingView: node.carryingView, atFlingIndex: node.flingIndex)
            
        }
        
    }
    
    func tellDelegateDidShow(#node:GZFlingNode!){
        
        if node == nil {
            self.tellDelegateDidArriveEnd(atFlingIndex: self.reusedNodesPool.rearNode!.flingIndex)
        }else{
            if let delegateMethod = self.delegate?.flingViewDidShowCarryingView {
                delegateMethod(self, didShowCarryingView: node.carryingView, atFlingIndex: node.flingIndex)
            }
        }
        
        
        
        
    }
    
    
    func tellDelegateWillArriveEnd(atFlingIndex index:Int){
        
        if let delegateMethod = self.delegate?.flingViewWillArriveEndIndex  {
            delegateMethod(self, atIndex: index)
        }
        
    }
    
    func tellDelegateDidArriveEnd(atFlingIndex index:Int){
        
        if let delegateMethod = self.delegate?.flingViewDidArriveEndIndex  {
            delegateMethod(self, atIndex: index)
        }
        
    }
    
    
    //FIXME: 可能改成回傳Node, 如果是End就回傳nil
    func askDatasourceShouldEnd()->GZFlingNode!{
        
        //從reuse Pool 取得一個Node
        var reusedNode = self.reusedNodesPool.pop()
        
        var carryingView = reusedNode.carryingView
        
        if let rearNode = self.visibleNodesQueue.rearNode {
            carryingView.flingIndex = rearNode.flingIndex + 1
        }
        
        if let shouldEndMethod = self.dataSource?.flingViewShouldEnd {
            var shouldEnd = shouldEndMethod(self, atFlingIndex: reusedNode.flingIndex)
            
            if shouldEnd {
                self.reusedNodesPool.push(node: reusedNode)
                return nil
            }
            

        }
        
        return reusedNode
        
//        if self.askDatasourceShouldEnd(atIndex:carryingView.flingIndex){
//            
//            println("self.askDatasourceShouldEnd 1")
//            
//            
//            
//            return false
//            
//        }
        
        
//        var shouldEnd = false
//        
//        if let shouldEndMethod = self.dataSource?.flingViewShouldEnd {
//            shouldEnd = shouldEndMethod(self, atFlingIndex: index)
//        }
//        
//        return shouldEnd
        
    }

    //回傳是否要Continue
    func askDatasourceToContinue()->Bool {
        
        
        var reusedNode = self.askDatasourceShouldEnd()//self.reusedNodesPool.pop()
        if reusedNode == nil {
            return false
        }
        
        var carryingView = reusedNode.carryingView
        
//        var carryingView = reusedNode.carryingView
//        
//        if let rearNode = self.visibleNodesQueue.rearNode {
//            carryingView.flingIndex = rearNode.flingIndex + 1
//        }
//        
//        if self.askDatasourceShouldEnd(atIndex:carryingView.flingIndex){
//            
//            println("self.askDatasourceShouldEnd 1")
//            
//            self.reusedNodesPool.push(node: reusedNode)
//            
//            return false
//
//        }
        
        if let prepareMethod = self.dataSource?.flingViewPrepareCarryingView {
            
            prepareMethod(self, preparingCarryingView: carryingView, atFlingIndex: reusedNode.flingIndex)
            
        }
        
        //如果有尾巴，就把新的carryingView插在最後面
        if let rearNode = self.visibleNodesQueue.rearNode {
            self.insertSubview(carryingView, belowSubview: rearNode.carryingView)
        }else{
            self.addSubview(carryingView)
        }
        
        self.animation.prepare(node: reusedNode)
        carryingView.prepareForReuse()
        
        carryingView.alpha = 1.0
        
        self.visibleNodesQueue.push(node: reusedNode)

        
        return true
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
    
    mutating func reset(){
        self.predictEndIndex = -1
        self.counter = 0
        self.translation = CGPointZero
    }
    
    init(){
        
    }
    
}

//MARK:- Delegate Methods Declare
@objc public protocol GZFlingViewDelegate {
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

@objc public protocol GZFlingViewDatasource{
    func numberOfCarryingViewsForReusingInFlingView(flingView:GZFlingView) -> Int
    func carryingViewForReusingAtIndexInFlingView(flingView:GZFlingView, carryingViewForReusingAtIndex reuseIndex:Int) -> GZFlingCarryingView
    
    optional func flingViewShouldEnd(flingView:GZFlingView, atFlingIndex index:Int)->Bool
    optional func flingViewPrepareCarryingView(flingView:GZFlingView, preparingCarryingView carryingView:GZFlingCarryingView, atFlingIndex index:Int)
}


//MARK: - GZFlingNodesQueue & GZFlingNodes

class GZFlingNodesQueue{
    
    private var privateQueueInstance:PrivateQueueInstance
    
    /**
    (readonly)
    */
    internal var frontNode:GZFlingNode?{
        get{
            return self.privateQueueInstance.frontNode
        }
        
    }
    
    /**
    (readonly)
    */
    internal var rearNode:GZFlingNode?{
        get{
            return self.privateQueueInstance.rearNode
        }
    }
    
    /**
    (readonly)
    */
    internal var currentNode:GZFlingNode?{
        get{
            return self.privateQueueInstance.currentNode
        }
    }
    
    /**
    (readonly)
    */
    var nextNode:GZFlingNode? {
        get{
            return (self.currentNode?.nextNode)!
        }
    }
    
    
    /**
    (readonly)
    */
    internal var size:Int{
        get{
            return self.privateQueueInstance.size
        }
    }
    
    init(){
        
        self.privateQueueInstance = PrivateQueueInstance()
        
    }
    
    convenience init(frontNode:GZFlingNode){
        
        self.init()
        
        var copy = frontNode.copy() as GZFlingNode
        
        self.push(node: frontNode)
        
        self.privateQueueInstance.size = 1
    }
    
    
    func push(#node:GZFlingNode!){
        
        if node == nil {
            return
        }
        
        var copy = node.copy() as GZFlingNode
        
        if let rearNode = self.privateQueueInstance.rearNode {
            rearNode.privateInstance.nextNode = copy
            self.privateQueueInstance.rearNode = copy
            //            copy.privateInstance.nextNode = frontNode
            //            self.privateQueueInstance.rearNode?.privateInstance.nextNode = copy
            //            self.privateQueueInstance.rearNode = copy
            
        }else{
            self.privateQueueInstance.frontNode = copy
            self.privateQueueInstance.rearNode = copy
            self.privateQueueInstance.currentNode = copy
        }
        
        self.privateQueueInstance.size++
        
    }
    
    func pop() -> GZFlingNode!{
        
        assert(self.privateSize > 0, "Please check your queue size, it's cannot be 0 to pop.")
        
        //取frontNode出來做為willPopNode
        var willPopNode = self.frontNode
        //先取frontNode的nextNode出來
        var nextFrontNode = willPopNode?.nextNode
        
        //因為要pop了，所以將要pop的Node的next設為nil
        willPopNode?.setNextNode(nil)
        
        self.setFrontNode(nextFrontNode)
        self.setCurrentNode(nextFrontNode)
        
        self.privateSize = max(self.privateSize-1, 0)
        
        if self.size == 0 {
            
            self.privateQueueInstance.rearNode = nil
            
        }
        
        //        println("self.privateSize:\(self.privateSize)")
        
        return willPopNode
        
    }
    
    
    func next() -> GZFlingNode {
        
        var nextNode:GZFlingNode = (self.currentNode?.nextNode)!
        self.privateQueueInstance.currentNode = nextNode
        
        self.privateQueueInstance.rearNode = self.rearNode?.nextNode
        self.privateQueueInstance.frontNode = self.frontNode?.nextNode
        
        return nextNode
    }
    
    func enumerateObjectsUsingBlock(block:(node:GZFlingNode, idx:Int, isEnded:UnsafeMutablePointer<Bool>)->Void){
        
        var node = self.frontNode
        
        var isEndedPtr = false
        
        for idx in 0..<self.size {
            
            if isEndedPtr { break }
            
            block(node: node!, idx: idx, isEnded: &isEndedPtr)
            
            node = node?.nextNode
            
        }
        
    }
    
    
    
    func clear(enumerateHandler:((node:GZFlingNode)->Void) = {(node:GZFlingNode)->Void in return}){
        
        self.rearNode?.privateInstance.nextNode = nil
        
        var node:GZFlingNode! = self.frontNode
        
        for idx in 0 ..< self.privateQueueInstance.size {
            var poppedNode = self.pop()
            
            //因為有Default值，所以可以不用檢查
            enumerateHandler(node:poppedNode)
        }
        
    }
    
    func reset(){
        
        if self.size == 0 {
            return
        }
        
        self.rearNode?.privateInstance.nextNode = nil
        
        var node:GZFlingNode! = self.frontNode
        
        self.privateQueueInstance.frontNode = nil
        self.privateQueueInstance.rearNode = nil
        self.privateQueueInstance.currentNode = nil
        self.privateQueueInstance.size = 0
        
        while node != nil {
            
            node.carryingView.removeFromSuperview()
            node = node.nextNode
            
        }
        
    }
    
    
    func printLinkedList(){
        //        GZDebugLog(self)
        
        self.enumerateObjectsUsingBlock { (node, idx, isEnded) -> Void in
            
            println("[\(idx)]node:\(node), next:\(node.nextNode)")
            
        }
        
    }
    
    // MARK: - PrivateQueueInstance
    
    private struct PrivateQueueInstance {
        var frontNode : GZFlingNode?
        var rearNode : GZFlingNode?
        var currentNode : GZFlingNode?
        
        var size:Int = 0
        
        init(){
            
        }
        
    }
    
}


extension GZFlingNodesQueue {
    
    private var privateSize:Int {
        set{
            
            self.privateQueueInstance.size = newValue
            
        }
        get{
            
            return self.privateQueueInstance.size
            
        }
    }
    
    
    //MARK: - Setter
    
    private func setFrontNode(node:GZFlingNode!){
        self.privateQueueInstance.frontNode = node
    }
    
    private func setCurrentNode(node:GZFlingNode!){
        self.privateQueueInstance.currentNode = node
    }
    
    private func setRearNode(node:GZFlingNode!){
        self.privateQueueInstance.frontNode = node
    }
    
    
    
}

//MARK: -
class GZFlingNode : NSObject, NSCopying {
    
    // MARK: Properties
    
    /**
    (readonly)
    */
    var nextNode:GZFlingNode?{
        get{
            return self.privateInstance.nextNode
        }
    }
    
    /**
    (readonly)
    */
    var carryingView:GZFlingCarryingView{
        return self.privateInstance.carryingView
    }
    
    /**
    (readonly)
    */
    var flingIndex:Int{
        return self.carryingView.flingIndex
    }
    
    private var privateInstance:PrivateInstance
    
    init(carryingView:GZFlingCarryingView) {
        self.privateInstance = PrivateInstance(carryingView: carryingView)
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        
        return GZFlingNode(carryingView: self.carryingView)
        
    }
    
    
    private func setNextNode(node:GZFlingNode!){
        self.privateInstance.nextNode = node
    }
    
    private class PrivateInstance {
        var carryingView:GZFlingCarryingView
        var nextNode:GZFlingNode?
        
        init(carryingView:GZFlingCarryingView){
            self.carryingView = carryingView
        }
        
        deinit{
            
            //            GZDebugLog("Node is deinit")
            
        }
        
    }
    
    
}


extension GZFlingNodesQueue : Printable {
    var description:String{
        get{
            var rearNode = self.rearNode
            var printNode = self.frontNode
            
            var descriptionString = ""
            
            self.enumerateObjectsUsingBlock { (node, idx, isEnded) -> Void in
                descriptionString += "\(printNode)->"
            }
            
            
            return descriptionString
        }
    }
    
}

func += (nodeList:GZFlingNodesQueue, node:GZFlingNode){
    nodeList.push(node: node)
}


enum GZFlingViewAnimationState:Int{
    case Init = 0
}


//MARK: - Animation

let kGZFlingViewAnimationDuration:NSTimeInterval = 0.2

public class GZFlingViewAnimation {
    
    var flingView:GZFlingView!
    var beginLocation:CGPoint = CGPoint()
    
    init(){
        
    }
    
    var expectedMinSize:Int {
        return 0
    }
    
    func gesturePanning(#gesture:UIPanGestureRecognizer, currentNode:GZFlingNode!, translation:CGPoint){}
    func willBeginGesture(#gesture:UIPanGestureRecognizer, currentNode:GZFlingNode!){}
    func didEndGesture(#gesture:UIPanGestureRecognizer, currentNode:GZFlingNode!){}
    
    
    func prepare(#node:GZFlingNode){
        //pass
    }
    
    func willAppear(#node:GZFlingNode!){
        //pass
    }
    
    func didAppear(#node:GZFlingNode!){
        //pass
    }
    
    
    func shouldCancel(#direction:GZFlingViewSwipingDirection, currentNode:GZFlingNode?, translation:CGPoint)->Bool{return true}
    func showChoosenAnimation(#direction:GZFlingViewSwipingDirection, currentNode:GZFlingNode?, translation:CGPoint, completionHandler:((finished:Bool)->Void)){completionHandler(finished: true)}
    
    func showCancelAnimation(#direction:GZFlingViewSwipingDirection, currentNode:GZFlingNode?, translation:CGPoint,completionHandler:((finished:Bool)->Void)){completionHandler(finished: true)}
    
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
    
    override func prepare(#node:GZFlingNode) {
        
        var carryingView = node.carryingView
        
        carryingView.layer.position = self.beginLocation
        carryingView.transform = self.initialTransforms
        
        self.radomClosewise = self.getNewRandomClosewise()
        
    }
    
    override func willAppear(#node:GZFlingNode!){
        
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
                    weakSelf.privateInstance.previousTranslation = CGPoint()
                }
                
        })
        
        
    }
    
    override func willBeginGesture(#gesture: UIPanGestureRecognizer, currentNode:GZFlingNode?) {
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
    
    
    
    override func shouldCancel(#direction: GZFlingViewSwipingDirection, currentNode:GZFlingNode?,translation: CGPoint) -> Bool {
        
        //self.flingView.frame.width/6*2
        return !(fabs(translation.x) > self.maxWidthForFling )
    }
    
    
    struct PrivateInstance {
        
        var previousTranslation = CGPoint()
        
    }
    
}

//MARK: - CarryingView

public class GZFlingCarryingView: UIView {
    
    public var flingIndex:Int = 0
    public var flingView:GZFlingView!
    
    @IBOutlet public var customView:UIView! = UIView(){
        
        willSet{
            
            if (newValue != customView) {
                self.customView?.removeFromSuperview()
            }
            
        }
        
        didSet{
            
            if oldValue != customView  {
                self.addSubview(customView!)
            }
        }
        
    }
    
    
    public init(customView:UIView!) {
        super.init()
        
        self.customView = customView
        self.addSubview(customView)
        
        self.initialize()
    }
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initialize()
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.initialize()
        
    }
    
    func initialize(){
        self.layer.shouldRasterize = true
    }
    
    public func prepareForReuse(){
        
    }
    
    deinit{
        //        GZDebugLog("GZFlingCarryingView is deinit")
        
    }
    
    override public func drawRect(rect: CGRect) {
        var context = UIGraphicsGetCurrentContext()
        CGContextSetAllowsAntialiasing(context, true)
        CGContextSetShouldAntialias(context, true)
    }
    
}


