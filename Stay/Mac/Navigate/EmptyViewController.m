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

- (void)navigateViewDidLoad {
    [super navigateViewDidLoad];
    self.view.backgroundColor = FCStyle.background;
    [self label];
    [self button];
    [self guide];
    NSLog(@"EmptyViewController view %@",self.view);
}

- (void)navigateViewWillAppear:(BOOL)animated{
    [super navigateViewWillAppear:animated];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self.label setFrame:CGRectMake((self.view.frame.size.width - self.label.frame.size.width)/2, (self.view.frame.size.height - 18)/2, self.label.frame.size.width,18)];
    [self.button setFrame:CGRectMake((self.view.frame.size.width - self.button.frame.size.width)/2, self.label.frame.origin.y + self.label.frame.size.height+10, self.button.frame.size.width,35)];
    [self.guide setFrame:CGRectMake((self.view.frame.size.width - self.guide.frame.size.width)/2, self.button.frame.origin.y + self.button.frame.size.height+10, self.guide.frame.size.width, 18)];
}

- (UILabel *)label{
    if (nil == _label){
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height - 18)/2, self.view.frame.size.width, 18)];
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *appname = infoDictionary[@"CFBundleDisplayName"];
        NSString *appVersion = [NSString stringWithFormat:@" %@(%@)",infoDictionary[@"CFBundleShortVersionString"],infoDictionary[@"CFBundleVersion"]];
        NSMutableAttributedString *builder = [[NSMutableAttributedString alloc] init];
        [builder appendAttributedString:[[NSAttributedString alloc] initWithString:appname attributes:@{
            NSForegroundColorAttributeName:FCStyle.fcSecondaryBlack,
            NSFontAttributeName:FCStyle.headlineBold,
            NSObliquenessAttributeName:@(0.2)
            
        }]];
        
        [builder appendAttributedString:[[NSAttributedString alloc] initWithString:appVersion attributes:@{
            NSForegroundColorAttributeName:FCStyle.fcSecondaryBlack,
            NSFontAttributeName:FCStyle.body,
            NSObliquenessAttributeName:@(0.2)
            
        }]];
        
        _label.attributedText = builder;
        [_label sizeToFit];
        [_label setFrame:CGRectMake((self.view.frame.size.width - _label.frame.size.width)/2, (self.view.frame.size.height - 18)/2, _label.frame.size.width,18)];
        [self.view addSubview:_label];
    }
    
    return _label;
}


- (UIButton *)button{
    if (nil == _button){
        _button = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 200)/2,
                                                             self.label.frame.origin.y + self.label.frame.size.height+10,
                                                             200, 35)];
        [_button setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"ActivateForSafari", @"")
                                                                attributes:@{
            NSForegroundColorAttributeName : FCStyle.fcBlack,
            NSFontAttributeName : FCStyle.body
        }] forState:UIControlStateNormal];
        _button.backgroundColor = FCStyle.secondaryBackground;
        [_button addTarget:self action:@selector(enableExtension:) forControlEvents:UIControlEventTouchUpInside];
        [_button sizeToFit];
        _button.bounds = CGRectMake(0, 0, _button.frame.size.width+20, 35);
        _button.layer.cornerRadius = 8;
        [self.view addSubview:_button];
    }
    
    return _button;
}

- (UILabel *)guide{
    if (nil == _guide){
        _guide = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                           self.button.frame.origin.y + self.button.frame.size.height+10,
                                                           self.view.frame.size.width, 18)];
        _guide.font = FCStyle.subHeadline;
        _guide.textColor = FCStyle.fcSecondaryBlack;
        _guide.text = NSLocalizedString(@"ExtensionGuide", @"");
        [_guide sizeToFit];
        _guide.bounds = CGRectMake(0, 0, _guide.frame.size.width, 18);
        [self.view addSubview:_guide];
    }
    
    return _guide;
}

- (void)enableExtension:(id)sender{
   [FCShared.plugin.carbon enableExtension];
    
    
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"safari://"] options:@{} completionHandler:^(BOOL success) {
//        
//    }];

}

@end
