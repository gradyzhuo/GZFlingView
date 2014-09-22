//
//  GZFlingCarryingView.swift
//  Flingy
//
//  Created by Grady Zhuo on 2014/9/21.
//  Copyright (c) 2014年 Grady Zhuo. All rights reserved.
//

import UIKit

public typealias GZFlingCarryingView = GZFlingView.CarryingView

public extension GZFlingView {
    
    public class CarryingView: UIView {
        
        public var flingIndex:Int = 0
        
        public var customView:UIView = UIView() {
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
        
        
        public init(customView:UIView!) {
            super.init()
            
            self.customView = customView
            self.addSubview(customView)
            
        }
        
        public override init(frame: CGRect) {
            super.init(frame: frame)
            
        }
        
        public required init(coder aDecoder: NSCoder) {
            super.init()
        }
        
        public override func layoutSubviews() {
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