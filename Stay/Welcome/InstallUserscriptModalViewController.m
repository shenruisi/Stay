//
//  InstallUserscriptModalViewController.m
//  Stay
//
//  Created by ris on 2023/5/4.
//

#import "InstallUserscriptModalViewController.h"
#import "FCApp.h"
#import "FCStyle.h"
#import "ImageHelper.h"
#import "SYNetworkUtils.h"
#import "UIImageView+WebCache.h"
#import "FCRoundedShadowView2.h"
#import "DownloadScriptSlideController.h"
#import "Tampermonkey.h"
#import "DataManager.h"
#import <CommonCrypto/CommonDigest.h>
#import "UserscriptUpdateManager.h"
#import "SharedStorageManager.h"
#import "ScriptMananger.h"
#import "DeviceHelper.h"

@interface InstallUserscriptModalViewController()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *bigTitle;
@property (nonatomic, strong) NSDictionary *scriptDic;
@property (nonatomic, strong) UIView *imageBox;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIButton *runBtn;
@property (nonatomic, strong) UILabel *previewLabel;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) DownloadScriptSlideController *loadingSlideController;

@end

@implementation InstallUserscriptModalViewController

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
    
    
    NSLocale *locale = [NSLocale currentLocale];

    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT),^{
    
        [[SYNetworkUtils shareInstance] requestPOST:@"https://api.shenyin.name/stay-fork/tutorial/userscript" params:@{@"client":@{@"pro":@true,@"country":locale != nil?locale.countryCode:@""}} successBlock:^(NSString * _Nonnull responseObject) {
            
            NSData *jsonData = [responseObject dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
            options:NSJSONReadingMutableContainers
            error:nil];
            
            
            self.scriptDic = dic[@"biz"];
            dispatch_async(dispatch_get_main_queue(),^{
                [self imageBox];
                NSString *icon = self.scriptDic[@"icon_url"];
                [self.iconImageView sd_setImageWithURL:[NSURL URLWithString: icon]];
                self.titleLabel.text = self.scriptDic[@"name"];
                self.descLabel.text = self.scriptDic[@"author"];
                [self runBtn];
                [self previewLabel];
                NSArray *picArray = self.scriptDic[@"screenshots"];
                if(picArray != nil) {
                    CGFloat imageleft = 27;
                    for(int i = 0; i < picArray.count; i++) {
                        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 250, 540)];
                        //            [imageView sd_setImageWithURL:picArray[i]];
                        [imageView sd_setImageWithURL:picArray[i] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                            UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanBigImageClick1:)];
                            [imageView addGestureRecognizer:tapGestureRecognizer1];
                            //让UIImageView和它的父类开启用户交互属性
                            [imageView setUserInteractionEnabled:YES];
                        }];
                        imageView.layer.cornerRadius = 25;
                        imageView.layer.borderWidth = 1;
                        imageView.layer.borderColor = FCStyle.borderColor.CGColor;
                        imageView.layer.masksToBounds = YES;
                        imageView.left = imageleft;
                        [self.scrollView addSubview:imageView];
                        if(i < picArray.count - 1) {
                            imageleft += 27 + 250;
                        } else {
                            imageleft += 250 - picArray.count * 10;
                        }
                        _scrollView.contentSize = CGSizeMake(imageleft, 540);
                    }
                    
           
                }
            });
        } failBlock:^(NSError * _Nonnull error) {
            
        }];

  
    });
    
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
    NSArray *datas =  [[DataManager shareManager] findScript:1];
    BOOL userscriptInstalled = datas.count > 0;
    if (userscriptInstalled){
        [self.navigationController popModalViewController];
    }
}

- (void)getDetail:(UIButton *)sender {
    NSString *url = self.scriptDic[@"hosting_url"];
    NSString *name = self.scriptDic[@"name"];
    NSString *icon = self.scriptDic[@"icon_url"];
    self.loadingSlideController = nil;
    self.loadingSlideController.originMainText = name;
    self.loadingSlideController.iconUrl = icon;
    [self.loadingSlideController show];


    NSMutableCharacterSet *set  = [[NSCharacterSet URLFragmentAllowedCharacterSet] mutableCopy];
     [set addCharactersInString:@"#"];
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT),^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[url stringByAddingPercentEncodingWithAllowedCharacters:set]]];
        NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        UserScript *userScript =  [[Tampermonkey shared] parseWithScriptContent:str];
        if( userScript != nil && userScript.errorMessage != nil && userScript.errorMessage.length > 0 ) {
            if(userScript.errorCode >= 1000) {
                dispatch_async(dispatch_get_main_queue(),^{
                    if (self.loadingSlideController.isShown){
                        [self.loadingSlideController dismiss];
                        self.loadingSlideController = nil;
                    }
                    NSNotification *notification = [NSNotification notificationWithName:@"downloadError" object:userScript.errorMessage];
                    [[NSNotificationCenter defaultCenter]postNotification:notification];
                });
            } else {
//                [self.loadingSlideController updateSubText:userScript.errorMessage];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),
                               dispatch_get_main_queue(), ^{
                    
                    
                    
                    if (self.loadingSlideController.isShown){
                        [self.loadingSlideController dismiss];
                        self.loadingSlideController = nil;
                    }
                });
            }
            return;
        }
        NSString *uuidName = [NSString stringWithFormat:@"%@%@",userScript.name,userScript.namespace];
        NSString *uuid = [self md5HexDigest:uuidName];
        userScript.uuid = uuid;
        userScript.active = true;
        userScript.downloadUrl = url;

        BOOL saveSuccess = [[UserscriptUpdateManager shareManager] saveRequireUrl:userScript];
        BOOL saveResourceSuccess = [[UserscriptUpdateManager shareManager] saveResourceUrl:userScript];
        if(!saveSuccess || !saveResourceSuccess) {
//            [self.loadingSlideController updateSubText:NSLocalizedString(@"Error", @"")];
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
            
            NSMutableCharacterSet *set  = [[NSCharacterSet URLFragmentAllowedCharacterSet] mutableCopy];
             [set addCharactersInString:@"#"];
            if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[self.scriptDic[@"have_a_try"] stringByAddingPercentEncodingWithAllowedCharacters:set]]]){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.scriptDic[@"have_a_try"] stringByAddingPercentEncodingWithAllowedCharacters:set]]];
            }
        });
    });
    
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
        _bigTitle.text = NSLocalizedString(@"InstallUserscript", @"");
        [self.view addSubview:_bigTitle];
        [NSLayoutConstraint activateConstraints:@[
            [_bigTitle.leadingAnchor constraintEqualToAnchor:_backButton.trailingAnchor],
            [_bigTitle.centerYAnchor constraintEqualToAnchor:_backButton.centerYAnchor]
        ]];
    }
    
    return _bigTitle;
}

- (FCRoundedShadowView2 *)imageBox {
    if(_imageBox == nil) {
        _imageBox = [[FCRoundedShadowView2 alloc] initWithRadius:28 borderWith:1 cornerMask:kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner];
        _imageBox.layer.borderColor = FCStyle.borderColor.CGColor;
        _imageBox.backgroundColor = FCStyle.fcWhite;
        _imageBox.translatesAutoresizingMaskIntoConstraints = NO;
        _imageBox.clipsToBounds = YES;
        _imageBox.layer.cornerRadius = 28;
        [self.view addSubview:_imageBox];
        [NSLayoutConstraint activateConstraints:@[
            [_imageBox.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
            [_imageBox.topAnchor constraintEqualToAnchor:self.bigTitle.bottomAnchor constant:22],
            [_imageBox.heightAnchor constraintEqualToConstant:118],
            [_imageBox.widthAnchor constraintEqualToConstant:118]

        ]];
    }
    return _imageBox;
}

- (UIImageView *)iconImageView {
    if(_iconImageView == nil) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.contentMode =  UIViewContentModeScaleAspectFit;
        _iconImageView.clipsToBounds = YES;
        _iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.imageBox addSubview:self.iconImageView];
        [NSLayoutConstraint activateConstraints:@[
            [_iconImageView.centerXAnchor constraintEqualToAnchor:self.imageBox.centerXAnchor],
            [_iconImageView.centerYAnchor constraintEqualToAnchor:self.imageBox.centerYAnchor],
            [_iconImageView.heightAnchor constraintEqualToConstant:78],
            [_iconImageView.widthAnchor constraintEqualToConstant:78]
        ]];
    }
    
    return _iconImageView;
}

- (UILabel *)titleLabel {
    if(_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = FCStyle.title3Bold;
        _titleLabel.textColor = FCStyle.fcBlack;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.lineBreakMode= NSLineBreakByTruncatingTail;
        _titleLabel.numberOfLines = 2;
        [self.view addSubview:_titleLabel];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [_titleLabel.leftAnchor constraintEqualToAnchor:self.imageBox.rightAnchor constant:16],
            [_titleLabel.topAnchor constraintEqualToAnchor:self.bigTitle.bottomAnchor constant:25],
//            [_titleLabel.heightAnchor constraintEqualToConstant:28],
            [_titleLabel.widthAnchor constraintEqualToConstant:200]
        ]];
    }
    return _titleLabel;
}

- (UILabel *)descLabel {
    if(_descLabel == nil) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.font = FCStyle.subHeadline;
        _descLabel.textColor = FCStyle.grayNoteColor;
        _descLabel.textAlignment = NSTextAlignmentLeft;
        _descLabel.lineBreakMode= NSLineBreakByTruncatingTail;
        [self.view addSubview:_descLabel];
        _descLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [_descLabel.leftAnchor constraintEqualToAnchor:self.imageBox.rightAnchor constant:16],
            [_descLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:5],
            [_descLabel.heightAnchor constraintEqualToConstant:19],
            [_descLabel.widthAnchor constraintEqualToConstant:200]
        ]];
    }
    return _descLabel;
}

-(UIButton *)runBtn {
    if(_runBtn == nil) {
        _runBtn = [[UIButton alloc] init];
        _runBtn.layer.borderWidth = 1;
        _runBtn.layer.borderColor = FCStyle.accent.CGColor;
        [_runBtn setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"GuidePage2Button", @"")
                                                                attributes:@{
            NSForegroundColorAttributeName : FCStyle.accent,
            NSFontAttributeName : FCStyle.subHeadlineBold
        }] forState:UIControlStateNormal];
        [_runBtn addTarget:self action:@selector(getDetail:) forControlEvents:UIControlEventTouchUpInside];
        _runBtn.layer.cornerRadius = 15;
        
        [self.view addSubview:_runBtn];
        _runBtn.translatesAutoresizingMaskIntoConstraints = NO;
        CGRect rect = [NSLocalizedString(@"GuidePage2Button", @"") boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, FCStyle.bodyBold.pointSize)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName : FCStyle.subHeadlineBold}
                                               context:nil];
        [NSLayoutConstraint activateConstraints:@[
            [_runBtn.leftAnchor constraintEqualToAnchor:self.imageBox.rightAnchor constant:16],
            [_runBtn.bottomAnchor constraintEqualToAnchor:self.imageBox.bottomAnchor constant:-2],
            [_runBtn.heightAnchor constraintEqualToConstant:30],
            [_runBtn.widthAnchor constraintEqualToConstant:rect.size.width + 20]
        ]];

    }
    return _runBtn;
}

- (UILabel *)previewLabel {
    if(_previewLabel == nil) {
        _previewLabel = [[UILabel alloc] init];
        _previewLabel.font = FCStyle.title3Bold;
        _previewLabel.textColor = FCStyle.fcBlack;
        _previewLabel.textAlignment = NSTextAlignmentLeft;
        _previewLabel.lineBreakMode= NSLineBreakByTruncatingTail;
        _previewLabel.text = NSLocalizedString(@"GuidePage2Text5", @"");
        [self.view addSubview:_previewLabel];
    
        _previewLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [_previewLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
            [_previewLabel.topAnchor constraintEqualToAnchor:self.imageBox.bottomAnchor constant:16],
            [_previewLabel.heightAnchor constraintEqualToConstant:21],
            [_previewLabel.widthAnchor constraintEqualToConstant:100]
        ]];
    }
    
    return _previewLabel;
}

- (UIScrollView *)scrollView {
    if(_scrollView == nil) {
        _scrollView= [[UIScrollView alloc] init];
        _scrollView.clipsToBounds = NO;
        _scrollView.pagingEnabled = true;
        _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
        _scrollView.showsHorizontalScrollIndicator = false;

        [self.view addSubview:_scrollView];
        [NSLayoutConstraint activateConstraints:@[
            [_scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
            [_scrollView.topAnchor constraintEqualToAnchor:self.previewLabel.bottomAnchor constant:15],
            [_scrollView.heightAnchor constraintEqualToConstant:540],
            [_scrollView.widthAnchor constraintEqualToConstant:267]
        ]];
    }
    return _scrollView;
}

- (DownloadScriptSlideController *)loadingSlideController{
    if (nil == _loadingSlideController){
        _loadingSlideController = [[DownloadScriptSlideController alloc] init];
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
