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
    
    
    self.appearance = [[UINavigationBarAppearance alloc] init];
    [self.appearance configureWithTransparentBackground];
    self.appearance.backgroundColor = UIColor.clearColor;
    self.appearance.backgroundEffect = nil;
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.view.bounds;
    NSArray<UIColor *> *colors = FCStyle.accentGradient;
    gradientLayer.colors = @[(id)colors[0].CGColor, (id)colors[1].CGColor];
    [self.view.layer insertSublayer:gradientLayer atIndex:0];
//    self.appearance = [[UINavigationBarAppearance alloc] init];
//    [self.appearance configureWithTransparentBackground];
//    self.appearance.backgroundEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
//
//    self.navigationItem.standardAppearance = self.appearance;
//    self.navigationItem.scrollEdgeAppearance = self.appearance;
    self.enableTabItem = NO;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationBarBaseLine = self.navigationController.navigationBar.height + (self.enableTabItem ? 44 : 0);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self scrollEffectHandle:scrollView];
}

- (void)scrollEffectHandle:(UIScrollView *)scrollView{
    UINavigationBarAppearance *appearance =  [self navigationBarEffect:scrollView.contentOffset.y];
    self.navigationItem.standardAppearance = appearance;
    self.navigationItem.scrollEdgeAppearance = appearance;
}

- (UINavigationBarAppearance *)navigationBarEffect:(CGFloat)yOffset{
    if (yOffset >= 0){
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        appearance.backgroundEffect =  [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
        return appearance;
    }
    else{
        if (yOffset + self.navigationBarBaseLine >= 0){
            UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
            appearance.backgroundEffect =  [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
            return appearance;
        }
        else{
            UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
            [appearance configureWithTransparentBackground];
            appearance.backgroundColor = UIColor.clearColor;
            appearance.backgroundEffect = nil;
            return appearance;
        }
    }
}


- (void)setEnableTabItem:(BOOL)enableTabItem{
    _enableTabItem = enableTabItem;
    [self fcNavigationBar].enableTabItem = enableTabItem;
}

- (void)setEnableSearchTabItem:(BOOL)enableSearchTabItem{
    _enableSearchTabItem = enableSearchTabItem;
    [self fcNavigationBar].enableTabItemSearch = enableSearchTabItem;
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

- (void)searchTabItemDidClick{}

- (void)willBeginSearch{}
- (void)didBeganSearch{}
- (void)willEndSearch{}
- (void)didEndSearch{}
- (void)searchTextDidChange:(NSString *)text{}

- (void)endSearch{
    [[self fcNavigationBar] cancelSearch];
}

@end
