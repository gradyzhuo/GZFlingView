//
//  ViewController.swift
//  GZFlingViewDemo
//
//  Created by Grady Zhuo on 10/13/15.
//  Copyright © 2015 Grady Zhuo. All rights reserved.
//

import UIKit
import GZFlingView

class ViewController: UIViewController, GZFlingViewDelegate, GZFlingViewDatasource {
    
    
    @IBOutlet weak var flingView:GZFlingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let tinderAnimation = self.flingView.animation as? GZFlingViewAnimationTinder {
//            tinderAnimation.initalScaleValue = 
//            tinderAnimation.secondInitalScaleValue = 0.9
//            tinderAnimation.targetScaleValue = 0.8
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func carryingViewForReusingAtIndexInFlingView(flingView: GZFlingView, carryingViewForReusingAtIndex reuseIndex: Int) -> GZFlingCarryingView {
        
        let view = UIView()
        let carryingView = GZFlingCarryingView(customView: view)
        carryingView.backgroundColor = reuseIndex == 0 ? UIColor.redColor() : (reuseIndex == 1 ? UIColor.yellowColor() : reuseIndex == 2 ? UIColor.orangeColor() : UIColor.greenColor())
        
        return carryingView
      
    }
    
    func flingViewShouldEnd(flingView: GZFlingView, atFlingIndex index: Int) -> Bool {
        return index >= 10
    }
    
    func flingViewDidDragCarryingView(flingView: GZFlingView, withDraggingCarryingView carryingView: GZFlingCarryingView, withContentOffset contentOffset: CGPoint) {
        print("contentOffset:\(contentOffset)")
    }
    
//    func numberOfCarryingViewsForReusingInFlingView(flingView: GZFlingView) -> Int {
//        return 4
//    }
//    
//
    
//    func flingView(flingView: GZFlingView, didDragCarryingView carryingView: GZFlingCarryingView, withContentOffset contentOffset: CGPoint) {
//        print("contentOffset:\(contentOffset)")
//    }
//    
//    func flingView(flingView: GZFlingView, shouldEndAtIndex index: Int) -> Bool {
//        return index > 10
//    }
    
}

