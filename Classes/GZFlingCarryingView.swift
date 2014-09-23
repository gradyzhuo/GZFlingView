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
    
    @IBOutlet public var customView:UIView! = UIView(){
        willSet{
            
            if (newValue != customView) {
                self.customView!.removeFromSuperview()
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
    
    func reset(){
        
        self.superview?.sendSubviewToBack(self)
        
        if self.constraints().count > 0{
            self.setNeedsLayout()
        }else{
            self.customView.frame = self.bounds
        }
        
    }
    
    func prepareForShow(){
        self.reset()
        
        self.alpha = 1.0
        
    }
    
    deinit{
        println("GZFlingCarryingView is deinit")
        
    }
    
}
