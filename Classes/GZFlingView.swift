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
    
    public func choose(direction:GZFlingViewSwipingDirection){
        
        if PrivateInstance.overEnd  {
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
            
            if let carryingView = self.dataSource?.carryingViewForReusingAtIndexInFlingView(self, carryingViewForReusingAtIndex: index) {
                
                self.addSubview(carryingView)
                self.sendSubviewToBack(carryingView)
                
                carryingView.frame = self.bounds
                carryingView.flingIndex = index
                carryingView.flingView = self
                
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
        
    }
    
    
}

//MARK: - Gesture Support
extension GZFlingView : UIGestureRecognizerDelegate {
    
    func viewDidPan(gesture: UIPanGestureRecognizer){
        
        var translation = gesture.translationInView(self)
        PrivateInstance.translation = translation
            
        self.animation.gesturePanning(carryingView: self.topCarryingView, translation: translation)
        self.tellDelegateDidDrag(carryingView: self.topCarryingView, contentOffset: translation)
        
        
        if gesture.state == .Ended && !PrivateInstance.overEnd {
            
            PrivateInstance.direction = GZFlingViewSwipingDirection(rawValue: Int(translation.x > 0))
            
            if self.animation.shouldCancel(direction: PrivateInstance.direction, translation: translation){
                self.showCancelAnimation(self.direction, translation: translation)
            }else{
                self.showChoosenAnimation(self.direction, translation: translation)
            }
            
        }
        
    }
    
    
    //MARK: Gesture Recognizer Delegate
    override public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        var should = self.nodesQueue.size != 0 && !PrivateInstance.overEnd  && self.dataSource != nil
        
        if should {
            self.tellDelegateWillBeginDragging(carryingView: self.topCarryingView)
        }
        
        
        return should
    }
}


//MARK: - Delegate Method Support
extension GZFlingView {
    
    func tellDelegateDidEndDragging(#carryingView:GZFlingCarryingView){
        
//        if let delegateMethod = self.delegate?.flingViewDidEndDragging {
//            delegateMethod(self, withDraggingCarryingView: carryingView)
//        }
        
    }
    
    func tellDelegateWillCancelChoosingCarryingView(#carryingView:GZFlingCarryingView){
        
        if let delegateMethod = self.delegate?.flingViewWillCancelChooseCarryingView {
            
            delegateMethod(self, willCancelChooseCarryingView: carryingView, atFlingIndex: carryingView.flingIndex)
            
        }

    }
    
    func tellDelegateDidCancelChoosingCarryingView(#carryingView:GZFlingCarryingView){
        
        if let delegateMethod = self.delegate?.flingViewDidCancelChooseCarryingView {
            
            delegateMethod(self, didCancelChooseCarryingView: carryingView, atFlingIndex: carryingView.flingIndex)

            
        }
        
    }
    
    func tellDelegateDidChooseCarryingView(#carryingView:GZFlingCarryingView){
        
        if let delegateMethod = self.delegate?.flingViewDidChooseCarryingView {
            
            delegateMethod(self, didChooseCarryingView: carryingView, atFlingIndex: carryingView.flingIndex)
            
        }

    }
    
    func tellDelegateWillBeginDragging(#carryingView:GZFlingCarryingView){
        
        if let delegateMethod = self.delegate?.flingViewWillBeginDraggingCarryingView {
            delegateMethod(self, withCarryingView: carryingView)
        }
        
    }
    
    func tellDelegateDidDrag(#carryingView:GZFlingCarryingView, contentOffset:CGPoint){
        
        
        if let delegateMethod = self.delegate?.flingViewDidDragCarryingView {
            delegateMethod(self, withDraggingCarryingView: carryingView, withContentOffset: contentOffset)
        }
        
    }
    
    func tellDelegateWillShow(#carryingView:GZFlingCarryingView, atFlingIndex index:Int){
        
        if self.isEnded {
            return
        }
        
        if let delegateMethod = self.delegate?.flingViewWillShowCarryingView {
            delegateMethod(self, willShowCarryingView: carryingView, atFlingIndex: index)

        }

        
    }
    
    func tellDelegateDidShow(#carryingView:GZFlingCarryingView, atFlingIndex index:Int){
        
        
        if PrivateInstance.arriveEnd {
            
            if let delegateMethod = self.delegate?.flingViewWillArriveEndIndex  {
                delegateMethod(self, atIndex: index)
            }
            
        }else if PrivateInstance.overEnd {
            
            if let delegateMethod = self.delegate?.flingViewDidArriveEndIndex {
                delegateMethod(self, atIndex: index)
            }
            
        }else{
            if let delegateMethod = self.delegate?.flingViewDidShowCarryingView {
                delegateMethod(self, didShowCarryingView: carryingView, atFlingIndex: index)
            }
        }

        
    }
    
    
    
    func askDatasourceForNeedShow(forCarryingView carryingView:GZFlingCarryingView, atIndex index:Int){
        
        self.sendSubviewToBack(carryingView)
        
        if let shouldNeedShowMethod = self.dataSource?.flingViewShouldNeedShowCarryingView {
            if shouldNeedShowMethod(self, atFlingIndex: index) {
                
                if let prepareMethod = self.dataSource?.flingViewPrepareCarryingView {
                    carryingView.flingIndex = index
                    
                    carryingView.alpha = 1.0
                    carryingView.prepareForShow()
                    
                    prepareMethod(self, preparingCarryingView: carryingView, atFlingIndex: index)
                    
                    PrivateInstance.predictEndIndex = index
                }
                
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
        
//        static var backupConstraitOfCarryingView:[AnyObject]?
        
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
    
    optional func flingViewShouldNeedShowCarryingView(flingView:GZFlingView, atFlingIndex index:Int)->Bool
    optional func flingViewPrepareCarryingView(flingView:GZFlingView, preparingCarryingView carryingView:GZFlingCarryingView, atFlingIndex index:Int)->Void
}

