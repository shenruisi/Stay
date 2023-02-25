//
//  MainTabBarController.m
//  Stay
//
//  Created by zly on 2021/11/9.
//

#import "MainTabBarController.h"
#import "SYBrowseViewController.h"
#import "SYHomeViewController.h"
#import "NavigationController.h"
#import "SYMoreViewController.h"
#import "SYDetailViewController.h"
#import "SYFIleManagerViewController.h"
#import "FCStyle.h"
#import "ImageHelper.h"
#if iOS
#import "Stay-Swift.h"
#else
#import "Stay-Swift.h"
#endif

@interface MainTabBarController ()


@end

@implementation MainTabBarController
#define  UIColorWithRGBA(r,g,b,a) [UIColor colorWithRed:r / 255.0  green:g / 255.0 blue:b / 255.0 alpha:a]

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createTabbar];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self createTabbar];
//    NSLog(@"MainTabBarController view %@",self.view);
}

-(void)createTabbar
{
    NSArray *titleArray = @[NSLocalizedString(@"settings.library","Library"),NSLocalizedString(@"settings.search","search"),NSLocalizedString(@"Downloader","Downloader"),NSLocalizedString(@"settings.more","more")];
    
    SYHomeViewController *homeController = [[SYHomeViewController alloc] init];
    SYBrowseViewController *searchController = [[SYBrowseViewController alloc] init];
    SYMoreViewController *syMoreController = [[SYMoreViewController alloc] init];
    SYFIleManagerViewController *syFIleManagerController = [[SYFIleManagerViewController alloc] init];
    UIColor *normalColor = FCStyle.grayNoteColor;
    

    [self setUpOneChildViewController:homeController image:[ImageHelper sfNamed:@"rectangle.stack.fill" font:[UIFont systemFontOfSize:18] color:normalColor] selectImage:[ImageHelper sfNamed:@"rectangle.stack.fill" font:[UIFont systemFontOfSize:18] color:FCStyle.accent]  title:titleArray[0] tag:1];
    
    [self setUpOneChildViewController:searchController image:[ImageHelper sfNamed:@"square.grid.2x2.fill" font:[UIFont systemFontOfSize:18] color:normalColor] selectImage:[ImageHelper sfNamed:@"square.grid.2x2.fill" font:[UIFont systemFontOfSize:18] color:FCStyle.accent]  title:titleArray[1] tag:2];
    
    [self setUpOneChildViewController:syFIleManagerController image:[ImageHelper sfNamed:@"square.and.arrow.down.fill" font:[UIFont systemFontOfSize:18] color:normalColor] selectImage:[ImageHelper sfNamed:@"square.and.arrow.down.fill" font:[UIFont systemFontOfSize:18] color:FCStyle.accent]  title:nil tag:3];
    
    
    [self setUpOneChildViewController:syMoreController image:[ImageHelper sfNamed:@"gearshape.fill" font:[UIFont systemFontOfSize:18] color:normalColor] selectImage:[ImageHelper sfNamed:@"gearshape.fill" font:[UIFont systemFontOfSize:18] color:FCStyle.accent]  title:titleArray[3] tag:4];
    self.homeController = homeController;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if (item.tag == 2) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeTab"
                                                            object:nil];
    }
    
}

- (void)setUpOneChildViewController:(UIViewController *)viewController image:(UIImage *)image selectImage:(UIImage *)selectImage  title:(NSString *)title tag:(NSInteger) tag{
    UINavigationController *navC = [[UINavigationController alloc]initWithRootViewController:viewController];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    navC.tabBarItem.image = image;
    selectImage = [selectImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [navC.tabBarItem setSelectedImage:selectImage];
#ifdef Mac
    navC.tabBarItem.imageInsets = UIEdgeInsetsMake(3, 3, 0, 3);
#else
    navC.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
#endif
    navC.tabBarItem.tag = tag;
    viewController.navigationItem.title = title;
    navC.navigationBar.tintColor = FCStyle.accent;
////    navC.navigationBar.barTintColor = RGB(138, 138, 138);
    UINavigationBarAppearance *appearance =[UINavigationBarAppearance new];
    [appearance configureWithOpaqueBackground];
    appearance.backgroundColor = DynamicColor(RGB(20, 20, 20),RGB(246, 246, 246));
    navC.navigationBar.standardAppearance = appearance;
    navC.navigationBar.scrollEdgeAppearance = appearance;
    UITabBarAppearance *tabbarAppearance = [[UITabBarAppearance alloc] init];
    tabbarAppearance.backgroundColor = DynamicColor(RGB(20, 20, 20),RGB(246, 246, 246));
    self.tabBar.scrollEdgeAppearance = tabbarAppearance;
    self.tabBar.standardAppearance = tabbarAppearance;
    
    [self addChildViewController:navC];
}



@end
