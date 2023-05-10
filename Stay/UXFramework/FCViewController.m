//
//  FCViewController.m
//  Stay
//
//  Created by ris on 2023/3/14.
//

#import "FCViewController.h"
#import "FCStyle.h"
#import "FCConfig.h"
#import "ImageHelper.h"

@interface FCViewController ()<UINavigationBarDelegate>

@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) UIBarButtonItem *backItem;
@end

@implementation FCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.navigationController.viewControllers.count > 1){
        self.navigationItem.leftBarButtonItems = @[self.backItem];
    }
    
    self.appearance = [[UINavigationBarAppearance alloc] init];
    [self.appearance configureWithTransparentBackground];
    self.appearance.backgroundColor = UIColor.clearColor;
    self.appearance.backgroundEffect = nil;
    
    [self gradientLayer];
    self.enableTabItem = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backgrundColorTypeDidChange:)
                                                 name:@"BackgroundColorDidChange"
                                               object:nil];
}

- (UIBarButtonItem *)backItem{
    if (nil == _backItem){
        _backItem = [[UIBarButtonItem alloc] initWithImage:[ImageHelper sfNamed:@"chevron.backward"
                                                                           font:FCStyle.headline
                                                                          color:FCStyle.accent]
                                                     style:UIBarButtonItemStylePlain
                                                    target:self
                                                    action:@selector(backAction:)];
    }
    
    return _backItem;
}

- (void)backAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (CAGradientLayer *)gradientLayer{
    if (nil == _gradientLayer){
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.frame = self.view.bounds;
        NSArray<UIColor *> *colors = FCStyle.accentGradient;
        _gradientLayer.colors = @[(id)colors[0].CGColor, (id)colors[1].CGColor];
        [self.view.layer insertSublayer:_gradientLayer atIndex:0];
    }
    
    return _gradientLayer;
}


- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [self backgrundColorTypeDidChange:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.enableTabItem = _enableTabItem;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationBarBaseLine = self.navigationController.navigationBar.height + (self.enableTabItem ? 44 : 0);
}

- (void)backgrundColorTypeDidChange:(NSNotification *)note{
    NSArray<UIColor *> *colors = FCStyle.accentGradient;
    self.gradientLayer.colors = @[(id)colors[0].CGColor, (id)colors[1].CGColor];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self scrollEffectHandle:scrollView];
}

- (void)scrollEffectHandle:(UIScrollView *)scrollView{
    UINavigationBarAppearance *appearance =  [self navigationBarEffect:scrollView.contentOffset.y];
    self.navigationItem.standardAppearance = appearance;
    self.navigationItem.scrollEdgeAppearance = appearance;
    
    
}

- (void)searchEffectHanlde:(UIScrollView *)scrollView{
    if (self.enableSearchTabItem && self.navigationBarBaseLine > 0){
        FCNavigationBar *navigationBar = (FCNavigationBar *)self.navigationController.navigationBar;
        [navigationBar showSearchWithOffset:self.navigationController.navigationBar.height - self.navigationBarBaseLine];
    }
}

- (void)searchStartCheck:(UIScrollView *)scrollView{
    if (self.enableSearchTabItem && self.navigationBarBaseLine > 0 && !self.fcNavigationBar.inSearch){
        FCNavigationBar *navigationBar = (FCNavigationBar *)self.navigationController.navigationBar;
        [navigationBar startSearch];
    }
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
    if ([self.navigationController.navigationBar isKindOfClass:[FCNavigationBar class]]){
        return (FCNavigationBar *)self.navigationController.navigationBar;
    }
    return nil;
}

- (FCNavigationTabItem *)navigationTabItem{
    return [self fcNavigationBar].navigationTabItem;
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

- (void)removeFromParentViewController{
    [self clear];
    [super removeFromParentViewController];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"BackgroundColorDidChange"
                                                  object:nil];
}

@end
