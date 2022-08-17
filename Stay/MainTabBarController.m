//
//  MainTabBarController.m
//  Stay
//
//  Created by zly on 2021/11/9.
//

#import "MainTabBarController.h"
#import "SYSearchViewController.h"
#import "SYHomeViewController.h"
#import "NavigationController.h"
#import "SYMoreViewController.h"
#import "SYDetailViewController.h"
#import "FCStyle.h"
#import "ImageHelper.h"

@interface MainTabBarController ()


@end

@implementation MainTabBarController
#define  UIColorWithRGBA(r,g,b,a) [UIColor colorWithRed:r / 255.0  green:g / 255.0 blue:b / 255.0 alpha:a]

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self createTabbar];
    NSLog(@"MainTabBarController view %@",self.view);
}

-(void)createTabbar
{
    NSArray *titleArray = @[NSLocalizedString(@"settings.library","Library"),NSLocalizedString(@"settings.search","search"),NSLocalizedString(@"settings.more","more")];
    
    SYHomeViewController *homeController = [[SYHomeViewController alloc] init];
    SYSearchViewController *searchController = [[SYSearchViewController alloc] init];
    SYMoreViewController *syMoreController = [[SYMoreViewController alloc] init];    
    
    UIColor *normalColor = RGB(144, 144, 144);
    

    [self setUpOneChildViewController:homeController image:[ImageHelper sfNamed:@"rectangle.stack.fill" font:[UIFont systemFontOfSize:18] color:normalColor] selectImage:[ImageHelper sfNamed:@"rectangle.stack.fill" font:[UIFont systemFontOfSize:18] color:FCStyle.accent]  title:titleArray[0]];
    
    [self setUpOneChildViewController:searchController image:[ImageHelper sfNamed:@"square.grid.2x2.fill" font:[UIFont systemFontOfSize:18] color:normalColor] selectImage:[ImageHelper sfNamed:@"square.grid.2x2.fill" font:[UIFont systemFontOfSize:18] color:FCStyle.accent]  title:titleArray[1]];
    [self setUpOneChildViewController:syMoreController image:[ImageHelper sfNamed:@"gearshape.fill" font:[UIFont systemFontOfSize:18] color:normalColor] selectImage:[ImageHelper sfNamed:@"gearshape.fill" font:[UIFont systemFontOfSize:18] color:FCStyle.accent]  title:titleArray[2]];
    self.homeController = homeController;
}


- (void)setUpOneChildViewController:(UIViewController *)viewController image:(UIImage *)image selectImage:(UIImage *)selectImage  title:(NSString *)title{
    UINavigationController *navC = [[UINavigationController alloc]initWithRootViewController:viewController];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    navC.tabBarItem.image = image;
#ifdef Mac
    navC.tabBarItem.imageInsets = UIEdgeInsetsMake(3, 3, 0, 3);
#endif
    selectImage = [selectImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [navC.tabBarItem setSelectedImage:selectImage];
    viewController.navigationItem.title = title;
    navC.navigationBar.tintColor = FCStyle.accent;
//    navC.navigationBar.barTintColor = RGB(138, 138, 138);
    UINavigationBarAppearance *appearance =[UINavigationBarAppearance new];
    [appearance configureWithOpaqueBackground];
    appearance.backgroundColor = DynamicColor(RGB(20, 20, 20),RGB(246, 246, 246));
    navC.navigationBar.standardAppearance = appearance;
    navC.navigationBar.scrollEdgeAppearance = appearance;
    UITabBarAppearance *tabbarAppearance = [[UITabBarAppearance alloc] init];
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
       paraStyle.alignment = NSTextAlignmentLeft;
    [tabbarAppearance.stackedLayoutAppearance.selected setTitleTextAttributes:@{NSForegroundColorAttributeName: RGB(182, 32, 224),NSParagraphStyleAttributeName : paraStyle}];

    [tabbarAppearance.inlineLayoutAppearance.selected setTitleTextAttributes:@{NSForegroundColorAttributeName: RGB(182, 32, 224),NSParagraphStyleAttributeName : paraStyle}];
    tabbarAppearance.backgroundColor = DynamicColor(RGB(20, 20, 20),RGB(246, 246, 246));
    self.tabBar.scrollEdgeAppearance = tabbarAppearance;
    self.tabBar.standardAppearance = tabbarAppearance;
    NSDictionary *dictHome = [NSDictionary dictionaryWithObject:UIColorWithRGBA(185,101,223,1)  forKey:NSForegroundColorAttributeName];
    [navC.tabBarItem setTitleTextAttributes:dictHome forState:UIControlStateSelected];

    [self addChildViewController:navC];
}



@end
