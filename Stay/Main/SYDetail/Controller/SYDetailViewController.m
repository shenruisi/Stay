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

@interface SYDetailViewController ()
@property (nonatomic, strong) UIBarButtonItem *rightIcon;
@property (nonatomic, strong) SYSelectTabViewController *sYSelectTabViewController;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIScrollView *matchScrollView;
@property (nonatomic, strong) UIScrollView *grantScrollView;

@end

@implementation SYDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = FCStyle.popup;

    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    [self createDetailView];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(scriptSaveSuccess:) name:@"scriptSaveSuccess" object:nil];
    self.navigationItem.rightBarButtonItem = [self rightIcon];

    // Do any additional setup after loading the view.
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

- (void)createDetailView{
    CGFloat left = 15;
    CGFloat maxWidthRate = 0.7;
    CGFloat top = 0;
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(left, 17 + 91, kScreenWidth * maxWidthRate, 21)];
    title.text = self.script.name;
    title.textColor = FCStyle.fcBlack;
    title.font = FCStyle.headlineBold;
    [self.view addSubview:title];
    top = title.bottom + 5;
    UILabel *runAt = [[UILabel alloc] initWithFrame:CGRectMake(left, top, kScreenWidth * maxWidthRate, 16)];
    runAt.font = FCStyle.subHeadline;
    runAt.text = [NSString stringWithFormat:@"Run at %@",self.script.runAt];
    runAt.textColor = FCStyle.fcBlack;
    [self.view addSubview:runAt];
    top = runAt.bottom + 5;
    UILabel *authour = [[UILabel alloc] initWithFrame:CGRectMake(left, top, kScreenWidth * maxWidthRate, 16)];
    authour.font = FCStyle.subHeadline;
    authour.text = [NSString stringWithFormat:@"Created by %@",self.script.author];
    authour.textColor = FCStyle.fcSecondaryBlack;
    [self.view addSubview:authour];
    
    UIButton *actBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 28 + 91, 90, 30)];
    if(self.script.active) {
        [actBtn setTitle:@"Activated" forState:UIControlStateNormal];
        actBtn.backgroundColor = FCStyle.accent;
        [actBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        [actBtn setTitle:@"Stopped" forState:UIControlStateNormal];
        actBtn.backgroundColor = [UIColor whiteColor];
        [actBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        actBtn.layer.borderWidth = 1;
        actBtn.layer.borderColor = [UIColor blackColor].CGColor;
    }
    actBtn.font = FCStyle.subHeadlineBold;
    actBtn.layer.cornerRadius = 15;
    actBtn.right = kScreenWidth - 12;
    [self.view addSubview:actBtn];
    
    top = authour.bottom + 10;
    UILabel *descDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(left,top,kScreenWidth - left * 2 ,50)];
    descDetailLabel.font = FCStyle.headline;
    descDetailLabel.text = self.script.desc;
    descDetailLabel.lineBreakMode= NSLineBreakByTruncatingTail;
    descDetailLabel.textColor =  FCStyle.fcBlack;
    descDetailLabel.textAlignment = NSTextAlignmentLeft;
    descDetailLabel.numberOfLines = 0;
    [descDetailLabel sizeToFit];
    [self.view addSubview:descDetailLabel];
    
    top = descDetailLabel.bottom + 10;
    UIImage *image =  [UIImage systemImageNamed:@"v.circle.fill"
                                 withConfiguration:[UIImageSymbolConfiguration configurationWithFont:[UIFont systemFontOfSize:15]]];
    image = [image imageWithTintColor:FCStyle.fcBlack renderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(left, top, 19, 19);
    [self.view addSubview:imageView];
    
    UILabel *version = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 15)];
    version.font = FCStyle.footnote;
    version.text = self.script.version;
    version.textColor = FCStyle.fcBlack;
    version.left = imageView.right + 5;
    version.centerY = imageView.centerY;
    [self.view addSubview:version];

    top = version.bottom + 10;
    if(self.script.downloadUrl != nil && self.script.downloadUrl.length > 0){
       UILabel *autoUpdateLabel = [self createDefaultLabelWithText:NSLocalizedString(@"settings.autoUpdate","autoUpdate")];
       autoUpdateLabel.top = top;
       autoUpdateLabel.left = left;
       autoUpdateLabel.font = FCStyle.headlineBold;
       [self.view  addSubview:autoUpdateLabel];
      
       UISwitch *autoUpdateSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(10,99,42 ,27)];
       autoUpdateSwitch.centerY = autoUpdateLabel.centerY;
       autoUpdateSwitch.right = kScreenWidth - left;
       [autoUpdateSwitch setOnTintColor:FCStyle.accent];
       [autoUpdateSwitch setOn: self.script.updateSwitch];
       [self.view addSubview:autoUpdateSwitch];
       [autoUpdateSwitch addTarget:self action:@selector(updateSwitchAction:) forControlEvents:UIControlEventValueChanged];
        top = autoUpdateLabel.bottom + 20;
   }
    
    UILabel *scriptLabel = [self createDefaultLabelWithText:NSLocalizedString(@"settings.scriptContent","Script Content")];
    scriptLabel.font = FCStyle.headlineBold;
    scriptLabel.top = top;
    scriptLabel.left = left;
    [self.view addSubview:scriptLabel];
    
    NSString *imageName = CGColorEqualToColor([[self createBgColor] CGColor],[RGB(20, 20, 20) CGColor])?@"arrow-dark":@"arrow";
    UIImageView *scriptIconLabel = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    scriptIconLabel.right = kScreenWidth - 19;
    scriptIconLabel.centerY = scriptLabel.centerY;
    [self.view  addSubview:scriptIconLabel];
    
    UIButton *scriptBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    scriptBtn.frame = CGRectMake(0, 0, kScreenWidth, 40);
    scriptBtn.centerY = scriptLabel.centerY;
    scriptBtn.right = kScreenWidth - left;

    [scriptBtn addTarget:self action:@selector(showScript:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scriptBtn];

    
    top = scriptLabel.bottom + 10;
    
    UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, top, kScreenWidth, 35)];
    
    [self.view addSubview:buttonView];
    
    NSArray *selectedArray = @[@"Matches",@"Grants",@"Download URL",@"Exclude sites"];
    
    NSArray *widthArray =@[@"0.18", @"0.134",@"0.28", @"0.256"];
    
    CGFloat btnLeft = 5;
    
    for(int i = 0; i < 4; i++) {
        NSString *rate = widthArray[i];
        CGFloat btnWidth =  rate.floatValue * kScreenWidth;
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(btnLeft, 0, btnWidth, 31)];
        [btn setTitle:selectedArray[i] forState:UIControlStateNormal];
        [btn setTitleColor:FCStyle.fcBlack forState:UIControlStateNormal];
        btn.font = FCStyle.headlineBold;
        btn.tag = 100 + i;
        btnLeft += btnWidth + 14;
        [buttonView addSubview:btn];
    }
    
    top = buttonView.bottom;
    
    self.scrollView.top = top;
    self.scrollView.height = kScreenHeight - top;
    [self.view addSubview:self.scrollView];
    
    [self.scrollView addSubview:self.matchScrollView];
    self.matchScrollView.contentSize = CGSizeMake(kScreenWidth, self.matchScrollView.contentSize.height + top);
    
    
    [self.scrollView addSubview:self.grantScrollView];
    self.grantScrollView.contentSize = CGSizeMake(kScreenWidth, self.grantScrollView.contentSize.height + top);

    
}

- (void)deleteScript:(id)sender {
    [[DataManager shareManager] deleteScriptInUserScriptByNumberId: self.script.uuid];
    [self.navigationController popViewControllerAnimated:TRUE];
}

- (void)showScript:(id)sender {
    SYEditViewController *cer = [[SYEditViewController alloc] init];
    cer.content = self.script.content;
    cer.uuid = self.script.uuid;
    cer.userScript = self.script;
    cer.isEdit = true;
    cer.isSearch = self.isSearch;
    [self.navigationController pushViewController:cer animated:true];
}

- (void)showNotes:(id)sender {
    SYNotesViewController *cer = [[SYNotesViewController alloc] init];
    cer.notes = self.script.notes;
    [self.navigationController pushViewController:cer animated:true];
}

- (void) switchAction:(UISwitch *) scriptSwitch {
    if (scriptSwitch.on == YES) {
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
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15,99,kScreenWidth - 57 ,1)];
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

- (void)shareBtnClick {
    self.sYSelectTabViewController.url = self.script.downloadUrl;
    self.sYSelectTabViewController.content = self.script.content;
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
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth * 4, kScreenHeight)];
    }
    return _scrollView;
}

- (UIScrollView *)matchScrollView {
    if(_matchScrollView == nil) {
        CGFloat baseLeft = 12;
        _matchScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        UILabel *matchLabel = [self createDefaultLabelWithText:@"Matches"];
        matchLabel.top = 13;
        matchLabel.left = baseLeft;
        matchLabel.textColor = FCStyle.fcPlaceHolder;
        [_matchScrollView addSubview:matchLabel];
        CGFloat top = matchLabel.bottom + 8;
        if (self.script.matches.count > 0) {
            for (NSString *title in self.script.matches) {
                UIView *view = [self baseNote:title];
                view.top = top;
                view.left = baseLeft;
                [_matchScrollView addSubview:view];
                top += 48;
            }
        } else {
            
        }
        
        top += 35;
        UILabel *includesLabel = [self createDefaultLabelWithText:@"includes"];
        includesLabel.top = top;
        includesLabel.left = baseLeft;
        includesLabel.textColor = FCStyle.fcPlaceHolder;
        [_matchScrollView addSubview:includesLabel];
        
        top = includesLabel.bottom + 8;

        
        if (self.script.includes.count > 0) {
            for (NSString *title in self.script.includes) {
                UIView *view = [self baseNote:title];
                view.top = top;
                view.left = baseLeft;
                [_matchScrollView addSubview:view];
                top += 48;
            }
        } else {
            
        }
        
        top += 35;

        UILabel *excludesLabel =  [self createDefaultLabelWithText:@"excludes"];
        excludesLabel.top = top;
        excludesLabel.left = baseLeft;
        excludesLabel.textColor = FCStyle.fcPlaceHolder;
        [_matchScrollView addSubview:excludesLabel];
        
        top = excludesLabel.bottom + 8;
        
        if (self.script.excludes.count > 0) {
            for (NSString *title in self.script.excludes) {
                UIView *view = [self baseNote:title];
                view.top = top;
                view.left = baseLeft;
                [_matchScrollView addSubview:view];
                top += 48;
            }
        } else {
            
        }
        
        _matchScrollView.contentSize = CGSizeMake(kScreenWidth,top);
        
        
    }
    return _matchScrollView;
}

- (UIScrollView *)grantScrollView {
    if(_grantScrollView == nil) {
        _grantScrollView =  [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        CGFloat baseLeft = 12;
        CGFloat top = 22;
        if (self.script.grants.count > 0) {
            for (NSString *title in self.script.grants) {
                UIView *view = [self baseNote:title];
                view.top = top;
                view.left = baseLeft;
                [_grantScrollView addSubview:view];
                top += 48;
            }
        } else {
            
        }
    }
    return _grantScrollView;
}


- (UIView *)baseNote:(NSString *)title{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 24, 48)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 24 - 23, 18)];
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

@end
