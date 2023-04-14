//
//  FCNavigationController.m
//  Stay
//
//  Created by ris on 2023/3/14.
//

#import "FCNavigationController.h"
#import "FCTabBarController.h"

@interface FCNavigationController ()<
 UINavigationControllerDelegate
>

@end

@implementation FCNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    
    
    
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (viewController.tabBarController){
        if (viewController.hidesBottomBarWhenPushed){
            [[NSNotificationCenter defaultCenter] postNotificationName:FCUITabBarControllerShouldHideTabBar
                                                                object:nil];
        }
        else{
            [[NSNotificationCenter defaultCenter] postNotificationName:FCUITabBarControllerShouldShowTabBar
                                                                object:nil];
        }
    }
}

@end
