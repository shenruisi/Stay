//
//  InstallUserscriptModalViewController.m
//  Stay
//
//  Created by ris on 2023/5/4.
//

#import "InstallUserscriptModalViewController.h"
#import "FCApp.h"
#import "FCStyle.h"
#import "ImageHelper.h"

@interface InstallUserscriptModalViewController()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *bigTitle;
@end

@implementation InstallUserscriptModalViewController

- (instancetype)init{
    if (self = [super init]){
        self.hideNavigationBar = YES;
    }
    
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationBar.backgroundColor = UIColor.clearColor;
    
    [self gradientLayer];
    [self backButton];
    [self bigTitle];
    
}

- (CAGradientLayer *)gradientLayer{
    if (nil == _gradientLayer){
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.frame = [self getMainView].bounds;
        NSArray<UIColor *> *colors = FCStyle.accentGradient;
        _gradientLayer.colors = @[(id)colors[0].CGColor, (id)colors[1].CGColor];
        [[self getMainView].layer insertSublayer:_gradientLayer atIndex:0];
    }
    
    return _gradientLayer;
}

- (UIButton *)backButton{
    if (nil == _backButton){
        _backButton = [[UIButton alloc] init];
        [_backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        _backButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_backButton setImage:[ImageHelper sfNamed:@"chevron.backward" font:FCStyle.title1 color:FCStyle.accent] forState:UIControlStateNormal];
        [self.view addSubview:_backButton];
        [NSLayoutConstraint activateConstraints:@[
            [_backButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
            [_backButton.topAnchor constraintEqualToAnchor:self.view.topAnchor]
        ]];
    }
    
    return _backButton;
}

- (UILabel *)bigTitle{
    if (nil == _bigTitle){
        _bigTitle = [[UILabel alloc] init];
        _bigTitle.userInteractionEnabled = YES;
        _bigTitle.translatesAutoresizingMaskIntoConstraints = NO;
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(backAction)];
        [_bigTitle addGestureRecognizer:gesture];
        _bigTitle.font = FCStyle.title1Bold;
        _bigTitle.textColor = FCStyle.accent;
        _bigTitle.text = NSLocalizedString(@"InstallUserscript", @"");
        [self.view addSubview:_bigTitle];
        [NSLayoutConstraint activateConstraints:@[
            [_bigTitle.leadingAnchor constraintEqualToAnchor:_backButton.trailingAnchor],
            [_bigTitle.centerYAnchor constraintEqualToAnchor:_backButton.centerYAnchor]
        ]];
    }
    
    return _bigTitle;
}

- (void)backAction{
    [self.navigationController popModalViewController];
}

- (CGSize)mainViewSize{
    return FCApp.keyWindow.size;
}


@end
