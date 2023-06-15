//
//  SYInviteCardModelController.m
//  Stay
//
//  Created by zly on 2023/6/1.
//

#import "SYInviteCardModelController.h"
#import "FCStyle.h"
#import "UIImageView+WebCache.h"
#import "ImageHelper.h"
#import "FCImageView.h"
#import "API.h"
#import "DeviceHelper.h"
#import "FCStore.h"
#import "UserScript.h"

@interface SelectBarView:UIView

@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;
@end
@implementation SelectBarView

- (instancetype)initWithFrame:(CGRect)frame {
    if([super initWithFrame:frame]) {
        [self setUI];
    }
    
    return self;
}

- (void)setUI{
    // 创建左侧按钮
    _leftButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _leftButton.frame = CGRectMake(0, 0, self.width/2, self.height);
        [self addSubview:_leftButton];
        
    // 创建右侧按钮
    _rightButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _rightButton.frame = CGRectMake(self.width/2, 0, self.width/2, self.height);
    [self addSubview:_rightButton];
    
    // 设置父视图的布局
    _leftButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    _rightButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
}

@end

@interface SYInviteCardModelController()<UITextFieldDelegate>

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *inviteView;
@property (nonatomic, strong) FCImageView *iconImageView;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UILabel *useLabel;
@property (nonatomic, strong) UILabel *stayLabel;
@property (nonatomic, strong) UILabel *sinceLabel;
@property (nonatomic, strong) UIImageView *sigImageView;
@property (nonatomic, strong) UILabel *extensionLabel;
@property (nonatomic, strong) UILabel *nameTitleLabel;
@property (nonatomic, strong) FCImageView *iconView;
@property (nonatomic, strong) UILabel *coverLabel;
@property (nonatomic, strong) SelectBarView *imageControl;
@property (nonatomic, strong) UIView *colorView;
@property (nonatomic, strong) UILabel *colorLabel;
@property (nonatomic, strong) SelectBarView *colorControl;
@property (nonatomic, strong) UIButton *confirmBtn;
@property (nonatomic, strong) NSString *colorStr;
@property (nonatomic, strong) NSString *firstImageStr;
@property (nonatomic, strong) UILabel *proLabel;
@property (nonatomic, strong) UILabel *dateLabel;

@end
@implementation SYInviteCardModelController


- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationBar.showCancel = YES;
    self.colorStr = self.color;
    self.firstImageStr = _defaultImage.length > 0?_defaultImage:@"https://res.stayfork.app/covers/rainbow.png";
    self.hideNavigationBar = NO;
    self.title = NSLocalizedString(@"GenerateCard", @"");
    [self backView];
    [self gradientLayer];
    [self inviteView];
    [self iconImageView];
    [self nameLabel];
    
    Boolean isPro = [[FCStore shared] getPlan:NO] == FCPlan.None?FALSE:TRUE;
    if ([[UserScript localeCodeLanguageCodeOnly] isEqualToString:@"zh"]) {
        self.useLabel.text = [NSString stringWithFormat:@"%@%@开始使用", NSLocalizedString(@"IUseStay",@""),_detail.sinceCn];
        [self.useLabel sizeToFit];
        [self stayLabel];
        [self sigImageView];

        if(isPro) {
            self.proLabel.centerY =  self.useLabel.centerY;
            self.proLabel.left = self.stayLabel.right + 5;
        }
        self.extensionLabel.right = self.inviteView.width - 21;
    } else {
        [self useLabel];
        [self stayLabel];
        if(isPro) {
            self.proLabel.centerY =  self.useLabel.centerY;
            self.proLabel.left = self.stayLabel.right + 5;
            self.dateLabel.centerY = self.useLabel.centerY;
            self.dateLabel.left = self.proLabel.right + 5;
        } else {
            self.dateLabel.centerY = self.useLabel.centerY;
            self.dateLabel.left = self.stayLabel.right + 5;
        }
    }
    
    [self sigImageView];
    [self extensionLabel];
    [self nameTitleLabel];
    [self textField];
    [self iconView];
    [self coverLabel];
    [self imageControl];
    [self colorView];
    [self colorLabel];
    [self colorControl];
    [self confirmBtn];
}

- (void)randomImage
{
    [self.textField resignFirstResponder];
    NSUInteger randomIndex = arc4random_uniform((uint32_t)self.imageList.count);
    _defaultImage = self.imageList[randomIndex];
    [self.iconImageView sd_setImageWithURL:self.defaultImage placeholderImage:nil options:0 context:nil progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.iconImageView.progress = (CGFloat)receivedSize / expectedSize;
        });
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        [self.iconImageView clearProcess];
    }];
    
    
    [self.iconView sd_setImageWithURL:self.defaultImage placeholderImage:nil options:0 context:nil progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.iconView.progress = (CGFloat)receivedSize / expectedSize;
        });
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        [self.iconView clearProcess];
    }];
}

- (void)confirmInviteCard {
        Boolean isPro = [[FCStore shared] getPlan:NO] == FCPlan.None?FALSE:TRUE;

    if(isPro) {
        [[API shared]  queryPath:@"/gift-task/init"
                             pro:isPro
                        deviceId:DeviceHelper.uuid
                             biz:@{
            @"name" : _nameLabel.text,
            @"cover" : _defaultImage.length > 0?_defaultImage:@"https://res.stayfork.app/covers/rainbow.png",
            @"color":_colorStr.length > 0?_colorStr:[self hexFromUIColor:FCStyle.accent]
        }
                      completion:^(NSInteger statusCode, NSError * _Nonnull error, NSDictionary * _Nonnull server, NSDictionary * _Nonnull biz) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                [[NSUserDefaults standardUserDefaults] setObject:@{@"image":_defaultImage.length > 0?_defaultImage:@"https://res.stayfork.app/covers/rainbow.png",@"color":_colorStr.length > 0? _colorStr:@"",
                                                                   @"name":_textField.text
                                                                 }                                                     forKey:@"default_invite"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self.navigationController.slideController dismiss];
                
                NSNotification *notification = [NSNotification notificationWithName:@"app.stay.notification.SaveInviteSuccess" object:nil];
                [[NSNotificationCenter defaultCenter]postNotification:notification];
            });
        }];
    } else {
        [[API shared]  queryPath:@"/invite-task/init"
                             pro:isPro
                        deviceId:DeviceHelper.uuid
                             biz:@{
            @"name" : _nameLabel.text,
            @"cover" : _defaultImage.length > 0?_defaultImage:@"https://res.stayfork.app/covers/rainbow.png",
            @"color":_colorStr.length > 0?_colorStr:[self hexFromUIColor:FCStyle.accent]
        }
                      completion:^(NSInteger statusCode, NSError * _Nonnull error, NSDictionary * _Nonnull server, NSDictionary * _Nonnull biz) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                [[NSUserDefaults standardUserDefaults] setObject:@{@"image":_defaultImage.length > 0?_defaultImage:@"https://res.stayfork.app/covers/rainbow.png",@"color":_colorStr.length > 0? _colorStr:@"",
                                                                   @"name":_textField.text
                                                                 }                                                     forKey:@"default_invite"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self.navigationController.slideController dismiss];
                
                NSNotification *notification = [NSNotification notificationWithName:@"app.stay.notification.SaveInviteSuccess" object:nil];
                [[NSNotificationCenter defaultCenter]postNotification:notification];
            });
            
        }];
    }
 
        
}

- (void)resetImage
{
    [self.textField resignFirstResponder];

    _defaultImage = self.firstImageStr;
    [self.iconImageView sd_setImageWithURL:self.defaultImage placeholderImage:nil options:0 context:nil progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.iconImageView.progress = (CGFloat)receivedSize / expectedSize;
        });
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        [self.iconImageView clearProcess];
    }];
    
    
    [self.iconView sd_setImageWithURL:self.defaultImage placeholderImage:nil options:0 context:nil progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.iconView.progress = (CGFloat)receivedSize / expectedSize;
        });
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        [self.iconView clearProcess];
    }];
}

- (void)randomColor {
    [self.textField resignFirstResponder];

    UIColor *randomColor = [self randomTintColor];
    NSString *hexString = [self hexFromUIColor:randomColor];
    _colorStr = hexString;
    self.nameLabel.textColor = randomColor;
    self.useLabel.textColor = randomColor;
    self.stayLabel.backgroundColor = randomColor;
    [self.sigImageView setImage:[ImageHelper sfNamed:@"arrow.turn.right.down" font:FCStyle.body color:randomColor]];
    self.extensionLabel.textColor = randomColor;
    self.colorView.backgroundColor = randomColor;
    Boolean isPro = [[FCStore shared] getPlan:NO] == FCPlan.None?FALSE:TRUE;
    if (![[UserScript localeCodeLanguageCodeOnly] isEqualToString:@"zh"]) {
        self.dateLabel.textColor =randomColor;
    }
}

- (void)resetColor {
    [self.textField resignFirstResponder];
    _colorStr = _color.length > 0?_color:[self hexFromUIColor:FCStyle.accent];
    UIColor *randomColor = UIColorFromRGB(_colorStr);
    self.nameLabel.textColor = randomColor;
    self.useLabel.textColor = randomColor;
    self.stayLabel.backgroundColor = randomColor;
    [self.sigImageView setImage:[ImageHelper sfNamed:@"arrow.turn.right.down" font:FCStyle.body color:randomColor]];
    self.extensionLabel.textColor = randomColor;
    self.colorView.backgroundColor = randomColor;
    if (![[UserScript localeCodeLanguageCodeOnly] isEqualToString:@"zh"]) {
        self.dateLabel.textColor =randomColor;
    }
}

- (UIColor *)randomTintColor {
    CGFloat red = (CGFloat)arc4random_uniform(256) / 255.0;
    CGFloat green = (CGFloat)arc4random_uniform(256) / 255.0;
    CGFloat blue = (CGFloat)arc4random_uniform(256) / 255.0;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

- (void)textChange {
    self.nameLabel.text = self.textField.text;
    [self.nameLabel sizeToFit];
}


- (UIView *)backView {
    if(_backView == nil) {
        _backView = [[UIView alloc] initWithFrame:CGRectMake(18, 10, [self getMainView].frame.size.width - 36, 350)];
        [self.view addSubview:_backView];
    }

    return _backView;
}

- (UIView *)inviteView {
    if(_inviteView == nil) {
        _inviteView = [[UIView alloc] initWithFrame:CGRectMake(40, 25, [self getMainView].frame.size.width - 36 - 80, 314)];
        _inviteView.backgroundColor = FCStyle.fcWhite;
        _inviteView.layer.cornerRadius = 10;
        _inviteView.clipsToBounds = YES;
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

- (FCImageView *)iconImageView {
    if(nil == _iconImageView) {
        _iconImageView = [[FCImageView alloc] initWithFrame:CGRectMake(14, 14, [self getMainView].frame.size.width - 36 - 80 - 28, 175)];
        if(self.defaultImage.length > 1) {
            [_iconImageView sd_setImageWithURL:self.defaultImage];
        } else {
            [_iconImageView setImage:[UIImage imageNamed:@"rainbow"]];
        }
        
        _iconImageView.layer.cornerRadius = 10;
        _iconImageView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
        _iconImageView.clipsToBounds = YES;
        [self.inviteView addSubview:_iconImageView];
    }
    return _iconImageView;
}

- (UILabel *)nameLabel {
    if(_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, 200, 28)];
        if(_color.length > 0) {
            _nameLabel.textColor =  UIColorFromRGB(_color);
        } else {
            _nameLabel.textColor = FCStyle.accent;
        }
        _nameLabel.font = [UIFont boldSystemFontOfSize:24];
        _nameLabel.text = self.defaultName;
        _nameLabel.top = self.iconImageView.bottom + 12;
        [self.inviteView addSubview:_nameLabel];

    }
    return _nameLabel;
}

-(UITextField *)textField {
    if(_textField == nil) {
        _textField= [[UITextField alloc] initWithFrame:CGRectMake(18, 100, [self getMainView].frame.size.width - 36, 45)];
        _textField.borderStyle = UITextBorderStyleRoundedRect;
        _textField.backgroundColor = FCStyle.secondaryPopup;
        _textField.delegate = self;
        _textField.top = self.nameTitleLabel.bottom + 10;
        _textField.layer.cornerRadius = 10;
        _textField.clipsToBounds = YES;
        _textField.layer.borderWidth = 1;
        _textField.layer.borderColor = FCStyle.borderColor.CGColor;
        _textField.text = self.defaultName;
        [_textField addTarget:self action:@selector(textChange) forControlEvents:UIControlEventEditingChanged];
        [self.view addSubview:_textField];
    }
    return _textField;
}

- (UILabel *)useLabel {
    if(nil == _useLabel) {
        _useLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, 300, 22)];
        _useLabel.font = FCStyle.footnote;
        if(_color.length > 0) {
            _useLabel.textColor =  UIColorFromRGB(_color);
        } else {
            _useLabel.textColor = FCStyle.accent;
        }
        _useLabel.text = NSLocalizedString(@"IUseStay",@"");
        [_useLabel sizeToFit];
        _useLabel.top = self.nameLabel.bottom + 9;
        [self.inviteView addSubview:_useLabel];
    }
    return _useLabel;
}

- (UILabel *)stayLabel {
    if(nil == _stayLabel){
        _stayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 44, 22)];
        if(_color.length > 0) {
            _stayLabel.backgroundColor =  UIColorFromRGB(_color);
        } else {
            _stayLabel.backgroundColor = FCStyle.accent;
        }
        _stayLabel.textColor = FCStyle.fcWhite;
        _stayLabel.font = FCStyle.footnote;
        _stayLabel.text = NSLocalizedString(@"Stay",@"");
        _stayLabel.layer.cornerRadius = 10;
        _stayLabel.clipsToBounds = YES;
        _stayLabel.textAlignment = NSTextAlignmentCenter;
        [self.inviteView addSubview:_stayLabel];
        _stayLabel.left = self.useLabel.right + 5;
        _stayLabel.centerY = self.useLabel.centerY;
    }
    return _stayLabel;
}

- (UIImageView *)sigImageView {
    if(nil == _sigImageView) {
        _sigImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 19)];
        [_sigImageView setImage:[ImageHelper sfNamed:@"arrow.turn.right.down" font:FCStyle.body color:_color.length > 0?UIColorFromRGB(_color):FCStyle.accent]];
        [self.inviteView addSubview:_sigImageView];
        _sigImageView.top = self.stayLabel.bottom;
        _sigImageView.left = self.stayLabel.right - 7;

    }
    return _sigImageView;
}

- (UILabel *)extensionLabel {
    if(nil == _extensionLabel) {
        _extensionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 19)];
        _extensionLabel.font = FCStyle.footnoteBold;
        if(_color.length > 0) {
            _extensionLabel.textColor =  UIColorFromRGB(_color);
        } else {
            _extensionLabel.textColor = FCStyle.accent;
        }
        _extensionLabel.text = NSLocalizedString(@"ASafariExtension",@"");
        [_extensionLabel sizeToFit];
        [self.inviteView addSubview:_extensionLabel];
        _extensionLabel.top = self.sigImageView.bottom;
        _extensionLabel.left = self.stayLabel.left;
    }
    return _extensionLabel;
}

- (UILabel *)nameTitleLabel {
    if(nil == _nameTitleLabel) {
        _nameTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, 42, 18)];
        _nameTitleLabel.font = FCStyle.subHeadlineBold;
        _nameTitleLabel.textColor = FCStyle.subtitleColor;
        _nameTitleLabel.text = NSLocalizedString(@"Name",@"");
        _nameTitleLabel.top = self.backView.bottom + 15;
        [self.view addSubview:_nameTitleLabel];

    }
    return _nameTitleLabel;
}

- (FCImageView *)iconView {
    if(nil == _iconView) {
        _iconView = [[FCImageView alloc] initWithFrame:CGRectMake(18, 0, 26, 26)];
        _iconView.layer.cornerRadius = 13;
        _iconView.clipsToBounds = YES;
        if(self.defaultImage.length > 1) {
            [_iconView sd_setImageWithURL:self.defaultImage];
        } else {
            [_iconView setImage:[UIImage imageNamed:@"rainbow"]];
        }
        [self.view addSubview:_iconView];
        _iconView.top = self.textField.bottom + 15;

    }
    return _iconView;
}

- (UILabel *)coverLabel {
    if(nil == _coverLabel) {
        _coverLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, 44, 18)];
        _coverLabel.font = FCStyle.subHeadlineBold;
        _coverLabel.textColor = FCStyle.subtitleColor;
        _coverLabel.text = NSLocalizedString(@"Cover",@"");
        [self.view addSubview:_coverLabel];
        _coverLabel.centerY = self.iconView.centerY;
        _coverLabel.left =self.iconView.right + 5;
    }
    return _coverLabel;
}

- (SelectBarView *)imageControl {
    if(nil == _imageControl) {
        _imageControl = [[SelectBarView alloc] initWithFrame:CGRectMake(18, 0, [self getMainView].frame.size.width - 36, 45)];
        _imageControl.backgroundColor = FCStyle.secondaryPopup;
        _imageControl.layer.cornerRadius = 10;
        _imageControl.layer.masksToBounds = YES;
        
        [_imageControl.leftButton setTitle:NSLocalizedString(@"Random",@"") forState:UIControlStateNormal];
        [_imageControl.leftButton setTitleColor:FCStyle.accent forState:UIControlStateNormal];
        _imageControl.leftButton.font = FCStyle.body;
        [_imageControl.leftButton addTarget:self action:@selector(randomImage) forControlEvents:UIControlEventTouchUpInside];
        [_imageControl.rightButton setTitle:NSLocalizedString(@"Reset",@"") forState:UIControlStateNormal];
        [_imageControl.rightButton setTitleColor:FCStyle.accent forState:UIControlStateNormal];
        _imageControl.rightButton.font = FCStyle.body;
        [_imageControl.rightButton addTarget:self action:@selector(resetImage) forControlEvents:UIControlEventTouchUpInside];

        [self.view addSubview:_imageControl];
        _imageControl.top = self.iconView.bottom + 15;

    }
    return _imageControl;
}

- (UIView *)colorView {
    if(nil == _colorView) {
        _colorView = [[UIView alloc] initWithFrame:CGRectMake(18, 0, 26, 26)];
        _colorView.layer.cornerRadius = 13;
        _colorView.layer.masksToBounds = YES;
        _colorView.layer.borderColor = FCStyle.borderColor.CGColor;
        _colorView.layer.borderWidth = 1;
        if(_color.length <= 0) {
            _colorView.backgroundColor = FCStyle.accent;
        } else {
            _colorView.backgroundColor = UIColorFromRGB(_color);
        }
        [self.view addSubview:_colorView];
        _colorView.top = self.imageControl.bottom + 15;
    }
    return _colorView;
}

- (UILabel *)colorLabel {
    if(nil == _colorLabel) {
        _colorLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, 44, 18)];
        _colorLabel.font = FCStyle.subHeadlineBold;
        _colorLabel.textColor = FCStyle.subtitleColor;
        _colorLabel.text = NSLocalizedString(@"Color",@"");
        [self.view addSubview:_colorLabel];
        _colorLabel.centerY = self.colorView.centerY;
        _colorLabel.left =self.colorView.right + 5;
    }
    return _colorLabel;
}

- (SelectBarView *)colorControl {
    if(nil == _colorControl) {
        _colorControl = [[SelectBarView alloc] initWithFrame:CGRectMake(18, 0, [self getMainView].frame.size.width - 36, 45)];
        _colorControl.backgroundColor = FCStyle.secondaryPopup;
        _colorControl.layer.cornerRadius = 10;
        _colorControl.layer.masksToBounds = YES;
        
        [_colorControl.leftButton setTitle:NSLocalizedString(@"Random",@"") forState:UIControlStateNormal];
        [_colorControl.leftButton setTitleColor:FCStyle.accent forState:UIControlStateNormal];
        _colorControl.leftButton.font = FCStyle.body;
        [_colorControl.leftButton addTarget:self action:@selector(randomColor) forControlEvents:UIControlEventTouchUpInside];
        [_colorControl.rightButton setTitle:NSLocalizedString(@"Reset",@"") forState:UIControlStateNormal];
        [_colorControl.rightButton setTitleColor:FCStyle.accent forState:UIControlStateNormal];
        _colorControl.rightButton.font = FCStyle.body;
        [_colorControl.rightButton addTarget:self action:@selector(resetColor) forControlEvents:UIControlEventTouchUpInside];

        [self.view addSubview:_colorControl];
        _colorControl.top = self.colorView.bottom + 10;

    }
    return _colorControl;
}

- (UIButton *)confirmBtn {
    if(nil == _confirmBtn) {
        _confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(18, 0, [self getMainView].frame.size.width - 36, 45)];
        [_confirmBtn setTitle:NSLocalizedString(@"Confirm",@"") forState:UIControlStateNormal];
        [_confirmBtn setTitleColor:FCStyle.accent forState:UIControlStateNormal];
        [_confirmBtn addTarget:self action:@selector(confirmInviteCard) forControlEvents:UIControlEventTouchUpInside];
        _confirmBtn.font = FCStyle.bodyBold;
        _confirmBtn.layer.borderColor = FCStyle.accent.CGColor;
        _confirmBtn.layer.borderWidth = 1;
        _confirmBtn.layer.cornerRadius = 10;
        [self.view addSubview:_confirmBtn];
        _confirmBtn.top = self.colorControl.bottom + 15;
    }
    return _confirmBtn;
}

- (UILabel *)proLabel{
    if (nil == _proLabel){
        _proLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 15)];
        _proLabel.backgroundColor = FCStyle.backgroundGolden;
        _proLabel.font = [UIFont boldSystemFontOfSize:10];
        _proLabel.text = @"PRO";
        _proLabel.layer.borderWidth = 1;
        _proLabel.layer.borderColor = FCStyle.borderGolden.CGColor;
        _proLabel.layer.cornerRadius = 5;
        _proLabel.textAlignment = NSTextAlignmentCenter;
        _proLabel.textColor = FCStyle.fcGolden;
        _proLabel.clipsToBounds = YES;
        [self.inviteView addSubview:_proLabel];

    }
    
    return _proLabel;
}

- (UILabel *)dateLabel {
    if(nil == _dateLabel) {
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 18)];
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

    }
    return _dateLabel;
}

- (NSString *)hexFromUIColor:(UIColor *)color
{
    if (CGColorGetNumberOfComponents(color.CGColor) < 4) {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        color = [UIColor colorWithRed:components[0]
                                green:components[0]
                                 blue:components[0]
                                alpha:components[1]];
    }

    if (CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) != kCGColorSpaceModelRGB) {
        return [NSString stringWithFormat:@"#FFFFFF"];
    }

    return [NSString stringWithFormat:@"#%x%x%x", (int)((CGColorGetComponents(color.CGColor))[0]*255.0),
            (int)((CGColorGetComponents(color.CGColor))[1]*255.0),
            (int)((CGColorGetComponents(color.CGColor))[2]*255.0)];
}

- (CGSize)mainViewSize{
    return CGSizeMake(MIN(kScreenWidth - 30, 450), 765);
}

- (void)clear{
}
@end
