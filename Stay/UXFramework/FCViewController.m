//
//  FCViewController.m
//  Stay
//
//  Created by ris on 2023/3/14.
//

#import "FCViewController.h"
#import "FCStyle.h"
#import "FCConfig.h"

@interface FCViewController ()<UINavigationBarDelegate>

@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@end

@implementation FCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
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

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"BackgroundColorDidChange"
                                                  object:nil];
}

@end
