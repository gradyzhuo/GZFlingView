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
    
    
    public init(customView:UIView!) {
        super.init()
        
        self.customView = customView
        self.addSubview(customView)
        
        self.initialize()
    }
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initialize()
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
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
        var context = UIGraphicsGetCurrentContext()
        CGContextSetAllowsAntialiasing(context, true)
        CGContextSetShouldAntialias(context, true)
    }
    
}
