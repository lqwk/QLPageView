//
//  QLDemoViewController.swift
//  page
//
//  Created by Qingwei Lan on 4/9/16.
//  Copyright © 2016 Qingwei Lan. All rights reserved.
//

import Foundation
import UIKit

class QLDemoViewController: UIViewController, QLPageViewDelegate, QLPageViewDataSource {
    
    var pageView: QLPageView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageView = QLPageView(frame: self.view.bounds)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        pageView?.frame = self.view.bounds
        pageView?.pageViewStyle = ButtonBarStyle.WithLabel
        pageView?.dataSource = self
        pageView?.delegate = self
        self.view.addSubview(pageView!)
    }
    
    func initialIndexForPageInPageView(sender: QLPageView) -> Int {
        return 1
    }
    
    func numberOfPagesInPageView(sender: QLPageView) -> Int {
        return 6
    }
    
    func titleForLabelForPageAtIndex(sender: QLPageView, index: Int) -> String {
        return "Wed"
    }
    
    func titleForButtonForPageAtIndex(sender: QLPageView, index: Int) -> String {
        return "6"
    }
    
    func viewForPageAtIndex(sender: QLPageView, index: Int) -> UIView {
        let view = UIView(frame: self.view.bounds)
        if index % 2 == 0 {
            view.backgroundColor = UIColor.blackColor()
        } else {
            view.backgroundColor = UIColor.blueColor()
        }
        return view
    }
}
