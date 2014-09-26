//
//  GZFlingViewAnimation.swift
//  Flingy
//
//  Created by Grady Zhuo on 2014/9/25.
//  Copyright (c) 2014年 Grady Zhuo. All rights reserved.
//

import Foundation

typealias GZFlingViewAnimationChoosingAnimationHandler = (flingView:GZFlingView ,carryingView:GZFlingCarryingView, beginLocation:CGPoint, translation:CGPoint)->Void

typealias GZFlingViewAnimationChoosedAnimationHandler = (flingView:GZFlingView, carryingView:GZFlingCarryingView, direction:GZFlingViewSwipingDirection, translation:CGPoint) -> Void

typealias GZFlingViewAnimationCompletionHandler = (flingView:GZFlingView, carryingView:GZFlingCarryingView, beginLocation:CGPoint) -> Void





class GZFlingViewAnimation {
    
    var flingView:GZFlingView!
    
    init(){
        self.flingView = nil
    }
    
    init(flingView:GZFlingView){
        self.flingView = flingView
    }
    
    var choosingClosure:GZFlingViewAnimationChoosingAnimationHandler {
        
        get{
            return { (flingView:GZFlingView, carryingView:GZFlingCarryingView, beginLocation:CGPoint, translation:CGPoint)->Void in
                
                //empty
            }
        }
        
    }
    
    var cancelAnimation:GZFlingViewAnimationCompletionHandler {
        get{
            return { (flingView:GZFlingView, carryingView:GZFlingCarryingView, beginLocation:CGPoint)->Void in
                
                //empty

            }
        }
    }
    
    var completionAnimation:GZFlingViewAnimationChoosedAnimationHandler {
        get{
            
            return { (flingView:GZFlingView, carryingView:GZFlingCarryingView, direction:GZFlingViewSwipingDirection, translation:CGPoint)->Void in
                
                //empty
                
            }
            
        }
    }

    
    var completionHandler:GZFlingViewAnimationCompletionHandler {
        
        get{
            return { (flingView:GZFlingView, carryingView:GZFlingCarryingView, beginLocation:CGPoint)->Void in
                
                //empty
            
            }
            
        }
    }

    
    
    
}



class GZFlingViewAnimationTinder:GZFlingViewAnimation{

    
    override var choosingClosure:GZFlingViewAnimationChoosingAnimationHandler {
        
        get{
            return {(flingView:GZFlingView ,carryingView:GZFlingCarryingView, beginLocation:CGPoint, translation:CGPoint)->Void in
                
                carryingView.layer.position = beginLocation.pointByOffsetting(translation.x, dy: translation.y)
                carryingView.transform = CGAffineTransformMakeRotation(GZFlingViewAnimationType.radomClosewise*fabs(translation.x)/100*0.1)
                
            }
        }
        
    }
    
    override var cancelAnimation:GZFlingViewAnimationCompletionHandler {
        get{
            return { (flingView:GZFlingView, carryingView:GZFlingCarryingView, beginLocation:CGPoint)->Void in
                carryingView.layer.position = beginLocation
                carryingView.transform = CGAffineTransformIdentity
            }
        }
    }
    
    override var completionAnimation:GZFlingViewAnimationChoosedAnimationHandler {
        get{
            
            return {(flingView:GZFlingView, carryingView:GZFlingCarryingView, direction:GZFlingViewSwipingDirection, translation:CGPoint)->Void in
                
                carryingView.layer.position.offset(translation.x*2, dy: translation.y*2)
                carryingView.transform = CGAffineTransformMakeRotation(GZFlingViewAnimationType.radomClosewise * 0.25)
                carryingView.alpha = 0
                
            }
            
        }
    }
    
    
    override var completionHandler:GZFlingViewAnimationCompletionHandler {
        
        get{
            
            return { (flingView:GZFlingView, carryingView:GZFlingCarryingView, beginLocation:CGPoint)->Void in
                carryingView.layer.position = beginLocation
                carryingView.transform = CGAffineTransformIdentity
            }
            
        }
    }
    
    
}