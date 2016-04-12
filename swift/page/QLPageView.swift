//
//  QLPageView.swift
//  page
//
//  Created by Qingwei Lan on 4/9/16.
//  Copyright © 2016 Qingwei Lan. All rights reserved.
//

import Foundation
import UIKit

enum ButtonBarStyle {
    case Default
    case WithLabel
    case WithRightSwitch
}

// ------------------------------------------------------
// This protocol represents the data model object
// ------------------------------------------------------
@objc protocol QLPageViewDataSource: class {
    
    /**
     Title of the button associated with the page at index.
     */
    func titleForButtonForPageAtIndex(sender: QLPageView, index: Int) -> String
    
    /**
     View of the page at index.
     */
    func viewForPageAtIndex(sender: QLPageView, index: Int) -> UIView
    
    /**
     The page where the page view starts, default is 0.
     The initial displayed page always has index 0.
     Index must be in range: 0 <= index < numberOfPages.
     */
    optional func initialIndexForPageInPageView(sender: QLPageView) -> Int
    
    /**
     The number of pages in the page view, default is 0.
     Maximum number of pages is 6.
     */
    optional func numberOfPagesInPageView(sender: QLPageView) -> Int
    
    /**
     Title of the button associated with the page at index.
     Only works if pageViewStyle is QLPageViewButtonStyleWithLabel.
     Default is nil.
     */
    optional func titleForLabelForPageAtIndex(sender: QLPageView, index: Int) -> String
    
    /**
     Selected index for page view, default is initialIndex.
     */
    optional func selectedIndexForPageView(sender: QLPageView) -> Int
}

// ------------------------------------------------------
// This protocol represents the display and behaviour
// ------------------------------------------------------
@objc protocol QLPageViewDelegate: class {
    
    /**
     Sets the height for the button bar.
     Default height is 50.0.
     */
    optional func heightForButtonBarForPageView(sender: QLPageView) -> CGFloat
    
    /**
     Sets the color of the button bar.
     Default is black color.
     */
    optional func colorForButtonBarForPageView(sender: QLPageView) -> UIColor
    
    /**
     Sets the color of the button bar selection indicator.
     Default is white color.
     */
    optional func colorForButtonBarSelectionIndicatorForPageView(sender: QLPageView) -> UIColor
    
    /**
     Sets the on tint color of the control switch.
     Default is yellow color.
     */
    optional func onTintColorForControlSwitchForPageView(sender: QLPageView) -> UIColor
    
    /**
     Sets the font of the button.
     Default font is Helvetica-Bold with size 14.0.
     */
    optional func fontForButtonsForPageView(sender: QLPageView) -> UIFont
    
    /**
     Sets the font of the label.
     Default font is Helvetica with size 10.0.
     */
    optional func fontForLabelsForPageView(sender: QLPageView) -> UIFont
    
    /**
     Called when Control Switch changes value.
     */
    optional func controlSwitchDidChangeValue(sender: QLPageView, value: Bool)
    
    /**
     Called when page changed.
     */
    optional func didMoveToPage(sender: QLPageView, page: Int)
}

@objc class QLPageView: UIView, UIScrollViewDelegate {
    
    weak var dataSource: QLPageViewDataSource? = nil
    weak var delegate: QLPageViewDelegate? = nil
    
    /**
     The declared style of the pageView that defines the appearance of the button bar
     */
    var pageViewStyle: ButtonBarStyle = .Default
    
    /**
     Initial index of the page view
     */
    var initialIndex = 0
    
    /**
     Number of pages in the page view
     */
    var numberOfPages = 0
    
    /**
     Height of the button bar
     */
    var buttonBarHeight: CGFloat = 50.0
    
    /**
     The control switch defined in the button bar, nil if pageViewStyle is not
     .WithRightSwitch
     */
    private(set) var controlSwitch: UISwitch? = nil
    
    /**
     Currently selected page index.
     */
    private(set) var selectedIndex = 0 {
        didSet {
            deselectButtonAtIndex(oldValue)
            selectButtonAtIndex(selectedIndex)
        }
    }
    
    /**
     Color of button bar (also color of button titles).
     Default color is black.
     */
    var buttonBarColor: UIColor = UIColor.blackColor()
    
    /**
     On tint color of the control switch.
     Default color is yellow.
     */
    var switchOnTintColor = UIColor.yellowColor()
    
    /**
     Font of button bar buttons.
     Default font is Helvetica-Bold with size 14.0.
     */
    var buttonFont = UIFont(name: "Helvetica-Bold", size: 14.0)!
    
    /**
     Font of button bar labels (if the labels exist).
     Default font is Helvetica with size 10.0.
     Can be nil unless pageViewStyle is .WithLabel.
     */
    var labelFont = UIFont(name: "Helvetica", size: 10.0)!
    
    
    /**
     Scroll view containing the views of the pages.
     */
    private var containerScrollView: UIScrollView? = nil
    
    /**
     View containing the buttons of the pages
     */
    private var buttonBar: UIView? = nil
    
    /**
     Circle used to indicate selected page
     */
    private var selectionIndicator: UIView? = nil
    
    /**
     Color of button bar selection indicator.
     Default color is white.
     */
    private var buttonBarSelectionIndicatorColor = UIColor.whiteColor()
    
    /**
     Array that keeps hold of all buttons
     */
    private var buttons = [UIButton]()
    
    /**
     Array that keeps hold of all labels
     */
    private var labels = [UILabel]()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didMoveToSuperview() {
        if self.superview != nil {
            reloadPageView()
        }
    }
    
    func reloadPageView() {
        if dataSource == nil {
            return
        }
        if let selectedIndex = dataSource?.selectedIndexForPageView?(self) {
            self.selectedIndex = selectedIndex
        }
        if let initialIndex = dataSource?.initialIndexForPageInPageView?(self) {
            self.initialIndex = initialIndex
        }
        
        selectedIndex = initialIndex
        
        // Remove all subviews
        for view in self.subviews {
            view.removeFromSuperview()
        }
        
        // Initializations
        loadContainerScrollView()
        loadButtonBar()
        
        gotoPage(selectedIndex, animated: false)
        selectButtonAtIndex(selectedIndex)
    }
    
    func loadContainerScrollView() {
        if let buttonBarHeight = delegate?.heightForButtonBarForPageView?(self) {
            self.buttonBarHeight = buttonBarHeight
        }
        if let numberOfPages = dataSource?.numberOfPagesInPageView?(self) {
            self.numberOfPages = numberOfPages
        }
        
        containerScrollView = UIScrollView(frame: CGRectMake(0, buttonBarHeight, self.frame.size.width, self.frame.size.height - buttonBarHeight))
        self.addSubview(containerScrollView!)
        containerScrollView?.contentSize = CGSizeMake(CGRectGetWidth(self.frame) * CGFloat(numberOfPages), 1)
        
        containerScrollView?.delegate = self
        containerScrollView?.pagingEnabled = true
        containerScrollView?.showsHorizontalScrollIndicator = false
        containerScrollView?.showsVerticalScrollIndicator = false
        containerScrollView?.directionalLockEnabled = true
        containerScrollView?.bounces = false
        
        for i in 0...numberOfPages-1 {
            loadPageWithIndex(i)
        }
    }
    
    func loadPageWithIndex(index: Int) {
        // Get view from dataSource
        let page = dataSource?.viewForPageAtIndex(self, index: index)
        
        // Setup frame of page
        var frame = containerScrollView?.frame
        frame?.origin.x = frame!.size.width * CGFloat(index)
        frame?.origin.y = 0
        page?.frame = frame!
        
        containerScrollView?.addSubview(page!)
    }
    
    func loadButtonBar() {
        if let buttonBarHeight = delegate?.heightForButtonBarForPageView?(self) {
            self.buttonBarHeight = buttonBarHeight
        }
        if let buttonBarColor = delegate?.colorForButtonBarForPageView?(self) {
            self.buttonBarColor = buttonBarColor
        }
        
        // Initialize button bar
        buttonBar = UIView(frame: CGRectMake(0, 0, self.frame.size.width, buttonBarHeight))
        buttonBar?.backgroundColor = buttonBarColor
        self.addSubview(buttonBar!)
        
        loadButtons()
    }
    
    func loadButtons() {
        if let numberOfPages = dataSource?.numberOfPagesInPageView?(self) {
            self.numberOfPages = numberOfPages
        }
        if let buttonBarSelectionIndicatorColor = delegate?.colorForButtonBarSelectionIndicatorForPageView?(self) {
            self.buttonBarSelectionIndicatorColor = buttonBarSelectionIndicatorColor
        }
        if let buttonBarColor = delegate?.colorForButtonBarForPageView?(self) {
            self.buttonBarColor = buttonBarColor
        }
        
        var gapV: CGFloat = 0.0
        var gapH: CGFloat = 0.0
        var selectionIndicatorY: CGFloat = 0.0
        var buttonWidth: CGFloat = 0.0
        var labelWidth: CGFloat = 0.0
        
        switch pageViewStyle {
        case .Default:
            gapV = buttonBar!.bounds.size.height/6.0
            buttonWidth = 4.0*gapV
            let temp = ((numberOfPages-1) < 0) ? 0 : (numberOfPages-1)
            gapH = (buttonBar!.bounds.size.width - CGFloat(numberOfPages)*buttonWidth - CGFloat(temp)*2*gapV)/2.0
            selectionIndicatorY = gapV
            
        case .WithLabel:
            gapV = buttonBar!.bounds.size.height/7.0
            buttonWidth = 4.0*gapV
            labelWidth = 1.5*gapV
            let temp = ((numberOfPages-1) < 0) ? 0 : (numberOfPages-1)
            gapH = (buttonBar!.bounds.size.width - CGFloat(numberOfPages)*buttonWidth - CGFloat(temp)*2*gapV)/2.0
            selectionIndicatorY = 2*gapV
        
        case .WithRightSwitch:
            if let switchOnTintColor = delegate?.onTintColorForControlSwitchForPageView?(self) {
                self.switchOnTintColor = switchOnTintColor
            }
            
            let switchX = buttonBar!.bounds.size.width*(3/4.0)
            let switchY = buttonBar!.bounds.size.height/2.0 - 15.0
            
            // Add switch
            controlSwitch = UISwitch(frame: CGRectMake(switchX, switchY, 10.0, 10.0))
            controlSwitch?.addTarget(self, action: #selector(QLPageView.switchChangedValue(_:)), forControlEvents: UIControlEvents.ValueChanged)
            controlSwitch?.onTintColor = switchOnTintColor
            buttonBar?.addSubview(controlSwitch!)
            
            let contentWidth: CGFloat = switchX;
            gapV = buttonBar!.bounds.size.height/6.0;
            buttonWidth = 4.0*gapV;
            gapH = (contentWidth - CGFloat(numberOfPages)*buttonWidth) / (CGFloat(numberOfPages)+1);
            selectionIndicatorY = gapV;
        }
        
        // load selection indicator
        selectionIndicator = UIView(frame: CGRectMake(gapH, selectionIndicatorY, buttonWidth, buttonWidth))
        selectionIndicator?.backgroundColor = buttonBarSelectionIndicatorColor
        selectionIndicator?.layer.cornerRadius = 2*gapV
        buttonBar?.addSubview(selectionIndicator!)
        
        // load buttons & Labels
        for i in 0...numberOfPages-1 {
            var button: UIButton? = nil
            switch pageViewStyle {
            case .Default:
                button = UIButton(frame: CGRectMake(gapH+CGFloat(i)*6*gapV, 2*gapV, buttonWidth, buttonWidth))
                
            case .WithLabel:
                button = UIButton(frame: CGRectMake(gapH+CGFloat(i)*6*gapV, 2*gapV, buttonWidth, buttonWidth))
                
                // add labels
                let label = UILabel(frame: CGRectMake(gapH+CGFloat(i)*6*gapV, 0, buttonWidth, labelWidth))
                if let title = dataSource?.titleForLabelForPageAtIndex?(self, index: i) {
                    label.text = title
                } else {
                    label.text = ""
                }
                label.font = labelFont
                label.textColor = buttonBarSelectionIndicatorColor
                label.textAlignment = NSTextAlignment.Center
                label.userInteractionEnabled = false
                buttonBar?.addSubview(label)
                labels.append(label)
            
            case .WithRightSwitch:
                button = UIButton(frame: CGRectMake(gapH+CGFloat(i)*(gapH+buttonWidth), gapV, buttonWidth, buttonWidth))
            }
            
            button?.layer.cornerRadius = 2*gapV
            button?.backgroundColor = UIColor.clearColor()
            button?.setTitle(dataSource?.titleForButtonForPageAtIndex(self, index: i), forState: UIControlState.Normal)
            button?.setTitleColor(buttonBarSelectionIndicatorColor, forState: UIControlState.Normal)
            button?.titleLabel?.font = buttonFont
            button?.titleLabel?.textAlignment = NSTextAlignment.Center
            button?.addTarget(self, action: #selector(QLPageView.selectPage(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            buttonBar?.addSubview(button!)
            buttons.append(button!)
        }
    }
    
    func gotoPage(index: Int, animated: Bool) {
        var bounds = containerScrollView?.bounds
        bounds?.origin.x = CGRectGetWidth(bounds!) * CGFloat(index)
        bounds?.origin.y = 0.0
        containerScrollView?.scrollRectToVisible(bounds!, animated: animated)
    }
    
    func selectButtonAtIndex(index: Int) {
        if let buttonBarColor = delegate?.colorForButtonBarForPageView?(self) {
            self.buttonBarColor = buttonBarColor
        }
        
        if buttons.count != 0 {
            let button = buttons[index]
            button.setTitleColor(buttonBarColor, forState: UIControlState.Normal)
        }
    }
    
    func deselectButtonAtIndex(index: Int) {
        if let buttonBarSelectionIndicatorColor = delegate?.colorForButtonBarSelectionIndicatorForPageView?(self) {
            self.buttonBarSelectionIndicatorColor = buttonBarSelectionIndicatorColor
        }
        
        if buttons.count != 0 {
            let button = buttons[index]
            button.setTitleColor(buttonBarSelectionIndicatorColor, forState: UIControlState.Normal)
        }
    }
    
    @objc func switchChangedValue(sender: UISwitch) {
        delegate?.controlSwitchDidChangeValue?(self, value: sender.on)
    }
    
    @objc func selectPage(sender: UIButton) {
        let i = buttons.indexOf(sender)
        gotoPage(i!, animated: true)
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let pageWidth = CGRectGetWidth(containerScrollView!.frame)
        let contentWidth = containerScrollView!.contentSize.width - pageWidth
        
        if contentWidth != 0 {
            let scrolledPercentage: CGFloat = containerScrollView!.contentOffset.x / contentWidth
            let lastButton = buttons.last
            let firstButton = buttons.first
            let barWidth = lastButton!.frame.origin.x - firstButton!.frame.origin.x
            
            var frame = selectionIndicator?.frame
            frame?.origin.x = firstButton!.frame.origin.x + scrolledPercentage * barWidth
            selectionIndicator?.frame = frame!
            
            let index = Int(floor((containerScrollView!.contentOffset.x - pageWidth / 2) / pageWidth) + 1)
            if index != selectedIndex {
                selectedIndex = index
                delegate?.didMoveToPage?(self, page: selectedIndex)
            }
        }
    }
    
}
