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
    CGFloat left = 15;
    CGFloat top = 40;
    CGFloat width = self.width / 2 - (left * 2);

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(left, top, width, 30)];
    title.text = NSLocalizedString(@"GuidePage1Text1", @"");
    title.font = FCStyle.title1Bold;
    title.textColor = FCStyle.fcBlack;
    [self addSubview:title];
    
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
    UIView *activiteView = [[UIView alloc] initWithFrame:CGRectMake(left, top, width, 45)];
    activiteView.backgroundColor = FCStyle.background;
    activiteView.layer.cornerRadius = 8;
    UIImage *image = [UIImage imageNamed:self.activite?@"icon":@"noActIcon"];
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(15,17,26,26)] ;
    imageview.image = image;
    imageview.centerY = 24;
    [activiteView addSubview:imageview];
    
    UILabel *activiteLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, top, 100, 22)];
    activiteLabel.text = self.activite? NSLocalizedString(@"Activated", @"") : NSLocalizedString(@"NotActivated", @"");
    activiteLabel.font = FCStyle.body;
    activiteLabel.textColor = FCStyle.fcBlack;
    activiteLabel.right = width - 15;
    activiteLabel.centerY = 24;
    activiteLabel.textAlignment = UITextAlignmentRight;
    [activiteView addSubview:activiteLabel];
    [self addSubview:activiteView];
    
    top = activiteView.bottom + 10;
    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, top, width, 22)];
    tipsLabel.text = NSLocalizedString(@"GuidePage1Text4", @"");
    tipsLabel.font = FCStyle.body;
    tipsLabel.textColor = FCStyle.fcSecondaryBlack;
    [self addSubview:tipsLabel];
    
    top =  tipsLabel.bottom + 10;
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    WKUserContentController * wkUController = [[WKUserContentController alloc] init];
    config.userContentController = wkUController;
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake((self.width/2 - 320) / 2,top,320,450) configuration:config];
    webView.layer.cornerRadius = 10;
    webView.layer.borderColor = FCStyle.fcSeparator.CGColor;
    webView.layer.borderWidth = 1;
    [webView setOpaque:false];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://fastclip.app/stay/video/activated.htm"]]];
    [self addSubview:webView];
    
    top = webView.bottom + 15;
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((self.width/2-240)/2, top, 240, 45)];
    btn.backgroundColor = FCStyle.accent;
    btn.layer.cornerRadius = 8;
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, (45 - 16) / 2, 150, 16)];
    titleLabel.text = self.activite?NSLocalizedString(@"Next",@""):NSLocalizedString(@"GuidePage1Button", @"");
    titleLabel.font = FCStyle.bodyBold;
    titleLabel.textColor = [UIColor whiteColor];
    [btn addSubview:titleLabel];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *accessory = [[UIImageView alloc] initWithFrame:CGRectMake(0, (45 - 16) / 2, 12, 16)];
    [accessory setImage:[ImageHelper sfNamed:@"chevron.right" font:[UIFont systemFontOfSize:16] color:[UIColor whiteColor]]];
    accessory.right = 240 - 15;
    [btn addSubview:accessory];
    [self addSubview:btn];
    

    
    left = self.width/2 + 15;
    top = 40;
    
    UILabel *title2 = [[UILabel alloc] initWithFrame:CGRectMake(left, top, width, 30)];
    title2.text = NSLocalizedString(@"GuidePage1Text1", @"");
    title2.font = FCStyle.title1Bold;
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
    
    top += 41;
    self.tableview.top = top;
    
    NSString *url = @"https://fastclip.app/stay/welcome-zh.json";
    
    if (![[UserScript localeCode] isEqualToString:@"zh"]) {
        url = @"https://fastclip.app/stay/welcome.json";
    }
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT),^{
    
        NSMutableCharacterSet *set  = [[NSCharacterSet URLFragmentAllowedCharacterSet] mutableCopy];
         [set addCharactersInString:@"#"];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[url stringByAddingPercentEncodingWithAllowedCharacters:set]]];

        if (data.length > 0) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            self.scriptList = dic[@"userscripts"];
            self.guideUrl = dic[@"guide"];
            dispatch_async(dispatch_get_main_queue(),^{
                self->_runScriptLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"GuidePage2Button", @""), self->_scriptList[0][@"name"]];
                
            });

        }
        dispatch_async(dispatch_get_main_queue(),^{
            [self.tableview reloadData];
        });
    });
    
    top = self.tableview.bottom + 15;
//    UIButton *seeMoreBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.width/2+(self.width/2-240)/2, top, 240, 24)];
//    [seeMoreBtn setTitle:NSLocalizedString(@"GuidePage2Text4", @"") forState:UIControlStateNormal];
//    seeMoreBtn.titleLabel.font = FCStyle.body;
//    [seeMoreBtn setTitleColor: FCStyle.accent forState:UIControlStateNormal];
//    [seeMoreBtn addTarget:self action:@selector(seeMore) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:seeMoreBtn];
    
    _runBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.width/2+(self.width/2-240)/2, 682, 240, 45)];
    _runBtn.backgroundColor = FCStyle.accent;
    _runBtn.layer.cornerRadius = 8;
    _runScriptLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, (45 - 16) / 2, 200, 16)];
    _runScriptLabel.text = self.activite?NSLocalizedString(@"Next",@""):NSLocalizedString(@"GuidePage1Button", @"");
    _runScriptLabel.font = FCStyle.bodyBold;
    _runScriptLabel.textColor = [UIColor whiteColor];
    [_runBtn addSubview:_runScriptLabel];
    UIImageView *accessory2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, (45 - 16) / 2, 12, 16)];
    [accessory2 setImage:[ImageHelper sfNamed:@"chevron.right" font:[UIFont systemFontOfSize:16] color:[UIColor whiteColor]]];
    accessory2.right = 240 - 15;
    [_runBtn addSubview:accessory2];
    [_runBtn addTarget:self action:@selector(clickRun) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_runBtn];
    
    UIButton *closebtn = [[UIButton alloc] initWithFrame:CGRectMake(left, top, 40, 22)];
    [closebtn  setTitle:NSLocalizedString(@"Skip", @"") forState:UIControlStateNormal];
    closebtn.titleLabel.font = FCStyle.body;
    [closebtn setTitleColor:FCStyle.accent forState:UIControlStateNormal];
    closebtn.top = 10;
    closebtn.right = self.width / 2 -17;
    [closebtn addTarget:self action:@selector(closeFlash) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closebtn];
    
    UIButton *closebtn2 = [[UIButton alloc] initWithFrame:CGRectMake(left, top, 40, 22)];
    [closebtn2  setTitle:NSLocalizedString(@"Skip", @"") forState:UIControlStateNormal];
    closebtn2.titleLabel.font = FCStyle.body;
    [closebtn2 setTitleColor:FCStyle.accent forState:UIControlStateNormal];
    closebtn2.top = 10;
    closebtn2.right = self.width -17;
    [closebtn2 addTarget:self action:@selector(closeFlash) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closebtn2];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.scriptList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.backgroundColor = FCStyle.secondaryPopup;

    cell.contentView.backgroundColor = FCStyle.secondaryPopup;
    for (UIView *subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    
    if(indexPath.row == self.selectedCount) {
        cell.contentView.backgroundColor  = FCStyle.accentHighlight;
    }
    
    NSString *icon = self.scriptList[indexPath.row][@"icon"];

    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(15,12,26,26)] ;
    [imageview sd_setImageWithURL:[NSURL URLWithString: icon]];
    [cell.contentView addSubview:imageview];

    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(54, 18, 300, 16)];
    title.text = self.scriptList[indexPath.row][@"name"];
    title.font = FCStyle.bodyBold;
    title.textColor = FCStyle.fcBlack;
    [cell.contentView addSubview:title];
    
    
    
    UILabel *desc = [[UILabel alloc] initWithFrame:CGRectMake(15, 40, tableView.width - 30, 45)];
    desc.text = self.scriptList[indexPath.row][@"description"];
    desc.font = FCStyle.subHeadline;
    desc.textColor = FCStyle.fcSecondaryBlack;
    desc.numberOfLines = 0;
    [cell.contentView addSubview:desc];
    
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(14,97, tableView.width - 30,1)];
    line.backgroundColor = FCStyle.fcSeparator;
    [cell.contentView addSubview:line];
    line.hidden = indexPath.row == self.scriptList.count - 1;
    
    return  cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 98.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedCount = indexPath.row;
    self->_runScriptLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"GuidePage2Button", @""),  _scriptList[indexPath.row][@"name"]];
    [tableView reloadData];
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

- (void)clickRun {
    [self.loadingSlideController show];
    NSString *url = self.scriptList[self.selectedCount][@"downloadURL"];
    
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
        }
        else{
            [[DataManager shareManager] updateUserScript:userScript];
        }
        
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),
        dispatch_get_main_queue(), ^{
            if (self.loadingSlideController.isShown){
                [self.loadingSlideController dismiss];
                self.loadingSlideController = nil;
            }
            [self closeFlash];
            [self initScrpitContent];
            NSString *jumpurl = self.scriptList[self.selectedCount][@"jumpURL"];
            if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[jumpurl stringByAddingPercentEncodingWithAllowedCharacters:set]]]){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[jumpurl stringByAddingPercentEncodingWithAllowedCharacters:set]]];
            }
        });
    });
    
}

- (void)btnClick {
    if(self.activite) {
        [UIView animateWithDuration:0.5 animations:^{
            self.contentOffset =  CGPointMake(self.width / 2 , 0);
        }];
    }
}


- (void)initScrpitContent{
    NSMutableArray *array =  [[NSMutableArray alloc] init];
    NSArray *datas =  [[DataManager shareManager] findScript:1];
    if(datas.count > 0) {
        for(int i = 0; i < datas.count; i++) {
            UserScript *scrpit = datas[i];
            UserscriptInfo *info = [[SharedStorageManager shared] getInfoOfUUID:scrpit.uuid];
            info.content = [scrpit toDictionary];
            [info flush];
            scrpit.parsedContent = @"";
            [array addObject: [scrpit toDictionary]];
        }
        [SharedStorageManager shared].userscriptHeaders.content = array;
        [[SharedStorageManager shared].userscriptHeaders flush];
        [[ScriptMananger shareManager] buildData];
    }
    
}


- (UITableView *)tableview {
    if (_tableview == nil) {
        _tableview = [[UITableView alloc]initWithFrame:CGRectMake(self.width/2+15 , 0, self.width / 2  - 30, 196) style:UITableViewStylePlain];
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.backgroundColor = [UIColor clearColor];
        _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableview.layer.cornerRadius = 8;
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
@end
