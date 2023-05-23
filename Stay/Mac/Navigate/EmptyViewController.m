//
//  EmptyViewController.m
//  Stay-Mac
//
//  Created by ris on 2022/6/22.
//

#import "EmptyViewController.h"
#import "FCStyle.h"
#import "FCShared.h"
#import "Plugin.h"
#import <SafariServices/SafariServices.h>

@interface EmptyViewController ()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UILabel *guide;

@end

@implementation EmptyViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = FCStyle.background;
    [self label];
    [self button];
    [self guide];
}


- (UILabel *)label{
    if (nil == _label){
        _label = [[UILabel alloc] init];
        _label.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *appname = infoDictionary[@"CFBundleDisplayName"];
        NSString *appVersion = [NSString stringWithFormat:@" %@(%@)",infoDictionary[@"CFBundleShortVersionString"],infoDictionary[@"CFBundleVersion"]];
        NSMutableAttributedString *builder = [[NSMutableAttributedString alloc] init];
        [builder appendAttributedString:[[NSAttributedString alloc] initWithString:appname attributes:@{
            NSForegroundColorAttributeName:FCStyle.fcSecondaryBlack,
            NSFontAttributeName:FCStyle.headlineBold,
        }]];
        
        [builder appendAttributedString:[[NSAttributedString alloc] initWithString:appVersion attributes:@{
            NSForegroundColorAttributeName:FCStyle.fcSecondaryBlack,
            NSFontAttributeName:FCStyle.body,
        }]];
        
        _label.attributedText = builder;
        [self.view addSubview:_label];
        
        [NSLayoutConstraint activateConstraints:@[
            [_label.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
            [_label.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
        ]];
    }
    
    return _label;
}


- (UIButton *)button{
#ifdef FC_MAC
    if (nil == _button){
        _button = [[UIButton alloc] init];
        _button.translatesAutoresizingMaskIntoConstraints = NO;
        [_button setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"ActivateForSafari", @"")
                                                                attributes:@{
            NSForegroundColorAttributeName : FCStyle.accent,
            NSFontAttributeName : FCStyle.subHeadlineBold
        }] forState:UIControlStateNormal];
        _button.backgroundColor = UIColor.clearColor;
        [_button addTarget:self action:@selector(enableExtension:) forControlEvents:UIControlEventTouchUpInside];
        [_button sizeToFit];
        _button.layer.borderColor = FCStyle.accent.CGColor;
        _button.layer.borderWidth = 1;
        _button.layer.cornerRadius = 10;
        [self.view addSubview:_button];
        
        [NSLayoutConstraint activateConstraints:@[
            [_button.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
            [_button.topAnchor constraintEqualToAnchor:self.label.bottomAnchor constant:10],
            [_button.widthAnchor constraintEqualToConstant:150],
            [_button.heightAnchor constraintEqualToConstant:35]
        ]];
    }
    
    return _button;
#else
    return nil;
#endif
}

- (UILabel *)guide{
#ifdef FC_MAC
    if (nil == _guide){
        _guide = [[UILabel alloc] init];
        _guide.translatesAutoresizingMaskIntoConstraints = NO;
        _guide.font = FCStyle.subHeadline;
        _guide.textColor = FCStyle.fcSecondaryBlack;
        _guide.text = NSLocalizedString(@"ExtensionGuide", @"");
        [self.view addSubview:_guide];
        
        [NSLayoutConstraint activateConstraints:@[
            [_guide.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
            [_guide.topAnchor constraintEqualToAnchor:self.button.bottomAnchor constant:10]
        ]];
    }
    
    return _guide;
#else
    return nil;
#endif
}

- (void)enableExtension:(id)sender{
#ifdef FC_MAC
   [FCShared.plugin.carbon enableExtension];
#endif
}

@end
