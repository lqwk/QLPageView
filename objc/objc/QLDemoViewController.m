//
//  QLDemoViewController.m
//  objc
//
//  Created by Qingwei Lan on 4/6/16.
//  Copyright © 2016 Qingwei Lan. All rights reserved.
//

#import "QLDemoViewController.h"
#import "QLPageView.h"

@interface QLDemoViewController () <QLPageViewDataSource, QLPageViewDelegate>

@property (nonatomic, strong) QLPageView *pageView;

@end

@implementation QLDemoViewController

#pragma mark - View Controller

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _pageView = [[QLPageView alloc] initWithFrame:self.view.bounds];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.pageView.frame = self.view.bounds;
    self.pageView.pageViewStyle = QLPageViewButtonBarStyleWithLabel;
    self.pageView.dataSource = self;
    self.pageView.delegate = self;
    [self.view addSubview:self.pageView];
}

#pragma mark - QLPageViewDataSource

- (NSInteger)initialIndexForPageInPageView:(QLPageView *)pageView
{
    return 1;
}

- (NSInteger)numberOfPagesInPageView:(QLPageView *)pageView
{
    return 6;
}

- (NSString *)pageView:(QLPageView *)pageView titleForLabelForPageAtIndex:(NSInteger)index
{
    return @"Wed";
}

- (NSString *)pageView:(QLPageView *)pageView titleForButtonForPageAtIndex:(NSInteger)index
{
    return @"6";
}

- (UIView *)pageView:(QLPageView *)pageView viewForPageAtIndex:(NSInteger)index
{
    UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
    if ((index % 2) == 0)
        view.backgroundColor = [UIColor blackColor];
    else
        view.backgroundColor = [UIColor whiteColor];
    return view;
}

@end