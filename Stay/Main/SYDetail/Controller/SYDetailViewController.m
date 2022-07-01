//
//  SYDetailViewController.m
//  Stay
//
//  Created by zly on 2021/11/28.
//

#import "SYDetailViewController.h"
#import "DataManager.h"
#import "SYEditViewController.h"
#import "UserscriptUpdateManager.h"
#import "SYNotesViewController.h"
#import "ScriptMananger.h"
#import "SharedStorageManager.h"
#import "SYSelectTabViewController.h"
#import "FCStyle.h"
#import <objc/runtime.h>

#ifdef Mac
#import "QuickAccess.h"
#endif

@interface SYDetailViewController ()
@property (nonatomic, strong) UIBarButtonItem *rightIcon;
@property (nonatomic, strong) SYSelectTabViewController *sYSelectTabViewController;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIScrollView *matchScrollView;
@property (nonatomic, strong) UIScrollView *grantScrollView;
@property (nonatomic, strong) UIScrollView *whiteTableView;
@property (nonatomic, strong) UIScrollView *blackTableView;
@property (nonatomic, strong) UIButton *actBtn;
@property (nonatomic, strong) UIView *slideView;
@property (nonatomic, strong) UIView *slideLineView;
@property (nonatomic, assign) CGFloat scrollerTop;

@end

@implementation SYDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = FCStyle.popup;

    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
#ifndef Mac
    [self createDetailView];
#endif
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(scriptSaveSuccess:) name:@"scriptSaveSuccess" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deleteScript:) name:@"deleteDetail" object:nil];
    self.navigationItem.rightBarButtonItem = [self rightIcon];
#ifdef Mac
    self.navigationController.navigationBarHidden = YES;
#endif
    // Do any additional setup after loading the view.
}

- (void)navigateViewDidLoad{
#ifdef Mac
    [super navigateViewDidLoad];
    UIView *navigationBarConver = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 50)];
    navigationBarConver.tag = NSIntegerMax;
    navigationBarConver.backgroundColor = FCStyle.background;
    [self.view addSubview:navigationBarConver];
    [self createDetailView];
#endif
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    for (UIView *subView in self.view.subviews) {
        if (subView.tag != NSIntegerMax){
            [subView removeFromSuperview];
        }
    }
    [self createDetailView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}
 
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
}

- (void)scriptSaveSuccess:(id)sender{
    self.script =  [[DataManager shareManager] selectScriptByUuid:self.script.uuid];
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self createDetailView];
}

- (void)buildBlackView {
    [self.blackTableView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGFloat left = 10;
    CGFloat top = 14;
    if(self.script.blacklist != nil && self.script.blacklist.count > 0) {
        for (NSString *str in self.script.blacklist ) {
            UIView *whiteSiteView = [self creteSitesView:str type:@"black"];
            whiteSiteView.top = top;
            whiteSiteView.left = left;
            [self.blackTableView addSubview:whiteSiteView];
            top += 58;
        }
    }
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, self.view.width - 20, 48);
    btn.backgroundColor = FCStyle.accent;
    [btn setTitle:NSLocalizedString(@"settings.add","Add") forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = FCStyle.headlineBold;
    btn.layer.cornerRadius = 8;
    btn.top = top;
    btn.left = left;
    [btn addTarget:self action:@selector(addBlackSite) forControlEvents:UIControlEventTouchUpInside];
    top = btn.bottom + 20;
    [self.blackTableView addSubview:btn];
    self.blackTableView.contentSize = CGSizeMake(self.view.width, top + _scrollerTop);

}

- (void)buildWhiteView {
    [self.whiteTableView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    CGFloat left = 10;
    CGFloat top = 14;
    if(self.script.whitelist != nil && self.script.whitelist.count > 0) {
        for (NSString *str in self.script.whitelist ) {
            UIView *whiteSiteView = [self creteSitesView:str type:@"white"];
            whiteSiteView.top = top;
            whiteSiteView.left = left;
            [self.whiteTableView addSubview:whiteSiteView];
            top += 58;
        }
    }
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, self.view.width - 20, 48);
    btn.backgroundColor = FCStyle.accent;
    [btn setTitle:NSLocalizedString(@"settings.add","Add") forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = FCStyle.headlineBold;
    btn.layer.cornerRadius = 8;
    btn.top = top;
    btn.left = left;
    [btn addTarget:self action:@selector(addWhiteSite) forControlEvents:UIControlEventTouchUpInside];
    [self.whiteTableView addSubview:btn];
    top = btn.bottom + 20;
    self.whiteTableView.contentSize = CGSizeMake(self.view.width, top + _scrollerTop);
}

- (void)createDetailView{
    CGFloat left = 15;
    CGFloat maxWidthRate = 0.7;
    CGFloat top = 0;
#ifdef Mac
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(left, 50 + 20, self.view.width * maxWidthRate, 21)];
#else
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(left, 17 + 91, self.view.width * maxWidthRate, 21)];
#endif
    title.text = self.script.name;
    title.textColor = FCStyle.fcBlack;
    title.font = FCStyle.headlineBold;
    [self.view addSubview:title];
    top = title.bottom + 5;
    UILabel *runAt = [[UILabel alloc] initWithFrame:CGRectMake(left, top, self.view.width * maxWidthRate, 16)];
    runAt.font = FCStyle.subHeadline;
    runAt.text = [NSString stringWithFormat:@"Run at %@",self.script.runAt];
    runAt.textColor = FCStyle.fcBlack;
    [self.view addSubview:runAt];
    top = runAt.bottom + 5;
    UILabel *authour = [[UILabel alloc] initWithFrame:CGRectMake(left, top, self.view.width * maxWidthRate, 16)];
    authour.font = FCStyle.subHeadline;
    authour.text = [NSString stringWithFormat:@"Created by %@",self.script.author];
    authour.textColor = FCStyle.fcSecondaryBlack;
    [self.view addSubview:authour];
    
    if(self.script.active) {
        [self.actBtn setTitle:@"Activated" forState:UIControlStateNormal];
        self.actBtn.backgroundColor = FCStyle.accent;
        self.actBtn.layer.borderWidth = 1;
        self.actBtn.layer.borderColor = FCStyle.accent.CGColor;
        [self.actBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        [self.actBtn setTitle:@"Stopped" forState:UIControlStateNormal];
        self.actBtn.backgroundColor = [UIColor whiteColor];
        [self.actBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.actBtn.layer.borderWidth = 1;
        self.actBtn.layer.borderColor = [UIColor blackColor].CGColor;
    }

    
    top = authour.bottom + 10;
    UILabel *descDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(left,top,self.view.width - left * 2 ,50)];
    descDetailLabel.font = FCStyle.body;
    descDetailLabel.text = self.script.desc;
    descDetailLabel.lineBreakMode= NSLineBreakByTruncatingTail;
    descDetailLabel.textColor =  FCStyle.fcBlack;
    descDetailLabel.textAlignment = NSTextAlignmentLeft;
    descDetailLabel.numberOfLines = 3;
    [descDetailLabel sizeToFit];
    [self.view addSubview:descDetailLabel];
    
    top = descDetailLabel.bottom + 10;
    UIImage *image =  [UIImage systemImageNamed:@"v.circle.fill"
                                 withConfiguration:[UIImageSymbolConfiguration configurationWithFont:[UIFont systemFontOfSize:15]]];
    image = [image imageWithTintColor:FCStyle.fcBlack renderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(left, top, 19, 19);
    [self.view addSubview:imageView];
    
    UILabel *version = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 15)];
    version.font = FCStyle.footnote;
    version.text = self.script.version;
    version.textColor = FCStyle.fcBlack;
    version.left = imageView.right + 5;
    version.centerY = imageView.centerY;
    [self.view addSubview:version];
    top = version.bottom + 10;
    
    if(self.script.license != nil && self.script.license.length > 0) {
        UIImage *licenseImage =  [UIImage systemImageNamed:@"l.circle.fill"
                                     withConfiguration:[UIImageSymbolConfiguration configurationWithFont:[UIFont systemFontOfSize:15]]];
        licenseImage = [licenseImage imageWithTintColor:FCStyle.fcBlack renderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImageView *licenseImageView = [[UIImageView alloc] initWithImage:licenseImage];
        licenseImageView.frame = CGRectMake(left, top, 19, 19);
        [self.view addSubview:licenseImageView];
        UILabel *license = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 15)];
        license.font = FCStyle.footnote;
        license.text = self.script.license;
        license.textColor = FCStyle.fcBlack;
        license.left = licenseImageView.right + 5;
        license.centerY = licenseImageView.centerY;
        [self.view addSubview:license];
        top = license.bottom + 10;
    }
    
    
    if(self.script.downloadUrl != nil && self.script.downloadUrl.length > 0){
       UILabel *autoUpdateLabel = [self createDefaultLabelWithText:NSLocalizedString(@"settings.autoUpdate","autoUpdate")];
        autoUpdateLabel.width = 200;
        autoUpdateLabel.top = top;
        autoUpdateLabel.left = left;
        autoUpdateLabel.font = FCStyle.bodyBold;
        [self.view  addSubview:autoUpdateLabel];
      
        UISwitch *autoUpdateSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(10,99,42 ,31)];
        autoUpdateSwitch.centerY = autoUpdateLabel.centerY;
        autoUpdateSwitch.right = self.view.width - left;
        [autoUpdateSwitch setOnTintColor:FCStyle.accent];
        [autoUpdateSwitch setOn: self.script.updateSwitch];
        [self.view addSubview:autoUpdateSwitch];
        [autoUpdateSwitch addTarget:self action:@selector(updateSwitchAction:) forControlEvents:UIControlEventValueChanged];
        top = autoUpdateLabel.bottom + 15;
   }
    
    UILabel *scriptLabel = [self createDefaultLabelWithText:NSLocalizedString(@"settings.scriptContent","Script Content")];
    scriptLabel.font = FCStyle.bodyBold;
    scriptLabel.width = 200;
    scriptLabel.top = top;
    scriptLabel.left = left;
    [self.view addSubview:scriptLabel];
    
    NSString *imageName = CGColorEqualToColor([[self createBgColor] CGColor],[RGB(20, 20, 20) CGColor])?@"arrow-dark":@"arrow";
    UIImageView *scriptIconLabel = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    scriptIconLabel.right = self.view.width - 19;
    scriptIconLabel.centerY = scriptLabel.centerY;
    [self.view  addSubview:scriptIconLabel];
    
    UIButton *scriptBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    scriptBtn.frame = CGRectMake(0, 0, self.view.width, 40);
    scriptBtn.centerY = scriptLabel.centerY;
    scriptBtn.right = self.view.width - left;

    [scriptBtn addTarget:self action:@selector(showScript:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scriptBtn];

    top = scriptLabel.bottom + 15;
    
    
    UILabel *injectLabel = [self createDefaultLabelWithText:NSLocalizedString(@"settings.injectMode","Inject Mode")];
    injectLabel.font = FCStyle.headlineBold;
    injectLabel.width = 200;
    injectLabel.top = top;
    injectLabel.left = left;
    [self.view addSubview:injectLabel];
    
    NSArray *segmentedArray = [[NSArray alloc]initWithObjects:@"Auto",@"Page",@"Content",nil];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc]initWithItems:segmentedArray];
    segmentedControl.frame =  CGRectMake(0, top, 243.0, 31);
    
    [segmentedControl addTarget:self action:@selector(segmentControllerAction:) forControlEvents:UIControlEventValueChanged];
    if(self.script.injectInto != nil && self.script.injectInto.length > 0) {
        NSUInteger idx = [segmentedArray indexOfObject:self.script.injectInto];
        segmentedControl.selectedSegmentIndex = idx;
    } else {
        segmentedControl.selectedSegmentIndex = 0;
    }
    segmentedControl.right = self.view.width - 13;
    segmentedControl.centerY = injectLabel.centerY;
    [self.view addSubview:segmentedControl];

    top = segmentedControl.bottom + 10;
    
    UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, top, self.view.width, 35)];
    [self.view addSubview:buttonView];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 34, self.view.width, 1)];
    lineView.backgroundColor = FCStyle.fcShadowLine;
    
    [buttonView addSubview:lineView];
    
    NSArray *selectedArray = @[@"Matches",@"Grants",@"White list", @"Black list"];
    CGFloat btnLeft = 5;
    
    for(int i = 0; i < 4; i++) {
        CGFloat btnWidth =  (self.view.width - 10 - 42 ) / 4.0;
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(btnLeft, 0, btnWidth, 31)];
        [btn setTitle:selectedArray[i] forState:UIControlStateNormal];
        [btn setTitleColor:FCStyle.fcBlack forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(switchTab:) forControlEvents:UIControlEventTouchUpInside];
        btn.font = FCStyle.bodyBold;
        btn.tag = 100 + i;
        btnLeft += btnWidth + 14;
        [buttonView addSubview:btn];
        
        if (i == 0) {
            [buttonView addSubview:self.slideView];
            self.slideView.left = 5;
            [buttonView addSubview:self.slideLineView];
            self.slideLineView.left = 5;
        }
    }
    
    
    top = buttonView.bottom;
    _scrollerTop = top;
    self.scrollView.top = top;
    self.scrollView.height = kScreenHeight - top;
    [self.view addSubview:self.scrollView];
    
    [self.scrollView addSubview:self.matchScrollView];
    self.matchScrollView.contentSize = CGSizeMake(self.view.width, self.matchScrollView.contentSize.height + top);
    
    
    [self.scrollView addSubview:self.grantScrollView];
    self.grantScrollView.contentSize = CGSizeMake(self.view.width, self.grantScrollView.contentSize.height + top);

    [self.scrollView addSubview:self.whiteTableView];
    self.whiteTableView.contentSize = CGSizeMake(self.view.width, self.grantScrollView.contentSize.height + top);
    
    [self.scrollView addSubview:self.blackTableView];
    self.blackTableView.contentSize = CGSizeMake(self.view.width, self.grantScrollView.contentSize.height + top);
    [self buildWhiteView];
    [self buildBlackView];
}



- (void)deleteScript:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否删除脚本" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *conform = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.sYSelectTabViewController dismiss];
        [[DataManager shareManager] deleteScriptInUserScriptByNumberId: self.script.uuid];
        [self.navigationController popViewControllerAnimated:TRUE];
        NSNotification *notification = [NSNotification notificationWithName:@"app.stay.notification.userscriptDidDeleteNotification" object:nil];
        [[NSNotificationCenter defaultCenter]postNotification:notification];
    }];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:cancle];
    [alert addAction:conform];
    [self presentViewController:alert animated:YES completion:nil];

}

- (void)showScript:(id)sender {
    SYEditViewController *cer = [[SYEditViewController alloc] init];
    cer.content = self.script.content;
    cer.uuid = self.script.uuid;
    cer.userScript = self.script;
    cer.isEdit = true;
    cer.isSearch = self.isSearch;
#ifdef Mac
    [[QuickAccess secondaryController] pushViewController:cer];
#else
    [self.navigationController pushViewController:cer animated:true];
#endif
}

- (void)showNotes:(id)sender {
    SYNotesViewController *cer = [[SYNotesViewController alloc] init];
    cer.notes = self.script.notes;
    [self.navigationController pushViewController:cer animated:true];
}


- (void)segmentControllerAction:(UISegmentedControl *)segment
{
    NSInteger index = segment.selectedSegmentIndex;
    NSArray *segmentedArray = [[NSArray alloc]initWithObjects:@"Auto",@"Page",@"Content",nil];
    NSString *inject = segmentedArray[index];
    [[DataManager shareManager] updateScriptConfigInjectInfo:inject numberId:self.script.uuid];
    [self initScrpitContent];

}

- (void) switchAction:(id)sender {
    self.script.active = !self.script.active;
    
    if(self.script.active) {
        [self.actBtn setTitle:@"Activated" forState:UIControlStateNormal];
        self.actBtn.backgroundColor = FCStyle.accent;
        self.actBtn.layer.borderWidth = 1;
        self.actBtn.layer.borderColor = FCStyle.accent.CGColor;
        [self.actBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        NSNotification *notification = [NSNotification notificationWithName:@"app.stay.notification.userscriptDidActiveNotification" object:nil];
        [[NSNotificationCenter defaultCenter]postNotification:notification];
    } else {
        [self.actBtn setTitle:@"Stopped" forState:UIControlStateNormal];
        self.actBtn.backgroundColor = [UIColor whiteColor];
        [self.actBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.actBtn.layer.borderWidth = 1;
        self.actBtn.layer.borderColor = [UIColor blackColor].CGColor;
        NSNotification *notification = [NSNotification notificationWithName:@"app.stay.notification.userscriptDidStopNotification" object:nil];
        [[NSNotificationCenter defaultCenter]postNotification:notification];
    }
    
    if (self.script.active) {
        [[DataManager shareManager] updateScrpitStatus:1 numberId:self.script.uuid];
    } else {
        [[DataManager shareManager] updateScrpitStatus:0 numberId:self.script.uuid];
    }
    
    [self initScrpitContent];
}

- (void) updateSwitchAction:(UISwitch *) scriptSwitch {
    if (scriptSwitch.on == YES) {
        [[DataManager shareManager] updateScriptConfigAutoupdate:1 numberId:self.script.uuid];
    } else {
        [[DataManager shareManager] updateScriptConfigAutoupdate:0 numberId:self.script.uuid];
    }
}

- (UIView *)createLine{
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15,99,self.view.width - 57 ,1)];
    UIColor *bgcolor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return RGBA(216, 216, 216, 0.3);
            }
            else {
                return RGBA(37, 37, 40, 1);
            }
        }];

    [line setBackgroundColor:bgcolor];
    return line;
}

- (UILabel *)createDefaultLabelWithText:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.font = FCStyle.headline;
    label.text = text;
    [label sizeToFit];
    return  label;
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

- (void)switchTab:(UIButton *)btn {
    int tag =  btn.tag - 100;
    
    
    [UIView animateWithDuration:0.1 animations:^{
        self.slideView.left = btn.left;
        self.slideLineView.left = btn.left;
    }];
    
    self.scrollView.contentOffset = CGPointMake(tag * self.view.width, 0);
}

- (void)shareBtnClick {
    self.sYSelectTabViewController.url = self.script.downloadUrl;
    self.sYSelectTabViewController.content = self.script.content;
    self.sYSelectTabViewController.needDelete = true;
    [self.sYSelectTabViewController show];
}

- (UIBarButtonItem *)rightIcon {
    if (nil == _rightIcon){
        UIImage *image = [UIImage systemImageNamed:@"ellipsis.circle.fill" withConfiguration:[UIImageSymbolConfiguration configurationWithFont:[UIFont systemFontOfSize:17]]];

        _rightIcon = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(shareBtnClick)];
    }
    return _rightIcon;
}

- (SYSelectTabViewController *)sYSelectTabViewController {
    if(_sYSelectTabViewController == nil) {
        _sYSelectTabViewController = [[SYSelectTabViewController alloc] init];
    }
    return _sYSelectTabViewController;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (UIColor *)createBgColor {
    UIColor *viewBgColor = DynamicColor(RGB(20, 20, 20),RGB(246, 246, 246));
    return viewBgColor;
}


- (UIScrollView *)scrollView {
    if(_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width * 4, kScreenHeight)];
    }
    return _scrollView;
}

- (UIScrollView *)matchScrollView {
    if(_matchScrollView == nil) {
        CGFloat baseLeft = 12;
        _matchScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kScreenHeight)];
        CGFloat top = 13;
        if (self.script.mathes.count > 0) {
            UILabel *matchLabel = [self createDefaultLabelWithText:@"Matches"];
            matchLabel.top = 13;
            matchLabel.left = baseLeft;
            matchLabel.textColor = FCStyle.fcPlaceHolder;
            top = matchLabel.bottom + 8;
            [_matchScrollView addSubview:matchLabel];
            for (int i = 0; i < self.script.mathes.count; i++) {
                NSString *title  = self.script.mathes[i];
                UIView *view = [self baseNote:title];
                if (i == 0) {
                    view.layer.cornerRadius = 8;
                    view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
                }
                view.top = top;
                view.left = baseLeft;
                [_matchScrollView addSubview:view];
                if (i != self.script.mathes.count -1) {
                    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0, self.view.width - 24 - 23, 1)];
                    line.backgroundColor = FCStyle.fcSeparator;
                    line.top = top + 47;
                    line.left = baseLeft + 23;
                    [_matchScrollView addSubview:line];
                } else {
                    view.layer.cornerRadius = 8;
                    view.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMinXMaxYCorner;
                }
                if (self.script.mathes.count == 1) {
                    view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMinXMaxYCorner;
                }
                
                top += 48;
            }
        }
        
        
        if (self.script.includes.count > 0) {
            
            top += 35;
            UILabel *includesLabel = [self createDefaultLabelWithText:@"includes"];
            includesLabel.top = top;
            includesLabel.left = baseLeft;
            includesLabel.textColor = FCStyle.fcPlaceHolder;
            [_matchScrollView addSubview:includesLabel];
            top = includesLabel.bottom + 8;
            
            for (int i = 0; i < self.script.includes.count; i++) {
                NSString *title  = self.script.includes[i];
                UIView *view = [self baseNote:title];
                view.top = top;
                view.left = baseLeft;
                [_matchScrollView addSubview:view];
                if (i == 0) {
                    view.layer.cornerRadius = 8;
                    view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
                }
                if (i != self.script.includes.count -1) {
                    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0, self.view.width - 24 - 23, 1)];
                    line.backgroundColor = FCStyle.fcSeparator;
                    line.top = top + 47;
                    line.left = baseLeft + 23;
                    [_matchScrollView addSubview:line];
                }else {
                    view.layer.cornerRadius = 8;
                    view.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMinXMaxYCorner;
                }
                
                if (self.script.includes.count == 1) {
                    view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMinXMaxYCorner;
                }
                
                top += 48;
            }
        }
        

        if (self.script.excludes.count > 0) {
            top += 35;

            UILabel *excludesLabel =  [self createDefaultLabelWithText:@"excludes"];
            excludesLabel.top = top;
            excludesLabel.left = baseLeft;
            excludesLabel.textColor = FCStyle.fcPlaceHolder;
            [_matchScrollView addSubview:excludesLabel];
            
            top = excludesLabel.bottom + 8;
            for (int i = 0; i < self.script.excludes.count; i ++) {
                NSString *title  = self.script.excludes[i];

                UIView *view = [self baseNote:title];
                view.top = top;
                view.left = baseLeft;
                [_matchScrollView addSubview:view];
                if (i == 0) {
                    view.layer.cornerRadius = 8;
                    view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
                }
                if (i != self.script.excludes.count -1) {
                    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0, self.view.width - 24 - 23, 1)];
                    line.backgroundColor = FCStyle.fcSeparator;
                    line.top = top + 47;
                    line.left = baseLeft + 23;
                    [_matchScrollView addSubview:line];
                }else {
                    view.layer.cornerRadius = 8;
                    view.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMinXMaxYCorner;
                }
                
                if (self.script.excludes.count == 1) {
                    view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMinXMaxYCorner;
                }

                top += 48;
            }
        }
        
        _matchScrollView.contentSize = CGSizeMake(self.view.width,top);
        
        
    }
    return _matchScrollView;
}

- (UIScrollView *)grantScrollView {
    if(_grantScrollView == nil) {
        _grantScrollView =  [[UIScrollView alloc] initWithFrame:CGRectMake(self.view.width, 0, self.view.width, kScreenHeight)];
        CGFloat baseLeft = 12;
        CGFloat top = 22;
        if (self.script.grants.count > 0) {
            for (int i = 0; i < self.script.grants.count; i++) {
                NSString *title  = self.script.grants[i];
                UIView *view = [self baseNote:title];
                view.top = top;
                view.left = baseLeft;
                [_grantScrollView addSubview:view];
                if (i == 0) {
                    view.layer.cornerRadius = 8;
                    view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
                }
                if (i != self.script.grants.count -1) {
                    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0, self.view.width - 24 - 23, 1)];
                    line.backgroundColor = FCStyle.fcSeparator;
                    line.top = top + 47;
                    line.left = baseLeft + 23;
                    [_grantScrollView addSubview:line];
                }else {
                    view.layer.cornerRadius = 8;
                    view.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMinXMaxYCorner;
                }
                
                if (self.script.grants.count == 1) {
                    view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMinXMaxYCorner;
                }

                top += 48;
            }
        }
        _grantScrollView.contentSize = CGSizeMake(self.view.width,top);

    }
    return _grantScrollView;
}

- (UIButton *)actBtn {
    if (_actBtn == nil) {
#ifdef Mac
        _actBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 50 + 20, 90, 30)];
#else
        _actBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 28 + 91, 90, 30)];
#endif
        
        _actBtn.font = FCStyle.subHeadlineBold;
        _actBtn.layer.cornerRadius = 15;
        _actBtn.right = self.view.width - 12;
        [self.view addSubview:_actBtn];
        
        [_actBtn addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _actBtn;
}

- (UIView *)baseNote:(NSString *)title{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width - 24, 48)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width  - 24 - 23, 18)];
    label.font = FCStyle.body;
    label.text = title;
    label.textColor = FCStyle.fcBlack;
    label.left = 23;
    label.centerY = 24;
    label.backgroundColor = [UIColor clearColor];
    [view addSubview:label];
    view.backgroundColor = FCStyle.secondaryPopup;
    return view;
}

- (UIView *)slideView {
    if (_slideView == nil) {
        CGFloat btnWidth =  (self.view.width - 10 - 42 ) / 4.0;
        _slideView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, btnWidth, 31)];
        _slideView.backgroundColor = RGBA(182, 32, 224, 0.11);
        _slideView.layer.cornerRadius = 8;
        _slideView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    }
    
    return _slideView;
}

- (UIView *)slideLineView {
    if (_slideLineView == nil) {
        CGFloat btnWidth =  (self.view.width - 10 - 42 ) / 4.0;
        _slideLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 32, btnWidth, 3)];
        _slideLineView.backgroundColor = FCStyle.accent;
    }
    
    return _slideLineView;
}

- (UIScrollView *)whiteTableView {
    if(_whiteTableView == nil) {
        _whiteTableView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.view.width * 2, 0, self.view.width, kScreenHeight)];
        
    }
    
    return _whiteTableView;
}

- (UIScrollView *)blackTableView {
    if(_blackTableView == nil) {
        _blackTableView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.view.width * 3, 0, self.view.width, kScreenHeight)];
    }
    
    return _blackTableView;
}

- (UIView *)creteSitesView:(NSString *)site type:(NSString *)type {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width - 23, 48)];
    view.backgroundColor = FCStyle.secondaryPopup;
    view.layer.cornerRadius = 8;
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 323, 19)];
    title.text = site;
    title.font = FCStyle.body;
    title.textColor = FCStyle.fcBlack;
    title.centerY = 24;
    title.left = 12;

    [view addSubview:title];
    
    UIImage *image =  [UIImage systemImageNamed:@"minus.circle"
                                 withConfiguration:[UIImageSymbolConfiguration configurationWithFont:[UIFont systemFontOfSize:23]]];
    image = [image imageWithTintColor:FCStyle.fcBlack renderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 23, 23);
    [btn setBackgroundImage:image forState:UIControlStateNormal];
    btn.centerY = 24;
    btn.right = self.view.width - 10 - 18;
    [btn addTarget:self action:@selector(updateSite:) forControlEvents:UIControlEventTouchUpInside];
    objc_setAssociatedObject (btn , @"site", site, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject (btn , @"type", type, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [view addSubview:btn];
    return view;
}

- (void)addBlackSite {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"add black site" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *conform = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *titleTextField = alert.textFields.firstObject;
        NSString *site = titleTextField.text;
        
        NSMutableArray *array =  [NSMutableArray arrayWithArray:self.script.blacklist];
        [array addObject:site];
        self.script.blacklist = array;
        [[DataManager shareManager] updateScriptConfigBlackList:[array componentsJoinedByString:@","] numberId:self.script.uuid];
        [self initScrpitContent];
        [self buildBlackView];
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
          textField.placeholder = @"add site";
      }];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];

    [alert addAction:cancle];
    [alert addAction:conform];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)updateSite:(UIButton *)btn {
    NSString *site = objc_getAssociatedObject(btn,@"site");
    NSString *type = objc_getAssociatedObject(btn,@"type");

    if([type isEqualToString:@"black"]) {
        NSMutableArray *array =  [NSMutableArray arrayWithArray:self.script.blacklist];
        [array removeObject:site];
        self.script.blacklist = array;
        [self buildBlackView];
    } else {
        NSMutableArray *array =  [NSMutableArray arrayWithArray:self.script.whitelist];
        [array removeObject:site];
        self.script.whitelist = array;
        [self buildWhiteView];
    }
    

}


- (void)addWhiteSite {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"add white site" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *conform = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *titleTextField = alert.textFields.firstObject;
        NSString *site = titleTextField.text;
        
        NSMutableArray *array =  [NSMutableArray arrayWithArray:self.script.whitelist];
        [array addObject:site];
        self.script.whitelist = array;
        
        [[DataManager shareManager] updateScriptConfigWhiteList:[array componentsJoinedByString:@","]  numberId:self.script.uuid];
        [self initScrpitContent];
        [self buildWhiteView];
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
          textField.placeholder = @"add site";
      }];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];

    [alert addAction:cancle];
    [alert addAction:conform];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
