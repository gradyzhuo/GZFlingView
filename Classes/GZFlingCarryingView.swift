//
//  GZFlingCarryingView.swift
//  GZFlingViewDemo
//
//  Created by Grady Zhuo on 12/11/14.
//  Copyright (c) 2014 Grady Zhuo. All rights reserved.
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
    
    
    public convenience init(customView:UIView!) {
        self.init(frame: .zero)
        
        self.customView = customView
        self.addSubview(customView)
        
        self.initialize()
    }
    
    
    func initialize(){
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.mainScreen().scale
    }
    
    public func prepareForReuse(){
        
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
