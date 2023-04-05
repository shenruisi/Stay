//
//  FCViewController.m
//  Stay
//
//  Created by ris on 2023/3/14.
//

#import "FCViewController.h"
#import "FCStyle.h"

@interface FCViewController ()<UINavigationBarDelegate>

@end

@implementation FCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.enableTabItem = NO;
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.view.bounds;
    NSArray<UIColor *> *colors = FCStyle.accentGradient;
    gradientLayer.colors = @[(id)colors[0].CGColor, (id)colors[1].CGColor];
    [self.view.layer insertSublayer:gradientLayer atIndex:0];
}

- (void)setEnableTabItem:(BOOL)enableTabItem{
    _enableTabItem = enableTabItem;
    [self fcNavigationBar].enableTabItem = enableTabItem;
}

- (FCNavigationBar *)fcNavigationBar{
    return  (FCNavigationBar *)self.navigationController.navigationBar;
}

- (FCNavigationTabItem *)navigationTabItem{
    return [self fcNavigationBar].navigationTabItem;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.enableTabItem = _enableTabItem;
}

- (void)tabItemDidClick:(FCTabButtonItem *)item refresh:(BOOL)refresh{}

@end
