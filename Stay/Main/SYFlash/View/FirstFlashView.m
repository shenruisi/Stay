//
//  FirstFlashView.m
//  Stay
//
//  Created by zly on 2022/7/24.
//

#import "FirstFlashView.h"
#import "FCStyle.h"
#import "SYNetworkUtils.h"
#import "UIImageView+WebCache.h"
#import "LoadingSlideController.h"
#import "Tampermonkey.h"
#import "DataManager.h"
#import "NSString+Urlencode.h"
#import "UserscriptUpdateManager.h"
#import <CommonCrypto/CommonDigest.h>
#import "SharedStorageManager.h"
#import "ScriptMananger.h"
#import "ImageHelper.h"
#import <WebKit/WebKit.h>
#import "SYScanImage.h"
#import "SYBigImageViewController.h"

@interface FirstFlashView()<
UITableViewDelegate,
UITableViewDataSource
>{
    UILabel *_runScriptLabel;
}
@property (nonatomic, strong) LoadingSlideController *loadingSlideController;

@end

@implementation FirstFlashView

-(void)createFirstView {
    
    self.tableview = nil;
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
       
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    CGFloat left = 15;
    CGFloat top = 13;
    CGFloat width = self.width / 3 - (left * 2);

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(left, top, width, 30)];
    title.text = NSLocalizedString(@"GuidePage1Text1", @"");
    title.font = FCStyle.headlineBold;
    title.textColor = FCStyle.fcBlack;
    
    [self addSubview:title];
    
    
    UIButton *feedbackBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 44)];
    [feedbackBtn  setTitle:NSLocalizedString(@"GuidePage1ButtonFeedBack", @"") forState:UIControlStateNormal];
    feedbackBtn.titleLabel.font = FCStyle.body;
    feedbackBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [feedbackBtn setTitleColor:FCStyle.accent forState:UIControlStateNormal];
    [feedbackBtn addTarget:self action:@selector(feedback) forControlEvents:UIControlEventTouchUpInside];
    feedbackBtn.top = top;
    feedbackBtn.right = self.width / 3 - 26;

    [self addSubview:feedbackBtn];
    
    top = title.bottom + 5;
    UILabel *stepLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, top, width, 20)];
    stepLabel.text = NSLocalizedString(@"GuidePage1Text2", @"");
    stepLabel.font = FCStyle.body;
    stepLabel.textColor = FCStyle.fcSecondaryBlack;
    [self addSubview:stepLabel];
    
    top = stepLabel.bottom + 5;
    UILabel *extensionLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, top, width, 20)];
    extensionLabel.text = NSLocalizedString(@"GuidePage1Text3", @"");
    extensionLabel.font = FCStyle.body;
    extensionLabel.textColor = FCStyle.fcBlack;
    [self addSubview:extensionLabel];
    
    top = extensionLabel.bottom + 10;
    UIView *activiteView = [[UIView alloc] initWithFrame:CGRectMake(left, top, width, 35)];
    activiteView.backgroundColor = FCStyle.background;
    activiteView.layer.cornerRadius = 8;
    UIImage *image = [UIImage imageNamed:self.activite?@"NavIcon":@"noActIcon"];
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(15,17,26,26)] ;
    imageview.image = image;
    imageview.centerY = 17.5;
    imageview.layer.cornerRadius = 8;
    imageview.layer.masksToBounds = YES;
    [activiteView addSubview:imageview];
    
    UILabel *activiteLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, top, 100, 22)];
    activiteLabel.text = self.activite? NSLocalizedString(@"Activated", @"") : NSLocalizedString(@"NotActivated", @"");
    activiteLabel.font = FCStyle.body;
    activiteLabel.textColor = FCStyle.fcBlack;
    activiteLabel.right = width - 15;
    activiteLabel.centerY = 17.5;
    activiteLabel.textAlignment = UITextAlignmentRight;
    [activiteView addSubview:activiteLabel];
    [self addSubview:activiteView];
    top = activiteView.bottom + 10;
    
    UIImageView *number1 = [[UIImageView alloc] initWithFrame:CGRectMake(left, top, 24, 24)];
    [number1 setImage:[ImageHelper sfNamed:@"1.circle" font:[UIFont systemFontOfSize:20] color:FCStyle.accent]];
    [self addSubview:number1];

    UIView *tapWebView = [[UIView alloc] initWithFrame:CGRectMake(number1.right + 5, top, width, 30)];
    tapWebView.backgroundColor = [FCStyle.accent colorWithAlphaComponent:0.1];
    tapWebView.layer.cornerRadius = 10;
    tapWebView.clipsToBounds = true;
    
    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 4, width, 22)];

//    tipsLabel.text = NSLocalizedString(@"GuidePage1Text4", @"");
    tipsLabel.text = NSLocalizedString(@"GuidePage1Text4", @"") ;
    tipsLabel.font = FCStyle.bodyBold;

    tipsLabel.textColor = FCStyle.accent;
    [tipsLabel sizeToFit];
    tipsLabel.textAlignment = NSTextAlignmentLeft;
    tapWebView.width = tipsLabel.width + 40;
    UIImageView *arrowImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 17, 17)];
    [arrowImage setImage:[ImageHelper sfNamed:@"arrow.up.right" font:[UIFont systemFontOfSize:18] color:FCStyle.accent]];
    arrowImage.left = tipsLabel.right + 5;
    arrowImage.centerY = tipsLabel.centerY;
    [tapWebView addSubview:tipsLabel];
    [tapWebView addSubview:arrowImage];
    [self addSubview:tapWebView];

    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openTutorial)];
    tapWebView.userInteractionEnabled = true;
    [tapWebView addGestureRecognizer:tapGesture];
    
    top =  number1.bottom + 17;
    
    UIImageView *number2 = [[UIImageView alloc] initWithFrame:CGRectMake(left, top, 24, 24)];
    [number2 setImage:[ImageHelper sfNamed:@"2.circle" font:[UIFont systemFontOfSize:20] color:FCStyle.accent]];
    [self addSubview:number2];
    
    UILabel *tipsLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(number2.right + 5, top, width, 22)];
//    tipsLabel2.attributedText =
    
    NSString *str2 = [NSString stringWithFormat: NSLocalizedString(@"GuidePage1Text5", @""),NSLocalizedString(@"GuidePage1Text11", @""),NSLocalizedString(@"GuidePage1Text19", @"")];
    
    NSMutableAttributedString *noteStr = [[NSMutableAttributedString alloc] initWithString:str2];

    NSRange range = [str2 rangeOfString:NSLocalizedString(@"GuidePage1Text11", @"")];
    
    NSRange range20 = [str2 rangeOfString:NSLocalizedString(@"GuidePage1Text19", @"")];
    tipsLabel2.textColor = FCStyle.fcBlack;
    tipsLabel2.font = FCStyle.body;
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
    tipsLabel2.attributedText = noteStr;
    [tipsLabel2 sizeToFit];
    [self addSubview:tipsLabel2];
    top = number2.bottom + 11;
    
    UIImageView *prewImage = [[UIImageView alloc] initWithFrame:CGRectMake(tipsLabel2.left, top, 332,40)];
    NSString *name1 = @"tutorial2";
    if (! [[UserScript localeCodeLanguageCodeOnly] isEqualToString:@"zh"]) {
        name1 = @"tutorial1-en";
    }
    [prewImage setImage: [UIImage imageNamed:name1]];
    [self addSubview:prewImage];
    
    top = prewImage.bottom + 15;
    
    UIImageView *number3 = [[UIImageView alloc] initWithFrame:CGRectMake(left, top, 24, 24)];
    [number3 setImage:[ImageHelper sfNamed:@"3.circle" font:[UIFont systemFontOfSize:20] color:FCStyle.accent]];
    [self addSubview:number3];
    
    UILabel *tipsLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(number3.right + 5, top, width, 22)];
    tipsLabel3.textColor = FCStyle.fcBlack;
    tipsLabel3.font = FCStyle.body;
    NSString *str3 = [NSString stringWithFormat: NSLocalizedString(@"GuidePage1Text6", @""),NSLocalizedString(@"GuidePage1Text12", @"")];
    NSMutableAttributedString *noteStr2 = [[NSMutableAttributedString alloc] initWithString:str3];
    NSRange range3 = [str3 rangeOfString:NSLocalizedString(@"GuidePage1Text12", @"")];
    [noteStr2 addAttribute:NSForegroundColorAttributeName value:FCStyle.accent range:range3];
    [noteStr2 addAttribute:NSFontAttributeName value:FCStyle.bodyBold range:range3];

    tipsLabel3.attributedText = noteStr2;
    [tipsLabel3 sizeToFit];
    [self addSubview:tipsLabel3];
    
    
    UIImageView *extensionImage = [[UIImageView alloc] initWithFrame:CGRectMake(left, top, 26, 21)];
    [extensionImage setImage:[ImageHelper sfNamed:@"puzzlepiece.extension" font:[UIFont systemFontOfSize:20] color:FCStyle.accent]];
    extensionImage.left = tipsLabel3.right + 5;
    extensionImage.centerY = tipsLabel3.centerY;
    [self addSubview:extensionImage];
    
    top = tipsLabel3.bottom + 10;
    
    UIImageView *prewImage1 = [[UIImageView alloc] initWithFrame:CGRectMake(tipsLabel2.left, top, 225,40)];
    NSString *name2 = @"tutorial3";
    if (! [[UserScript localeCodeLanguageCodeOnly] isEqualToString:@"zh"]) {
        name2 = @"tutorial2-en";
        prewImage1.width = 258;
    }
    [prewImage1 setImage: [UIImage imageNamed:name2]];
    [self addSubview:prewImage1];
    
    top = prewImage1.bottom + 10;

    UIImageView *number4 = [[UIImageView alloc] initWithFrame:CGRectMake(left, top, 24, 24)];
    [number4 setImage:[ImageHelper sfNamed:@"4.circle" font:[UIFont systemFontOfSize:20] color:FCStyle.accent]];
    [self addSubview:number4];
    
    UILabel *tipsLabel4 = [[UILabel alloc] initWithFrame:CGRectMake(number4.right + 5, top, width, 22)];
    tipsLabel4.textColor = FCStyle.fcBlack;
    tipsLabel4.font = FCStyle.body;

    NSString *str4 = [NSString stringWithFormat: NSLocalizedString(@"GuidePage1Text7", @""),NSLocalizedString(@"GuidePage1Text13", @""),NSLocalizedString(@"GuidePage1Text14", @"")];
    NSMutableAttributedString *noteStr3 = [[NSMutableAttributedString alloc] initWithString:str4];
    NSRange range4 = [str4 rangeOfString:NSLocalizedString(@"GuidePage1Text13", @"")];
    [noteStr3 addAttribute:NSForegroundColorAttributeName value:FCStyle.accent range:range4];
    [noteStr3 addAttribute:NSFontAttributeName value:FCStyle.bodyBold range:range4];
    NSRange range5 = [str4 rangeOfString:NSLocalizedString(@"GuidePage1Text14", @"")];
    [noteStr3 addAttribute:NSForegroundColorAttributeName value:FCStyle.accent range:range5];
    [noteStr3 addAttribute:NSFontAttributeName value:FCStyle.bodyBold range:range5];

    tipsLabel4.attributedText = noteStr3;
    [tipsLabel4 sizeToFit];
    [self addSubview:tipsLabel4];
    top = tipsLabel4.bottom + 10;
    
    UIImageView *prewImage2 = [[UIImageView alloc] initWithFrame:CGRectMake(tipsLabel2.left, top, 332,129)];
    NSString *name3 = @"tutorial4";
    if (! [[UserScript localeCodeLanguageCodeOnly] isEqualToString:@"zh"]) {
        name3 = @"tutorial3-en";
    }
    [prewImage2 setImage: [UIImage imageNamed:name3]];
    [self addSubview:prewImage2];
    
    top = prewImage2.bottom + 10;

    UIImageView *number5 = [[UIImageView alloc] initWithFrame:CGRectMake(left, top, 24, 24)];
    [number5 setImage:[ImageHelper sfNamed:@"5.circle" font:[UIFont systemFontOfSize:20] color:FCStyle.accent]];
    [self addSubview:number5];
    
    UILabel *tipsLabel5 = [[UILabel alloc] initWithFrame:CGRectMake(number4.right + 5, top, 71, 22)];
    tipsLabel5.textColor = FCStyle.fcBlack;
    tipsLabel5.font = FCStyle.body;
    NSString *str5 = [NSString stringWithFormat: NSLocalizedString(@"GuidePage1Text8", @""),NSLocalizedString(@"GuidePage1Text13", @"")];
    NSMutableAttributedString *noteStr4 = [[NSMutableAttributedString alloc] initWithString:str5];
    NSRange range6 = [str5 rangeOfString:NSLocalizedString(@"GuidePage1Text13", @"")];
    [noteStr4 addAttribute:NSForegroundColorAttributeName value:FCStyle.accent range:range6];
    [noteStr4 addAttribute:NSFontAttributeName value:FCStyle.bodyBold range:range6];

    tipsLabel5.attributedText= noteStr4;
    [tipsLabel5 sizeToFit];

    [self addSubview:tipsLabel5];
    
    UIImage *iconImage = [UIImage imageNamed:@"NavIcon"];
    UIImageView *iconiImageview = [[UIImageView alloc] initWithFrame:CGRectMake(15,17,24,24)] ;
    iconiImageview.image = iconImage;
    iconiImageview.centerY = tipsLabel5.centerY;
    iconiImageview.left = tipsLabel5.right;
//    iconiImageview.layer.cornerRadius = 8;
//    iconiImageview.layer.masksToBounds = YES;
    [self addSubview:iconiImageview];
    
    
    top = tipsLabel5.bottom + 10;

    UIImageView *prewImage3 = [[UIImageView alloc] initWithFrame:CGRectMake(tipsLabel2.left, top, 226,40)];
    NSString *name4 = @"tutorial5";
    if (! [[UserScript localeCodeLanguageCodeOnly] isEqualToString:@"zh"]) {
        name4 = @"tutorial4-en";
    }
    [prewImage3 setImage: [UIImage imageNamed:name4]];
    [self addSubview:prewImage3];
    
    top = prewImage3.bottom + 15;
    
    UIImageView *number6 = [[UIImageView alloc] initWithFrame:CGRectMake(left, top, 24, 24)];
    [number6 setImage:[ImageHelper sfNamed:@"6.circle" font:[UIFont systemFontOfSize:20] color:FCStyle.accent]];
    [self addSubview:number6];
    
    UILabel *tipsLabel6 = [[UILabel alloc] initWithFrame:CGRectMake(number4.right + 5, top, width - 24, 44)];
    tipsLabel6.textColor = FCStyle.fcBlack;
    tipsLabel6.font = FCStyle.body;
    NSString *str6 = [NSString stringWithFormat: NSLocalizedString(@"GuidePage1Text9", @""),NSLocalizedString(@"GuidePage1Text15", @""),NSLocalizedString(@"GuidePage1Text16", @"")];
    NSMutableAttributedString *noteStr5 = [[NSMutableAttributedString alloc] initWithString:str6];
    NSRange range7 = [str6 rangeOfString:NSLocalizedString(@"GuidePage1Text15", @"")];
    [noteStr5 addAttribute:NSForegroundColorAttributeName value:FCStyle.accent range:range7];
    [noteStr5 addAttribute:NSFontAttributeName value:FCStyle.bodyBold range:range7];
    NSRange range8 = [str6 rangeOfString:NSLocalizedString(@"GuidePage1Text16", @"")];
    [noteStr5 addAttribute:NSForegroundColorAttributeName value:FCStyle.accent range:range8];
    [noteStr5 addAttribute:NSFontAttributeName value:FCStyle.bodyBold range:range8];

    tipsLabel6.attributedText = noteStr5;
    tipsLabel6.numberOfLines = 0;
    [tipsLabel6 sizeToFit];

    [self addSubview:tipsLabel6];
    
    top = tipsLabel6.bottom + 10;

    UIImageView *number7 = [[UIImageView alloc] initWithFrame:CGRectMake(left, top, 24, 24)];
    [number7 setImage:[ImageHelper sfNamed:@"7.circle" font:[UIFont systemFontOfSize:20] color:FCStyle.accent]];
    [self addSubview:number7];
    
    
    UILabel *tipsLabel7 = [[UILabel alloc] initWithFrame:CGRectMake(number4.right + 5, top, width - 24, 22)];
    tipsLabel7.textColor = FCStyle.fcBlack;
    tipsLabel7.font = FCStyle.body;
    NSString *str7 = [NSString stringWithFormat: NSLocalizedString(@"GuidePage1Text10", @""),NSLocalizedString(@"GuidePage1Text17", @""),NSLocalizedString(@"GuidePage1Text18", @"")];
    NSMutableAttributedString *noteStr6 = [[NSMutableAttributedString alloc] initWithString:str7];
    NSRange range9 = [str7 rangeOfString:NSLocalizedString(@"GuidePage1Text17", @"")];
    [noteStr6 addAttribute:NSForegroundColorAttributeName value:FCStyle.accent range:range9];
    [noteStr6 addAttribute:NSFontAttributeName value:FCStyle.bodyBold range:range9];

    NSRange range10 = [str7 rangeOfString:NSLocalizedString(@"GuidePage1Text18", @"")];
    [noteStr6 addAttribute:NSForegroundColorAttributeName value:FCStyle.accent range:range10];
    [noteStr6 addAttribute:NSFontAttributeName value:FCStyle.bodyBold range:range10];
    tipsLabel7.attributedText = noteStr6;
    [tipsLabel7 sizeToFit];
    [self addSubview:tipsLabel7];

    top = tipsLabel7.bottom + 15;
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((self.width/3-240)/2, top, 240, 45)];
    btn.backgroundColor = FCStyle.background;
    btn.layer.cornerRadius = 8;
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, (45 - 16) / 2, 150, 16)];
    titleLabel.text = self.activite?NSLocalizedString(@"Next",@""):NSLocalizedString(@"GuidePage1Button", @"");
    titleLabel.font = FCStyle.bodyBold;
    titleLabel.textColor = FCStyle.accent;
    [btn addSubview:titleLabel];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *accessory = [[UIImageView alloc] initWithFrame:CGRectMake(0, (45 - 16) / 2, 12, 16)];
    [accessory setImage:[ImageHelper sfNamed:@"chevron.right" font:[UIFont systemFontOfSize:16] color:FCStyle.accent]];
    accessory.right = 240 - 15;
    [btn addSubview:accessory];
    [self addSubview:btn];
    


    
    left = self.width/3 + 15;
    top = 13;
    
    UILabel *title2 = [[UILabel alloc] initWithFrame:CGRectMake(left, top, width, 30)];
    title2.text = NSLocalizedString(@"GuidePage1Text1", @"");
    title2.font = FCStyle.headlineBold;
    title2.textColor = FCStyle.fcBlack;
    [self addSubview:title2];
    
    top = title2.bottom + 5;
    UILabel *stepLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(left, top, width, 20)];
    stepLabel2.text = NSLocalizedString(@"GuidePage2Text2", @"");
    stepLabel2.font = FCStyle.body;
    stepLabel2.textColor = FCStyle.fcSecondaryBlack;
    [self addSubview:stepLabel2];
    
    top = stepLabel2.bottom + 5;
    UILabel *extensionLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(left, top, width, 20)];
    extensionLabel2.text = NSLocalizedString(@"GuidePage2Text3", @"");
    extensionLabel2.font = FCStyle.body;
    extensionLabel2.textColor = FCStyle.fcBlack;
    [self addSubview:extensionLabel2];
    
    top += 20;
    self.tableview.top = top;
    
    NSString *url = @"https://stayfork.app/install/iphone";
    
//    if (! [[UserScript localeCodeLanguageCodeOnly] isEqualToString:@"zh"]) {
//        url = @"https://fastclip.app/stay/welcome.json";
//    }
    NSLocale *locale = [NSLocale currentLocale];

    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT),^{
    
        [[SYNetworkUtils shareInstance] requestPOST:@"https://api.shenyin.name/stay-fork/tutorial/userscript" params:@{@"client":@{@"pro":@true,@"country":locale != nil?locale.countryCode:@""}} successBlock:^(NSString * _Nonnull responseObject) {
            
            NSData *jsonData = [responseObject dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
            options:NSJSONReadingMutableContainers
            error:nil];
            
            
            self.scriptDic = dic[@"biz"];
            dispatch_async(dispatch_get_main_queue(),^{
                [self.tableview reloadData];
                if(self.scriptDic != nil) {
                    if(self.scriptDic[@"uuid"] != nil) {
                       UserScript *script = [[DataManager shareManager] selectScriptByUuid:self.scriptDic[@"uuid"]];
                        if(script.usedTimes >= 1) {
                            _runBtn.hidden = false;
                            [_runBtn setTitle:NSLocalizedString(@"GuidePage2ButtonFinished", @"") forState:UIControlStateNormal];
                                    [_runBtn addTarget:self action:@selector(finished) forControlEvents:UIControlEventTouchUpInside];
                        } else {
                            if(script.uuid != nil) {
                                _runBtn.hidden = false;
                                [_runBtn addTarget:self action:@selector(closeFlash) forControlEvents:UIControlEventTouchUpInside];
                            }
                        }
                    }
                } else {
                    _runBtn.hidden = true;
                }
            });
        } failBlock:^(NSError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(),^{
                [self.tableview reloadData];
            });
        }];

  
    });
           
    top = self.tableview.bottom + 15;
    
    _runBtn = [[UIButton alloc] initWithFrame:CGRectMake(left, top, 40, 30)];
    [_runBtn  setTitle:NSLocalizedString(@"Skip", @"") forState:UIControlStateNormal];
    _runBtn.titleLabel.font = FCStyle.body;
    [_runBtn setTitleColor:FCStyle.accent forState:UIControlStateNormal];
    _runBtn.top = 13;
    _runBtn.right = self.width / 3 * 2 -17;
    _runBtn.hidden = true;

    [self addSubview:_runBtn];
    
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 30, 80, 80)];
    imageView.image = [UIImage imageNamed:@"tutorial6"];
    imageView.centerX = self.width / 3 * 2.5;
    [self addSubview:imageView];
    
    
    UILabel *title3 = [[UILabel alloc] initWithFrame:CGRectMake(left, top, width, 28)];
    title3.text = NSLocalizedString(@"GuidePage3Text1", @"");
    title3.font = FCStyle.title3Bold;
    title3.textColor = FCStyle.fcBlack;
    title3.top = imageView.bottom + 24;
    title3.centerX = imageView.centerX;
    title3.textAlignment = NSTextAlignmentCenter;
    [self addSubview:title3];
    
    UILabel *title4 = [[UILabel alloc] initWithFrame:CGRectMake(left, top, width, 22)];
    title4.text = NSLocalizedString(@"GuidePage3Text2", @"");
    title4.font = FCStyle.bodyBold;
    title4.textColor = FCStyle.fcBlack;
    title4.top = title3.bottom + 38;
    title4.centerX = imageView.centerX;
    title4.textAlignment = NSTextAlignmentCenter;
    [self addSubview:title4];
    
    
    UIButton *addMoreBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.width/2+(self.width/2-240)/2, 682, 240, 45)];
    addMoreBtn.backgroundColor = FCStyle.background;
    addMoreBtn.layer.cornerRadius = 10;
    UILabel *btnLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, (45 - 16) / 2, 200, 16)];
    btnLabel.text = NSLocalizedString(@"GuidePage3Button", @"");
    btnLabel.font = FCStyle.bodyBold;
    btnLabel.textColor = FCStyle.accent;
    [addMoreBtn addSubview:btnLabel];
    UIImageView *accessory2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, (45 - 16) / 2, 19, 19)];
    [accessory2 setImage:[ImageHelper sfNamed:@"square.grid.2x2.fill" font:[UIFont systemFontOfSize:16] color:FCStyle.accent]];
    accessory2.right = 240 - 15;
    accessory2.contentMode = UIViewContentModeBottom;
    [addMoreBtn addSubview:accessory2];
    addMoreBtn.centerX = imageView.centerX;
    addMoreBtn.top = title4.bottom + 38;
    [addMoreBtn addTarget:self action:@selector(addMore) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:addMoreBtn];
    
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor =  FCStyle.fcWhite;
    for (UIView *subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    
   
    if(self.scriptDic == nil) {
        return cell;
    }
    CGFloat left = 15;
    
    NSString *icon = self.scriptDic[@"icon_url"];
    
    UIView *imageBox = [[UIView alloc] initWithFrame:CGRectMake(left, 15, 118, 118)];
    imageBox.layer.cornerRadius = 30;
    imageBox.layer.borderWidth = 1;
    imageBox.layer.borderColor = FCStyle.borderColor.CGColor;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 78, 78)];
    [imageView sd_setImageWithURL:[NSURL URLWithString:icon]];
    imageView.clipsToBounds = YES;
    imageView.centerX = 59;
    imageView.centerY = 59;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageBox addSubview:imageView];
    [cell.contentView addSubview:imageBox];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(left + imageBox.right , 20, self.width / 3  - 60 - 118, 21)];
    titleLabel.font = FCStyle.title3Bold;
    titleLabel.textColor = FCStyle.fcBlack;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.lineBreakMode= NSLineBreakByTruncatingTail;
    titleLabel.numberOfLines = 2;
    titleLabel.text = self.scriptDic[@"name"];
    [titleLabel sizeToFit];
    [cell.contentView addSubview:titleLabel];
    
    UILabel *descLabel = [[UILabel alloc]initWithFrame:CGRectMake(left + imageBox.right , titleLabel.bottom, self.width / 3  - 30 - 118 , 19)];
    descLabel.font = FCStyle.subHeadline;
    descLabel.textColor = FCStyle.grayNoteColor;
    descLabel.textAlignment = NSTextAlignmentLeft;
    descLabel.lineBreakMode= NSLineBreakByTruncatingTail;
    descLabel.text = self.scriptDic[@"author"];
    [cell.contentView addSubview:descLabel];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(left + imageBox.right, 100, 240, 30)];
    btn.backgroundColor = FCStyle.background;

    NSString *uuidName = [NSString stringWithFormat:@"%@%@",self.scriptDic[@"name"],self.scriptDic[@"namespace"]];
    NSString *uuid = [self md5HexDigest:uuidName];
    
    if([[DataManager shareManager] selectScriptByUuid:uuid] == nil ||  [[DataManager shareManager] selectScriptByUuid:uuid].uuid == nil) {
    
        [btn setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"GuidePage2Button", @"")
                                                                attributes:@{
            NSForegroundColorAttributeName : FCStyle.accent,
            NSFontAttributeName : FCStyle.subHeadlineBold
        }] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(getDetail:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [btn setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"GuidePage2ButtonAdded", @"")
                                                                attributes:@{
            NSForegroundColorAttributeName : [UIColor whiteColor],
            NSFontAttributeName : FCStyle.subHeadlineBold
        }] forState:UIControlStateNormal];
        btn.backgroundColor = FCStyle.accent;
    }
    [btn sizeToFit];
    btn.width = btn.width + 20;
    btn.bottom = 119 + 10;
    btn.layer.cornerRadius = 15;
    [cell.contentView addSubview:btn];
    
    UILabel *previewLabel = [[UILabel alloc]initWithFrame:CGRectMake(left , imageBox.bottom + 10, self.width / 3 - 30 - 118 , 28)];
    previewLabel.font = FCStyle.title3Bold;
    previewLabel.textColor = FCStyle.fcBlack;
    previewLabel.textAlignment = NSTextAlignmentLeft;
    previewLabel.lineBreakMode= NSLineBreakByTruncatingTail;
    previewLabel.text = NSLocalizedString(@"GuidePage2Text5", @"");
    [cell.contentView addSubview:previewLabel];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, previewLabel.bottom + 10, self.width / 3, 540)];
    
    scrollView.showsHorizontalScrollIndicator = false;
    NSArray *picArray = self.scriptDic[@"screenshots"];
    if(picArray != nil) {
        CGFloat imageleft = 27;
        for(int i = 0; i < picArray.count; i++) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 250, 540)];
            [imageView sd_setImageWithURL:picArray[i]];
            imageView.layer.cornerRadius = 15;
            imageView.layer.borderWidth = 1;
            imageView.layer.borderColor = FCStyle.borderColor.CGColor;
            imageView.layer.masksToBounds = YES;
            imageView.left = imageleft;
            [scrollView addSubview:imageView];
            imageleft += 27 + 250;
            scrollView.contentSize = CGSizeMake(imageleft + 27, 540);
            
            UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanBigImageClick1:)];
            [imageView addGestureRecognizer:tapGestureRecognizer1];
            //让UIImageView和它的父类开启用户交互属性
            [imageView setUserInteractionEnabled:YES];
        }
    }
    
    [cell.contentView addSubview:scrollView];
    
    return  cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 475.0f;
}


- (void)closeFlash {
    NSNotification *notification = [NSNotification notificationWithName:@"closeFlash" object:nil];
    [[NSNotificationCenter defaultCenter]postNotification:notification];
}

- (void)seeMore {
    NSMutableCharacterSet *set  = [[NSCharacterSet URLFragmentAllowedCharacterSet] mutableCopy];
     [set addCharactersInString:@"#"];
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[self.guideUrl stringByAddingPercentEncodingWithAllowedCharacters:set]]]){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.guideUrl stringByAddingPercentEncodingWithAllowedCharacters:set]]];
    }
}

- (void)btnClick {
    if(self.activite) {
        [UIView animateWithDuration:0.5 animations:^{
            self.contentOffset =  CGPointMake(self.width / 3 , 0);
        }];
    }
    else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://fastclip.app"]];
    }
}

- (void)finished {
    [UIView animateWithDuration:0.5 animations:^{
        self.contentOffset =  CGPointMake(self.width / 3 * 2 , 0);
    }];
}

- (void)addMore {
    NSNotification *notification = [NSNotification notificationWithName:@"closeFlash" object:nil];
    [[NSNotificationCenter defaultCenter]postNotification:notification];
}

- (void)openTutorial {
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"https://stayfork.app/install/iphone" ]]){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://stayfork.app/install/iphone"]];
    }
}

- (void)initScrpitContent{
    NSMutableArray *array =  [[NSMutableArray alloc] init];
    NSArray *datas =  [[DataManager shareManager] findScript:1];
    if(datas.count > 0) {
        for(int i = 0; i < datas.count; i++) {
            UserScript *script = datas[i];
            UserscriptInfo *info = [[SharedStorageManager shared] getInfoOfUUID:script.uuid];
            info.content = [script toDictionary];
            [info flush];
            script.parsedContent = @"";
            script.otherContent = @"";
            [array addObject: [script toDictionary]];
        }
        [SharedStorageManager shared].userscriptHeaders.content = array;
        [[SharedStorageManager shared].userscriptHeaders flush];
        [[ScriptMananger shareManager] buildData];
    }
    
}

-(void)scanBigImageClick1:(UITapGestureRecognizer *)tap{
    NSLog(@"点击图片");
    
    UIImageView *clickedImageView = (UIImageView *)tap.view;
    [SYScanImage scanBigImageWithImageView:clickedImageView];
}


- (void)feedback {
    NSString *url = @"mailto:feedback@fastclip.app?subject=Feedback - TUTORIAL_SUBJECT";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]
                                       options:@{} completionHandler:^(BOOL succeed){}];
    
    
}

- (UITableView *)tableview {
    if (_tableview == nil) {
        _tableview = [[UITableView alloc]initWithFrame:CGRectMake(self.width/3+15 , 0, self.width / 3  - 30, self.height) style:UITableViewStylePlain];
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableview.layer.cornerRadius = 8;
        _tableview.scrollEnabled = false;
//        _tableview.backgroundColor = FCStyle.background;
        _tableview.backgroundColor = FCStyle.fcWhite;
        [self addSubview:_tableview];
    }
    return _tableview;
}


- (NSArray *)scriptList {
    if(_scriptList == nil) {
        _scriptList = [NSArray array];
    }
    return _scriptList;
}

- (LoadingSlideController *)loadingSlideController{
    if (nil == _loadingSlideController){
        _loadingSlideController = [[LoadingSlideController alloc] init];
        _loadingSlideController.originMainText = NSLocalizedString(@"settings.downloadScript", @"");
    }
    return _loadingSlideController;
}

- (NSString* )md5HexDigest:(NSString* )input {
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02X", digest[i]];
    }
    return result;
}


- (void)getDetail:(UIButton *)sender {
    NSString *url = self.scriptDic[@"hosting_url"];
    NSString *name = self.scriptDic[@"name"];
    
    self.loadingSlideController.originSubText = name;
    [self.loadingSlideController show];


    NSMutableCharacterSet *set  = [[NSCharacterSet URLFragmentAllowedCharacterSet] mutableCopy];
     [set addCharactersInString:@"#"];
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT),^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[url stringByAddingPercentEncodingWithAllowedCharacters:set]]];
        NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        UserScript *userScript =  [[Tampermonkey shared] parseWithScriptContent:str];

        NSString *uuidName = [NSString stringWithFormat:@"%@%@",userScript.name,userScript.namespace];
        NSString *uuid = [self md5HexDigest:uuidName];
        userScript.uuid = uuid;
        userScript.active = true;
        userScript.downloadUrl = url;

        BOOL saveSuccess = [[UserscriptUpdateManager shareManager] saveRequireUrl:userScript];
        BOOL saveResourceSuccess = [[UserscriptUpdateManager shareManager] saveResourceUrl:userScript];
        if(!saveSuccess || !saveResourceSuccess) {
            [self.loadingSlideController updateSubText:NSLocalizedString(@"Error", @"")];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),
            dispatch_get_main_queue(), ^{
                if (self.loadingSlideController.isShown){
                    [self.loadingSlideController dismiss];
                    self.loadingSlideController = nil;
                }
            });
            return;
        }
        if ([[DataManager shareManager] selectScriptByUuid:userScript.uuid].name.length == 0){
            [[DataManager shareManager] insertUserConfigByUserScript:userScript];
            NSNotification *notification = [NSNotification notificationWithName:@"scriptSaveSuccess" object:nil];
            [[NSNotificationCenter defaultCenter]postNotification:notification];
            NSNotification *addNotification = [NSNotification notificationWithName:@"app.stay.notification.userscriptDidAddNotification" object:nil userInfo:@{@"uuid":uuid}];
            [[NSNotificationCenter defaultCenter]postNotification:addNotification];
            dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT),^{
                NSString *url = [NSString stringWithFormat:@"%@%@",@"https://api.shenyin.name/stay-fork/install/",uuid];
                
                [[SYNetworkUtils shareInstance] requestGET:url params:nil successBlock:^(NSString * _Nonnull responseObject) {
                        NSData *jsonData = [responseObject dataUsingEncoding:NSUTF8StringEncoding];
             
                        } failBlock:^(NSError * _Nonnull error) {
                          
                        }];
            });
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),
        dispatch_get_main_queue(), ^{
            if (self.loadingSlideController.isShown){
                [self.loadingSlideController dismiss];
                self.loadingSlideController = nil;
            }
            [self initScrpitContent];
            [self.tableview reloadData];
            
            NSMutableCharacterSet *set  = [[NSCharacterSet URLFragmentAllowedCharacterSet] mutableCopy];
             [set addCharactersInString:@"#"];
            if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[self.scriptDic[@"have_a_try"] stringByAddingPercentEncodingWithAllowedCharacters:set]]]){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.scriptDic[@"have_a_try"] stringByAddingPercentEncodingWithAllowedCharacters:set]]];
            }
        });
    });
    
}

- (void)onBecomeActive{
    if(self.scriptDic != nil) {
        if(self.scriptDic[@"uuid"] != nil) {
            _runBtn.hidden = false;
           UserScript *script = [[DataManager shareManager] selectScriptByUuid:self.scriptDic[@"uuid"]];
            if(script.usedTimes >= 1) {
                [_runBtn setTitle:NSLocalizedString(@"GuidePage2ButtonFinished", @"") forState:UIControlStateNormal];
                [_runBtn addTarget:self action:@selector(finished) forControlEvents:UIControlEventTouchUpInside];
            } else {
                [_runBtn addTarget:self action:@selector(closeFlash) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
}
@end
