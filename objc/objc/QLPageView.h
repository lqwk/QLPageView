//
//  QLPageView.h
//  objc
//
//  Created by Qingwei Lan on 4/6/16.
//  Copyright © 2016 Qingwei Lan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    QLPageViewButtonBarStyleDefault,
    QLPageViewButtonBarStyleWithLabel,
    QLPageViewButtonBarStyleWithRightSwitch
} QLPageViewButtonBarStyle;

@protocol QLPageViewDataSource;
@protocol QLPageViewDelegate;

@interface QLPageView : UIView

@property (nonatomic, assign) id <QLPageViewDataSource> dataSource;
@property (nonatomic, assign) id <QLPageViewDelegate> delegate;

/**
 The declared style of the pageView that defines the appearance of the button bar
 */
@property (nonatomic) QLPageViewButtonBarStyle pageViewStyle;

/**
 The control switch defined in the button bar, nil if pageViewStyle is not
 QLPageViewButtonBarStyleWithRightSwitch
 */
@property (nonatomic, strong, readonly) UISwitch *controlSwitch;

/**
 Currently selected page index.
 */
@property (nonatomic, readonly) NSInteger selectedIndex;

/**
 Initial index of the page view
 */
@property (nonatomic) NSInteger initialIndex;

/**
 Number of pages in the page view
 */
@property (nonatomic) NSInteger numberOfPages;

/**
 Height of the button bar
 */
@property (nonatomic) CGFloat buttonBarHeight;


// Display properties

/**
 Color of button bar (also color of button titles).
 Default color is black.
 */
@property (nonatomic, strong) UIColor *buttonBarColor;

/**
 Color of button bar selection indicator.
 Default color is white.
 */
@property (nonatomic, strong) UIColor *buttonBarSelectionIndicatorColor;

/**
 Font of button bar buttons.
 Default font is Helvetica-Bold with size 14.0.
 */
@property (nonatomic, strong) UIFont *buttonFont;

/**
 Font of button bar labels (if the labels exist).
 Default font is Helvetica with size 10.0.
 Can be nil unless pageViewStyle is QLPageViewButtonBarStyleWithLabel.
 */
@property (nonatomic, strong) UIFont *labelFont;

/**
 On tint color of the control switch.
 Default color is yellow.
 */
@property (nonatomic, strong) UIColor *switchOnTintColor;

@end

// ------------------------------------------------------
// This protocol represents the data model object
// ------------------------------------------------------
@protocol QLPageViewDataSource <NSObject>

@required

/**
 Title of the button associated with the page at index.
 */
- (NSString *)pageView:(QLPageView *)pageView titleForButtonForPageAtIndex:(NSInteger)index;

/**
 View of the page at index.
 */
- (UIView *)pageView:(QLPageView *)pageView viewForPageAtIndex:(NSInteger)index;

@optional

/**
 The page where the page view starts, default is 0.
 The initial displayed page always has index 0.
 Index must be in range: 0 <= index < numberOfPages.
 */
- (NSInteger)initialIndexForPageInPageView:(QLPageView *)pageView;

/**
 The number of pages in the page view, default is 0.
 Maximum number of pages is 6.
 */
- (NSInteger)numberOfPagesInPageView:(QLPageView *)pageView;

/**
 Title of the button associated with the page at index.
 Only works if pageViewStyle is QLPageViewButtonStyleWithLabel.
 Default is nil.
 */
- (NSString *)pageView:(QLPageView *)pageView titleForLabelForPageAtIndex:(NSInteger)index;

/**
 Selected index for page view, default is initialIndex.
 */
- (NSInteger)selectedIndexForPageView:(QLPageView *)pageView;

@end

// ------------------------------------------------------
// This protocol represents the display and behaviour
// ------------------------------------------------------
@protocol QLPageViewDelegate <NSObject>

@optional

/**
 Sets the height for the button bar.
 Default height is 50.0.
 */
- (CGFloat)heightForButtonBarForPageView:(QLPageView *)pageView;

/**
 Sets the color of the button bar.
 Default is black color.
 */
- (UIColor *)colorForButtonBarForPageView:(QLPageView *)pageView;

/**
 Sets the color of the button bar selection indicator.
 Default is white color.
 */
- (UIColor *)colorForButtonBarSelectionIndicatorForPageView:(QLPageView *)pageView;

/**
 Sets the on tint color of the control switch.
 Default is yellow color.
 */
- (UIColor *)onTintColorForControlSwitchForPageView:(QLPageView *)pageView;

/**
 Sets the font of the button.
 Default font is Helvetica-Bold with size 14.0.
 */
- (UIFont *)fontForButtonsForPageView:(QLPageView *)pageView;

/**
 Sets the font of the label.
 Default font is Helvetica with size 10.0.
 */
- (UIFont *)fontForLabelsForPageView:(QLPageView *)pageView;

/**
 Called when Control Switch changes value.
 */
- (void)pageView:(QLPageView *)pageView controlSwitchDidChangeValue:(BOOL)value;

/**
 Called when page changed.
 */
- (void)pageView:(QLPageView *)pageView didMoveToPage:(NSInteger)page;

@end