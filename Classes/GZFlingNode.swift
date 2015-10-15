//
//  GZFlingNode.swift
//  GZFlingViewDemo
//
//  Created by Grady Zhuo on 12/11/14.
//  Copyright (c) 2014 Grady Zhuo. All rights reserved.
//

import UIKit

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
        
        self.push(node: frontNode)
        
        self.privateQueueInstance.size = 1
    }
    
    
    func push(node node:GZFlingNode!){
        
        if node == nil {
            return
        }
        
        let copy = node.copy() as! GZFlingNode
        
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
        
        guard self.privateSize > 0 else{
            print("Please check your queue size, it's cannot be 0 to pop.")
            return nil
        }
        
        //取frontNode出來做為willPopNode
        let willPopNode = self.frontNode
        //先取frontNode的nextNode出來
        let nextFrontNode = willPopNode?.nextNode
        
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
        
        let nextNode:GZFlingNode = (self.currentNode?.nextNode)!
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

        for _ in 0 ..< self.privateQueueInstance.size {
            let poppedNode = self.pop()
            
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
            
            print("[\(idx)]node:\(node), next:\(node.nextNode)")
            
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
public class GZFlingNode : NSObject, NSCopying {
    
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
    
    public func copyWithZone(zone: NSZone) -> AnyObject {
        
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


extension GZFlingNodesQueue : CustomStringConvertible {
    var description:String{
        get{
            let printNode = self.frontNode
            
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