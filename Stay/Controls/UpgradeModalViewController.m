//
//  UpgradeModalViewController.m
//  Stay
//
//  Created by ris on 2023/4/14.
//

#import "UpgradeModalViewController.h"
#import "FCApp.h"
#import "FCStyle.h"
#import "FCButton.h"
#if FC_IOS
#import "Stay-Swift.h"
#else
#import "Stay-Swift.h"
#endif

@interface UpgradeModalViewController()

@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) NSLayoutConstraint *messageLabelHeight;
@property (nonatomic, strong) FCButton *upgradeButton;
@property (nonatomic, strong) FCButton *dismissButton;
@end

@implementation UpgradeModalViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Upgrade", @"");
//    self.navigationBar.showCancel = YES;
    [self messageLabel];
    [self upgradeButton];
    [self dismissButton];
}

- (void)viewWillAppear{
    [super viewWillAppear];
    NSMutableAttributedString *messageAttributed = [[NSMutableAttributedString alloc] init];
    [messageAttributed appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"UpgradeMessage", @"") attributes:@{
        NSFontAttributeName : FCStyle.body,
        NSForegroundColorAttributeName : FCStyle.fcBlack
    }]];
    
    [messageAttributed appendAttributedString:[[NSAttributedString alloc] initWithString:self.message attributes:@{
        NSFontAttributeName : FCStyle.bodyBold,
        NSForegroundColorAttributeName : FCStyle.fcGolden
    }]];
    

    [self.messageLabel setAttributedText:messageAttributed];
}

- (void)upgradeAction:(id)sender{
    [self.navigationController.slideController dismiss];
    
#ifdef FC_MAC
            [self.navigationController.slideController.baseCer presentViewController:
             [[UINavigationController alloc] initWithRootViewController:[[SYSubscribeController alloc] init]]
                               animated:YES completion:^{}];
#else
            [self.navigationController.slideController.baseCer.navigationController pushViewController:[[SYSubscribeController alloc] init] animated:YES];
#endif
    
}

- (void)dismissAction:(id)sender{
    [self.navigationController.slideController dismiss];
}

- (UILabel *)messageLabel{
    if (nil == _messageLabel){
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.numberOfLines = 2;
        _messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_messageLabel];
        [NSLayoutConstraint activateConstraints:@[
            [_messageLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:15],
            [_messageLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-15],
            [_messageLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:30]
            
        ]];
    }
    
    return _messageLabel;
}

- (FCButton *)upgradeButton{
    if (nil == _upgradeButton){
        _upgradeButton = [[FCButton alloc] init];
        [_upgradeButton addTarget:self action:@selector(upgradeAction:) forControlEvents:UIControlEventTouchUpInside];
        [_upgradeButton setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Upgrade", @"")
                                                                attributes:@{
            NSForegroundColorAttributeName : FCStyle.fcGolden,
            NSFontAttributeName : FCStyle.bodyBold
        }] forState:UIControlStateNormal];
        _upgradeButton.backgroundColor = FCStyle.backgroundGolden;
        _upgradeButton.layer.borderColor = FCStyle.borderGolden.CGColor;
        _upgradeButton.layer.borderWidth = 1;
        _upgradeButton.layer.cornerRadius = 10;
        _upgradeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_upgradeButton];
        
        [NSLayoutConstraint activateConstraints:@[
            [_upgradeButton.bottomAnchor constraintEqualToAnchor:self.dismissButton.topAnchor constant:-15],
            [_upgradeButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:15],
            [_upgradeButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-15],
            [_upgradeButton.heightAnchor constraintEqualToConstant:45]
        ]];
    }
    
    return _upgradeButton;
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

- (CGSize)mainViewSize{
    return CGSizeMake(MIN(FCApp.keyWindow.frame.size.width - 30, 360), 280);
}

@end
