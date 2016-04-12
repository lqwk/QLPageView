//
//  QLPageView.m
//  objc
//
//  Created by Qingwei Lan on 4/6/16.
//  Copyright © 2016 Qingwei Lan. All rights reserved.
//

#import "QLPageView.h"

@interface QLPageView () <UIScrollViewDelegate>

// Currently selected page index
@property (nonatomic, readwrite) NSInteger selectedIndex;

// Scroll view containing the views of the pages
@property (nonatomic, strong) UIScrollView *containerScrollView;
// View containing the buttons of the pages
@property (nonatomic, strong) UIView *buttonBar;
// Circle used to indicate selected page
@property (nonatomic, strong) UIView *selectionIndicator;

// Array that keeps hold of all buttons
@property (nonatomic, strong) NSArray *buttons;
// Array that keeps hold of all labels
@property (nonatomic, strong) NSArray *labels;

@end

@implementation QLPageView
{
    CGFloat gapV;
    CGFloat gapH;
    CGFloat selectionIndicatorY;
    CGFloat buttonWidth;
    CGFloat labelWidth;
    
    struct {
        bool initialIndexForPageInPageView;
        bool numberOfPagesInPageView;
        bool titleForLabelForPageAtIndex;
        bool selectedIndexForPageView;
    } dataSourceCan;
    
    struct {
        bool heightForButtonBarForPageView;
        bool colorForButtonBarForPageView;
        bool colorForButtonBarSelectionIndicatorForPageView;
        bool onTintColorForControlSwitchForPageView;
        bool fontForButtonsForPageView;
        bool fontForLabelsForPageView;
        bool controlSwitchDidChangeValue;
        bool didMoveToPage;
    } delegateCan;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _pageViewStyle = QLPageViewButtonBarStyleDefault;
        _buttonBarHeight = 50.0;
        _buttonBarColor = [UIColor blackColor];
        _switchOnTintColor = [UIColor yellowColor];
        _buttonBarSelectionIndicatorColor = [UIColor whiteColor];
        _buttonFont = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
        _labelFont = [UIFont fontWithName:@"Helvetica" size:10.0];
    }
    
    return self;
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    if (self.superview) {
        [self reloadPageView];
    }
}

- (void)reloadPageView
{
    if (!self.dataSource) {
        return;
    }
    
    if (dataSourceCan.selectedIndexForPageView) {
        self.selectedIndex = [self.dataSource selectedIndexForPageView:self];
    }
    if (dataSourceCan.initialIndexForPageInPageView) {
        self.initialIndex = [self.dataSource initialIndexForPageInPageView:self];
    }
    
    self.selectedIndex = self.initialIndex;
    
    // Remove all subviews
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    
    [self loadContainerScrollView];
    [self loadButtonBar];
    
    [self gotoPage:self.selectedIndex animated:NO];
    [self selectButtonAtIndex:self.selectedIndex];
}

- (void)setDataSource:(id<QLPageViewDataSource>)dataSource
{
    _dataSource = dataSource;
    
    dataSourceCan.initialIndexForPageInPageView = [self.dataSource respondsToSelector:@selector(initialIndexForPageInPageView:)];
    dataSourceCan.numberOfPagesInPageView = [self.dataSource respondsToSelector:@selector(numberOfPagesInPageView:)];
    dataSourceCan.selectedIndexForPageView = [self.dataSource respondsToSelector:@selector(selectedIndexForPageView:)];
    dataSourceCan.titleForLabelForPageAtIndex = [self.dataSource respondsToSelector:@selector(pageView:titleForLabelForPageAtIndex:)];
}

- (void)setDelegate:(id<QLPageViewDelegate>)delegate
{
    _delegate = delegate;
    
    delegateCan.colorForButtonBarForPageView = [self.delegate respondsToSelector:@selector(colorForButtonBarForPageView:)];
    delegateCan.colorForButtonBarSelectionIndicatorForPageView = [self.delegate respondsToSelector:@selector(colorForButtonBarSelectionIndicatorForPageView:)];
    delegateCan.onTintColorForControlSwitchForPageView = [self.delegate respondsToSelector:@selector(onTintColorForControlSwitchForPageView:)];
    delegateCan.controlSwitchDidChangeValue = [self.delegate respondsToSelector:@selector(pageView:controlSwitchDidChangeValue:)];
    delegateCan.didMoveToPage = [self.delegate respondsToSelector:@selector(pageView:didMoveToPage:)];
    delegateCan.fontForButtonsForPageView = [self.delegate respondsToSelector:@selector(fontForButtonsForPageView:)];
    delegateCan.fontForLabelsForPageView = [self.delegate respondsToSelector:@selector(fontForLabelsForPageView:)];
    delegateCan.heightForButtonBarForPageView = [self.delegate respondsToSelector:@selector(heightForButtonBarForPageView:)];
}

#pragma mark - Container Scroll View Methods

- (void)loadContainerScrollView
{
    if (delegateCan.heightForButtonBarForPageView) {
        self.buttonBarHeight = [self.delegate heightForButtonBarForPageView:self];
    }
    if (dataSourceCan.numberOfPagesInPageView) {
        self.numberOfPages = [self.dataSource numberOfPagesInPageView:self];
    }
    
    // Initialize container scroll view
    _containerScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.buttonBarHeight, self.frame.size.width, self.frame.size.height - self.buttonBarHeight)];
    
    [self addSubview:self.containerScrollView];
    
    // Setting the height to 1 will allow only horizontal scrolls
    self.containerScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame) * self.numberOfPages, 1);
    
    self.containerScrollView.delegate = self;
    self.containerScrollView.pagingEnabled = YES;
    self.containerScrollView.showsHorizontalScrollIndicator = NO;
    self.containerScrollView.showsVerticalScrollIndicator = NO;
    self.containerScrollView.directionalLockEnabled = YES;
    self.containerScrollView.bounces = NO;
    
    for (NSInteger i = 0; i < self.numberOfPages ; i++) {
        [self loadPageWithIndex:i];
    }
}

- (void)loadPageWithIndex:(NSInteger)index
{
    // Get the view from the dataSource
    UIView *page = [self.dataSource pageView:self viewForPageAtIndex:index];
    
    // Setup the frame of the page
    CGRect frame = self.containerScrollView.frame;
    frame.origin.x = frame.size.width * index;
    frame.origin.y = 0;
    page.frame = frame;
    
    [self.containerScrollView addSubview:page];
}

#pragma mark - Button Bar Methods

- (void)loadButtonBar
{
    if (delegateCan.heightForButtonBarForPageView) {
        self.buttonBarHeight = [self.delegate heightForButtonBarForPageView:self];
    }
    if (delegateCan.colorForButtonBarForPageView) {
        self.buttonBarColor = [self.delegate colorForButtonBarForPageView:self];
    }
    
    
    // Initialize button bar
    _buttonBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.buttonBarHeight)];
    self.buttonBar.backgroundColor = self.buttonBarColor;
    [self addSubview:self.buttonBar];
    
    [self loadButtons];
}

- (void)loadButtons
{
    if (dataSourceCan.numberOfPagesInPageView) {
        self.numberOfPages = [self.dataSource numberOfPagesInPageView:self];
    }
    if (delegateCan.colorForButtonBarSelectionIndicatorForPageView) {
        self.buttonBarSelectionIndicatorColor = [self.delegate colorForButtonBarSelectionIndicatorForPageView:self];
    }
    if (delegateCan.colorForButtonBarForPageView) {
        self.buttonBarColor = [self.delegate colorForButtonBarForPageView:self];
    }
    
    NSMutableArray *buttons = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray *labels = [[NSMutableArray alloc] initWithCapacity:0];
    
    switch (self.pageViewStyle)
    {
        case QLPageViewButtonBarStyleDefault:
        {
            gapV = self.buttonBar.bounds.size.height/6.0;
            buttonWidth = 4.0*gapV;
            gapH = (self.buttonBar.bounds.size.width - self.numberOfPages*buttonWidth - (((self.numberOfPages-1) < 0) ? 0 : (self.numberOfPages-1))*2*gapV)/2.0;
            selectionIndicatorY = gapV;
            
            break;
        }
            
        case QLPageViewButtonBarStyleWithLabel:
        {
            
            gapV = self.buttonBar.bounds.size.height/7.0;
            buttonWidth = 4.0*gapV;
            labelWidth = 1.5*gapV;
            gapH = (self.buttonBar.bounds.size.width - self.numberOfPages*buttonWidth - (((self.numberOfPages-1) < 0) ? 0 : (self.numberOfPages-1))*2*gapV)/2.0;
            selectionIndicatorY = 2*gapV;
            
            break;
        }
            
        case QLPageViewButtonBarStyleWithRightSwitch:
        {
            UIColor *onTintColor = self.switchOnTintColor;
            if (delegateCan.onTintColorForControlSwitchForPageView) {
                onTintColor = [self.delegate onTintColorForControlSwitchForPageView:self];
            }
            CGFloat switchX = self.buttonBar.bounds.size.width*(3/4.0);
            CGFloat switchY = self.buttonBar.bounds.size.height/2.0 - 15.0;
            
            // Add switch
            _controlSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(switchX, switchY, 10.0, 10.0)];
            [self.controlSwitch addTarget:self action:@selector(switchChangedValue:) forControlEvents:UIControlEventValueChanged];
            [self.buttonBar addSubview:self.controlSwitch];
            self.controlSwitch.onTintColor = onTintColor;
            
            CGFloat contentWidth = switchX;
            gapV = self.buttonBar.bounds.size.height/6.0;
            buttonWidth = 4.0*gapV;
            gapH = (contentWidth - self.numberOfPages*buttonWidth) / (self.numberOfPages+1);
            selectionIndicatorY = gapV;
            
            break;
        }
            
        default: break;
    }
    
    // Load selection indicator
    _selectionIndicator = [[UIView alloc] initWithFrame:CGRectMake(gapH, selectionIndicatorY, buttonWidth, buttonWidth)];
    self.selectionIndicator.backgroundColor = self.buttonBarSelectionIndicatorColor;
    self.selectionIndicator.layer.cornerRadius = 2*gapV;
    [self.buttonBar addSubview:self.selectionIndicator];
    
    // Load buttons & Labels
    for (NSInteger i = 0; i < self.numberOfPages; i++) {
        // Add buttons
        UIButton *button;
        switch (self.pageViewStyle)
        {
            case QLPageViewButtonBarStyleDefault:
            {
                button = [[UIButton alloc] initWithFrame:CGRectMake(gapH+i*6*gapV, 2*gapV, buttonWidth, buttonWidth)];
                break;
            }
                
            case QLPageViewButtonBarStyleWithLabel:
            {
                button = [[UIButton alloc] initWithFrame:CGRectMake(gapH+i*6*gapV, 2*gapV, buttonWidth, buttonWidth)];
                
                // Add labels
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(gapH+i*6*gapV, 0, buttonWidth, labelWidth)];
                if (dataSourceCan.titleForLabelForPageAtIndex) {
                    label.text = [self.dataSource pageView:self titleForLabelForPageAtIndex:i];
                } else {
                    label.text = @"";
                }
                label.font = self.labelFont;
                label.textColor = self.buttonBarSelectionIndicatorColor;
                label.textAlignment = NSTextAlignmentCenter;
                label.userInteractionEnabled = NO;
                [self.buttonBar addSubview:label];
                [labels addObject:label];
                break;
            }
                
            case QLPageViewButtonBarStyleWithRightSwitch:
            {
                button = [[UIButton alloc] initWithFrame:CGRectMake(gapH+i*(gapH+buttonWidth), gapV, buttonWidth, buttonWidth)];
                break;
            }
                
            default: break;
        }
        
        button.layer.cornerRadius = 2*gapV;
        button.backgroundColor = [UIColor clearColor];
        [button setTitle:[self.dataSource pageView:self titleForButtonForPageAtIndex:i] forState:UIControlStateNormal];
        [button setTitleColor:self.buttonBarSelectionIndicatorColor forState:UIControlStateNormal];
        button.titleLabel.font = self.buttonFont;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button addTarget:self action:@selector(selectPage:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonBar addSubview:button];
        [buttons addObject:button];
    }
    
    _buttons = buttons;
    _labels = labels;
}

#pragma mark - Actions

- (void)selectPage:(UIButton *)sender
{
    NSInteger index = [self.buttons indexOfObject:sender];
    [self gotoPage:index animated:YES];
}

- (void)selectButtonAtIndex:(NSInteger)index
{
    if (delegateCan.colorForButtonBarForPageView) {
        self.buttonBarColor = [self.delegate colorForButtonBarForPageView:self];
    }
    if ([self.buttons count]) {
        UIButton *button = [self.buttons objectAtIndex:index];
        [button setTitleColor:self.buttonBarColor forState:UIControlStateNormal];
    }
}

- (void)deselectButtonAtIndex:(NSInteger)index
{
    if (delegateCan.colorForButtonBarSelectionIndicatorForPageView) {
        self.buttonBarSelectionIndicatorColor = [self.delegate colorForButtonBarSelectionIndicatorForPageView:self];
    }
    if ([self.buttons count]) {
        UIButton *button = [self.buttons objectAtIndex:index];
        [button setTitleColor:self.buttonBarSelectionIndicatorColor forState:UIControlStateNormal];
    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    [self deselectButtonAtIndex:self.selectedIndex];
    _selectedIndex = selectedIndex;
    [self selectButtonAtIndex:self.selectedIndex];
}

- (void)gotoPage:(NSInteger)index animated:(BOOL)animated
{
    CGRect bounds = self.containerScrollView.bounds;
    bounds.origin.x = CGRectGetWidth(bounds) * index;
    bounds.origin.y = 0;
    [self.containerScrollView scrollRectToVisible:bounds animated:animated];
}

- (void)switchChangedValue:(UISwitch *)sender
{
    if (delegateCan.controlSwitchDidChangeValue) {
        [self.delegate pageView:self controlSwitchDidChangeValue:sender.isOn];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = CGRectGetWidth(self.containerScrollView.frame);
    
    CGFloat contentWidth = self.containerScrollView.contentSize.width - pageWidth;
    
    if (contentWidth != 0) {
        CGFloat scrolledPercentage = self.containerScrollView.contentOffset.x / contentWidth;
        UIButton *lastButton = self.buttons.lastObject;
        UIButton *firstButton = self.buttons.firstObject;
        CGFloat barWidth = lastButton.frame.origin.x - firstButton.frame.origin.x;
        
        CGRect frame = self.selectionIndicator.frame;
        frame.origin.x = firstButton.frame.origin.x + scrolledPercentage * barWidth;
        self.selectionIndicator.frame = frame;
        
        NSInteger index = floor((self.containerScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        if (index != self.selectedIndex) {
            self.selectedIndex = index;
            if (delegateCan.didMoveToPage) {
                [self.delegate pageView:self didMoveToPage:self.selectedIndex];
            }
        }
    }
}

@end