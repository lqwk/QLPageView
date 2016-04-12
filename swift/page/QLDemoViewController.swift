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
        switch index {
        case 0: return "Mon"
        case 1: return "Tue"
        case 2: return "Wed"
        case 3: return "Thu"
        case 4: return "Fri"
        case 5: return "Sat"
        default: break
        }
        return ""
    }
    
    func titleForButtonForPageAtIndex(sender: QLPageView, index: Int) -> String {
        return "\(index+1)"
    }
    
    func viewForPageAtIndex(sender: QLPageView, index: Int) -> UIView {
        let view = UIView(frame: self.view.bounds)
        if index % 2 == 0 {
            view.backgroundColor = UIColor.blackColor()
        } else {
            view.backgroundColor = UIColor.cyanColor()
        }
        return view
    }
}
