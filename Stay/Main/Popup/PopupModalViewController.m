//
//  PopupModalViewController.m
//  Stay
//
//  Created by ris on 2023/5/31.
//

#import "PopupModalViewController.h"
#import "FCApp.h"
#import "UIImageView+WebCache.h"
#import "FCImageView.h"
#import <SDImageCache.h>
#import "FCStyle.h"
#import "DeviceHelper.h"
#import "FCButton.h"
#import "JumpCenter.h"
#import "QuickAccess.h"

@interface PopupModalViewController()

@property (nonatomic, strong) FCImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) FCButton *jumpButton;
@property (nonatomic, strong) FCButton *dismissButton;
@end

@implementation PopupModalViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.hideNavigationBar = YES;
    [self imageView];
    NSURL *url = [NSURL URLWithString:self.dic[@"image_url"]];
    [self.imageView sd_setImageWithURL:url placeholderImage:nil options:0 context:nil progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.progress = (CGFloat)receivedSize / expectedSize;
        });
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        [self.imageView clearProcess];
    }];
    
    if ([DeviceHelper.country isEqualToString:@"CN"]){
        self.titleLabel.text = self.dic[@"title_cn"];
    }
    else{
        self.titleLabel.text = self.dic[@"title_en"];
    }
    
    if ([DeviceHelper.country isEqualToString:@"CN"]){
        self.subtitleLabel.text = self.dic[@"subtitle_cn"];
    }
    else{
        self.subtitleLabel.text = self.dic[@"subtitle_en"];
    }
    [self dismissButton];
    [self jumpButton];
}

- (FCImageView *)imageView{
    if (nil == _imageView){
        _imageView = [[FCImageView alloc] init];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_imageView];
        
        [NSLayoutConstraint activateConstraints:@[
            [_imageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
            [_imageView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
            [_imageView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
            [_imageView.heightAnchor constraintEqualToConstant:300]
        ]];
    }
    
    return _imageView;
}

- (UILabel *)titleLabel{
    if (nil == _titleLabel){
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = FCStyle.headlineBold;
        _titleLabel.textColor = FCStyle.fcBlack;
        _titleLabel.numberOfLines = 2;
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_titleLabel];
        
        [NSLayoutConstraint activateConstraints:@[
            [_titleLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:15],
            [_titleLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-15],
            [_titleLabel.topAnchor constraintEqualToAnchor:self.imageView.bottomAnchor constant:10]
        ]];
    }
    
    return _titleLabel;
}

- (UILabel *)subtitleLabel{
    if (nil == _subtitleLabel){
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.font = FCStyle.footnote;
        _subtitleLabel.textColor = FCStyle.fcSecondaryBlack;
        _subtitleLabel.numberOfLines = 2;
        _subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_subtitleLabel];
        
        [NSLayoutConstraint activateConstraints:@[
            [_subtitleLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:15],
            [_subtitleLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-15],
            [_subtitleLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:5]
        ]];
    }
    
    return _subtitleLabel;
}

- (FCButton *)jumpButton{
    if (nil == _jumpButton){
        _jumpButton = [[FCButton alloc] init];
        [_jumpButton addTarget:self action:@selector(jumpAction:) forControlEvents:UIControlEventTouchUpInside];
        NSString *jumpTitle = [DeviceHelper.country isEqualToString:@"CN"] ? self.dic[@"jump_title_cn"] : self.dic[@"jump_title_en"];
        if (jumpTitle.length > 0){
            [_jumpButton setAttributedTitle:[[NSAttributedString alloc] initWithString:jumpTitle
                                                                    attributes:@{
                NSForegroundColorAttributeName : FCStyle.accent,
                NSFontAttributeName : FCStyle.bodyBold
            }] forState:UIControlStateNormal];
        }
        _jumpButton.backgroundColor = UIColor.clearColor;
        _jumpButton.layer.borderColor = FCStyle.accent.CGColor;
        _jumpButton.layer.borderWidth = 1;
        _jumpButton.layer.cornerRadius = 10;
        _jumpButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_jumpButton];
        
        [NSLayoutConstraint activateConstraints:@[
            [_jumpButton.bottomAnchor constraintEqualToAnchor:self.dismissButton.topAnchor constant:-15],
            [_jumpButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:15],
            [_jumpButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-15],
            [_jumpButton.heightAnchor constraintEqualToConstant:45]
        ]];
    }
    
    return _jumpButton;
}

- (void)jumpAction:(id)sender{
    [self.navigationController.slideController dismiss];
    NSString *urlStr = self.dic[@"jump_url"];
    MainTabBarController *tabBarController = [QuickAccess primaryController];
    UIViewController *cer = tabBarController.selectedViewController;
    if ([cer isKindOfClass:[UINavigationController class]]){
        UINavigationController *nav = (UINavigationController *)cer;
        cer = nav.topViewController;
    }
    
    [JumpCenter jumpWithUrl:urlStr baseCer:cer];
}

- (FCButton *)dismissButton{
    if (nil == _dismissButton){
        _dismissButton = [[FCButton alloc] init];
        [_dismissButton addTarget:self action:@selector(dismissAction:) forControlEvents:UIControlEventTouchUpInside];
        [_dismissButton setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Dismiss", @"")
                                                                attributes:@{
            NSForegroundColorAttributeName : FCStyle.fcSecondaryBlack,
            NSFontAttributeName : FCStyle.bodyBold
        }] forState:UIControlStateNormal];
        _dismissButton.backgroundColor = FCStyle.popup;
        _dismissButton.layer.borderColor = FCStyle.borderColor.CGColor;
        _dismissButton.layer.borderWidth = 1;
        _dismissButton.layer.cornerRadius = 10;
        _dismissButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_dismissButton];
        
        [NSLayoutConstraint activateConstraints:@[
            [_dismissButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-15],
            [_dismissButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:15],
            [_dismissButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-15],
            [_dismissButton.heightAnchor constraintEqualToConstant:45]
        ]];
    }
    
    return _dismissButton;
}

- (void)dismissAction:(id)sender{
    [self.navigationController.slideController dismiss];
}

- (CGSize)mainViewSize{
    return CGSizeMake(MIN(FCApp.keyWindow.frame.size.width - 30, 360), 550);
}
@end
