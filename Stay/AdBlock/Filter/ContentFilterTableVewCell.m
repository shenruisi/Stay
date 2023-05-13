//
//  ContentFilterTableVewCell.m
//  Stay
//
//  Created by ris on 2023/3/23.
//

#import "ContentFilterTableVewCell.h"
#import "FCStyle.h"
#import "ContentFilter2.h"
#import "StateView.h"
#import "UIView+Duplicate.h"
#import "FCStore.h"
#import <SafariServices/SafariServices.h>

@interface ContentFilterTableVewCell()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) StateView *stateView;
@property (nonatomic, strong) UILabel *typeLabel;
@property (nonatomic, strong) NSLayoutConstraint *typeLabelWidth;
@property (nonatomic, strong) UILabel *alertLabel;
@property (nonatomic, strong) NSLayoutConstraint *alertLabelWidth;
@property (nonatomic, strong) NSArray<NSLayoutConstraint *> *statusViewConstraints;
@property (nonatomic, strong) UIButton *enableButton;
@property (nonatomic, strong) UILabel *proLabel;
@end

@implementation ContentFilterTableVewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self nameLabel];
        [self typeLabel];
        [self stateView];
        [self alertLabel];
        [self enableButton];
        [self proLabel];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setActive:(BOOL)active{
    [super setActive:active];
    self.nameLabel.textColor = active ? FCStyle.fcBlack : FCStyle.fcSeparator;
    self.stateView.active = active;
    self.typeLabel.backgroundColor = active ? FCStyle.fcSecondaryBlack : FCStyle.fcSeparator;
}

- (void)doubleTap:(CGPoint)location{
    [super doubleTap:location];
    
    UIView *containerView = [self.fcContentView.containerView duplicate];
    containerView.backgroundColor  = FCStyle.popup;
    [self.contentView addSubview:containerView];
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [containerView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:[FCTableViewCell contentInset].left],
        [containerView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-[FCTableViewCell contentInset].right],
        [containerView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:[FCTableViewCell contentInset].top],
        [containerView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-[FCTableViewCell contentInset].bottom]
    ]];
    
    UILabel *nameLabel = (UILabel *)[self.nameLabel duplicate];
    nameLabel.textColor = !self.active ? FCStyle.fcBlack : FCStyle.fcSeparator;
    nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:nameLabel];
    [NSLayoutConstraint activateConstraints:@[
        [nameLabel.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor constant:10],
        [nameLabel.topAnchor constraintEqualToAnchor:containerView.topAnchor constant:10]
    ]];
    
    UILabel *typeLabel = (UILabel *)[self.typeLabel duplicate];
    typeLabel.textColor = FCStyle.fcWhite;
    typeLabel.backgroundColor = !self.active ? FCStyle.fcSecondaryBlack : FCStyle.fcSeparator;
    typeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:typeLabel];
    [NSLayoutConstraint activateConstraints:@[
        [typeLabel.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor constant:-10],
        [typeLabel.topAnchor constraintEqualToAnchor:containerView.topAnchor constant:10],
        [typeLabel.widthAnchor constraintEqualToConstant:self.typeLabelWidth.constant],
        [typeLabel.heightAnchor constraintEqualToConstant:20]
    ]];
    
    UILabel *alertLabel;
    if (!self.alertLabel.hidden){
        alertLabel = (UILabel *)[self.alertLabel duplicate];
        alertLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [containerView addSubview:alertLabel];
        [NSLayoutConstraint activateConstraints:@[
            [alertLabel.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor constant:10],
            [alertLabel.bottomAnchor constraintEqualToAnchor:containerView.bottomAnchor constant:-10],
            [alertLabel.widthAnchor constraintEqualToConstant:self.alertLabelWidth.constant],
            [alertLabel.heightAnchor constraintEqualToConstant:25]
        ]];
    }
    
    if (!self.enableButton.hidden){
        UIButton *enableButton = (UIButton *)[self.enableButton duplicate];
        enableButton.translatesAutoresizingMaskIntoConstraints = NO;
        [containerView addSubview:enableButton];
        [NSLayoutConstraint activateConstraints:@[
            [enableButton.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor constant:-10],
            [enableButton.bottomAnchor constraintEqualToAnchor:containerView.bottomAnchor constant:-10],
            [enableButton.widthAnchor constraintEqualToConstant:60],
            [enableButton.heightAnchor constraintEqualToConstant:25],
        ]];
    }
    
    StateView *stateView = (StateView *)[self.stateView fcDuplicate];
    stateView.active = !self.active;
    stateView.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:stateView];
    
    if (!self.enableButton.hidden){
        [NSLayoutConstraint activateConstraints:@[
            [stateView.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor constant:10],
            [stateView.bottomAnchor constraintEqualToAnchor:alertLabel.topAnchor constant:-12]
        ]];
    }
    else{
        [NSLayoutConstraint activateConstraints:@[
            [stateView.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor constant:10],
            [stateView.bottomAnchor constraintEqualToAnchor:containerView.bottomAnchor constant:-15]
        ]];
    }
    
    
    UIView *maskView = [[UIView alloc] init];
    maskView.backgroundColor = UIColor.blackColor;
    maskView.layer.cornerRadius = 0;
    containerView.maskView = maskView;
    CGFloat radius =  MAX((self.size.width - location.x),location.x);
    [maskView setFrame:CGRectMake(location.x, location.y, 0, 0)];
    [UIView animateWithDuration:0.5
                     animations:^{
        [maskView setFrame:CGRectMake(location.x - radius, location.y - radius, radius * 2, radius * 2)];
        maskView.layer.cornerRadius = radius;
    } completion:^(BOOL finished) {
        self.active = !self.active;
        containerView.maskView = nil;
        [containerView removeFromSuperview];
    }];
}

- (void)buildWithElement:(ContentFilter *)element{
    self.nameLabel.text = element.title;
    self.active = element.active;
    self.typeLabel.text = [ContentFilter stringOfType:element.type];
    CGRect rect = [self.typeLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 20)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{NSFontAttributeName : FCStyle.footnote}
                                           context:nil];
    self.typeLabelWidth.constant = rect.size.width + 20;
    self.alertLabel.hidden = element.enable;
    self.enableButton.hidden = element.enable;
    if (!element.enable){
        NSString *enableAlert;
        if (ContentFilterTypeBasic == element.type){
            enableAlert = NSLocalizedString(@"ContentFilterBasicAlert", @"");
        }
        else if (ContentFilterTypePrivacy == element.type){
            enableAlert = NSLocalizedString(@"ContentFilterPrivacyAlert", @"");
        }
        else if (ContentFilterTypeRegion == element.type){
            enableAlert = NSLocalizedString(@"ContentFilterRegionAlert", @"");
        }
        else if (ContentFilterTypeCustom == element.type){
            enableAlert = NSLocalizedString(@"ContentFilterCustomAlert", @"");
        }
        else if (ContentFilterTypeTag == element.type){
            enableAlert = NSLocalizedString(@"ContentFilterTagAlert", @"");
        }
        
        CGRect rect = [enableAlert boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 25)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{NSFontAttributeName : FCStyle.footnote}
                                                context:nil];
        self.alertLabel.text = enableAlert;
        self.alertLabelWidth.constant = MIN(rect.size.width + 20,200);
    }
    
    [NSLayoutConstraint deactivateConstraints:self.statusViewConstraints];
    if (!element.enable){
        self.statusViewConstraints = @[
            [self.stateView.leadingAnchor constraintEqualToAnchor:self.fcContentView.leadingAnchor constant:10],
            [self.stateView.bottomAnchor constraintEqualToAnchor:self.alertLabel.topAnchor constant:-12]
        ];
    }
    else{
        self.statusViewConstraints = @[
            [self.stateView.leadingAnchor constraintEqualToAnchor:self.fcContentView.leadingAnchor constant:10],
            [self.stateView.bottomAnchor constraintEqualToAnchor:self.fcContentView.bottomAnchor constant:-15]
        ];
    }
    [NSLayoutConstraint activateConstraints:self.statusViewConstraints];
    
    if (ContentFilterTypeTag == element.type
        || ContentFilterTypeCustom == element.type){
        self.proLabel.hidden = (FCPlan.None != [[FCStore shared] getPlan:NO]);
    }
    else{
        self.proLabel.hidden = YES;
    }
    
}

- (UILabel *)nameLabel{
    if (nil == _nameLabel){
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = FCStyle.body;
        _nameLabel.textColor = FCStyle.fcBlack;
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.fcContentView addSubview:_nameLabel];
        
        [NSLayoutConstraint activateConstraints:@[
            [_nameLabel.leadingAnchor constraintEqualToAnchor:self.fcContentView.leadingAnchor constant:10],
            [_nameLabel.topAnchor constraintEqualToAnchor:self.fcContentView.topAnchor constant:10]
        ]];
    }
    
    return _nameLabel;
}

- (UILabel *)typeLabel{
    if (nil == _typeLabel){
        _typeLabel = [[UILabel alloc] init];
        _typeLabel.font = FCStyle.footnote;
        _typeLabel.textColor = FCStyle.fcWhite;
        _typeLabel.backgroundColor = FCStyle.fcSecondaryBlack;
        _typeLabel.textAlignment = NSTextAlignmentCenter;
        _typeLabel.layer.cornerRadius = 10;
        _typeLabel.clipsToBounds = YES;
        _typeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.fcContentView addSubview:_typeLabel];
        self.typeLabelWidth = [_typeLabel.widthAnchor constraintEqualToConstant:54];
        [NSLayoutConstraint activateConstraints:@[
            [_typeLabel.trailingAnchor constraintEqualToAnchor:self.fcContentView.trailingAnchor constant:-10],
            [_typeLabel.topAnchor constraintEqualToAnchor:self.fcContentView.topAnchor constant:10],
            self.typeLabelWidth,
            [_typeLabel.heightAnchor constraintEqualToConstant:20],
        ]];
    }

    return _typeLabel;
}

- (UILabel *)alertLabel{
    if (nil == _alertLabel){
        _alertLabel = [[UILabel alloc] init];
        _alertLabel.font = FCStyle.footnote;
        _alertLabel.textColor = FCStyle.accent;
        _alertLabel.backgroundColor = [FCStyle.accent colorWithAlphaComponent:0.1];
        _alertLabel.textAlignment = NSTextAlignmentCenter;
        _alertLabel.layer.cornerRadius = 5;
        _alertLabel.clipsToBounds = YES;
        _alertLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.fcContentView addSubview:_alertLabel];
        self.alertLabelWidth = [_alertLabel.widthAnchor constraintEqualToConstant:54];
        [NSLayoutConstraint activateConstraints:@[
            [_alertLabel.leadingAnchor constraintEqualToAnchor:self.fcContentView.leadingAnchor constant:10],
            [_alertLabel.bottomAnchor constraintEqualToAnchor:self.fcContentView.bottomAnchor constant:-10],
            [_alertLabel.heightAnchor constraintEqualToConstant:25],
            self.alertLabelWidth
        ]];
    }
    
    return _alertLabel;
}

- (StateView *)stateView{
    if (nil == _stateView){
        _stateView = [[StateView alloc] init];
        _stateView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.fcContentView addSubview:_stateView];
        
        self.statusViewConstraints = @[
            [_stateView.leadingAnchor constraintEqualToAnchor:self.fcContentView.leadingAnchor constant:10],
            [_stateView.bottomAnchor constraintEqualToAnchor:self.fcContentView.bottomAnchor constant:-15]
        ];
        
        [NSLayoutConstraint activateConstraints:self.statusViewConstraints];
    }
    
    return _stateView;
}

- (UIButton *)enableButton{
    if (nil == _enableButton){
        _enableButton = [[UIButton alloc] init];
        _enableButton.backgroundColor = UIColor.clearColor;
        _enableButton.layer.cornerRadius = 10;
        _enableButton.layer.borderWidth = 1;
        _enableButton.layer.borderColor = FCStyle.accent.CGColor;
        [_enableButton setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Enable", @"")
                                                                attributes:@{
            NSForegroundColorAttributeName : FCStyle.accent,
            NSFontAttributeName : FCStyle.footnoteBold
        }] forState:UIControlStateNormal];
        [_enableButton addTarget:self action:@selector(enableAction:) forControlEvents:UIControlEventTouchUpInside];
        _enableButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.fcContentView addSubview:_enableButton];
        [NSLayoutConstraint activateConstraints:@[
            [_enableButton.trailingAnchor constraintEqualToAnchor:self.fcContentView.trailingAnchor constant:-10],
            [_enableButton.bottomAnchor constraintEqualToAnchor:self.fcContentView.bottomAnchor constant:-10],
            [_enableButton.widthAnchor constraintEqualToConstant:60],
            [_enableButton.heightAnchor constraintEqualToConstant:25],
        ]];
    }
    
    return _enableButton;
}

- (UILabel *)proLabel{
    if (nil == _proLabel){
        _proLabel = [[UILabel alloc] init];
        _proLabel.backgroundColor = FCStyle.backgroundGolden;
        _proLabel.font = [UIFont boldSystemFontOfSize:10];
        _proLabel.text = @"PRO";
        _proLabel.layer.borderWidth = 1;
        _proLabel.layer.borderColor = FCStyle.borderGolden.CGColor;
        _proLabel.layer.cornerRadius = 5;
        _proLabel.textAlignment = NSTextAlignmentCenter;
        _proLabel.textColor = FCStyle.fcGolden;
        _proLabel.clipsToBounds = YES;
        _proLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.fcContentView addSubview:_proLabel];
        [NSLayoutConstraint activateConstraints:@[
            [_proLabel.topAnchor constraintEqualToAnchor:self.nameLabel.topAnchor constant:2],
            [_proLabel.leadingAnchor constraintEqualToAnchor:self.nameLabel.trailingAnchor constant:5],
            [_proLabel.widthAnchor constraintEqualToConstant:30],
            [_proLabel.heightAnchor constraintEqualToConstant:15],
        ]];
    }
    
    return _proLabel;
}

- (void)enableAction:(id)sender{
#ifdef FC_MAC
        [FCShared.plugin.appKit openUrl:[NSURL URLWithString:@"https://www.craft.do/s/Zmlkwi42U4r5N0"]];
#else
        SFSafariViewController *safariVc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"https://www.craft.do/s/Zmlkwi42U4r5N0"]];
        [self.cer presentViewController:safariVc animated:YES completion:nil];
#endif
}

+ (NSString *)identifier{
    return @"ContentFilterTableVewCell";
}

@end
