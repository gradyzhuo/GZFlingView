//
//  GZFlingViewAnimation.swift
//  GZFlingViewDemo
//
//  Created by Grady Zhuo on 12/11/14.
//  Copyright (c) 2014 Grady Zhuo. All rights reserved.
//

import UIKit

public typealias GZFlingViewAnimationGestureInfo = (gestureRecognizer:UIPanGestureRecognizer?, translation: CGPoint, velocity: CGPoint)

enum GZFlingViewAnimationState:Int{
    case Init = 0
}


//MARK: - Animation Abstractor

let kGZFlingViewAnimationDuration:NSTimeInterval = 0.2


public protocol Animation {
    
    var flingView:GZFlingView! { get }
    var beginLocation:CGPoint { get }
    
    var expectedMinSize:Int { get }
    
    func gesturePanning(gestureInfo gestureInfo:GZFlingViewAnimationGestureInfo, currentNode:GZFlingNode!)
    func willBeginGesture(gestureInfo gestureInfo:GZFlingViewAnimationGestureInfo, currentNode:GZFlingNode!)
    func didEndGesture(gestureInfo gestureInfo:GZFlingViewAnimationGestureInfo, currentNode:GZFlingNode!)
    
    func prepare(node node:GZFlingNode)
    func willAppear(node node:GZFlingNode!)
    func didAppear(node node:GZFlingNode!)
    
    
    func shouldCancel(direction direction:GZFlingViewSwipingDirection, currentNode:GZFlingNode?, gestureInfo:GZFlingViewAnimationGestureInfo)->Bool
    func showChoosenAnimation(direction direction:GZFlingViewSwipingDirection, currentNode:GZFlingNode?, gestureInfo:GZFlingViewAnimationGestureInfo, completionHandler:((finished:Bool)->Void))
    func showRestoreAnimation(direction direction:GZFlingViewSwipingDirection, currentNode:GZFlingNode?, gestureInfo:GZFlingViewAnimationGestureInfo,completionHandler:((finished:Bool)->Void))
    
}

public class GZFlingViewAnimation : Animation {
    
    public internal(set) var flingView:GZFlingView!
    public internal(set) var beginLocation:CGPoint = CGPoint()
    
    init(){
        
    }
    
    public var expectedMinSize:Int {
        return 0
    }
    
    public func gesturePanning(gestureInfo gestureInfo:GZFlingViewAnimationGestureInfo, currentNode:GZFlingNode!){}
    public func willBeginGesture(gestureInfo gestureInfo:GZFlingViewAnimationGestureInfo, currentNode:GZFlingNode!){}
    public func didEndGesture(gestureInfo gestureInfo:GZFlingViewAnimationGestureInfo, currentNode:GZFlingNode!){}
    
    
    public func prepare(node node:GZFlingNode){
        /*template*/
    }
    
    public func willAppear(node node:GZFlingNode!){
        /*template*/
    }
    
    public func didAppear(node node:GZFlingNode!){
        /*template*/
    }
    
    
    public func shouldCancel(direction direction:GZFlingViewSwipingDirection, currentNode:GZFlingNode?, gestureInfo:GZFlingViewAnimationGestureInfo)->Bool{return true}
    public func showChoosenAnimation(direction direction:GZFlingViewSwipingDirection, currentNode:GZFlingNode?, gestureInfo:GZFlingViewAnimationGestureInfo, completionHandler:((finished:Bool)->Void)){completionHandler(finished: true)}
    
    public func showRestoreAnimation(direction direction:GZFlingViewSwipingDirection, currentNode:GZFlingNode?, gestureInfo:GZFlingViewAnimationGestureInfo, completionHandler:((finished:Bool)->Void)){completionHandler(finished: true)}
    
}
