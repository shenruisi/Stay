//
//  SYInviteCardModelController.m
//  Stay
//
//  Created by zly on 2023/6/1.
//

#import "SYInviteCardModelController.h"
#import "FCStyle.h"
@interface SYInviteCardModelController()

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *inviteView;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;


@end
@implementation SYInviteCardModelController


- (void)viewDidLoad{
    [super viewDidLoad];
    self.hideNavigationBar = NO;
    self.title = NSLocalizedString(@"GenerateCard", @"");
    [self backView];
    [self gradientLayer];
    [self inviteView];
}


- (UIView *)backView {
    if(_backView == nil) {
        _backView = [[UIView alloc] initWithFrame:CGRectMake(31, 19, [self getMainView].frame.size.width - 64, 383)];
        [self.view addSubview:_backView];
    }

    return _backView;
}

- (UIView *)inviteView {
    if(_inviteView == nil) {
        _inviteView = [[UIView alloc] initWithFrame:CGRectMake(40, 40, [self getMainView].frame.size.width - 64 - 80, 314)];
        _inviteView.backgroundColor = FCStyle.fcWhite;
        
        [self.backView addSubview:_inviteView];
    }
    return _inviteView;
}

- (CAGradientLayer *)gradientLayer{
    if (nil == _gradientLayer){
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.frame = [self backView].bounds;
        NSArray<UIColor *> *colors = FCStyle.accentGradient;
        _gradientLayer.colors = @[(id)colors[0].CGColor, (id)colors[1].CGColor];
        [self.backView.layer insertSublayer:_gradientLayer atIndex:0];
    }
    
    return _gradientLayer;
}

- (UIImageView *)iconImageView {
    if(nil == _iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(14, 14, [self getMainView].frame.size.width - 64 - 80 - 28, 175)];
//        _iconImageView.image = 
    }
    return _iconImageView;
}


- (CGSize)mainViewSize{
    return CGSizeMake(MIN(kScreenWidth - 30, 450), 765);
}

- (void)clear{
}
@end
