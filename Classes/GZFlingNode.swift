//
//  GZFlingNode.swift
//  GZKit
//
//  Created by Grady Zhuo on 2014/9/14.
//  Copyright (c) 2014年 Grady Zhuo. All rights reserved.
//

import Foundation

//typealias GZFlingNodesQueue = GZFlingNode.LoopQueue

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
    internal var rearNode:GZFlingNode!{
        get{
            return self.privateQueueInstance.rearNode
        }
    }
    
    /**
    (readonly)
    */
    internal var currentNode:GZFlingNode!{
        get{
            return self.privateQueueInstance.currentNode
        }
    }
    
    /**
    (readonly)
    */
    var nextNode:GZFlingNode! {
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
    
    //        func pop() -> GZFlingNode? {
    //
    //            var frontNode = self.frontNode
    //
    //            self.frontNode = frontNode?.nextNode
    //
    //            if self.rearNode != self.frontNode {
    //                self.rearNode?.nextNode = self.frontNode
    //            }else{
    //                self.rearNode?.nextNode = nil
    //
    //            return frontNode
    //
    //        }
    
    func push(#node:GZFlingNode){
        
        var copy = node.copy() as GZFlingNode
        
        if let frontNode = self.privateQueueInstance.frontNode {
            copy.privateInstance.nextNode = frontNode
            self.privateQueueInstance.rearNode!.privateInstance.nextNode = copy
            self.privateQueueInstance.rearNode = copy
            
        }else{
            copy.privateInstance.nextNode = copy
            self.privateQueueInstance.frontNode = copy
            self.privateQueueInstance.rearNode = copy
            self.privateQueueInstance.currentNode = copy
        }
        
        self.privateQueueInstance.size++
        
    }
    
    func next() -> GZFlingNode {
        
        var nextNode:GZFlingNode = (self.currentNode?.nextNode)!
        self.privateQueueInstance.currentNode = nextNode
        
        self.privateQueueInstance.rearNode = self.rearNode?.nextNode
        self.privateQueueInstance.frontNode = self.frontNode?.nextNode
        
        return nextNode
    }
    
    func preNext() -> GZFlingNode {
        
        var nextNode:GZFlingNode = (self.currentNode?.nextNode)!
        self.privateQueueInstance.currentNode = nextNode
        
        return nextNode
    }
    
    func enumerateObjectsUsingBlock(block:(node:GZFlingNode, idx:Int, isEnded:UnsafeMutablePointer<Bool>)->Void){
        
        
        if self.size == 0 {
            return
        }
        
        
        var isEndedPtr = false
        
        var rearNode = self.rearNode
        var node = self.frontNode!
        var idx = 0
        
        do{
            
            block(node: node, idx: idx++, isEnded: &isEndedPtr)
            node = node.nextNode
            
        }while (node != self.frontNode) && (!isEndedPtr)
        
    }
    
    func reset(){
        
        if self.size == 0 {
            return
        }
        
        self.rearNode.privateInstance.nextNode = nil
        
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
        GZDebugLog(self)
        
        var a = NSArray()
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


class GZFlingNode : NSObject, NSCopying {
    
    // MARK: SubClass Define
    
    
    // MARK: Properties
    
    /**
        (readonly)
    */
    var nextNode:GZFlingNode!{
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
    
    
    private var privateInstance:PrivateInstance
    
    init(carryingView:GZFlingCarryingView) {
        self.privateInstance = PrivateInstance(carryingView: carryingView)
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        
        return GZFlingNode(carryingView: self.carryingView)
        
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



