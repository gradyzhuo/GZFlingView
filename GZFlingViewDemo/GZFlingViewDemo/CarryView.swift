//
//  CarryView.swift
//  GZFlingViewDemo
//
//  Created by Grady Zhuo on 10/17/15.
//  Copyright © 2015 Grady Zhuo. All rights reserved.
//

import UIKit
import GZFlingView

class CarryView: GZFlingCarryingView {
    
    @IBAction func like(sender:AnyObject){
        self.flingView.choose(.Left)
    }
    
    @IBAction func nope(sender:AnyObject){
        self.flingView.choose(.Right)
    }
    
}