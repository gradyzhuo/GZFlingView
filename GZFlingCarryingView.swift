//
//  GZFlingCarryingView.swift
//  Flingy
//
//  Created by Grady Zhuo on 2014/9/21.
//  Copyright (c) 2014年 Grady Zhuo. All rights reserved.
//

import UIKit

typealias GZFlingCarryingView = GZFlingView.CarryingView

extension GZFlingView {
    
    class CarryingView: UIView {
        
        var flingIndex:Int = 0
        
        var customView:UIView = UIView() {
            willSet{
                
                if (newValue != customView) {
                    customView.removeFromSuperview()
                }
                
            }
            
            didSet{
                
                if oldValue != customView  {
                    self.addSubview(customView)
                }
            }
            
        }
        
        
        init(customView:UIView!) {
            super.init()
            
            self.customView = customView
            self.addSubview(customView)
            
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
        }
        
        required init(coder aDecoder: NSCoder) {
            super.init()
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            //        println("layoutSubviews")
            
            self.customView.frame = self.bounds
        }
        
        func relocation(#center:CGPoint!, prepareForShow showAgain:Bool){
            
            self.superview?.sendSubviewToBack(self)
            
            self.center = center
            self.transform = CGAffineTransformIdentity
            self.alpha = 1.0
            
            self.hidden = !showAgain
            
            
        }
        
        
    }
    
    
}