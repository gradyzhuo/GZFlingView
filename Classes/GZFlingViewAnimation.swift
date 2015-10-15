//
//  GZFlingViewAnimation.swift
//  GZFlingViewDemo
//
//  Created by Grady Zhuo on 12/11/14.
//  Copyright (c) 2014 Grady Zhuo. All rights reserved.
//

import UIKit

enum GZFlingViewAnimationState:Int{
    case Init = 0
}


//MARK: - Animation Abstractor

let kGZFlingViewAnimationDuration:NSTimeInterval = 0.2


public protocol Animation {
    
    var flingView:GZFlingView! { set get }
    var beginLocation:CGPoint { set get }
    
    var expectedMinSize:Int { get }
    
    func gesturePanning(gesture gesture:UIPanGestureRecognizer, currentNode:GZFlingNode!, translation:CGPoint)
    func willBeginGesture(gesture gesture:UIPanGestureRecognizer, currentNode:GZFlingNode!)
    func didEndGesture(gesture gesture:UIPanGestureRecognizer, currentNode:GZFlingNode!)
    
    func prepare(node node:GZFlingNode)
    func willAppear(node node:GZFlingNode!)
    func didAppear(node node:GZFlingNode!)
    
    
    func shouldCancel(direction direction:GZFlingViewSwipingDirection, currentNode:GZFlingNode?, translation:CGPoint)->Bool
    func showChoosenAnimation(direction direction:GZFlingViewSwipingDirection, currentNode:GZFlingNode?, translation:CGPoint, completionHandler:((finished:Bool)->Void))
    func showCancelAnimation(direction direction:GZFlingViewSwipingDirection, currentNode:GZFlingNode?, translation:CGPoint,completionHandler:((finished:Bool)->Void))
    
}

public class GZFlingViewAnimation : Animation {
    
    public var flingView:GZFlingView!
    public var beginLocation:CGPoint = CGPoint()
    
    init(){
        
    }
    
    public var expectedMinSize:Int {
        return 0
    }
    
    public func gesturePanning(gesture gesture:UIPanGestureRecognizer, currentNode:GZFlingNode!, translation:CGPoint){}
    public func willBeginGesture(gesture gesture:UIPanGestureRecognizer, currentNode:GZFlingNode!){}
    public func didEndGesture(gesture gesture:UIPanGestureRecognizer, currentNode:GZFlingNode!){}
    
    
    public func prepare(node node:GZFlingNode){
        /*template*/
    }
    
    public func willAppear(node node:GZFlingNode!){
        /*template*/
    }
    
    public func didAppear(node node:GZFlingNode!){
        /*template*/
    }
    
    
    public func shouldCancel(direction direction:GZFlingViewSwipingDirection, currentNode:GZFlingNode?, translation:CGPoint)->Bool{return true}
    public func showChoosenAnimation(direction direction:GZFlingViewSwipingDirection, currentNode:GZFlingNode?, translation:CGPoint, completionHandler:((finished:Bool)->Void)){completionHandler(finished: true)}
    
    public func showCancelAnimation(direction direction:GZFlingViewSwipingDirection, currentNode:GZFlingNode?, translation:CGPoint,completionHandler:((finished:Bool)->Void)){completionHandler(finished: true)}
    
}
