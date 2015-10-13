//
//  GZFlingCarryingView.swift
//  Flingy
//
//  Created by Grady Zhuo on 2014/9/21.
//  Copyright (c) 2014年 Grady Zhuo. All rights reserved.
//

import UIKit

public class GZFlingCarryingView: UIView {
    
    public internal(set) var flingIndex:Int = 0
    public internal(set) var flingView:GZFlingView!
    
    @IBOutlet public var customView:UIView! = UIView(){
        
        willSet{
            
            if (newValue != customView) {
                self.customView?.removeFromSuperview()
            }
            
        }
        
        didSet{
            
            if oldValue != customView  {
                self.addSubview(customView!)
            }
        }
        
    }
    
    
    public convenience init(customView:UIView!) {
        self.init(frame: .zero)
        
        self.customView = customView
        self.addSubview(customView)
    }
    
    public func prepareForReuse(){
        //template
    }
    
    deinit{
        //        GZDebugLog("GZFlingCarryingView is deinit")
    }
    
    override public func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextSetAllowsAntialiasing(context, true)
        CGContextSetShouldAntialias(context, true)
    }
    
}

