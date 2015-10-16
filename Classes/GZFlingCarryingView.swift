//
//  GZFlingCarryingView.swift
//  GZFlingViewDemo
//
//  Created by Grady Zhuo on 12/11/14.
//  Copyright (c) 2014 Grady Zhuo. All rights reserved.
//

import UIKit

public enum GZFlingCarryingViewTemplateType{
    case Xib(UINib)
    case Class(GZFlingCarryingView.Type)
}

public class GZFlingCarryingViewTemplate:NSObject {
    
    public internal(set) var type:GZFlingCarryingViewTemplateType
    
    public init(cls: GZFlingCarryingView.Type){
        self.type = .Class(cls)
    }
    
    public init(nibName: String, inBundle bundle:NSBundle!){
        self.type = .Xib(UINib(nibName: nibName, bundle: bundle))
    }
    
    public init(xib: UINib){
        self.type = .Xib(xib)
    }
    
    internal func instantiate() -> GZFlingCarryingView? {
        
        if case let .Class(cls) = self.type {
            let carryingView = cls.init()
            return carryingView
        }
        
        if case let .Xib(xib) = self.type {
            let views = xib.instantiateWithOwner(nil, options: nil)
            if let carryingView = views.first as? GZFlingCarryingView {
                return carryingView
            }else{
                return nil
            }
        }
        
        return nil
        
    }
}

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
