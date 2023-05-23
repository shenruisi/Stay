//
//  EnableStayModalViewController.m
//  Stay
//
//  Created by ris on 2023/5/4.
//

#import "EnableStayModalViewController.h"
#import "FCApp.h"
#import "FCStyle.h"
#import "ImageHelper.h"
#import "Tampermonkey.h"
#import "DataManager.h"
#import "SharedStorageManager.h"
#import "DeviceHelper.h"

@interface EnableStayModalViewController()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *bigTitle;
@property (nonatomic, strong) UILabel *number1;
@property (nonatomic, strong) UIButton *tapBtn;
@property (nonatomic, strong) UILabel *number2;
@property (nonatomic, strong) UILabel *tipsLabel2;
@property (nonatomic, strong) UIImageView *prewImage;
@property (nonatomic, strong) UILabel *number3;
@property (nonatomic, strong) UILabel *tipsLabel3;
@property (nonatomic, strong) UIImageView *extensionImage;
@property (nonatomic, strong) UILabel *number4;
@property (nonatomic, strong) UILabel *tipsLabel4;
@property (nonatomic, strong) UIImageView *prewImage2;
@property (nonatomic, strong) UILabel *number5;
@property (nonatomic, strong) UILabel *tipsLabel5;
@property (nonatomic, strong) UIImageView *prewImage3;
@property (nonatomic, strong) UILabel *number6;
@property (nonatomic, strong) UILabel *tipsLabel6;
@property (nonatomic, strong) UIButton *feedbackBtn;

@end

@implementation EnableStayModalViewController

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
    [self number1];
    [self tapBtn];
    [self number2];
    [self tipsLabel2];
    [self prewImage];
    [self number3];
    [self tipsLabel3];
    [self extensionImage];
    [self number4];
    [self tipsLabel4];
    [self prewImage2];
    [self number5];
    [self tipsLabel5];
    [self prewImage3];
    [self number6];
    [self tipsLabel6];
    [self feedbackBtn];
    
#ifdef FC_MAC
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(onBecomeActive:)
//                                                 name:SVCDidBecomeActiveNotification
//                                               object:nil];
#else
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
#endif
}

- (void)clear{
#ifdef FC_MAC
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:SVCDidBecomeActiveNotification object:nil];
#else
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
#endif
}

- (void)onBecomeActive:(NSNotification *)note{
    [SharedStorageManager shared].userDefaults = nil;
    BOOL safariExtensionEnabled = [SharedStorageManager shared].userDefaults.safariExtensionEnabled;
    if (safariExtensionEnabled){
        [self.navigationController popModalViewController];
    }
}

#pragma click
- (void)openTutorial {
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"https://stayfork.app/install/iphone" ]]){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://stayfork.app/install/iphone"]];
    }
}

- (void)feedback {
    NSString *url = [NSString stringWithFormat:@"mailto:feedback@fastclip.app?subject=Feedback-%@",NSLocalizedString(@"FeedbackEnabling", @"")];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[url  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                                       options:@{} completionHandler:^(BOOL succeed){}];
    
    
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
        _bigTitle.text = NSLocalizedString(@"EnableStay", @"");
        [self.view addSubview:_bigTitle];
        [NSLayoutConstraint activateConstraints:@[
            [_bigTitle.leadingAnchor constraintEqualToAnchor:_backButton.trailingAnchor],
            [_bigTitle.centerYAnchor constraintEqualToAnchor:_backButton.centerYAnchor]
        ]];
    }
    
    return _bigTitle;
}

- (UILabel *)number1 {
    if(_number1 == nil) {
        _number1 =  [[UILabel alloc] init];
        _number1.font = FCStyle.headlineBold;
        _number1.text = @"1.";
        _number1.textColor = FCStyle.fcBlack;
        _number1.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_number1];
        [NSLayoutConstraint activateConstraints:@[
            [_number1.topAnchor constraintEqualToAnchor:self.bigTitle.bottomAnchor constant:31],
            [_number1.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:21],
            [_number1.heightAnchor constraintEqualToConstant:21]

        ]];
    }
    return _number1;
}

- (UIButton *)tapBtn {
    if(_tapBtn == nil) {
        _tapBtn = [[UIButton alloc] init];
        _tapBtn.layer.borderWidth = 1;
        _tapBtn.layer.borderColor = FCStyle.accent.CGColor;
        [_tapBtn setTitleColor:FCStyle.accent forState:UIControlStateNormal];
        [_tapBtn setTitle:NSLocalizedString(@"GuidePage1Text4", @"") forState:UIControlStateNormal];
        _tapBtn.font = FCStyle.bodyBold;
        _tapBtn.translatesAutoresizingMaskIntoConstraints = NO;
        _tapBtn.layer.masksToBounds = YES;
        _tapBtn.layer.cornerRadius = 10;
        [_tapBtn addTarget:self action:@selector(openTutorial) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_tapBtn];

        CGRect rect = [_tapBtn.titleLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, FCStyle.bodyBold.pointSize)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName : FCStyle.bodyBold}
                                               context:nil];
        
        [NSLayoutConstraint activateConstraints:@[
            [_tapBtn.centerYAnchor constraintEqualToAnchor:self.number1.centerYAnchor],
            [_tapBtn.leftAnchor constraintEqualToAnchor:self.number1.rightAnchor constant:7],
            [_tapBtn.heightAnchor constraintEqualToConstant:35],
            [_tapBtn.widthAnchor constraintEqualToConstant:rect.size.width + 10]
        ]];
        
    }
    return _tapBtn;
}

- (UILabel *)number2 {
    if(_number2 == nil) {
        _number2 =  [[UILabel alloc] init];
        _number2.font = FCStyle.headlineBold;
        _number2.text = @"2.";
        _number2.textColor = FCStyle.fcBlack;
        _number2.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_number2];
        [NSLayoutConstraint activateConstraints:@[
            [_number2.topAnchor constraintEqualToAnchor:self.number1.bottomAnchor constant:30],
            [_number2.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:21],
            [_number2.heightAnchor constraintEqualToConstant:21]
        ]];
    }
    return _number2;
}


- (UILabel *)tipsLabel2 {
    if(_tipsLabel2 == nil){
        _tipsLabel2 = [[UILabel alloc] init];
        NSString *str2 = [NSString stringWithFormat: NSLocalizedString(@"GuidePage1Text5", @""),NSLocalizedString(@"GuidePage1Text11", @""),NSLocalizedString(@"GuidePage1Text19", @"")];
        NSMutableAttributedString *noteStr = [[NSMutableAttributedString alloc] initWithString:str2];

        NSRange range = [str2 rangeOfString:NSLocalizedString(@"GuidePage1Text11", @"")];
        
        NSRange range20 = [str2 rangeOfString:NSLocalizedString(@"GuidePage1Text19", @"")];
        _tipsLabel2.textColor = FCStyle.fcBlack;
        _tipsLabel2.font = FCStyle.body;
        if (! [[UserScript localeCodeLanguageCodeOnly] isEqualToString:@"zh"]) {
            [noteStr addAttribute:NSForegroundColorAttributeName value:FCStyle.accent range:range];
            [noteStr addAttribute:NSFontAttributeName value:FCStyle.footnoteBold range:range];
            
            [noteStr addAttribute:NSForegroundColorAttributeName value:FCStyle.accent range:range20];
            [noteStr addAttribute:NSFontAttributeName value:FCStyle.bodyBold range:range20];
        } else {
            [noteStr addAttribute:NSForegroundColorAttributeName value:FCStyle.accent range:range];
            [noteStr addAttribute:NSFontAttributeName value:FCStyle.bodyBold range:range];
            [noteStr addAttribute:NSForegroundColorAttributeName value:FCStyle.accent range:range20];
            [noteStr addAttribute:NSFontAttributeName value:FCStyle.footnoteBold range:range20];
        }
        
        _tipsLabel2.attributedText = noteStr;
        _tipsLabel2.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_tipsLabel2];
        [NSLayoutConstraint activateConstraints:@[
            [_tipsLabel2.topAnchor constraintEqualToAnchor:self.number2.topAnchor],
            [_tipsLabel2.leftAnchor constraintEqualToAnchor:self.number2.rightAnchor constant:7],
            [_tipsLabel2.heightAnchor constraintEqualToConstant:22],
        ]];

    }
    return _tipsLabel2;
}

- (UIImageView *)prewImage {
    if(_prewImage == nil) {
        _prewImage = [[UIImageView alloc] init];
        NSString *name1 = @"tutorial2";
        if (! [[UserScript localeCodeLanguageCodeOnly] isEqualToString:@"zh"]) {
            name1 = @"tutorial1-en";
        }
        [_prewImage setImage: [UIImage imageNamed:name1]];
        _prewImage.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_prewImage];
        [NSLayoutConstraint activateConstraints:@[
            [_prewImage.topAnchor constraintEqualToAnchor:self.tipsLabel2.bottomAnchor constant:12],
            [_prewImage.leftAnchor constraintEqualToAnchor:self.number2.rightAnchor constant:7],
            [_prewImage.heightAnchor constraintEqualToConstant:40],
            [_prewImage.widthAnchor constraintEqualToConstant:320],

        ]];
    }
    return _prewImage;
}


- (UILabel *)number3 {
    if(_number3 == nil) {
        _number3 =  [[UILabel alloc] init];
        _number3.font = FCStyle.headlineBold;
        _number3.text = @"3.";
        _number3.textColor = FCStyle.fcBlack;
        _number3.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_number3];
        [NSLayoutConstraint activateConstraints:@[
            [_number3.topAnchor constraintEqualToAnchor:self.prewImage.bottomAnchor constant:19],
            [_number3.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:21],
            [_number3.heightAnchor constraintEqualToConstant:21]
        ]];
    }
    return _number3;
}

- (UILabel *)tipsLabel3 {
    if(_tipsLabel3 == nil){
        _tipsLabel3 = [[UILabel alloc] init];
     
        _tipsLabel3.textColor = FCStyle.fcBlack;
        _tipsLabel3.font = FCStyle.body;
        NSString *str3 = [NSString stringWithFormat: NSLocalizedString(@"GuidePage1Text6", @""),NSLocalizedString(@"GuidePage1Text12", @"")];
        NSMutableAttributedString *noteStr2 = [[NSMutableAttributedString alloc] initWithString:str3];
        NSRange range3 = [str3 rangeOfString:NSLocalizedString(@"GuidePage1Text12", @"")];
        [noteStr2 addAttribute:NSForegroundColorAttributeName value:FCStyle.accent range:range3];
        [noteStr2 addAttribute:NSFontAttributeName value:FCStyle.bodyBold range:range3];

        _tipsLabel3.attributedText = noteStr2;
        _tipsLabel3.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_tipsLabel3];
        [NSLayoutConstraint activateConstraints:@[
            [_tipsLabel3.topAnchor constraintEqualToAnchor:self.number3.topAnchor],
            [_tipsLabel3.leftAnchor constraintEqualToAnchor:self.number3.rightAnchor constant:7],
            [_tipsLabel3.heightAnchor constraintEqualToConstant:22],
        ]];

    }
    return _tipsLabel3;
}

- (UIImageView *)extensionImage {
    if(_extensionImage == nil) {
        _extensionImage = [[UIImageView alloc] init];
        int width = 225;
        NSString *name2 = @"tutorial3";
        if (! [[UserScript localeCodeLanguageCodeOnly] isEqualToString:@"zh"]) {
            name2 = @"tutorial2-en";
            width = 258;
        }
        _extensionImage.translatesAutoresizingMaskIntoConstraints = NO;

        [_extensionImage setImage: [UIImage imageNamed:name2]];
        [self.view addSubview:_extensionImage];
        
        [NSLayoutConstraint activateConstraints:@[
            [_extensionImage.topAnchor constraintEqualToAnchor:self.tipsLabel3.bottomAnchor constant:12],
            [_extensionImage.leftAnchor constraintEqualToAnchor:self.number3.rightAnchor constant:7],
            [_extensionImage.heightAnchor constraintEqualToConstant:40],
            [_extensionImage.widthAnchor constraintEqualToConstant:width],

        ]];
    }
    return _extensionImage;
}

- (UILabel *)number4 {
    if(_number4 == nil) {
        _number4 =  [[UILabel alloc] init];
        _number4.font = FCStyle.headlineBold;
        _number4.text = @"4.";
        _number4.textColor = FCStyle.fcBlack;
        _number4.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_number4];
        [NSLayoutConstraint activateConstraints:@[
            [_number4.topAnchor constraintEqualToAnchor:self.extensionImage.bottomAnchor constant:19],
            [_number4.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:21],
            [_number4.heightAnchor constraintEqualToConstant:21]
        ]];
    }
    return _number4;
}

- (UILabel *)tipsLabel4 {
    if(_tipsLabel4 == nil){
        _tipsLabel4 = [[UILabel alloc] init];
        _tipsLabel4.textColor = FCStyle.fcBlack;
        _tipsLabel4.font = FCStyle.body;
        NSString *str4 = [NSString stringWithFormat: NSLocalizedString(@"GuidePage1Text7", @""),NSLocalizedString(@"GuidePage1Text13", @""),NSLocalizedString(@"GuidePage1Text14", @"")];
        NSMutableAttributedString *noteStr3 = [[NSMutableAttributedString alloc] initWithString:str4];
        NSRange range4 = [str4 rangeOfString:NSLocalizedString(@"GuidePage1Text13", @"")];
        [noteStr3 addAttribute:NSForegroundColorAttributeName value:FCStyle.accent range:range4];
        [noteStr3 addAttribute:NSFontAttributeName value:FCStyle.bodyBold range:range4];
        NSRange range5 = [str4 rangeOfString:NSLocalizedString(@"GuidePage1Text14", @"")];
        [noteStr3 addAttribute:NSForegroundColorAttributeName value:FCStyle.accent range:range5];
        [noteStr3 addAttribute:NSFontAttributeName value:FCStyle.bodyBold range:range5];

        _tipsLabel4.attributedText = noteStr3;
        _tipsLabel4.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_tipsLabel4];
        [NSLayoutConstraint activateConstraints:@[
            [_tipsLabel4.topAnchor constraintEqualToAnchor:self.number4.topAnchor],
            [_tipsLabel4.leftAnchor constraintEqualToAnchor:self.number4.rightAnchor constant:7],
            [_tipsLabel4.heightAnchor constraintEqualToConstant:22],
        ]];
    }
    return _tipsLabel4;
}

- (UIImageView *)prewImage2 {
    if(_prewImage2 == nil) {
        _prewImage2 = [[UIImageView alloc] init];
        NSString *name3 = @"tutorial4";
        if (! [[UserScript localeCodeLanguageCodeOnly] isEqualToString:@"zh"]) {
            name3 = @"tutorial3-en";
        }
        _prewImage2.translatesAutoresizingMaskIntoConstraints = NO;

        [_prewImage2 setImage: [UIImage imageNamed:name3]];
        [self.view addSubview:_prewImage2];
        
        [NSLayoutConstraint activateConstraints:@[
            [_prewImage2.topAnchor constraintEqualToAnchor:self.tipsLabel4.bottomAnchor constant:12],
            [_prewImage2.leftAnchor constraintEqualToAnchor:self.number4.rightAnchor constant:7],
            [_prewImage2.heightAnchor constraintEqualToConstant:129],
            [_prewImage2.widthAnchor constraintEqualToConstant:332],

        ]];
    }
    return _prewImage2;
}

- (UILabel *)number5 {
    if(_number5 == nil) {
        _number5 =  [[UILabel alloc] init];
        _number5.font = FCStyle.headlineBold;
        _number5.text = @"5.";
        _number5.textColor = FCStyle.fcBlack;
        _number5.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_number5];
        [NSLayoutConstraint activateConstraints:@[
            [_number5.topAnchor constraintEqualToAnchor:self.prewImage2.bottomAnchor constant:21],
            [_number5.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:21],
            [_number5.heightAnchor constraintEqualToConstant:21]
        ]];
    }
    return _number5;
}

- (UILabel *)tipsLabel5 {
    if(_tipsLabel5 == nil){
        _tipsLabel5 = [[UILabel alloc] init];
        _tipsLabel5.textColor = FCStyle.fcBlack;
        _tipsLabel5.font = FCStyle.body;
        NSString *str5 = [NSString stringWithFormat: NSLocalizedString(@"GuidePage1Text8", @""),NSLocalizedString(@"GuidePage1Text13", @"")];
        NSMutableAttributedString *noteStr4 = [[NSMutableAttributedString alloc] initWithString:str5];
        NSRange range6 = [str5 rangeOfString:NSLocalizedString(@"GuidePage1Text13", @"")];
        [noteStr4 addAttribute:NSForegroundColorAttributeName value:FCStyle.accent range:range6];
        [noteStr4 addAttribute:NSFontAttributeName value:FCStyle.bodyBold range:range6];

        _tipsLabel5.attributedText= noteStr4;
        _tipsLabel5.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_tipsLabel5];
        [NSLayoutConstraint activateConstraints:@[
            [_tipsLabel5.topAnchor constraintEqualToAnchor:self.number5.topAnchor],
            [_tipsLabel5.leftAnchor constraintEqualToAnchor:self.number5.rightAnchor constant:7],
            [_tipsLabel5.heightAnchor constraintEqualToConstant:22],
        ]];
    }
    return _tipsLabel5;
}

- (UIImageView *)prewImage3 {
    if(_prewImage3 == nil) {
        _prewImage3 = [[UIImageView alloc] init];
        NSString *name4 = @"tutorial5";
        if (! [[UserScript localeCodeLanguageCodeOnly] isEqualToString:@"zh"]) {
            name4 = @"tutorial5-en";
        }
        [_prewImage3 setImage: [UIImage imageNamed:name4]];
        _prewImage3.translatesAutoresizingMaskIntoConstraints = NO;

        [self.view addSubview:_prewImage3];
        
        [NSLayoutConstraint activateConstraints:@[
            [_prewImage3.topAnchor constraintEqualToAnchor:self.tipsLabel5.bottomAnchor constant:12],
            [_prewImage3.leftAnchor constraintEqualToAnchor:self.number5.rightAnchor constant:7],
            [_prewImage3.heightAnchor constraintEqualToConstant:40],
            [_prewImage3.widthAnchor constraintEqualToConstant:226],

        ]];
    }
    return _prewImage3;
 }

- (UILabel *)number6 {
    if(_number6 == nil) {
        _number6 =  [[UILabel alloc] init];
        _number6.font = FCStyle.headlineBold;
        _number6.text = @"6.";
        _number6.textColor = FCStyle.fcBlack;
        _number6.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_number6];
        [NSLayoutConstraint activateConstraints:@[
            [_number6.topAnchor constraintEqualToAnchor:self.prewImage3.bottomAnchor constant:21],
            [_number6.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:21],
            [_number6.heightAnchor constraintEqualToConstant:21]
        ]];
    }
    return _number6;
}

- (UILabel *)tipsLabel6 {
    if(_tipsLabel6 == nil){
        _tipsLabel6 = [[UILabel alloc] init];
        _tipsLabel6.textColor = FCStyle.fcBlack;
        _tipsLabel6.font = FCStyle.body;
        NSString *str6 = [NSString stringWithFormat: NSLocalizedString(@"GuidePage1Text9", @""),NSLocalizedString(@"GuidePage1Text15", @""),NSLocalizedString(@"GuidePage1Text16", @"")];
        NSMutableAttributedString *noteStr5 = [[NSMutableAttributedString alloc] initWithString:str6];
        NSRange range7 = [str6 rangeOfString:NSLocalizedString(@"GuidePage1Text15", @"")];
        [noteStr5 addAttribute:NSForegroundColorAttributeName value:FCStyle.accent range:range7];
        [noteStr5 addAttribute:NSFontAttributeName value:FCStyle.bodyBold range:range7];
        NSRange range8 = [str6 rangeOfString:NSLocalizedString(@"GuidePage1Text16", @"")];
        [noteStr5 addAttribute:NSForegroundColorAttributeName value:FCStyle.accent range:range8];
        [noteStr5 addAttribute:NSFontAttributeName value:FCStyle.bodyBold range:range8];

        _tipsLabel6.attributedText = noteStr5;
        _tipsLabel6.numberOfLines = 2;
        _tipsLabel6.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_tipsLabel6];
        [NSLayoutConstraint activateConstraints:@[
            [_tipsLabel6.topAnchor constraintEqualToAnchor:self.number6.topAnchor],
            [_tipsLabel6.leftAnchor constraintEqualToAnchor:self.number6.rightAnchor constant:7],
            [_tipsLabel6.widthAnchor constraintEqualToConstant:240]
        ]];
    }
    return _tipsLabel6;
}

- (UIButton *)feedbackBtn {
    if(_feedbackBtn == nil) {
        _feedbackBtn = [[UIButton alloc] init];
        _feedbackBtn.layer.borderWidth = 1;
        _feedbackBtn.layer.borderColor = FCStyle.accent.CGColor;
        [_feedbackBtn setTitleColor:FCStyle.accent forState:UIControlStateNormal];
        [_feedbackBtn setTitle:NSLocalizedString(@"GuidePage1ButtonFeedBack", @"") forState:UIControlStateNormal];
        _feedbackBtn.font = FCStyle.bodyBold;
        _feedbackBtn.translatesAutoresizingMaskIntoConstraints = NO;
        _feedbackBtn.layer.masksToBounds = YES;
        _feedbackBtn.layer.cornerRadius = 10;
        [_feedbackBtn addTarget:self action:@selector(feedback) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_feedbackBtn];
        
        [NSLayoutConstraint activateConstraints:@[
            [_feedbackBtn.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:21],
            [_feedbackBtn.topAnchor constraintEqualToAnchor:self.tipsLabel6.bottomAnchor  constant:49],
            [_feedbackBtn.heightAnchor constraintEqualToConstant:45],
            [_feedbackBtn.widthAnchor constraintEqualToConstant:349]
        ]];
        
    }
    return _feedbackBtn;
}

- (void)backAction{
    [self.navigationController popModalViewController];
}

- (CGSize)mainViewSize{
    if (FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type]){
        return CGSizeMake(500, 700);
    }
    else{
        return FCApp.keyWindow.size;
    }
}


@end
