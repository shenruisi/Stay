//
//  FCTabBarController.m
//  Stay
//
//  Created by ris on 2023/3/14.
//

#import "FCTabBarController.h"

#import "FCStyle.h"

NSNotificationName const _Nonnull FCUITabBarControllerShouldHideTabBar = @"app.fastclip.notification.FCUITabBarControllerShouldHideTabBar";
NSNotificationName const _Nonnull FCUITabBarControllerShouldShowTabBar = @"app.fastclip.notification.FCUITabBarControllerShouldShowTabBar";

@interface FCTabBarController ()<FCTabBarDelegate,UITabBarControllerDelegate>

@end

@implementation FCTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    self.tabBar.backgroundColor = UIColor.clearColor;
    self.tabBar.tintColor = UIColor.clearColor;
    self.tabBar.clipsToBounds = YES;
    [self.tabBar setBackgroundImage:[UIImage new]];
    [self.tabBar setShadowImage:[UIImage new]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tabBarShouldHide:)
                                                 name:FCUITabBarControllerShouldHideTabBar
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tabBarShouldShow:)
                                                 name:FCUITabBarControllerShouldShowTabBar
                                               object:nil];
    
}

- (void)tabBarShouldHide:(NSNotification *)note{
    self.tabBar.hidden = YES;
    [self.fcTabBar dismiss];
}

- (void)tabBarShouldShow:(NSNotification *)note{
    self.tabBar.hidden = NO;
    [self.fcTabBar show];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (FCTabBar *)fcTabBar{
    if (nil == _fcTabBar){
        _fcTabBar = [[FCTabBar alloc] initWithStyle:FCTabBarStyleNormal];
        _fcTabBar.height = self.tabBar.frame.size.height;
        _fcTabBar.delegate = self;
        for (FCTabBarItem *item in self.tabBarItems){
            [_fcTabBar addItem:item];
        }
        _fcTabBar.layer.zPosition = MAXFLOAT;
        [self.view addSubview:_fcTabBar];
    }
    
    return _fcTabBar;
}

- (void)viewSafeAreaInsetsDidChange{
    [super viewSafeAreaInsetsDidChange];
    [self layout];
//    [self.fcTabBar selectIndex:0];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self layout];
    
}

- (void)layout{
    [self.fcTabBar layout];
    [self.view bringSubviewToFront:self.fcTabBar];
}

- (void)tabBar:(FCTabBar *)tabBar didSelectIndex:(NSInteger)index{
    [self setSelectedIndex:index];
}


@end
