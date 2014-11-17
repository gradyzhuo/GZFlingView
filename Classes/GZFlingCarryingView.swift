//
//  GZFlingCarryingView.swift
//  Flingy
//
//  Created by Grady Zhuo on 2014/9/21.
//  Copyright (c) 2014年 Grady Zhuo. All rights reserved.
//

import UIKit

public class GZFlingCarryingView: UIView {
    
    public var flingIndex:Int = 0
    public var flingView:GZFlingView!
    
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
    
    
    public init(customView:UIView!) {
        super.init()
        
        self.customView = customView
        self.addSubview(customView)
    }
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func prepareForReuse(){
        
    }
    
    deinit{
        //        GZDebugLog("GZFlingCarryingView is deinit")
        
    }
    
    override public func drawRect(rect: CGRect) {
        var context = UIGraphicsGetCurrentContext()
        CGContextSetAllowsAntialiasing(context, true)
        CGContextSetShouldAntialias(context, true)
    }
    
}

