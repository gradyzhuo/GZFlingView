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
    
    
    var maxCount:Int = 0
    @IBOutlet weak var flingView:GZFlingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        if let tinderAnimation = self.flingView.animation as? GZFlingViewAnimationTinder {
//            tinderAnimation.initalScaleValue = 1.0
//            tinderAnimation.secondInitalScaleValue = 0.9
//            tinderAnimation.targetScaleValue = 0.8
//        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func reset(){
        
        
    }
    
    
    //MARK: -
    
    func carryingViewTemplateInFlingView(flingView: GZFlingView) -> GZFlingCarryingViewTemplate {
        return GZFlingCarryingViewTemplate(nibName: "CarryView", inBundle: nil)
    }
    
    func flingView(flingView: GZFlingView, carryingViewForReusingAtIndex reuseIndex: Int) -> GZFlingCarryingView {
        
        let view = UIView()
        let carryingView = GZFlingCarryingView(customView: view)
        carryingView.backgroundColor = reuseIndex == 0 ? UIColor.redColor() : (reuseIndex == 1 ? UIColor.yellowColor() : reuseIndex == 2 ? UIColor.orangeColor() : UIColor.greenColor())
//        carryingView.backgroundColor = carryingView.backgroundColor?.colorWithAlphaComponent(0.5)
        
        return UINib(nibName: "CarryView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! GZFlingCarryingView
        
    }
    
    func flingView(flingView: GZFlingView, preparingCarryingView carryingView: GZFlingCarryingView, atFlingIndex index: Int) {
        let rIndex = index % 4
        carryingView.backgroundColor =  rIndex == 0 ? UIColor.redColor() : (rIndex == 1 ? UIColor.yellowColor() : rIndex == 2 ? UIColor.orangeColor() : UIColor.greenColor())
    }
    
    func flingView(flingView: GZFlingView, shouldEndAtFlingIndex index: Int) -> Bool {
        print("index:\(index)")
        return maxCount == 0 ? false : index >= maxCount
    }
    
    func flingView(flingView: GZFlingView, didDragCarryingView carryingView: GZFlingCarryingView, withContentOffset contentOffset: CGPoint) {
        print("contentOffset:\(contentOffset)")
    }
    
}

