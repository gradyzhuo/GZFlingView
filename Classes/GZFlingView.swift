//
//  GZFlingChooseView.swift
//  GZKit
//
//  Created by Grady Zhuo on 2014/9/14.
//  Copyright (c) 2014年 Grady Zhuo. All rights reserved.
//

import UIKit

//為了使Reuse Pool 確保比畫面的多，所以要加上的常數
private let kGZFlingViewReusePoolReservedSize = 3

@IBDesignable public class GZFlingView: UIView {
 
    //MARK: - Properties Declare
    
    /**
        (readonly)
    */
    public internal(set) var topCarryingView : GZFlingCarryingView!
    
    /**
        (readonly)
    */
    public internal(set) var nextCarryingView : GZFlingCarryingView!
    
    /**
        (readonly)
    */
    public internal(set) var direction:GZFlingViewSwipingDirection = .Undefined
    
    
    //MARK: 為了做一個Pool 去 reuse
    internal var reusedNodesPool = GZFlingNodesQueue()
    
    //MARK: 現在畫面中在進行的Queue
    internal var visibleNodesQueue = GZFlingNodesQueue()

    internal var isLayouted:Bool = false
    
    /**
    (readonly)
    */
    public var numberOfVisibleCarryingViews:Int{
        return self.visibleNodesQueue.size
    }
    
    
    public internal(set) var panGestureRecognizer:UIPanGestureRecognizer = UIPanGestureRecognizer()
    
    @IBOutlet public var dataSource: GZFlingViewDatasource?{
        didSet{
            
            if dataSource != nil {
                self.reloadData(needLayout: false)
            }

        }
    }
    
    @IBOutlet public var delegate: GZFlingViewDelegate?
    
    public var isEnded:Bool{
        get{
            //檢查現在的Node，如果nil就代表結束了
            return self.visibleNodesQueue.currentNode == nil
        }
    }
    
    public internal(set) var contentOffset:CGPoint = .zero
    
    public var animation:GZFlingViewAnimation = GZFlingViewAnimationTinder()
    
    //MARK: - Public Methods
    
    public init() {
        super.init(frame: .zero)
        
        self.initialize()
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
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


//    //FIXME: when add subview and setting autolayout, it'll be crashed on iOS7.
//    
//    override public func layoutSublayersOfLayer(layer: CALayer) {
//        
////        if SYSTEM_VERSION_LESS_THAN("8.0"){
////            self.layoutSubviews()
////        }
//        
//        super.layoutSublayersOfLayer(layer)
//    }
//    
    
    public func choose(direction:GZFlingViewSwipingDirection, completionHandler:(finished:Bool) -> Void = {(finished:Bool) -> Void in return}) {
        
        if self.isEnded {
            return
        }
        
        self.panGestureRecognizer.enabled = false
        
        let info:GZFlingViewAnimationGestureInfo
        
        switch direction {
            
        case .Left:
            info = (gestureRecognizer:nil, translation: CGPoint(x: -200, y: 0), velocity: .zero)
            
        case .Right:
            info = (gestureRecognizer:nil, translation: CGPoint(x: 200, y: -0), velocity: .zero)
//        case .Top:
//            translation = CGPoint(x: 0, y: -100)
//        
//        case .Bottom:
//            translation = CGPoint(x: 0, y: 100)
            
        case .Undefined:
            info = (gestureRecognizer:nil, translation: CGPoint(x: 0, y: 0), velocity: .zero)
            
        }
        
        self.direction = direction
        self.showChoosenAnimation(direction, gestureInfo: info, completionHandelr: completionHandler)
        
    }
    
    
    public func reloadData(){
        self.reloadData(needLayout: true)
    }
    
    func prepareGestures(){
        self.panGestureRecognizer.addTarget(self, action: "viewDidPan:")
        self.panGestureRecognizer.delegate = self
        self.addGestureRecognizer(panGestureRecognizer)
    }

    
    func showChoosenAnimation(direction:GZFlingViewSwipingDirection, gestureInfo:GZFlingViewAnimationGestureInfo, completionHandelr:(finished:Bool) -> Void){
        
        /**/
        var currentNode:GZFlingNode! = nil
        if self.visibleNodesQueue.size != 0 {
            currentNode = self.visibleNodesQueue.pop()
        }
        
        //馬上回收
        self.reusedNodesPool.push(node: currentNode)
        
        /**/
        
        let nextNode = self.visibleNodesQueue.currentNode
        
        self.tellDelegateWillShow(node: nextNode)

        if !self.panGestureRecognizer.enabled {
            self.animation.willAppear(node: nextNode)
        }
        
        self.animation.showRestoreAnimation(direction: direction, currentNode: nextNode, gestureInfo: gestureInfo) { (finished) -> Void in
            
        }
        
        self.animation.showChoosenAnimation(direction: direction, currentNode:currentNode, gestureInfo: gestureInfo, completionHandler: {[unowned self] (finished) -> Void in
            
            currentNode.carryingView.removeFromSuperview()
            
            if let weakSelf:GZFlingView = self {
                
                weakSelf.tellDelegateDidChoose(node: currentNode)
                weakSelf.tellDelegateDidShow(node: nextNode)
    
                if !weakSelf.isEnded {
                    
                    if !weakSelf.panGestureRecognizer.enabled {
                        weakSelf.animation.didAppear(node: nextNode!)
                    }
                    
                    for _ in  0 ..< (weakSelf.animation.expectedMinSize - weakSelf.visibleNodesQueue.size) {
                        weakSelf.askDatasourceToContinue()
                    }
                    
                }
                
                weakSelf.panGestureRecognizer.enabled = true
                
            }
            
            completionHandelr(finished: finished)
            
        })

    }
    
    func showCancelAnimation(direction:GZFlingViewSwipingDirection, gestureInfo:GZFlingViewAnimationGestureInfo){
        
        let topNode = self.visibleNodesQueue.frontNode!
        
        self.tellDelegateWillCancelChoosing(node: topNode)
        
        self.animation.showRestoreAnimation(direction: direction, currentNode:topNode, gestureInfo: gestureInfo, completionHandler: {[weak self] (finished) -> Void in
            
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
                let carryingView = node.carryingView
                carryingView.frame = self.bounds
            })
            
            
            
            //應該要改成，Animation 要 n ，但FlingView保留+m, 避免畫面不順，但m在預設會是空的
            //重新安排及AddSubview
            for _ in 0 ..< self.animation.expectedMinSize{
                
                //將Node的CarryingView經由Datasource，交由外部進行處理
                let reusedNode = self.askDatasourceToContinue()
                if reusedNode == nil {
                    break
                }
                
            }
            
            let topNode = self.visibleNodesQueue.frontNode
            
            self.tellDelegateWillShow(node: topNode)
            
            self.animation.willAppear(node: topNode)
            self.animation.didAppear(node: topNode)
            
            self.tellDelegateDidShow(node: topNode)
            
        }
        
        self.isLayouted = true
        
    }

    
    private func reloadData(needLayout needLayout:Bool){
        
        self.reusedNodesPool.clear()
        
        let template = self.dataSource?.carryingViewTemplateInFlingView(self)
        
        let minQueueSize = self.animation.expectedMinSize + kGZFlingViewReusePoolReservedSize
        
        for index in 0 ..< minQueueSize {
            
            if let carryingView = template?.instantiate() {
                
                //prepare carryingView
                carryingView.flingView = self
                carryingView.alpha = 0.0
                carryingView.flingIndex = index
                
                let node = GZFlingNode(carryingView: carryingView)
                
                self.reusedNodesPool.push(node: node)
                
            }
            
            
        }

        
        if needLayout {
            self.relayoutIfNeeded()
        }
        
    }
    
    
}


//MARK: - Gesture Support
extension GZFlingView : UIGestureRecognizerDelegate {
    
    func viewDidPan(gesture: UIPanGestureRecognizer){
        
        let info:GZFlingViewAnimationGestureInfo = (gestureRecognizer:gesture, translation: gesture.translationInView(self), velocity: gesture.velocityInView(self))
        
        self.contentOffset = info.translation
        
        let topNode = self.visibleNodesQueue.frontNode!
        
        if gesture.state == .Changed {
            self.animation.gesturePanning(gestureInfo: info, currentNode:topNode)
            self.tellDelegateDidDrag(node:topNode , contentOffset: info.translation)
        }
        else if gesture.state == .Ended {
            
            self.tellDelegateDidEndDragging(node: topNode)
            
            if info.translation.x > 0 {
                self.direction = GZFlingViewSwipingDirection.Right
            }else if info.translation.x <= 0 {
                self.direction = GZFlingViewSwipingDirection.Left
            }
            
            if self.animation.shouldCancel(direction: self.direction, currentNode:topNode, gestureInfo: info){
                self.showCancelAnimation(self.direction, gestureInfo: info)
            }else{
                
                self.showChoosenAnimation(self.direction, gestureInfo: info, completionHandelr: { (finished) -> Void in
                    
                })
            }
            
        }
        
    }
    
    //MARK: Gesture Recognizer Delegate
    override public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        
        let frontNode = self.visibleNodesQueue.currentNode
        let should = !self.isEnded && self.dataSource != nil
        
        if should {
            let info = GZFlingViewAnimationGestureInfo(gestureRecognizer: self.panGestureRecognizer, translation: self.panGestureRecognizer.translationInView(self), velocity: self.panGestureRecognizer.velocityInView(self))
            
            self.animation.willBeginGesture(gestureInfo: info, currentNode:frontNode)
            self.tellDelegateWillBeginDragging(node: frontNode)
        }
        
        return should
    }
}


//MARK: - Delegate Method Support
extension GZFlingView {
    
    func tellDelegateDidEndDragging(node node:GZFlingNode!){
    
        
        let info = GZFlingViewAnimationGestureInfo(gestureRecognizer: self.panGestureRecognizer, translation: self.panGestureRecognizer.translationInView(self), velocity: self.panGestureRecognizer.velocityInView(self))
        
        self.animation.didEndGesture(gestureInfo: info, currentNode:node)
        
        self.delegate?.flingView?(self, didEndDraggingCarryingView: node.carryingView)
        
    }
    
    func tellDelegateWillCancelChoosing(node node:GZFlingNode!){
        
        self.delegate?.flingView?(self, willCancelChooseCarryingView: node.carryingView, atFlingIndex: node.flingIndex)

    }
    
    func tellDelegateDidCancelChoosing(node node:GZFlingNode!){
        
        self.delegate?.flingView?(self, didCancelChooseCarryingView: node.carryingView, atFlingIndex: node.flingIndex)
        
    }
    
    func tellDelegateDidChoose(node node:GZFlingNode!){
        
        self.delegate?.flingView?(self, didChooseCarryingView: node.carryingView, atFlingIndex: node.flingIndex)

    }
    
    func tellDelegateWillBeginDragging(node node:GZFlingNode!){
        
        self.delegate?.flingView?(self, willBeginDraggingCarryingView: node.carryingView)
        
    }
    
    func tellDelegateDidDrag(node node:GZFlingNode!, contentOffset:CGPoint){
        
        self.delegate?.flingView?(self, didDragCarryingView: node.carryingView, withContentOffset: contentOffset)
    }
    
    
    func tellDelegateWillShow(node node:GZFlingNode!){
        
        if node == nil {
            return
        }
        
        if node.nextNode == nil {
            self.tellDelegateWillArriveEnd(atFlingIndex: node.flingIndex)
        }
        
        self.delegate?.flingView?(self, willShowCarryingView: node.carryingView, atFlingIndex: node.flingIndex)
        
    }
    
    func tellDelegateDidShow(node node:GZFlingNode!){
        
        if node == nil {
            
            guard let rearNode = self.reusedNodesPool.rearNode else{
                return
            }
            
            self.tellDelegateDidArriveEnd(atFlingIndex: rearNode.flingIndex)
        }else{
            
            self.delegate?.flingView?(self, didShowCarryingView: node.carryingView, atFlingIndex: node.flingIndex)
            
        }
        
        
        
        
    }
    
    
    func tellDelegateWillArriveEnd(atFlingIndex index:Int){
        
        self.delegate?.flingView?(self, willArriveEndIndex: index)
        
    }
    
    func tellDelegateDidArriveEnd(atFlingIndex index:Int){
        
        self.delegate?.flingView?(self, didArriveEndIndex: index)

    }
    
    
    //FIXME: 可能改成回傳Node, 如果是End就回傳nil
    func askDatasourceShouldEnd()->GZFlingNode!{
        
        //從reuse Pool 取得一個Node
        guard let reusedNode = self.reusedNodesPool.pop() else{
            return nil
        }
        
        let carryingView = reusedNode.carryingView
        
        if let rearNode = self.visibleNodesQueue.rearNode {
            carryingView.flingIndex = rearNode.flingIndex + 1
        }
        
        
        let shouldEnd = (self.dataSource?.flingView?(self, shouldEndAtFlingIndex: reusedNode.flingIndex) ?? false)
        
        if shouldEnd {
            self.reusedNodesPool.push(node: reusedNode)
            return nil
        }
        
        return reusedNode
        
    }

    //回傳是否要Continue
    func askDatasourceToContinue()->GZFlingNode! {
        
        let reusedNode = self.askDatasourceShouldEnd()//self.reusedNodesPool.pop()
        if reusedNode == nil {
            return nil
        }
        
        let carryingView = reusedNode.carryingView
        
        self.dataSource?.flingView?(self, preparingCarryingView: carryingView, atFlingIndex: reusedNode.flingIndex)
        
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
        
        return reusedNode
    }
    

}

//private struct PrivateInstance {
//    
//    //MARK: 為了做一個Pool 去 reuse
//    private var reusedNodesPool = GZFlingNodesQueue()
//    //MARK: 現在畫面中在進行的Queue
//    private var visibleNodesQueue = GZFlingNodesQueue()
//
//    var beginLocation:CGPoint?
//    
//    var direction:GZFlingViewSwipingDirection = .Undefined
//    
//    var translation:CGPoint = CGPointZero
//    
//    var panGestureRecognizer = UIPanGestureRecognizer()
//    
//    var isLayouted:Bool = false
//    
////    mutating func reset(){
////        self.translation = CGPointZero
////    }
//    
//    init(){
//        
//    }
//    
//}

//MARK:- Delegate Methods Declare
@objc public protocol GZFlingViewDelegate {
    optional func flingView(flingView:GZFlingView, willChooseCarryingView carryingView:GZFlingCarryingView, atFlingIndex index:Int)->Void
    optional func flingView(flingView:GZFlingView, didChooseCarryingView carryingView:GZFlingCarryingView, atFlingIndex index:Int)->Void
    
    optional func flingView(flingView:GZFlingView, willCancelChooseCarryingView carryingView:GZFlingCarryingView, atFlingIndex index:Int)->Void
    optional func flingView(flingView:GZFlingView, didCancelChooseCarryingView carryingView:GZFlingCarryingView, atFlingIndex index:Int)->Void
    
    
    optional func flingView(flingView:GZFlingView, willShowCarryingView carryingView:GZFlingCarryingView, atFlingIndex index:Int)->Void
    optional func flingView(flingView:GZFlingView, didShowCarryingView carryingView:GZFlingCarryingView, atFlingIndex index:Int)->Void
    
    optional func flingView(flingView:GZFlingView, willBeginDraggingCarryingView carryingView:GZFlingCarryingView)->Void
    optional func flingView(flingView:GZFlingView, didDragCarryingView carryingView:GZFlingCarryingView, withContentOffset contentOffset:CGPoint)->Void
    
    optional func flingView(flingView:GZFlingView, willEndDraggingCarryingView carryingView:GZFlingCarryingView) -> Void
    optional func flingView(flingView:GZFlingView, didEndDraggingCarryingView carryingView:GZFlingCarryingView) -> Void
    
    optional func flingView(flingView:GZFlingView, willArriveEndIndex index:Int)->Void
    optional func flingView(flingView:GZFlingView, didArriveEndIndex index:Int)->Void
    
}

//MARK:- Datasource Methods Declare

@objc public protocol GZFlingViewDatasource{
    
    func carryingViewTemplateInFlingView(flingView:GZFlingView) -> GZFlingCarryingViewTemplate
    
    optional func flingView(flingView:GZFlingView, shouldEndAtFlingIndex index:Int)->Bool
    optional func flingView(flingView:GZFlingView, preparingCarryingView carryingView:GZFlingCarryingView, atFlingIndex index:Int)
}




