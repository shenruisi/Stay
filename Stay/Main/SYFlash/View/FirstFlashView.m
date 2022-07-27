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

@interface FirstFlashView()<
UITableViewDelegate,
UITableViewDataSource
>
@property (nonatomic, strong) LoadingSlideController *loadingSlideController;

@end

@implementation FirstFlashView

-(void)createFirstView {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGFloat left = 18;
    CGFloat top = 55;
    
    CGFloat width = self.width / 2 - (left * 2);
    
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(left, top, width, 24)];
    title.text = @"尝试首次通过Stay 2来运行脚本";
    title.font = FCStyle.headlineBold;
    title.textColor = FCStyle.fcBlack;
    [self addSubview:title];
    
    top += 36;
    
    UILabel *stepLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, top, width, 22)];
    stepLabel.text = @"步骤 1/2";
    stepLabel.font = FCStyle.body;
    stepLabel.textColor = FCStyle.fcPlaceHolder;
    [self addSubview:stepLabel];
    
    top += 26;
    
    UILabel *extensionLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, top, width, 22)];
    extensionLabel.text = @"激活Stay 2浏览器扩展";
    extensionLabel.font = FCStyle.body;
    extensionLabel.textColor = FCStyle.fcBlack;
    [self addSubview:extensionLabel];
    
    top += 32;
    
    UIView *activiteView = [[UIView alloc] initWithFrame:CGRectMake(14, top, width, 48)];
    activiteView.backgroundColor = FCStyle.background;
    activiteView.layer.cornerRadius = 8;
    UIImage *image = [UIImage imageNamed:self.activite?@"icon":@"noActIcon"];
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(9,17,26,26)] ;
    imageview.image = image;
    imageview.centerY = 24;
    [activiteView addSubview:imageview];
    
    UILabel *activiteLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, top, 50, 22)];
    activiteLabel.text = self.activite?@"已激活":@"未激活";
    activiteLabel.font = FCStyle.bodyBold;
    activiteLabel.textColor = FCStyle.fcBlack;
    activiteLabel.right = width - 15 - 28;
    activiteLabel.centerY = 24;
    [activiteView addSubview:activiteLabel];
    [self addSubview:activiteView];
    
    top += 61;
    
    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, top, width, 22)];
    tipsLabel.text = @"根据如下视频操作喂你吃后,返回Stay 2";
    tipsLabel.font = FCStyle.body;
    tipsLabel.textColor = FCStyle.fcPlaceHolder;
    [self addSubview:tipsLabel];
    
    top += 42;
    CGFloat imageLeft = (self.width / 2 - 320) / 2;
    UIImageView *techImageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageLeft, top, 320, 452.84)];
    UIImage *techImage = [UIImage imageNamed:@"flash"];
    techImageView.layer.borderWidth = 5;
    techImageView.layer.cornerRadius = 8;
    techImageView.layer.borderColor = FCStyle.fcPlaceHolder.CGColor;
    techImageView.image = techImage;
    [self addSubview:techImageView];
    
    UIImageView *playImageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageLeft, top, 58, 58)];
    UIImage *playImage = [UIImage systemImageNamed:@"play.circle.fill" withConfiguration:[UIImageSymbolConfiguration configurationWithFont:[UIFont systemFontOfSize:48]]];
    playImage = [playImage imageWithTintColor:FCStyle.fcBlack renderingMode:UIImageRenderingModeAlwaysOriginal];
    playImageView.image = playImage;
    playImageView.center = techImageView.center;
    [self addSubview:playImageView];
    
    top += 452.84 + 20;
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(81, top, 241, 45)];
    btn.backgroundColor = FCStyle.accent;
    btn.layer.cornerRadius = 8;
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitle:self.activite?@"下一步":@"去激活" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font = FCStyle.bodyBold;
    UIImage *nextImage = [UIImage systemImageNamed:@"chevron.right" withConfiguration:[UIImageSymbolConfiguration configurationWithFont:[UIFont systemFontOfSize:16]]];
    nextImage = [nextImage imageWithTintColor:FCStyle.fcBlack renderingMode:UIImageRenderingModeAlwaysOriginal];
    [btn setImage:nextImage forState:UIControlStateNormal];
    
    btn.titleEdgeInsets =  UIEdgeInsetsMake(0, -170, 0, 0);
    btn.imageEdgeInsets = UIEdgeInsetsMake(0, 210, 0, 0);
    [self addSubview:btn];
    

    
    left = width + 18 + 36;
    top = 55;
    
    UILabel *title2 = [[UILabel alloc] initWithFrame:CGRectMake(left, top, width, 24)];
    title2.text = @"尝试首次通过Stay 2来运行脚本";
    title2.font = FCStyle.headlineBold;
    title2.textColor = FCStyle.fcBlack;
    [self addSubview:title2];
    top += 36;
    
    UILabel *stepLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(left, top, width, 22)];
    stepLabel2.text = @"步骤 2/2";
    stepLabel2.font = FCStyle.body;
    stepLabel2.textColor = FCStyle.fcPlaceHolder;
    [self addSubview:stepLabel2];
    top += 26;
    
    UILabel *extensionLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(left, top, width, 22)];
    extensionLabel2.text = @"选择脚本运行";
    extensionLabel2.font = FCStyle.body;
    extensionLabel2.textColor = FCStyle.fcBlack;
    [self addSubview:extensionLabel2];
    top += 41;
    
    
    self.tableview.top = top;
    self.tableview.left = left;
    
    
    _runBtn = [[UIButton alloc] initWithFrame:CGRectMake(left, top, 241, 45)];
    _runBtn.backgroundColor = FCStyle.accent;
    _runBtn.layer.cornerRadius = 8;
    [_runBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _runBtn.titleLabel.font = FCStyle.bodyBold;
    [_runBtn setImage:nextImage forState:UIControlStateNormal];
    _runBtn.titleEdgeInsets =  UIEdgeInsetsMake(0, -100, 0, 0);
    _runBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 210, 0, 0);
    _runBtn.bottom = self.height - 100;
    _runBtn.centerX = self.width * 3 / 4;
    [_runBtn addTarget:self action:@selector(clickRun) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_runBtn];
    
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
                [_runBtn setTitle:[NSString stringWithFormat:@"运行%@", _scriptList[0][@"name"]] forState:UIControlStateNormal];
            });

        }
        dispatch_async(dispatch_get_main_queue(),^{
            [self.tableview reloadData];
        });
    });
    
    top += 233;
    
    UIButton *seeMoreBtn = [[UIButton alloc] initWithFrame:CGRectMake(left, top, width, 24)];
    [seeMoreBtn setTitle:@"查看更多脚本安装方式" forState:UIControlStateNormal];
    seeMoreBtn.titleLabel.font = FCStyle.headline;
    [seeMoreBtn setTitleColor: FCStyle.accent forState:UIControlStateNormal];
    
    [seeMoreBtn addTarget:self action:@selector(seeMore) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:seeMoreBtn];
    
    UIButton *closebtn = [[UIButton alloc] initWithFrame:CGRectMake(left, top, 40, 22)];
    [closebtn  setTitle:@"跳过" forState:UIControlStateNormal];
    closebtn.titleLabel.font = FCStyle.body;
    [closebtn setTitleColor:FCStyle.accent forState:UIControlStateNormal];
    closebtn.top = 10;
    closebtn.right = self.width / 2 -17;
    [closebtn addTarget:self action:@selector(closeFlash) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closebtn];
    
    UIButton *closebtn2 = [[UIButton alloc] initWithFrame:CGRectMake(left, top, 40, 22)];
    [closebtn2  setTitle:@"跳过" forState:UIControlStateNormal];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
    }
    cell.backgroundColor = DynamicColor(RGB(20, 20, 20),RGB(246, 246, 246));

    cell.contentView.backgroundColor =DynamicColor(RGB(20, 20, 20),RGB(246, 246, 246));
    for (UIView *subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    
    if(indexPath.row == self.selectedCount) {
        cell.contentView.backgroundColor  = RGBA(182, 32, 224, 0.11);
    }
    
    NSString *icon = self.scriptList[indexPath.row][@"icon"];

    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(15,15,26,26)] ;
    [imageview sd_setImageWithURL:[NSURL URLWithString: icon]];
    [cell.contentView addSubview:imageview];

    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(54, 18, 300, 22)];
    title.text = self.scriptList[indexPath.row][@"name"];
    title.font = FCStyle.headlineBold;
    title.textColor = FCStyle.fcBlack;
    [cell.contentView addSubview:title];
    
    
    
    UILabel *desc = [[UILabel alloc] initWithFrame:CGRectMake(15, 49, tableView.width - 30, 45)];
    desc.text = self.scriptList[indexPath.row][@"description"];
    desc.font = FCStyle.body;
    desc.textColor = FCStyle.fcPlaceHolder;
    desc.numberOfLines = 0;
    [cell.contentView addSubview:desc];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(14,97, tableView.width - 30,1)];
    line.backgroundColor = FCStyle.fcSeparator;
    [cell.contentView addSubview:line];
    return  cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 98.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedCount = indexPath.row;
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
        [[DataManager shareManager] insertUserConfigByUserScript:userScript];
        
        
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
        _tableview = [[UITableView alloc]initWithFrame:CGRectMake(14 , 0, self.width / 2  - 28, 212) style:UITableViewStylePlain];
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.backgroundColor = DynamicColor(RGB(28, 28, 28),[UIColor whiteColor]);
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
