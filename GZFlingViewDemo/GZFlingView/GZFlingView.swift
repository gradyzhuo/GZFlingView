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
    public var topCarryingView : GZFlingCarryingView?{
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
    public internal(set) var direction:GZFlingViewSwipingDirection = .Undefined
    
    public internal(set) var panGestureRecognizer = UIPanGestureRecognizer()
    
    public weak var dataSource: GZFlingViewDatasource?
    public weak var delegate: GZFlingViewDelegate?
    
    @IBOutlet public weak var IBDataSource: AnyObject?{
        didSet{
            self.dataSource = IBDataSource as? GZFlingViewDatasource
        }
    }
    @IBOutlet public weak var IBDelegate: AnyObject?{
        didSet{
            self.delegate = IBDelegate as? GZFlingViewDelegate
        }
    }
    
    
    private var beginLocation:CGPoint?
    private var counter:Int = 0
    
    private var clockwise:CGFloat = -1
    
    private var predictEndIndex = 0
    
    private var topIndex:Int = -1
    
    func reset(){
        self.topIndex = -1
        self.counter = 0
        self.contentOffset = CGPointZero
    }
    
    var overEnd:Bool {
        get{
            return self.predictEndIndex != -1 && self.topIndex > self.predictEndIndex
        }
    }
    
    var arriveEnd:Bool{
        get{
            return self.predictEndIndex != -1 && self.topIndex == self.predictEndIndex
            
        }
    }
    
    public internal(set) var isEnded:Bool = false
    
    public internal(set) var contentOffset:CGPoint = CGPointZero
    
    public var animation:GZFlingViewAnimation = GZFlingViewAnimationTinder()
    private var nodesQueue = GZFlingNodesQueue()
    
    
    //MARK: - Public Methods
    
    public init() {
        super.init(frame: CGRect.zero)
        
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
        
//        PrivateInstance.beginLocation = self.bounds.center
        self.animation.beginLocation = self.bounds.center
        
        if self.nodesQueue.size == 0 {
            
            self.reloadData()
            
        }
        
    }    
    
    public func nextCarryingView(fromCarryingView carryingView:GZFlingCarryingView) -> GZFlingCarryingView? {
        let node = self.nodeByCarryingView(carryingView)
        return node?.nextNode.carryingView
    }
    
    public func choose(direction:GZFlingViewSwipingDirection, completionHandelr:((finished:Bool) -> Void)?){
        
        if self.overEnd || self.topCarryingView == nil  {
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
        
        self.direction = direction
        self.showChoosenAnimation(direction, translation: translation!, completionHandelr: completionHandelr)
        
    }
    
    
    public func reloadData(){
        
        guard let dataSource = self.dataSource else {
            return
        }
        
        self.reset()
        self.nodesQueue.reset()
        
        let numberOfCarryingViews:Int = (dataSource.numberOfCarryingViewsForReusingInFlingView(self)) ?? 0
        
        for index in 0..<numberOfCarryingViews {
            
            let carryingView = dataSource.flingView(self, carryingViewForReusingAtIndex: index)
            
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
            
            self.counter++
            
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
        
        let currentCarryingView = (self.nodesQueue.currentNode?.carryingView)!
        let nextCarryingView = self.nodesQueue.currentNode.nextNode.carryingView
        
        self.tellDelegateWillShow(carryingView: nextCarryingView, atFlingIndex: nextCarryingView.flingIndex)
        
        let velocity = self.panGestureRecognizer.velocityInView(self)
        
        if CGPointEqualToPoint(velocity, CGPointZero) {
            self.animation.willAppear(carryingView: nextCarryingView)
        }
        
        self.animation.showChoosenAnimation(direction: direction, translation: translation, completionHandler: {[weak self] (finished) -> Void in
            
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.tellDelegateDidChooseCarryingView(carryingView: currentCarryingView)
            
            if !weakSelf.askDatasourceShouldEnd(atIndex: weakSelf.counter)  {
                weakSelf.askDatasourceForNeedShow(forCarryingView: currentCarryingView, atIndex: weakSelf.counter)
                weakSelf.tellDelegateDidShow(carryingView: nextCarryingView, atFlingIndex: nextCarryingView.flingIndex)
                
                
            }
            
            weakSelf.counter++
            
            weakSelf.isEnded = weakSelf.shouldTellDelegateDidArriveOrOverEnd(atFlingIndex: nextCarryingView.flingIndex)
            
            if CGPointEqualToPoint(velocity, CGPointZero) {
                weakSelf.animation.didAppear(carryingView: nextCarryingView)
            }
            
            if let handler = completionHandelr {
                handler(finished: finished)
            }
            
        })
        
        self.topIndex = nextCarryingView.flingIndex
        
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
        
        let translation = gesture.translationInView(self)
        self.contentOffset = translation
        
        
        if gesture.state == .Changed {
            self.animation.gesturePanning(gesture: gesture, translation: translation)
            
            self.tellDelegateDidDrag(carryingView: self.topCarryingView, contentOffset: translation)
        }
        else if gesture.state == .Ended && !self.overEnd {
            
            self.tellDelegateDidEndDragging(carryingView: self.topCarryingView)
            
            if translation.x > 0 {
                self.direction = GZFlingViewSwipingDirection.Right
            }else if translation.x <= 0 {
                self.direction = GZFlingViewSwipingDirection.Left
            }
            
            if self.animation.shouldCancel(direction: self.direction, translation: translation){
                self.showCancelAnimation(self.direction, translation: translation)
            }else{
                self.showChoosenAnimation(self.direction, translation: translation, completionHandelr: nil)
            }
            
        }
        
    }
    
    
    //MARK: Gesture Recognizer Delegate
    override public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        let should = self.nodesQueue.size != 0 && !self.isEnded  && self.dataSource != nil
        
        if should {
            self.animation.willBeginGesture(gesture: gestureRecognizer as! UIPanGestureRecognizer)
            self.tellDelegateWillBeginDragging(carryingView: self.topCarryingView)
        }
        
        
        return should
    }
}


//MARK: - Delegate Method Support
extension GZFlingView {
    
    func tellDelegateDidEndDragging(carryingView carryingView:GZFlingCarryingView!){
    
        self.animation.didEndGesture(gesture: self.panGestureRecognizer)
        self.delegate?.flingView?(self, didEndDraggingCarryingView: carryingView)
        
    }
    
    func tellDelegateWillCancelChoosingCarryingView(carryingView carryingView:GZFlingCarryingView!){
        
        self.delegate?.flingView?(self, willCancelChooseCarryingView: carryingView, atFlingIndex: carryingView.flingIndex)
    }
    
    func tellDelegateDidCancelChoosingCarryingView(carryingView carryingView:GZFlingCarryingView!){
        
        self.delegate?.flingView?(self, didCancelChooseCarryingView: carryingView, atFlingIndex: carryingView.flingIndex)
        
    }
    
    func tellDelegateDidChooseCarryingView(carryingView carryingView:GZFlingCarryingView!){
        
        self.delegate?.flingView?(self, didChooseCarryingView: carryingView, atFlingIndex: carryingView.flingIndex)

    }
    
    func tellDelegateWillBeginDragging(carryingView carryingView:GZFlingCarryingView!){
        
        self.delegate?.flingView?(self, willBeginDraggingCarryingView: carryingView)
        
    }
    
    func tellDelegateDidDrag(carryingView carryingView:GZFlingCarryingView!, contentOffset:CGPoint){
        
        self.delegate?.flingView?(self, didDragCarryingView: carryingView, withContentOffset: contentOffset)
        
    }
    
    func tellDelegateWillShow(carryingView carryingView:GZFlingCarryingView!, atFlingIndex index:Int){
        
        if self.isEnded {
            return
        }
        
        self.delegate?.flingView?(self, willShowCarryingView: carryingView, atFlingIndex: index)
        
    }
    
    func shouldTellDelegateDidArriveOrOverEnd(atFlingIndex index:Int)->Bool{
        var didArriveEnd = false
        
        if self.arriveEnd {
            
            didArriveEnd = true
            
            self.delegate?.flingView?(self, willArriveEndIndex: index)
            
        }else if self.overEnd {
            
            didArriveEnd = true
            self.delegate?.flingView?(self, didArriveEndIndex: index)

        }
        
        self.isEnded = didArriveEnd
        
        return didArriveEnd
    }
    
    func tellDelegateDidShow(carryingView carryingView:GZFlingCarryingView!, atFlingIndex index:Int){

        self.delegate?.flingView?(self, didShowCarryingView: carryingView, atFlingIndex: index)
        
    }
    
    func askDatasourceShouldEnd(atIndex index:Int)->Bool{
        
        let shouldEnd = (self.dataSource?.flingView?(self, shouldEndAtIndex: index) ?? false)
        self.predictEndIndex = shouldEnd ? self.predictEndIndex : index
        
        return shouldEnd
        
    }
    
    func askDatasourceForNeedShow(forCarryingView carryingView:GZFlingCarryingView!, atIndex index:Int){
        
        self.sendSubviewToBack(carryingView)
        
        carryingView.flingIndex = index
        
        self.animation.prepare(carryingView: carryingView, reuseIndex: index)
        
        carryingView.alpha = 1.0
        carryingView.prepareForReuse()
        
        self.dataSource?.flingView?(self, preparingCarryingView: carryingView, atFlingIndex: index)
    }

}

//MARK: - Private Instance Extension for Store Private Info
extension GZFlingView {
    
    private struct PrivateInstance {
        
        
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
    
    optional func flingView(flingView:GZFlingView, willBeginDraggingCarryingView carryingView:GZFlingCarryingView)->Void
    optional func flingView(flingView:GZFlingView, didDragCarryingView carryingView:GZFlingCarryingView, withContentOffset contentOffset:CGPoint)->Void
    
    optional func flingView(flingView:GZFlingView, willEndDraggingCarryingView carryingView:GZFlingCarryingView) -> Void
    optional func flingView(flingView:GZFlingView, didEndDraggingCarryingView carryingView:GZFlingCarryingView) -> Void
    
    optional func flingView(flingView:GZFlingView, willArriveEndIndex index:Int)->Void
    optional func flingView(flingView:GZFlingView, didArriveEndIndex index:Int)->Void
    
}

//MARK:- Datasource Methods Declare

@objc public protocol GZFlingViewDatasource : NSObjectProtocol{
    func numberOfCarryingViewsForReusingInFlingView(flingView:GZFlingView) -> Int
    func flingView(flingView:GZFlingView, carryingViewForReusingAtIndex reuseIndex:Int) -> GZFlingCarryingView
    
    optional func flingView(flingView:GZFlingView, shouldEndAtIndex index:Int)->Bool
    optional func flingView(flingView:GZFlingView, preparingCarryingView carryingView:GZFlingCarryingView, atFlingIndex index:Int)->Void
}

