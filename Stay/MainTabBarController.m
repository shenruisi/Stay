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
    
}

-(void)createTabbar
{
    NSArray *imgArray = @[@"js-lib.png",@"search.png",@"more.png"];
    NSArray *imgSelectArray = @[@"homepage-selected",@"search-selected.png",@"more-selected.png"];

    NSArray *titleArray = @[NSLocalizedString(@"settings.library","Library"),NSLocalizedString(@"settings.search","search"),NSLocalizedString(@"settings.more","more")];
    
    SYHomeViewController *homeController = [[SYHomeViewController alloc] init];
    SYSearchViewController *searchController = [[SYSearchViewController alloc] init];
    SYMoreViewController *syMoreController = [[SYMoreViewController alloc] init];
    
    [self setUpOneChildViewController:homeController image:[UIImage imageNamed:imgArray[0]] selectImage: [UIImage imageNamed:imgSelectArray[0]]  title:titleArray[0]];
    [self setUpOneChildViewController:searchController image:[UIImage imageNamed:imgArray[1]] selectImage: [UIImage imageNamed:imgSelectArray[1]] title:titleArray[1]];
    [self setUpOneChildViewController:syMoreController image:[UIImage imageNamed:imgArray[2]] selectImage: [UIImage imageNamed:imgSelectArray[2]] title:titleArray[2]];
    [[UITabBar appearance] setBackgroundColor:[UIColor colorWithRed:246/255.f green:246/255.F blue:246/255.f alpha:1]];
}


- (void)setUpOneChildViewController:(UIViewController *)viewController image:(UIImage *)image selectImage:(UIImage *)selectImage  title:(NSString *)title{
    UINavigationController *navC = [[UINavigationController alloc]initWithRootViewController:viewController];
    navC.title = title;
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    navC.tabBarItem.image = image;
    selectImage = [selectImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [navC.tabBarItem setSelectedImage:selectImage];
    navC.tabBarItem.title = title;
    viewController.navigationItem.title = title;
    NSDictionary *dictHome = [NSDictionary dictionaryWithObject:UIColorWithRGBA(185,101,223,1)  forKey:NSForegroundColorAttributeName];
    [navC.tabBarItem setTitleTextAttributes:dictHome forState:UIControlStateSelected];
    navC.navigationBar.tintColor = RGB(182, 32, 224);
    [navC.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : RGB(182, 32, 224)}];
    [self addChildViewController:navC];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
