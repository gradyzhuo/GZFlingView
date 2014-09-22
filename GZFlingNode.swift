//
//  GZFlingNode.swift
//  GZKit
//
//  Created by Grady Zhuo on 2014/9/14.
//  Copyright (c) 2014年 Grady Zhuo. All rights reserved.
//

import Foundation

typealias GZFlingNodesQueue = GZFlingNode.LoopQueue

class GZFlingNode:NSObject,NSCopying {
    
    // MARK: SubClass Define
    
    class LoopQueue{
        
        /**
            (readonly)
        */
        var frontNode:GZFlingNode!{
            get{
                return PrivateQueueInstance.frontNode
            }
            
        }
        
        /**
            (readonly)
        */
        var rearNode:GZFlingNode!{
            get{
                return PrivateQueueInstance.rearNode
            }
        }
        
        /**
            (readonly)
        */
        var currentNode:GZFlingNode!{
            get{
                return PrivateQueueInstance.currentNode
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
        var size:Int{
            get{
                return PrivateQueueInstance.size
            }
        }
        
        init(){
            PrivateQueueInstance.size = 0
            
        }
        
        init(frontNode:GZFlingNode){
            
            var copy = frontNode.copy() as GZFlingNode
            
            self.push(node: frontNode)
            
            PrivateQueueInstance.size = 1
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
            
            if let frontNode = PrivateQueueInstance.frontNode {
                copy.privateInstance.nextNode = frontNode
                PrivateQueueInstance.rearNode!.privateInstance.nextNode = copy
                PrivateQueueInstance.rearNode = copy
                
            }else{
                copy.privateInstance.nextNode = copy
                PrivateQueueInstance.frontNode = copy
                PrivateQueueInstance.rearNode = copy
                PrivateQueueInstance.currentNode = copy
            }
            
            PrivateQueueInstance.size++
            
        }
        
        func next() -> GZFlingNode {
            
            var nextNode:GZFlingNode = (self.currentNode?.nextNode)!
            PrivateQueueInstance.currentNode = nextNode
            
            PrivateQueueInstance.rearNode = self.rearNode?.nextNode
            PrivateQueueInstance.frontNode = self.frontNode?.nextNode
            
            return nextNode
        }
        
        var description:String{
            get{
                var rearNode = self.rearNode
                var printNode = self.frontNode
                
                var descriptionString = ""
                
                do{
                    
                    descriptionString += "\(printNode)->"
                    
                    printNode = (printNode?.nextNode)!
                    
                }while printNode != self.frontNode
                
                return descriptionString
            }
        }
        
        func printLinkedList(){
            println(self)
        }
        
        // MARK: PrivateQueueInstance
        
        private struct PrivateQueueInstance {
            static var frontNode : GZFlingNode?
            static var rearNode : GZFlingNode?
            static var currentNode : GZFlingNode?
            
            static var size:Int = 0
            
        }
        
    }
    
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
    
    
    private let privateInstance:PrivateInstance
    
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
        
    }
    
    
}

func += (nodeList:GZFlingNodesQueue, node:GZFlingNode){
    nodeList.push(node: node)
}



