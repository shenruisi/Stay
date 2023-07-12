//
//  SYInviteViewController.m
//  Stay
//
//  Created by zly on 2023/5/26.
//

#import "SYInviteViewController.h"
#import "InviteProgressView.h"
#import "FCStyle.h"
#import "API.h"
#import "DeviceHelper.h"
#import "InviteDetail.h"
#import "SYInviteCardController.h"
#import "UserScript.h"
#import "FCImageView.h"
#import "UIImageView+WebCache.h"
#import "ImageHelper.h"
#import "FCStore.h"
#import "SharedStorageManager.h"
#import <SafariServices/SafariServices.h>
#import "FCShared.h"
#import "Plugin.h"

@interface ShareLinkView:UIView
@property (nonatomic, strong) NSString *linkStr;
@property (nonatomic, assign) NSUInteger visitcount;
@property (nonatomic, strong) UIViewController *cer;

@end


@implementation ShareLinkView


- (void)setUpUI {
    UILabel *linkView = [[UILabel alloc] initWithFrame:CGRectMake(18, 12, self.width - 36, 45)];
    linkView.layer.cornerRadius = 10;
    linkView.layer.masksToBounds = YES;
    linkView.backgroundColor = FCStyle.secondaryPopup;
    linkView.text = _linkStr;
    linkView.font = FCStyle.body;
    linkView.textColor = FCStyle.fcBlack;
    linkView.textAlignment = NSTextAlignmentCenter;
    [self addSubview:linkView];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(18, 0, 30, 19)];
    [imgView setImage:[ImageHelper sfNamed:@"eye" font:FCStyle.body color:FCStyle.subtitleColor]];
    imgView.top = linkView.bottom + 11;
    [self addSubview:imgView];

    UILabel *visitLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 16)];
    visitLabel.text = [NSString stringWithFormat:@"%ld %@",_visitcount,NSLocalizedString(@"Viewed",@"")];
    visitLabel.font = FCStyle.footnoteBold;
    visitLabel.textColor = FCStyle.subtitleColor;
    visitLabel.centerY = imgView.centerY;
    visitLabel.left = imgView.right + 4;
    [self addSubview:visitLabel];

    
    UIButton *shareBtn =  [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 161, 35)];
    [shareBtn setImage:[ImageHelper sfNamed:@"doc.on.doc" font:FCStyle.body color:FCStyle.accent] forState:UIControlStateNormal];
    [shareBtn setTitle:NSLocalizedString(@"CopLink", @"") forState:UIControlStateNormal];
    [shareBtn setTitleColor:FCStyle.accent forState:UIControlStateNormal];
    shareBtn.titleLabel.font = FCStyle.footnoteBold;
//        [_savePhotoBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 8)];
    shareBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 8);
    shareBtn.layer.cornerRadius = 10;
    shareBtn.layer.borderWidth = 1;
    shareBtn.layer.borderColor = FCStyle.accent.CGColor;
    [shareBtn addTarget:_cer action:@selector(shareLink:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:shareBtn];
    shareBtn.top = visitLabel.bottom + 19;
    shareBtn.centerX = self.width / 2;
}



@end

@interface InviteImageView:UIView
@property (nonatomic, strong) UIView *inviteView;
@property (nonatomic, strong) FCImageView *iconImageView;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) InviteDetail *detail;
@property (nonatomic, strong) UILabel *useLabel;
@property (nonatomic, strong) UILabel *stayLabel;
@property (nonatomic, strong) UIImageView *sigImageView;
@property (nonatomic, strong) UILabel *extensionLabel;
@property (nonatomic, strong) UIImageView *qrCodeImageView;
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UIButton *addBtn;
@property (nonatomic, strong) UILabel *proLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UINavigationController *nav;
@property (nonatomic, strong) NSLayoutConstraint *sigImageConstraint;

@end

@implementation InviteImageView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}
- (void)setupUI {
    self.proLabel = nil;
    self.tipsLabel = nil;
    self.dateLabel = nil;
    self.qrCodeImageView = nil;
    self.extensionLabel = nil;
    self.sigImageView = nil;
    self.stayLabel = nil;
    self.useLabel = nil;
    self.nameLabel = nil;
    self.iconImageView = nil;

    [self.inviteView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self backView];
    [self inviteView];
    [self gradientLayer];
    [self iconImageView];
    [self nameLabel];

    Boolean isPro = [[FCStore shared] getPlan:NO] == FCPlan.None?FALSE:TRUE;
    if ([[UserScript localeCodeLanguageCodeOnly] isEqualToString:@"zh"] && _detail.sinceCn.length > 0) {
        NSString *userStr = [NSString stringWithFormat:@"%@%@开始使用", NSLocalizedString(@"IUseStay",@""),_detail.sinceCn];
        NSMutableAttributedString *userStrAttr = [[NSMutableAttributedString alloc]initWithString:userStr];
        NSRange range = [userStr rangeOfString:_detail.sinceCn];
        [userStrAttr addAttribute:NSFontAttributeName value:FCStyle.footnoteBold range:range];
        self.useLabel.attributedText = userStrAttr;
        [self stayLabel];
        [self sigImageView];

        if(isPro) {
            
//            [self proLabel];
           [self.inviteView addSubview:self.proLabel];
            
            [NSLayoutConstraint activateConstraints:@[
                [self.proLabel.centerYAnchor constraintEqualToAnchor:self.useLabel.centerYAnchor],
                [self.proLabel.leftAnchor constraintEqualToAnchor:self.stayLabel.rightAnchor constant:5],
                [self.proLabel.heightAnchor constraintEqualToConstant:15],
                [self.proLabel.widthAnchor constraintEqualToConstant:30],
            ]];
        }
        
        if(FCDeviceTypeMac == DeviceHelper.type) {
            if(self.sigImageConstraint == nil) {
                self.sigImageConstraint = [self.sigImageView.trailingAnchor constraintEqualToAnchor:self.inviteView.trailingAnchor constant:-30];
                
            }
            [NSLayoutConstraint activateConstraints:@[
                self.sigImageConstraint,
            ]];
        }
        
     
        [NSLayoutConstraint activateConstraints:@[
            [self.extensionLabel.leftAnchor constraintEqualToAnchor:self.sigImageView.leftAnchor constant:-60],
        ]];
    } else {
        [self useLabel];
        [self stayLabel];
        
        [NSLayoutConstraint activateConstraints:@[
            [self.extensionLabel.leftAnchor constraintEqualToAnchor: self.stayLabel.leftAnchor],
        ]];
        
        if(isPro) {
            
            
            
            [self.inviteView addSubview:self.proLabel];
             
             [NSLayoutConstraint activateConstraints:@[
                 [self.proLabel.centerYAnchor constraintEqualToAnchor:self.useLabel.centerYAnchor],
                 [self.proLabel.leftAnchor constraintEqualToAnchor:self.stayLabel.rightAnchor constant:5],
                 [self.proLabel.heightAnchor constraintEqualToConstant:15],
                 [self.proLabel.widthAnchor constraintEqualToConstant:30],
             ]];

            [NSLayoutConstraint activateConstraints:@[
                [self.dateLabel.centerYAnchor constraintEqualToAnchor:self.useLabel.centerYAnchor],
                [self.dateLabel.leftAnchor constraintEqualToAnchor:self.proLabel.rightAnchor constant:5],
            ]];
            
        } else {
            [NSLayoutConstraint activateConstraints:@[
                [self.dateLabel.centerYAnchor constraintEqualToAnchor:self.useLabel.centerYAnchor],
                [self.dateLabel.leftAnchor constraintEqualToAnchor:self.stayLabel.rightAnchor constant:5],
            ]];
        }
    }
    
    [self sigImageView];
    [self extensionLabel];
    [self qrCodeImageView];
    [self tipsLabel];
    [self addBtn];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.gradientLayer removeFromSuperlayer];
    self.gradientLayer = nil;
    [self gradientLayer];
    
    if(self.inviteView.width < 220 && self.inviteView.width > 50 ) {
        if ([[UserScript localeCodeLanguageCodeOnly] isEqualToString:@"zh"] && _detail.sinceCn.length > 0) {
        
            if(self.sigImageConstraint == nil) {
                self.sigImageConstraint = [self.sigImageView.trailingAnchor constraintEqualToAnchor:self.inviteView.trailingAnchor constant:-30];
                
            }
            [NSLayoutConstraint activateConstraints:@[
                self.sigImageConstraint,
            ]];
        }
    } else if(self.inviteView.width > 0){
        if ([[UserScript localeCodeLanguageCodeOnly] isEqualToString:@"zh"] && _detail.sinceCn.length > 0) {
            if(self.sigImageConstraint != nil) {
                [NSLayoutConstraint deactivateConstraints:@[
                    self.sigImageConstraint,
                ]];
            }
            
        }
    }
    
}

- (UIView *)backView {
    if(_backView == nil) {
        _backView = [[UIView alloc] init];
        _backView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_backView];
        [NSLayoutConstraint activateConstraints:@[
            [_backView.topAnchor constraintEqualToAnchor:self.topAnchor constant:16],
            [_backView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:11],
            [_backView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-11],
            [_backView.heightAnchor constraintEqualToConstant:438]
        ]];
    }
    return _backView;
}

- (UIView *)inviteView {
    if(_inviteView == nil) {
        _inviteView = [[UIView alloc] init];
        _inviteView.backgroundColor = FCStyle.secondaryBackground;
        _inviteView.layer.cornerRadius = 10;
        _inviteView.clipsToBounds = YES;
        _inviteView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.backView addSubview:_inviteView];
        [NSLayoutConstraint activateConstraints:@[
            [_inviteView.topAnchor constraintEqualToAnchor:self.backView.topAnchor constant:21],
            [_inviteView.leadingAnchor constraintEqualToAnchor:self.backView.leadingAnchor constant:40],
            [_inviteView.trailingAnchor constraintEqualToAnchor:self.backView.trailingAnchor constant:-40],
            [_inviteView.heightAnchor constraintEqualToConstant:390]
        ]];
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

- (FCImageView *)iconImageView {
    if(nil == _iconImageView) {
        _iconImageView = [[FCImageView alloc] init];
        if(self.detail.cover.length > 1) {
            [_iconImageView sd_setImageWithURL:self.detail.cover];
        } else {
            [_iconImageView setImage:[UIImage imageNamed:@"rainbow"]];
        }
        
        _iconImageView.layer.cornerRadius = 10;
        _iconImageView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
        _iconImageView.clipsToBounds = YES;
        _iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.inviteView addSubview:_iconImageView];
        
        [NSLayoutConstraint activateConstraints:@[
            [_iconImageView.topAnchor constraintEqualToAnchor:self.inviteView.topAnchor constant:15],
            [_iconImageView.leadingAnchor constraintEqualToAnchor:self.inviteView.leadingAnchor constant:14],
            [_iconImageView.trailingAnchor constraintEqualToAnchor:self.inviteView.trailingAnchor constant:-14],
            [_iconImageView.heightAnchor constraintEqualToConstant:174]
        ]];
        
        
        
    }
    return _iconImageView;
}

- (UILabel *)nameLabel {
    if(_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        if(self.detail.color.length > 0 ) {
            _nameLabel.textColor =  UIColorFromRGB(self.detail.color );
        } else {
            _nameLabel.textColor = FCStyle.accent;
        }
        _nameLabel.font = [UIFont boldSystemFontOfSize:24];
        _nameLabel.text = self.detail.name;
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.inviteView addSubview:_nameLabel];
        [NSLayoutConstraint activateConstraints:@[
            [_nameLabel.topAnchor constraintEqualToAnchor:self.iconImageView.bottomAnchor constant:12],
            [_nameLabel.leadingAnchor constraintEqualToAnchor:self.inviteView.leadingAnchor constant:14],
            [_nameLabel.trailingAnchor constraintEqualToAnchor:self.inviteView.trailingAnchor constant:-14],
            [_nameLabel.heightAnchor constraintEqualToConstant:28]
        ]];

    }
    return _nameLabel;
}

- (UILabel *)useLabel {
    if(nil == _useLabel) {
        _useLabel = [[UILabel alloc] init];
        _useLabel.font = FCStyle.footnote;
        if(self.detail.color.length > 0 ) {
            _useLabel.textColor =  UIColorFromRGB(self.detail.color);
        } else {
            _useLabel.textColor = FCStyle.accent;
        }
        _useLabel.text = NSLocalizedString(@"Iuse",@"");
        _useLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.inviteView addSubview:_useLabel];
        
        [NSLayoutConstraint activateConstraints:@[
            [_useLabel.topAnchor constraintEqualToAnchor:self.nameLabel.bottomAnchor constant:9],
            [_useLabel.leadingAnchor constraintEqualToAnchor:self.inviteView.leadingAnchor constant:14],
            [_useLabel.heightAnchor constraintEqualToConstant:22]
        ]];
        
    }
    return _useLabel;
}

- (UILabel *)stayLabel {
    if(nil == _stayLabel){
        _stayLabel = [[UILabel alloc] init];
        if(self.detail.color.length > 0) {
            _stayLabel.backgroundColor =  UIColorFromRGB(self.detail.color);
        } else {
            _stayLabel.backgroundColor = FCStyle.accent;
        }
        _stayLabel.textColor = FCStyle.fcWhite;
        _stayLabel.font = FCStyle.footnoteBold;
        _stayLabel.text = NSLocalizedString(@"Stay",@"");
        _stayLabel.layer.cornerRadius = 10;
        _stayLabel.clipsToBounds = YES;
        _stayLabel.textAlignment = NSTextAlignmentCenter;
        _stayLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.inviteView addSubview:_stayLabel];
        
        [NSLayoutConstraint activateConstraints:@[
            [_stayLabel.centerYAnchor constraintEqualToAnchor:self.useLabel.centerYAnchor],
            [_stayLabel.leftAnchor constraintEqualToAnchor: self.useLabel.rightAnchor constant:5],
            [_stayLabel.heightAnchor constraintEqualToConstant:22],
            [_stayLabel.widthAnchor constraintEqualToConstant:44]
        ]];
    
    }
    return _stayLabel;
}

- (UIImageView *)sigImageView {
    if(nil == _sigImageView) {
        _sigImageView = [[UIImageView alloc] init];
        [_sigImageView setImage:[ImageHelper sfNamed:@"arrow.turn.right.down" font:FCStyle.body color:self.detail.color.length > 0?UIColorFromRGB(self.detail.color):FCStyle.accent]];
        [self.inviteView addSubview:_sigImageView];
        _sigImageView.top = self.stayLabel.bottom;
        _sigImageView.left = self.stayLabel.right - 7;
        _sigImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [_sigImageView.topAnchor constraintEqualToAnchor:self.stayLabel.bottomAnchor],
            [_sigImageView.leftAnchor constraintEqualToAnchor: self.stayLabel.rightAnchor constant:-7],
            [_sigImageView.heightAnchor constraintEqualToConstant:19],
            [_sigImageView.widthAnchor constraintEqualToConstant:16]
        ]];
        

    }
    return _sigImageView;
}

- (UILabel *)extensionLabel {
    if(nil == _extensionLabel) {
        _extensionLabel = [[UILabel alloc] init];
        _extensionLabel.font = FCStyle.footnoteBold;
        if(self.detail.color.length > 0) {
            _extensionLabel.textColor =  UIColorFromRGB(self.detail.color);
        } else {
            _extensionLabel.textColor = FCStyle.accent;
        }
        _extensionLabel.text = NSLocalizedString(@"ASafariExtension",@"");
        _extensionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.inviteView addSubview:_extensionLabel];
        [NSLayoutConstraint activateConstraints:@[
            [_extensionLabel.topAnchor constraintEqualToAnchor:self.sigImageView.bottomAnchor],
            [_extensionLabel.heightAnchor constraintEqualToConstant:19],
        ]];
    }
    return _extensionLabel;
}

- (UIImageView *)qrCodeImageView {
    if(nil == _qrCodeImageView) {
        _qrCodeImageView = [[UIImageView alloc] init];
        _qrCodeImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.inviteView addSubview:_qrCodeImageView];
        _qrCodeImageView.layer.cornerRadius = 2;
        _qrCodeImageView.layer.masksToBounds = YES;
        if(self.detail.link.length > 0) {
            [self generatingTwoDimensionalCode];
        }
        
        [NSLayoutConstraint activateConstraints:@[
            [_qrCodeImageView.bottomAnchor constraintEqualToAnchor:self.inviteView.bottomAnchor constant: -11],
            [_qrCodeImageView.leadingAnchor constraintEqualToAnchor: self.inviteView.leadingAnchor constant:14],
            [_qrCodeImageView.heightAnchor constraintEqualToConstant:48],
            [_qrCodeImageView.widthAnchor constraintEqualToConstant:48],

        ]];
    
    }
    return _qrCodeImageView;
}

- (UILabel *)tipsLabel {
    if(nil == _tipsLabel) {
        _tipsLabel = [[UILabel alloc] init];
        Boolean isPro = [[FCStore shared] getPlan:NO] == FCPlan.None?FALSE:TRUE;
        _tipsLabel.font = FCStyle.footnote;
        _tipsLabel.textColor = FCStyle.subtitleColor;
        if(isPro){
            _tipsLabel.text = NSLocalizedString(@"inviteTipsPro",@"");
            _tipsLabel.numberOfLines = 0;
            [_tipsLabel sizeToFit];
        } else {
            _tipsLabel.text = [NSString stringWithFormat:NSLocalizedString(@"inviteTips",@""),self.detail.name];
            _tipsLabel.numberOfLines = 0;
        }
        _tipsLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.inviteView addSubview:_tipsLabel];
        [NSLayoutConstraint activateConstraints:@[
            [_tipsLabel.bottomAnchor constraintEqualToAnchor:self.inviteView.bottomAnchor constant: -11],
            [_tipsLabel.leadingAnchor constraintEqualToAnchor: self.inviteView.leadingAnchor constant:66],
            [_tipsLabel.trailingAnchor constraintEqualToAnchor: self.inviteView.trailingAnchor constant:-14],
            [_tipsLabel.heightAnchor constraintEqualToConstant:33],
        ]];
    }
    return _tipsLabel;
}

- (UIButton *)addBtn {
    if(nil == _addBtn) {
        _addBtn =  [[UIButton alloc] init];
        [_addBtn setImage:[ImageHelper sfNamed:@"square.and.arrow.up" font:FCStyle.body color:FCStyle.accent] forState:UIControlStateNormal];
        [_addBtn setTitle:NSLocalizedString(@"ShareCard", @"") forState:UIControlStateNormal];
        [_addBtn setTitleColor:FCStyle.accent forState:UIControlStateNormal];
        _addBtn.titleLabel.font = FCStyle.footnoteBold;
        _addBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 8);
        _addBtn.layer.cornerRadius = 10;
        _addBtn.layer.borderWidth = 1;
        _addBtn.layer.borderColor = FCStyle.accent.CGColor;
        [_addBtn addTarget:self action:@selector(shareImage:) forControlEvents:UIControlEventTouchUpInside];
        _addBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_addBtn];
        
        [NSLayoutConstraint activateConstraints:@[
            [_addBtn.topAnchor constraintEqualToAnchor:self.backView.bottomAnchor constant: 22],
            [_addBtn.leadingAnchor constraintEqualToAnchor: self.leadingAnchor constant:94],
            [_addBtn.trailingAnchor constraintEqualToAnchor: self.trailingAnchor constant:-94],
            [_addBtn.heightAnchor constraintEqualToConstant:33],
        ]];

    }
    return _addBtn;
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
       
    }
    
    return _proLabel;
}

- (UILabel *)dateLabel {
    if(nil == _dateLabel) {
        _dateLabel = [[UILabel alloc] init];
        if(self.detail.color.length > 0) {
            _dateLabel.textColor =  UIColorFromRGB(self.detail.color);
        } else {
            _dateLabel.textColor = FCStyle.accent;
        }
        _dateLabel.font = FCStyle.footnoteBold;
        NSString *contentStr =[NSString stringWithFormat:@"since %@",_detail.sinceCn];

        NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:contentStr];

        //设置：在0-3个单位长度内的内容显示成红色
        [str addAttribute:NSFontAttributeName value:FCStyle.footnote range:NSMakeRange(0, 5)];
        _dateLabel.attributedText = str;
        [self.inviteView addSubview:_dateLabel];
        _dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [_dateLabel.heightAnchor constraintEqualToConstant:18],
        ]];
    }
    return _dateLabel;
}


- (void)shareImage:(UIButton *)sender{
    UIView *shareBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,  390, 610)];
    
    UIView *shareInviteView = [[UIView alloc] initWithFrame:CGRectMake(50, 50, 290, 461)];
    shareInviteView.backgroundColor = FCStyle.secondaryBackground;
    shareInviteView.layer.cornerRadius = 10;
    shareInviteView.clipsToBounds = YES;
    [shareBackView addSubview:shareInviteView];
    
    
    CAGradientLayer *shareGradientLayer = [CAGradientLayer layer];
    shareGradientLayer.frame = shareBackView.bounds;
    NSArray<UIColor *> *colors = FCStyle.accentGradient;
    shareGradientLayer.colors = @[(id)colors[0].CGColor, (id)colors[1].CGColor];
    [shareBackView.layer insertSublayer:shareGradientLayer atIndex:0];
    
    
    FCImageView *shareIconImageView = [[FCImageView alloc] initWithFrame:CGRectMake(20, 21, 250, 200)];
    [shareIconImageView setImage:self.iconImageView.image];
    
    shareIconImageView.layer.cornerRadius = 10;
    shareIconImageView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    shareIconImageView.clipsToBounds = YES;
    [shareInviteView addSubview:shareIconImageView];
    UILabel *shareNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 28)];
    if(self.detail.color.length > 0 ) {
        shareNameLabel.textColor =  UIColorFromRGB(self.detail.color );
    } else {
        shareNameLabel.textColor = FCStyle.accent;
    }
    shareNameLabel.font = [UIFont boldSystemFontOfSize:24];
    shareNameLabel.text = self.detail.name;
    shareNameLabel.top = shareIconImageView.bottom + 12;
    [shareInviteView addSubview:shareNameLabel];
    
    
    UILabel *shareUseLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 300, 22)];
    shareUseLabel.font = FCStyle.footnote;
    if(self.detail.color.length > 0 ) {
        shareUseLabel.textColor =  UIColorFromRGB(self.detail.color);
    } else {
        shareUseLabel.textColor = FCStyle.accent;
    }
    shareUseLabel.text = NSLocalizedString(@"Iuse",@"");
    [shareUseLabel sizeToFit];
    shareUseLabel.top = shareNameLabel.bottom + 9;
    [shareInviteView addSubview:shareUseLabel];
    
    
    UILabel *shareStayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 44, 22)];
    if(self.detail.color.length > 0) {
        shareStayLabel.backgroundColor =  UIColorFromRGB(self.detail.color);
    } else {
        shareStayLabel.backgroundColor = FCStyle.accent;
    }
    shareStayLabel.textColor = FCStyle.fcWhite;
    shareStayLabel.font = FCStyle.footnoteBold;
    shareStayLabel.text = NSLocalizedString(@"Stay",@"");
    shareStayLabel.layer.cornerRadius = 10;
    shareStayLabel.clipsToBounds = YES;
    shareStayLabel.textAlignment = NSTextAlignmentCenter;
    [shareInviteView addSubview:shareStayLabel];
 
    
    UIImageView *shareSigImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 19)];
    [shareSigImageView setImage:[ImageHelper sfNamed:@"arrow.turn.right.down" font:FCStyle.body color:self.detail.color.length > 0?UIColorFromRGB(self.detail.color):FCStyle.accent]];
    [shareInviteView addSubview:shareSigImageView];
   
    
    UILabel *shareProLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 15)];
    shareProLabel.backgroundColor = FCStyle.backgroundGolden;
    shareProLabel.font = [UIFont boldSystemFontOfSize:10];
    shareProLabel.text = @"PRO";
    shareProLabel.layer.borderWidth = 1;
    shareProLabel.layer.borderColor = FCStyle.borderGolden.CGColor;
    shareProLabel.layer.cornerRadius = 5;
    shareProLabel.textAlignment = NSTextAlignmentCenter;
    shareProLabel.textColor = FCStyle.fcGolden;
    shareProLabel.clipsToBounds = YES;
    
    UILabel *shareExtensionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 19)];
    shareExtensionLabel.font = FCStyle.footnoteBold;
    if(self.detail.color.length > 0) {
        shareExtensionLabel.textColor =  UIColorFromRGB(self.detail.color);
    } else {
        shareExtensionLabel.textColor = FCStyle.accent;
    }
    shareExtensionLabel.text = NSLocalizedString(@"ASafariExtension",@"");
    [shareExtensionLabel sizeToFit];
    [shareInviteView addSubview:shareExtensionLabel];
    shareExtensionLabel.top = shareSigImageView.bottom;
    [shareExtensionLabel sizeToFit];
    shareExtensionLabel.left = shareStayLabel.left;
    
    Boolean isPro = [[FCStore shared] getPlan:NO] == FCPlan.None?FALSE:TRUE;
    if ([[UserScript localeCodeLanguageCodeOnly] isEqualToString:@"zh"]) {
        
        NSString *userStr = [NSString stringWithFormat:@"%@%@开始使用", NSLocalizedString(@"IUseStay",@""),_detail.sinceCn];
        
        NSMutableAttributedString *userStrAttr = [[NSMutableAttributedString alloc]initWithString:userStr];
        NSRange range = [userStr rangeOfString:_detail.sinceCn];
        [userStrAttr addAttribute:NSFontAttributeName value:FCStyle.footnoteBold range:range];
        
        shareUseLabel.attributedText =userStrAttr;
        [shareUseLabel sizeToFit];
        shareStayLabel.left = shareUseLabel.right + 5;
        shareStayLabel.centerY = shareUseLabel.centerY;
        shareSigImageView.top = shareStayLabel.bottom;
        shareSigImageView.left = shareStayLabel.right - 7;
        if(isPro) {
            [shareInviteView addSubview:shareProLabel];
            shareProLabel.centerY =  shareUseLabel.centerY;
            shareProLabel.left = shareStayLabel.right + 5;
        }
        shareExtensionLabel.top = shareSigImageView.bottom;
        shareExtensionLabel.right = shareInviteView.width - 41;
    } else {
        
        UILabel *shareDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 18)];
        if(self.detail.color.length > 0) {
            shareDateLabel.textColor =  UIColorFromRGB(self.detail.color);
        } else {
            shareDateLabel.textColor = FCStyle.accent;
        }
        shareDateLabel.font = FCStyle.footnoteBold;
        NSString *contentStr =[NSString stringWithFormat:@"since %@",_detail.sinceCn];

        NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:contentStr];

        //设置：在0-3个单位长度内的内容显示成红色
        [str addAttribute:NSFontAttributeName value:FCStyle.footnote range:NSMakeRange(0, 5)];
        shareDateLabel.attributedText = str;
        [shareInviteView addSubview:shareDateLabel];
        
        shareStayLabel.left = shareUseLabel.right + 5;
        shareStayLabel.centerY = shareUseLabel.centerY;
        shareSigImageView.top = shareStayLabel.bottom;
        shareSigImageView.left = shareStayLabel.right - 7;
        if(isPro) {
            [shareInviteView addSubview:shareProLabel];
            shareProLabel.centerY =  shareStayLabel.centerY;
            shareProLabel.left = shareStayLabel.right + 5;
            shareDateLabel.centerY = shareUseLabel.centerY;
            shareDateLabel.left = shareProLabel.right + 5;
            
            
        } else {
            shareDateLabel.centerY = shareUseLabel.centerY;
            shareDateLabel.left = shareStayLabel.right + 5;
        }
        
        shareExtensionLabel.top = shareSigImageView.bottom;
        shareExtensionLabel.left = shareStayLabel.left;
    }
    
    
    UIImageView *shareQrCodeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 0, 48, 48)];
    [shareInviteView addSubview:shareQrCodeImageView];
    shareQrCodeImageView.bottom = 450;
    if(self.detail.link.length > 0) {
        shareQrCodeImageView.image = self.qrCodeImageView.image;
    }
    
    UILabel *shareTipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 181, 33)];
    shareTipsLabel.font = FCStyle.footnote;
    shareTipsLabel.textColor = FCStyle.subtitleColor;
    if(isPro){
        shareTipsLabel.text = NSLocalizedString(@"inviteTipsPro",@"");
        shareTipsLabel.numberOfLines = 0;
        [shareTipsLabel sizeToFit];
    } else {
        shareTipsLabel.text = [NSString stringWithFormat:NSLocalizedString(@"inviteTips",@""),self.detail.name];
        shareTipsLabel.numberOfLines = 2;
    }
    
    [shareInviteView addSubview:shareTipsLabel];
    
    shareTipsLabel.bottom = shareQrCodeImageView.bottom;
    shareTipsLabel.left = shareQrCodeImageView.right + 5;
    
    UILabel *tips1Label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 21)];
    tips1Label.font = FCStyle.headlineBold;
    tips1Label.text = @"Once load,";
    tips1Label.textColor = FCStyle.fcThirdBlack;
    [tips1Label sizeToFit];
    tips1Label.left = 84;
    tips1Label.top = shareInviteView.bottom + 39;
    [shareBackView addSubview:tips1Label];
    
    UIImageView *stayImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 26, 26)];
    stayImage.image = [UIImage imageNamed:@"NavIcon"];
    [shareBackView addSubview:stayImage];
    stayImage.left = tips1Label.right + 5;
    stayImage.centerY = tips1Label.centerY;
    
    UILabel *tips2Label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 21)];
    tips2Label.font = FCStyle.headlineBold;
    tips2Label.text = @"tay forever.";
    tips2Label.textColor = FCStyle.fcThirdBlack;
    [tips2Label sizeToFit];
    tips2Label.left = stayImage.right + 3;
    tips2Label.top = shareInviteView.bottom + 39;
    [shareBackView addSubview:tips2Label];
    
   UIGraphicsBeginImageContextWithOptions(shareBackView.bounds.size, NO, [UIScreen mainScreen].scale);
   [shareBackView drawViewHierarchyInRect:shareBackView.bounds afterScreenUpdates:YES];
   UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
   UIGraphicsEndImageContext();
    
    UIActivityViewController *activityController=[[UIActivityViewController alloc]initWithActivityItems:@[image] applicationActivities:nil];
    activityController.popoverPresentationController.sourceView = self;
    activityController.popoverPresentationController.sourceRect = self.bounds;
    [self.nav presentViewController:activityController animated:YES completion:nil];

}

 -(void)generatingTwoDimensionalCode {

     // 创建过滤器
     CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];

     // 过滤器恢复默认
     [filter setDefaults];

     // 给过滤器添加数据
     NSString *string = self.detail.link;
     NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];

     [filter setValue:data forKeyPath:@"inputMessage"];

     // 获取二维码过滤器生成的二维码
     CIImage *image = [filter outputImage];// 此时的 image 是模糊的

     // 高清处理：将获取到的二维码添加到 imageview
     self.qrCodeImageView.image =[self createNonInterpolatedUIImageFormCIImage:image withSize:48];// withSize 大于等于视图显示的尺寸
}

- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {

     CGRect extent = CGRectIntegral(image.extent);
     CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));

     // 创建 bitmap
     size_t width = CGRectGetWidth(extent) * scale;
     size_t height = CGRectGetHeight(extent) * scale;
     CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
     CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
     CIContext *context = [CIContext contextWithOptions:nil];
     CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
     CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
     CGContextScaleCTM(bitmapRef, scale, scale);
     CGContextDrawImage(bitmapRef, extent, bitmapImage);
     // 保存 bitmap 到图片
     CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
     CGContextRelease(bitmapRef);
     CGImageRelease(bitmapImage);
     return [UIImage imageWithCGImage:scaledImage];
}


@end

@interface InviteRulesView:UIView

- (void)setupUI;

@end

@implementation InviteRulesView

//- (instancetype)initWithFrame:(CGRect)frame {
//    self = [super initWithFrame:frame];
//    if (self) {
//        [self setupUI];
//    }
//    return self;
//}

- (void)setupUI {
    Boolean isPro = [[FCStore shared] getPlan:NO] == FCPlan.None?FALSE:TRUE;

    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.text = isPro? NSLocalizedString(@"GiftRule",@"InviteFriend"):NSLocalizedString(@"InviteRule",@"InviteFriend");
    titleLab.font = FCStyle.headlineBold;
    titleLab.textColor = FCStyle.fcBlack;
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:titleLab];
    [NSLayoutConstraint activateConstraints:@[
        [titleLab.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [titleLab.topAnchor constraintEqualToAnchor:self.topAnchor constant:13],
        [titleLab.heightAnchor constraintEqualToConstant:21]
    ]];
    
    
    
    
    UILabel *descLab = [[UILabel alloc] init];
    descLab.text = isPro?NSLocalizedString(@"GiftRuleDesc",@"InviteFriend"):NSLocalizedString(@"InviteRuleDesc",@"InviteFriend");
    descLab.font = FCStyle.footnote;
    descLab.numberOfLines = 0;
    descLab.textColor = FCStyle.subtitleColor;
    descLab.textAlignment = NSTextAlignmentCenter;
    descLab.translatesAutoresizingMaskIntoConstraints = NO;
//    [descLab sizeToFit];
    [self addSubview:descLab];
    
    
    
    [NSLayoutConstraint activateConstraints:@[
        [descLab.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant: -13],
        [descLab.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant: 13],
        [descLab.topAnchor constraintEqualToAnchor:titleLab.bottomAnchor constant:13],
//        [descLab.heightAnchor constraintEqualToConstant:100]
    ]];
    
    
    CGRect rect = [descLab.text boundingRectWithSize:CGSizeMake(320, 300)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{NSFontAttributeName : FCStyle.footnote}
                                           context:nil];
    
    
    [NSLayoutConstraint activateConstraints:@[
        [self.heightAnchor  constraintEqualToConstant:rect.size.height + 13 + 21 + 13 + 27]
    ]];
    
}

@end


@interface HowToInviteView:UIView
@end

@implementation HowToInviteView

- (instancetype)init {
    self = [super init];
    if (self) {
           [self setupUI];
    }
    return self;
}

//- (instancetype)initWithFrame:(CGRect)frame {
//    self = [super initWithFrame:frame];
//    if (self) {
//        [self setupUI];
//    }
//    return self;
//}

- (void)setupUI {
    
    Boolean isPro = [[FCStore shared] getPlan:NO] == FCPlan.None?FALSE:TRUE;
    
    
    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.text = isPro ? NSLocalizedString(@"HowToGift",@""):  NSLocalizedString(@"HowToInvite",@"");
    titleLab.font = FCStyle.headlineBold;
    titleLab.textColor = FCStyle.fcBlack;
    titleLab.textAlignment = NSTextAlignmentLeft;
    titleLab.translatesAutoresizingMaskIntoConstraints = NO;
    [titleLab sizeToFit];
    [self addSubview:titleLab];
    
    
    [NSLayoutConstraint activateConstraints:@[
        [titleLab.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant: 10],
        [titleLab.topAnchor constraintEqualToAnchor:self.topAnchor constant:13],
        [titleLab.heightAnchor constraintEqualToConstant:21]
    ]];
    
    //    titleLab.centerX = self.width / 2;
    
    UILabel *descLab = [[UILabel alloc] init];
    descLab.text = isPro ? NSLocalizedString(@"HowToGiftDesc",@"InviteFriend") : NSLocalizedString(@"HowToInviteDesc",@"InviteFriend");
    descLab.font = FCStyle.footnote;
    descLab.numberOfLines = 0;
    descLab.textColor = FCStyle.subtitleColor;
    descLab.textAlignment = NSTextAlignmentLeft;
    descLab.translatesAutoresizingMaskIntoConstraints = NO;
    [descLab sizeToFit];
    [self addSubview:descLab];
    
    [NSLayoutConstraint activateConstraints:@[
        [descLab.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant: 10],
        [descLab.topAnchor constraintEqualToAnchor:titleLab.bottomAnchor constant:13],
        [descLab.heightAnchor constraintEqualToConstant:21]
    ]];
    
    UIImageView *accessor = [[UIImageView alloc] init];
    UIImage *image = [UIImage systemImageNamed:@"chevron.right"
                             withConfiguration:[UIImageSymbolConfiguration configurationWithFont:[UIFont systemFontOfSize:13]]];
    image = [image imageWithTintColor:FCStyle.fcSecondaryBlack renderingMode:UIImageRenderingModeAlwaysOriginal];
    accessor.image = image;
    [self addSubview:accessor];

    accessor.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [accessor.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [accessor.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-18],
        [accessor.heightAnchor constraintEqualToConstant:18],
        [accessor.widthAnchor constraintEqualToConstant:13],
    ]];
    
    
    [NSLayoutConstraint activateConstraints:@[
        [self.heightAnchor  constraintEqualToConstant:70]
    ]];
    
}

@end


@interface SYInviteViewController () <
UITableViewDelegate,
UITableViewDataSource
>
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) InviteProgressView *inviteView;
@property (nonatomic, strong) UILabel *pointLabel;
@property (nonatomic, strong) UILabel *inviteLabel;
@property (nonatomic, strong) InviteRulesView *inviteRulesView;
@property (nonatomic, strong) HowToInviteView *howToInviteView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *inviteBtn;
@property (nonatomic, assign) Boolean started;
@property (nonatomic, strong) SYInviteCardController *inviteCardController;
@property (nonatomic, strong) InviteImageView *inviteImageView;
@property (nonatomic, strong) InviteDetail *detail;
@property (nonatomic, strong) UILabel *proPointLabel;
@property (nonatomic, strong) UILabel *proInviteLeftLabel;
@property (nonatomic, strong) UILabel *proGiftTitleLabel;


@end

@implementation SYInviteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.hidesBottomBarWhenPushed = true;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    Boolean isPro = [[FCStore shared] getPlan:NO] == FCPlan.None?FALSE:TRUE;

    
    self.title = isPro?NSLocalizedString(@"GiftFriend",@"GiftFriend") : NSLocalizedString(@"InviteFriend",@"InviteFriend");
    [self tableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveInviteSuccess:)
                                                 name:@"app.stay.notification.SaveInviteSuccess"
                                               object:nil];

    if(!isPro) {
        
        [[API shared]  queryPath:@"/invite-task/detail"
                             pro:isPro
                        deviceId:DeviceHelper.uuid
                             biz:nil
                      completion:^(NSInteger statusCode, NSError * _Nonnull error, NSDictionary * _Nonnull server, NSDictionary * _Nonnull biz) {
            if(biz != NULL) {
                InviteDetail *inviteDetail = [InviteDetail ofDictionary:biz];
                if(inviteDetail.inviteCode.length > 0) {
                    self.started = true;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    self.inviteView.titleArray = inviteDetail.process;
                    _detail = inviteDetail;
                    [self.tableView reloadData];
                    [self.inviteView updateProgress:0.5];
                });
            }
        }];
    } else {
        [[API shared]  queryPath:@"/gift-task/detail"
                             pro:isPro
                        deviceId:DeviceHelper.uuid
                             biz:nil
                      completion:^(NSInteger statusCode, NSError * _Nonnull error, NSDictionary * _Nonnull server, NSDictionary * _Nonnull biz) {
            if(biz != NULL) {
                InviteDetail *inviteDetail = [InviteDetail ofDictionary:biz];
                if(inviteDetail.giftCode.length > 0) {
                    self.started = true;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    _detail = inviteDetail;
                    [self.tableView reloadData];
                });
            }
        }];
    }
    
      
    
   
}

- (void)saveInviteSuccess:(NSNotification *)sender{
    Boolean isPro = [[FCStore shared] getPlan:NO] == FCPlan.None?FALSE:TRUE;

    if(isPro) {
        [[API shared]  queryPath:@"/gift-task/detail"
                             pro:isPro
                        deviceId:DeviceHelper.uuid
                             biz:nil
                      completion:^(NSInteger statusCode, NSError * _Nonnull error, NSDictionary * _Nonnull server, NSDictionary * _Nonnull biz) {
            NSLog(@"%@",biz);
            
            if(biz != NULL) {
                InviteDetail *inviteDetail = [InviteDetail ofDictionary:biz];
                if(inviteDetail.giftCode.length > 0) {
                    self.started = true;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    self.inviteView.titleArray = inviteDetail.process;
                    _detail = inviteDetail;
                    [self.tableView reloadData];
                    [self.inviteView updateProgress:0.5];
                });
            }
        }];
    } else {
        [[API shared]  queryPath:@"/invite-task/detail"
                             pro:isPro
                        deviceId:DeviceHelper.uuid
                             biz:nil
                      completion:^(NSInteger statusCode, NSError * _Nonnull error, NSDictionary * _Nonnull server, NSDictionary * _Nonnull biz) {
            NSLog(@"%@",biz);
            
            if(biz != NULL) {
                InviteDetail *inviteDetail = [InviteDetail ofDictionary:biz];
                if(inviteDetail.inviteCode.length > 0) {
                    self.started = true;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    _detail = inviteDetail;
                    [self.tableView reloadData];
                });
            }
        }];
    }
}


- (void)inviteCreate:(UIButton *)sender {
    self.inviteCardController = nil;
    if(_detail != NULL) {

        self.inviteCardController.dateStr = _detail.sinceCn;

        self.inviteCardController.imageList = _detail.candidateCovers;
        self.inviteCardController.color = _detail.color;
        self.inviteCardController.defaultImage = _detail.cover;
        self.inviteCardController.defaultName = _detail.name;
        self.inviteCardController.detail = _detail;
    }
    if (!self.inviteCardController.isShown){
        [self.inviteCardController show];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0) {
        Boolean isPro = [[FCStore shared] getPlan:NO] == FCPlan.None?FALSE:TRUE;

        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                       reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:self.iconImageView];
        
        [NSLayoutConstraint activateConstraints:@[
            [self.iconImageView.centerXAnchor constraintEqualToAnchor:cell.contentView.centerXAnchor],
            [self.iconImageView.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor constant:25],
            [self.iconImageView.widthAnchor constraintEqualToConstant:100],
            [self.iconImageView.heightAnchor constraintEqualToConstant:100],
        ]];
        
        [cell.contentView addSubview:self.inviteBtn];

        [NSLayoutConstraint activateConstraints:@[
            [self.inviteBtn.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-19],
            [self.inviteBtn.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:19],
            [self.inviteBtn.heightAnchor constraintEqualToConstant:45],
        ]];
        
        
        
        if(!isPro) {
            [cell.contentView addSubview:self.pointLabel];
            [NSLayoutConstraint activateConstraints:@[
                [self.pointLabel.topAnchor constraintEqualToAnchor:self.iconImageView.bottomAnchor constant:24],
                [self.pointLabel.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:19],
                [self.pointLabel.heightAnchor constraintEqualToConstant:18],
            ]];
            
            [cell.contentView addSubview:self.inviteView];
            
            [NSLayoutConstraint activateConstraints:@[
                [self.inviteView.topAnchor constraintEqualToAnchor:self.pointLabel.bottomAnchor constant:11],
                [self.inviteView.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:19],
                [self.inviteView.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-19],
                [self.inviteView.heightAnchor constraintEqualToConstant:69],
            ]];
            
            [cell.contentView addSubview:self.inviteLabel];
            [NSLayoutConstraint activateConstraints:@[
                [self.inviteLabel.topAnchor constraintEqualToAnchor:self.inviteView.bottomAnchor constant:21],
                [self.inviteLabel.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:19],
                [self.inviteLabel.heightAnchor constraintEqualToConstant:18],
            ]];
            
            [cell.contentView addSubview:self.inviteRulesView];
            
            [NSLayoutConstraint activateConstraints:@[
                [self.inviteRulesView.topAnchor constraintEqualToAnchor:self.inviteLabel.bottomAnchor constant:18],
                [self.inviteRulesView.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:19],
                [self.inviteRulesView.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-19],
            ]];
            
        
            
        } else {
            [cell.contentView addSubview:self.proPointLabel];
            
            [NSLayoutConstraint activateConstraints:@[
                [self.proPointLabel.centerXAnchor constraintEqualToAnchor:self.iconImageView.centerXAnchor],
                [self.proPointLabel.topAnchor constraintEqualToAnchor:self.iconImageView.bottomAnchor constant:16],
                [self.proPointLabel.heightAnchor constraintEqualToConstant:24]
            ]];
    
            NSString *contentStr =[NSString stringWithFormat:@"%ld/%ld %@",_detail.rest,_detail.total,NSLocalizedString(@"UserLeft", @"")];

            NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:contentStr];

            //设置：在0-3个单位长度内的内容显示成红色

            [str addAttribute:NSForegroundColorAttributeName value:FCStyle.subtitleColor range:NSMakeRange(0, 1)];
            
            self.proInviteLeftLabel.attributedText = str;
            
            [cell.contentView addSubview:self.proInviteLeftLabel];
            
            [NSLayoutConstraint activateConstraints:@[
                [self.proInviteLeftLabel.centerXAnchor constraintEqualToAnchor:self.proPointLabel.centerXAnchor],
                [self.proInviteLeftLabel.topAnchor constraintEqualToAnchor:self.proPointLabel.bottomAnchor constant:16],
                [self.proPointLabel.heightAnchor constraintEqualToConstant:21]
            ]];
            [cell.contentView addSubview:self.proGiftTitleLabel];
            
            [NSLayoutConstraint activateConstraints:@[
                [self.proGiftTitleLabel.topAnchor constraintEqualToAnchor:self.proInviteLeftLabel.bottomAnchor constant:16],
                [self.proGiftTitleLabel.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:19],
                [self.proGiftTitleLabel.heightAnchor constraintEqualToConstant:18]
            ]];
                        
            [cell.contentView addSubview:self.inviteRulesView];
            [NSLayoutConstraint activateConstraints:@[
                [self.inviteRulesView.topAnchor constraintEqualToAnchor:self.proGiftTitleLabel.bottomAnchor constant:16],
                [self.inviteRulesView.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:19],
                [self.inviteRulesView.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-19],
            ]];
        }
        [cell.contentView addSubview:self.howToInviteView];
        
        [NSLayoutConstraint activateConstraints:@[
            [self.howToInviteView.topAnchor constraintEqualToAnchor:self.inviteRulesView.bottomAnchor constant:15],
            [self.howToInviteView.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:19],
            [self.howToInviteView.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-19],
        ]];
        
        
         
        if(_started) {
            [cell.contentView addSubview:self.inviteImageView];
            self.inviteImageView.detail = _detail;
            [self.inviteImageView setupUI];
            self.inviteImageView.top = self.howToInviteView.bottom + 13;
            [NSLayoutConstraint activateConstraints:@[
                [self.inviteImageView.topAnchor constraintEqualToAnchor:self.howToInviteView.bottomAnchor constant:13],
                [self.inviteImageView.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:19],
                [self.inviteImageView.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-19],
                [self.inviteImageView.heightAnchor constraintEqualToConstant:525],
            ]];
            
            
            ShareLinkView *linkView = [[ShareLinkView alloc] initWithFrame:CGRectMake(19, 0, self.view.width - 38, 150)];
            linkView.backgroundColor = FCStyle.secondaryBackground;
            linkView.layer.cornerRadius = 10;
            linkView.layer.masksToBounds = YES;
            linkView.visitcount = _detail.visitedCount;
            linkView.linkStr = _detail.link;
            linkView.cer = self;
            [linkView setUpUI];
            linkView.translatesAutoresizingMaskIntoConstraints = NO;
            [cell.contentView addSubview:linkView];
            
            [NSLayoutConstraint activateConstraints:@[
                [linkView.topAnchor constraintEqualToAnchor:self.inviteImageView.bottomAnchor constant:26],
                [linkView.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:19],
                [linkView.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-19],
                [linkView.heightAnchor constraintEqualToConstant:150],
            ]];
            
            [self.inviteBtn setTitle:NSLocalizedString(@"EditInfo", @"") forState:UIControlStateNormal];
            
            [NSLayoutConstraint activateConstraints:@[
                [self.inviteBtn.topAnchor constraintEqualToAnchor:linkView.bottomAnchor constant:32],
            ]];
        } else {
            [NSLayoutConstraint activateConstraints:@[
                [self.inviteBtn.topAnchor constraintEqualToAnchor:self.howToInviteView.bottomAnchor constant:23],
            ]];
        }
        return cell;
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(_started) {
        return 1375;
    } else {
        return 647;
    }
}


- (UIImageView *)iconImageView {
    if(_iconImageView == nil) {
        _iconImageView = [[UIImageView alloc] init];
        [_iconImageView setImage:[UIImage imageNamed:@"InviteBigIcon"]];
        _iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _iconImageView;
}


- (InviteProgressView *)inviteView {
    if(_inviteView == nil) {
        _inviteView = [[InviteProgressView alloc] init];
        _inviteView.backgroundColor = FCStyle.secondaryBackground;
        _inviteView.layer.cornerRadius = 10;
        _inviteView.translatesAutoresizingMaskIntoConstraints = NO;
        
    }
    
    return _inviteView;
}

- (UILabel *)pointLabel {
    if(_pointLabel == nil) {
        _pointLabel = [[UILabel alloc] init];
        _pointLabel.font = FCStyle.subHeadlineBold;
        _pointLabel.textColor = FCStyle.subtitleColor;
        _pointLabel.text = NSLocalizedString(@"PointProgress", @"");
        _pointLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _pointLabel;
}

- (UILabel *)inviteLabel {
    if(_inviteLabel == nil) {
        _inviteLabel = [[UILabel alloc] init];
        _inviteLabel.font = FCStyle.subHeadlineBold;
        _inviteLabel.textColor = FCStyle.subtitleColor;
        _inviteLabel.text = NSLocalizedString(@"InviteToGetPoint", @"");
        _inviteLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _inviteLabel;
}

- (InviteRulesView *)inviteRulesView {
    if(_inviteRulesView == nil) {
        _inviteRulesView = [[InviteRulesView alloc] init];
        _inviteRulesView.layer.cornerRadius = 10;
        _inviteRulesView.layer.masksToBounds = YES;
        _inviteRulesView.backgroundColor = FCStyle.secondaryBackground;
        _inviteRulesView.translatesAutoresizingMaskIntoConstraints = NO;
        [_inviteRulesView setupUI];
    }
    return _inviteRulesView;
}

- (HowToInviteView *)howToInviteView {
    if(_howToInviteView == nil) {
        _howToInviteView = [[HowToInviteView alloc] init];
        _howToInviteView.layer.cornerRadius = 10;
        _howToInviteView.backgroundColor = FCStyle.secondaryBackground;
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(clickHowTo)];
        [_howToInviteView addGestureRecognizer:gesture];
        _howToInviteView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _howToInviteView;
}

- (UIButton *)inviteBtn {
    if(_inviteBtn == nil) {
        _inviteBtn = [[UIButton alloc] init];
        [_inviteBtn setTitle:NSLocalizedString(@"StartInviting", @"") forState:UIControlStateNormal];
        Boolean isPro = [[FCStore shared] getPlan:NO] == FCPlan.None?FALSE:TRUE;
        if(isPro) {
            [_inviteBtn setTitle:NSLocalizedString(@"StartGifting", @"") forState:UIControlStateNormal];

        }
        
        
        [_inviteBtn setTitleColor:FCStyle.accent forState:UIControlStateNormal];
        [_inviteBtn addTarget:self action:@selector(inviteCreate:) forControlEvents:UIControlEventTouchUpInside];
        _inviteBtn.font = FCStyle.bodyBold;
        _inviteBtn.layer.borderColor = FCStyle.accent.CGColor;
        _inviteBtn.layer.borderWidth = 1;
        _inviteBtn.layer.cornerRadius = 10;
        _inviteBtn.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _inviteBtn;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        if (@available(iOS 15.0, *)){
           _tableView.sectionHeaderTopPadding = 0;
        }
        _tableView.sectionFooterHeight = 0;
        [self.view addSubview:_tableView];
                
        [NSLayoutConstraint activateConstraints:@[
            [_tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
            [_tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
            [_tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
            [_tableView.heightAnchor constraintEqualToConstant:self.view.height]
        ]];
        
    }
    return _tableView;
}


- (SYInviteCardController *)inviteCardController {
    if(_inviteCardController == nil) {
        _inviteCardController = [[SYInviteCardController alloc] init];
        _inviteCardController.nav = self.navigationController;
        
    }
    return _inviteCardController;
}

- (InviteImageView *)inviteImageView {
    if(nil == _inviteImageView) {
        _inviteImageView = [[InviteImageView alloc] init];
        _inviteImageView.backgroundColor = FCStyle.secondaryBackground;
        _inviteImageView.layer.cornerRadius = 10;
        _inviteImageView.layer.masksToBounds = YES;
        _inviteImageView.nav = self.navigationController;
        _inviteImageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _inviteImageView;
}


- (UILabel *)proPointLabel {
    if(nil == _proPointLabel) {
        _proPointLabel = [[UILabel alloc] init];
        _proPointLabel.text = [NSString stringWithFormat:@"%@ %@",@([SharedStorageManager shared].userDefaultsExRO.availableGiftPoints).description,NSLocalizedString(@"Points",@"")];
        _proPointLabel.font = FCStyle.title3Bold;
        _proPointLabel.textColor = FCStyle.accent;
        _proPointLabel.textAlignment = NSTextAlignmentCenter;
        _proPointLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
    }
    return _proPointLabel;
}

- (UILabel *)proInviteLeftLabel {
    if(nil == _proInviteLeftLabel) {
        _proInviteLeftLabel = [[UILabel alloc] init];
        _proInviteLeftLabel.textAlignment = NSTextAlignmentCenter;
        _proInviteLeftLabel.font = FCStyle.headlineBold;
        _proInviteLeftLabel.textColor = FCStyle.fcBlack;
        _proInviteLeftLabel.translatesAutoresizingMaskIntoConstraints = NO;

    }
    return _proInviteLeftLabel;
}

- (UILabel *)proGiftTitleLabel {
    if(nil == _proGiftTitleLabel) {
        _proGiftTitleLabel = [[UILabel alloc] init];
        _proGiftTitleLabel.text = NSLocalizedString(@"GiftYourPoint", @"");
        _proGiftTitleLabel.font = FCStyle.subHeadlineBold;
        _proGiftTitleLabel.textColor = FCStyle.subtitleColor;
        _proGiftTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _proGiftTitleLabel;
}

- (void)shareLink:(UIButton *)sender {
    //分享的url
    NSArray *activityItems = @[_detail.link];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];

    activityVC.popoverPresentationController.sourceView = self.view;
    activityVC.popoverPresentationController.sourceRect = self.view.bounds;
    
    [self.navigationController presentViewController:activityVC animated:YES completion:nil];
}

- (void)clickHowTo {
    
    NSString *url = @"https://www.craft.do/s/7Cc0xEh8BZ9HJg";
    Boolean isPro = [[FCStore shared] getPlan:NO] == FCPlan.None?FALSE:TRUE;

    if(!isPro) {
        url = @"https://www.craft.do/s/fkiUptzlNzV2DA";
    }
    
    
#ifdef FC_MAC
        [FCShared.plugin.appKit openUrl:[NSURL URLWithString:url]];
#else
//        if (FCDeviceTypeIPhone == DeviceHelper.type){
            SFSafariViewController *safariVc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:url]];
            [self presentViewController:safariVc animated:YES completion:nil];
//        } else{
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
//        }
#endif
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:@"app.stay.notification.SaveInviteSuccess"
                                                      object:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
