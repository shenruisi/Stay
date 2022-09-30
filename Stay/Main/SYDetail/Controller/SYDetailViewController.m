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
#import "SYTextInputViewController.h"
#import "ScriptMananger.h"
#import "ScriptEntity.h"
#import "UIImageView+WebCache.h"
#import "ImageHelper.h"


#ifdef Mac
#import "QuickAccess.h"
#endif

@interface SYDetailViewController ()<UITextViewDelegate,UITableViewDelegate, UITableViewDataSource>

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
@property (nonatomic, strong) UIView *navigationBarCover;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) bool needExpand;

@property (nonatomic, strong) SYTextInputViewController *sYTextInputViewController;


@end

@implementation SYDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = FCStyle.popup;

    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
#ifndef Mac
//    [self createDetailView];
#endif
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(scriptSaveSuccess:) name:@"scriptSaveSuccess" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deleteScript:) name:@"deleteDetail" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(whiteSiteNotification:) name:@"whiteSiteNotification" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(blackSiteNotification:) name:@"blackSiteNotification" object:nil];

    self.navigationItem.rightBarButtonItem = [self rightIcon];
#ifdef Mac
    self.navigationController.navigationBarHidden = YES;
#endif
    // Do any additional setup after loading the view.
}

- (void)navigateViewDidLoad{
#ifdef Mac
    [super navigateViewDidLoad];
    [self navigationBarCover];
//    [self createDetailView];
   [self.tableView reloadData];

#endif
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self reload];
}

//- (void)navigateViewWillAppear:(BOOL)animated{
//    [self reload];
//}

- (void)reload{
    self.navigationBarCover = nil;
    self.actBtn = nil;
    self.matchScrollView = nil;
    self.grantScrollView = nil;
    self.whiteTableView = nil;
    self.blackTableView = nil;
    self.scrollView = nil;
    self.slideView = nil;
    self.slideLineView = nil;
//    for (UIView *subView in self.view.subviews) {
//        [subView removeFromSuperview];
//    }
//
   [self.tableView reloadData];
    [self navigationBarCover];
//    [self createDetailView];
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
     [self.tableView reloadData];
//    [self createDetailView];
}

- (void)buildBlackView {
    [self.blackTableView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGFloat left = 10;
    CGFloat top = 14;
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width - 20, 100)];
    title.numberOfLines = 0;
    title.font = FCStyle.subHeadline;
    title.textColor = FCStyle.fcPlaceHolder;
    title.text = [NSString stringWithFormat:NSLocalizedString(@"BlacklistExplain", @""),self.script.name];
    [title sizeToFit];
    [self.blackTableView addSubview:title];
    title.top = top;
    title.left = 10;
    top = title.bottom + 30;

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
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width - 20, 100)];
    title.numberOfLines = 0;
    title.font = FCStyle.subHeadline;
    title.textColor = FCStyle.fcPlaceHolder;
    title.text = [NSString stringWithFormat:NSLocalizedString(@"WhitelistExplain", @""),self.script.name];
    [title sizeToFit];
    [self.whiteTableView addSubview:title];
    title.top = top;
    title.left = 10;
    top = title.bottom + 30;

    
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




#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
     return self.view.height;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = [NSString stringWithFormat:@"settings.%ld.cell",indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
     
     for (UIView *subView in cell.contentView.subviews) {
         [subView removeFromSuperview];
     }

     CGFloat left = 15;
     CGFloat titleLabelLeftSize = 0;
     if(self.script.icon != NULL && self.script.icon.length > 0) {
          UIView *imageBox = [[UIView alloc] initWithFrame:CGRectMake(left, 15, 57, 57)];
          imageBox.layer.cornerRadius = 10;
          imageBox.layer.borderWidth = 1;
          imageBox.layer.borderColor = FCStyle.borderColor.CGColor;
          
          UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 23, 23)];
      //    [imageView sd_setImageWithURL:[NSURL URLWithString: dic[@"icon_url"]]];
          [imageView sd_setImageWithURL:[NSURL URLWithString:self.script.icon]];

          imageView.clipsToBounds = YES;
          imageView.centerX = 28.5;
          imageView.centerY = 28.5;
          [imageBox addSubview:imageView];
          [cell.contentView addSubview:imageBox];
         titleLabelLeftSize = 15 + 57;
     }
     
     UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(left + titleLabelLeftSize , 15, self.view.width - titleLabelLeftSize - left * 2, 21)];
     titleLabel.font = FCStyle.headlineBold;
     titleLabel.textColor = FCStyle.fcBlack;
     titleLabel.textAlignment = NSTextAlignmentLeft;
     titleLabel.lineBreakMode= NSLineBreakByTruncatingTail;
     titleLabel.numberOfLines = 2;
     titleLabel.text = self.script.name;
     [titleLabel sizeToFit];
     [cell.contentView addSubview:titleLabel];
     
     if(self.script.active) {
         [self.actBtn setTitle:NSLocalizedString(@"Activated", @"") forState:UIControlStateNormal];
         self.actBtn.backgroundColor = FCStyle.accent;
         [self.actBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
     } else {
         [self.actBtn setTitle:NSLocalizedString(@"Stopped", @"")  forState:UIControlStateNormal];
          self.actBtn.backgroundColor = FCStyle.background;
          [self.actBtn setTitleColor:FCStyle.fcBlack forState:UIControlStateNormal];
     }
     
     [cell.contentView addSubview:self.actBtn];
     self.actBtn.left = titleLabel.left;
     self.actBtn.top = titleLabel.bottom + 5;
     

     UIScrollView *scrollView =  [self createBaseInfoView];
     scrollView.left = left;
     scrollView.top = self.actBtn.bottom + 15;
     [cell.contentView addSubview:scrollView];
     
     
     UIView *topline = [[UIView alloc] initWithFrame:CGRectMake(15, 0, self.view.width - 15, 0.5)];
     topline.backgroundColor = FCStyle.fcSeparator;
     topline.top = scrollView.top -1;
     [cell.contentView addSubview:topline];

     UIView *bottomline = [[UIView alloc] initWithFrame:CGRectMake(15, 59, self.view.width - 15, 0.5)];
     bottomline.backgroundColor = FCStyle.fcSeparator;
     bottomline.bottom = scrollView.bottom + 1;
     [cell.contentView addSubview:bottomline];
     
     UILabel *descDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(left,bottomline.bottom + 13,self.view.width - left * 2 -25 ,200)];
     descDetailLabel.text = self.script.desc;
     descDetailLabel.textColor =  FCStyle.fcBlack;
     descDetailLabel.textAlignment = NSTextAlignmentLeft;
     descDetailLabel.lineBreakMode= NSLineBreakByTruncatingMiddle;
     descDetailLabel.font = FCStyle.footnote;
     descDetailLabel.numberOfLines = 0;
     [descDetailLabel sizeToFit];

     if(descDetailLabel.height > 70) {
          if (!_needExpand) {
      #ifdef Mac
              descDetailLabel.height = 70;
      #else
              descDetailLabel.height = 62;
      #endif
               UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 15)];
               [btn setTitle:NSLocalizedString(@"more", @"") forState:UIControlStateNormal];
               [btn setTitleColor:FCStyle.accent forState:UIControlStateNormal];
               btn.bottom = descDetailLabel.bottom - 8;
               btn.font = FCStyle.footnote;
               btn.right = self.view.width - 8;
               [btn addTarget:self action:@selector(expand) forControlEvents:UIControlEventTouchUpInside];
               [cell.contentView addSubview:btn];
          }
     }
     
     UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0,  self.view.width - 30, 0.5)];
     line.backgroundColor = FCStyle.fcSeparator;
     line.top =  descDetailLabel.bottom + 15;
     line.left = 15;
     [cell.contentView addSubview:line];
     
     [cell.contentView addSubview:descDetailLabel];
          
     CGFloat top = line.bottom + 10;
     if(self.script.plafroms != nil && self.script.plafroms.count > 0) {
          UIView *availableView =  [self createAvailableView];
          availableView.left = 15;
          availableView.top = top;
          [cell.contentView addSubview:availableView];
          
          UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0,  self.view.width - 30, 0.5)];
          line.backgroundColor = FCStyle.fcSeparator;
          line.top =  availableView.bottom + 20;
          line.left = 15;
          [cell.contentView addSubview:line];
          top = line.bottom + 10;
     }
        
     if(self.script.downloadUrl != nil && self.script.downloadUrl.length > 0){
           UILabel *autoUpdateLabel = [self createDefaultLabelWithText:NSLocalizedString(@"settings.autoUpdate","autoUpdate")];
           autoUpdateLabel.width = 200;
           autoUpdateLabel.top = top;
           autoUpdateLabel.left = left;
           autoUpdateLabel.font = FCStyle.bodyBold;
           [cell.contentView  addSubview:autoUpdateLabel];
         
           UISwitch *autoUpdateSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(10,99,42 ,31)];
           autoUpdateSwitch.top = top;
           autoUpdateSwitch.right = self.view.width - left;
           [autoUpdateSwitch setOnTintColor:FCStyle.accent];
           [autoUpdateSwitch setOn: self.script.updateSwitch];
           [cell.contentView addSubview:autoUpdateSwitch];
           [autoUpdateSwitch addTarget:self action:@selector(updateSwitchAction:) forControlEvents:UIControlEventValueChanged];
          autoUpdateLabel.centerY = autoUpdateSwitch.centerY;
          
          UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0,  self.view.width - 30, 0.5)];
          line.backgroundColor = FCStyle.fcSeparator;
          line.top =  autoUpdateLabel.bottom + 20;
          line.left = 15;
          [cell.contentView addSubview:line];
          top = line.bottom + 10;
     }
     
     
     UILabel *injectLabel = [self createDefaultLabelWithText:NSLocalizedString(@"settings.injectMode","Inject Mode")];
     injectLabel.font = FCStyle.bodyBold;
     injectLabel.width = 200;
     injectLabel.top = top;
     injectLabel.left = left;
     [cell.contentView addSubview:injectLabel];
     
     NSArray *segmentedArray = [[NSArray alloc]initWithObjects:@"Auto",@"Page",@"Content",nil];
     UISegmentedControl *segmentedControl = [[UISegmentedControl alloc]initWithItems:segmentedArray];
     segmentedControl.frame =  CGRectMake(0, top, 243.0, 31);
     
     [segmentedControl addTarget:self action:@selector(segmentControllerAction:) forControlEvents:UIControlEventValueChanged];
     if(self.script.injectInto.length > 0) {
         NSUInteger idx = [segmentedArray indexOfObject:self.script.injectInto];
         NSLog(@"selected idx %@ %ld",self.script.injectInto,idx);
         segmentedControl.selectedSegmentIndex = idx;
     } else {
         segmentedControl.selectedSegmentIndex = 0;
     }
     segmentedControl.right = self.view.width - 13;
     segmentedControl.top = top;
     [cell.contentView addSubview:segmentedControl];
     
     injectLabel.centerY = segmentedControl.centerY;
     
     UIView *injectLine = [[UIView alloc] initWithFrame:CGRectMake(0,  0,  self.view.width - 30, 0.5)];
     injectLine.backgroundColor = FCStyle.fcSeparator;
     injectLine.top =  segmentedControl.bottom + 20;
     injectLine.left = 15;
     [cell.contentView addSubview:injectLine];
     top = injectLine.bottom + 10;
     
//     top = injectLabel.bottom + 25;
     UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, top, self.view.width, 35)];
     [cell.contentView addSubview:buttonView];
     
     UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 34, self.view.width, 1)];
     lineView.backgroundColor = FCStyle.fcShadowLine;
     
     [buttonView addSubview:lineView];
     
     NSArray *selectedArray = @[@"Matches",@"Grants",NSLocalizedString(@"Whitelist", @""),NSLocalizedString(@"Blacklist", @"")];
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
     self.scrollView.height = self.view.height - top;
     [cell.contentView addSubview:self.scrollView];
     
     [self.scrollView addSubview:self.matchScrollView];
 //    self.matchScrollView.contentSize = CGSizeMake(self.view.width, self.matchScrollView.contentSize.height + top);
     self.matchScrollView.height = self.view.height- top;
     
     [self.scrollView addSubview:self.grantScrollView];
     self.grantScrollView.height = self.view.height - top;

     [self.scrollView addSubview:self.whiteTableView];
     self.whiteTableView.contentSize = CGSizeMake(self.view.width, self.whiteTableView.contentSize.height + top);
     
     [self.scrollView addSubview:self.blackTableView];
     self.blackTableView.contentSize = CGSizeMake(self.view.width, self.blackTableView.contentSize.height + top);
     [self buildWhiteView];
     [self buildBlackView];
    
    return cell;
}

- (void)deleteScript:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否删除脚本" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *conform = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.sYSelectTabViewController dismiss];
        [[DataManager shareManager] deleteScriptInUserScriptByNumberId: self.script.uuid];
        [self.navigationController popViewControllerAnimated:TRUE];
        NSNotification *notification = [NSNotification notificationWithName:@"app.stay.notification.userscriptDidDeleteNotification" object:nil userInfo:@{@"uuid":self.script.uuid}];
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
    self.script.injectInto = inject;
    [self initScrpitContent];
     NSNotification *notification = [NSNotification notificationWithName:@"app.stay.notification.userscriptDidUpdateNotification" object:nil userInfo:@{
          @"uuid":self.script.uuid
     }];
          [[NSNotificationCenter defaultCenter]postNotification:notification];
}

- (void) switchAction:(id)sender {
    self.script.active = !self.script.active;
    
    if(self.script.active) {
        [self.actBtn setTitle:NSLocalizedString(@"Activated", @"")  forState:UIControlStateNormal];
        self.actBtn.backgroundColor = FCStyle.accent;
        [self.actBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        [self.actBtn setTitle:NSLocalizedString(@"Stopped", @"") forState:UIControlStateNormal];
         self.actBtn.backgroundColor = FCStyle.background;
         [self.actBtn setTitleColor:FCStyle.fcBlack forState:UIControlStateNormal];
    }
    
    if (self.script.active) {
        [[DataManager shareManager] updateScrpitStatus:1 numberId:self.script.uuid];
    } else {
        [[DataManager shareManager] updateScrpitStatus:0 numberId:self.script.uuid];
    }
    
    NSNotification *notification = [NSNotification notificationWithName:@"app.stay.notification.userscriptDidUpdateNotification" object:nil userInfo:@{@"uuid":self.script.uuid}];
          [[NSNotificationCenter defaultCenter]postNotification:notification];
    [self initScrpitContent];
}

- (void) updateSwitchAction:(UISwitch *) scriptSwitch {
    if (scriptSwitch.on == YES) {
        [[DataManager shareManager] updateScriptConfigAutoupdate:1 numberId:self.script.uuid];
    } else {
        [[DataManager shareManager] updateScriptConfigAutoupdate:0 numberId:self.script.uuid];
    }
    NSNotification *notification = [NSNotification notificationWithName:@"app.stay.notification.userscriptDidUpdateNotification" object:nil userInfo:@{@"uuid":self.script.uuid}];
          [[NSNotificationCenter defaultCenter]postNotification:notification];
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



- (UIView *)createAvailableView {
     UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width - 30, 21)];
     UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 19)];
     label.text = @"Avaliable on";
     label.font = FCStyle.footnoteBold;
     label.textColor =  FCStyle.grayNoteColor;
     [view addSubview:label];
     [label sizeToFit];
     
     CGFloat imageLeft = label.right + 5;
     for(int i = 0; i < self.script.plafroms.count; i++) {
         NSString *name = self.script.plafroms[i];
         if ([name isEqualToString:@"mac"]) {
             name = @"laptopcomputer";
         }
         UIImageView *imageView = [[UIImageView alloc] initWithImage:[ImageHelper sfNamed:name font:FCStyle.body color:FCStyle.grayNoteColor]];
         imageView.size = imageView.image.size;
         imageView.bottom = label.bottom;
         imageView.left = imageLeft;
         imageLeft += 5 + imageView.width;
         [view addSubview:imageView];
     }
     
     bool stayOnly = self.script.stayOnly;
     if(stayOnly) {
         UIView *splitline = [[UIView alloc] initWithFrame:CGRectMake(0, 12, 1, 17)];
         splitline.backgroundColor = FCStyle.fcSeparator;
         splitline.bottom = label.bottom;
         [view addSubview:splitline];
         splitline.left = imageLeft + 10;
         UILabel *onlyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 19)];
         onlyLabel.text = @"Only on";
         onlyLabel.font = FCStyle.footnoteBold;
         onlyLabel.textColor =  FCStyle.grayNoteColor;
         onlyLabel.bottom = label.bottom;
         onlyLabel.left = splitline.right + 12;
         [view addSubview:onlyLabel];
         UIImageView *bzImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bz"]]; ;
          bzImageView.size = CGSizeMake(20, 20);
         bzImageView.bottom = label.bottom;
         bzImageView.left = onlyLabel.right + 2;
         [view addSubview:bzImageView];
     }
     
     
     return view;
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

- (void)expand {
     _needExpand = true;
     [self.tableView reloadData];
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

- (void)share{
    [self shareBtnClick];
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
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width * 4, self.view.height)];
    }
    return _scrollView;
}

- (UIScrollView *)matchScrollView {
    if(_matchScrollView == nil) {
        CGFloat baseLeft = 12;
        _matchScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
        CGFloat top = 13;
        if (self.script.matches.count > 0) {
            UILabel *matchLabel = [self createDefaultLabelWithText:@"MATCHES"];
            matchLabel.top = 13;
            matchLabel.left = baseLeft;
            matchLabel.textColor = FCStyle.fcSecondaryBlack;
            matchLabel.font = FCStyle.footnoteBold;
            top = matchLabel.bottom + 8;
            [_matchScrollView addSubview:matchLabel];
            for (int i = 0; i < self.script.matches.count; i++) {
                NSString *title  = self.script.matches[i];
                UIView *view = [self baseNote:title];
                if (i == 0) {
                    view.layer.cornerRadius = 8;
                    view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
                }
                view.top = top;
                view.left = baseLeft;
                [_matchScrollView addSubview:view];
                if (i != self.script.matches.count -1) {
                    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0, self.view.width - 24 - 23, 0.5)];
                    line.backgroundColor = FCStyle.fcSeparator;
                    line.top = top + 47.5;
                    line.left = baseLeft + 23;
                    [_matchScrollView addSubview:line];
                } else {
                    view.layer.cornerRadius = 8;
                    view.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMinXMaxYCorner;
                }
                if (self.script.matches.count == 1) {
                    view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMinXMaxYCorner;
                }
                
                top += 48;
            }
        }
        
        
        if (self.script.includes.count > 0) {
             if(top >13) {
               top += 35;
             }
            UILabel *includesLabel = [self createDefaultLabelWithText:@"INCLUDES"];
            includesLabel.top = top;
            includesLabel.left = baseLeft;
            includesLabel.textColor = FCStyle.fcSecondaryBlack;
             includesLabel.font = FCStyle.footnoteBold;
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
                    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0, self.view.width - 24 - 23, 0.5)];
                    line.backgroundColor = FCStyle.fcSeparator;
                    line.top = top + 47.5;
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
             if(top >13) {
               top += 35;
             }            UILabel *excludesLabel =  [self createDefaultLabelWithText:@"EXCLUDES"];
            excludesLabel.top = top;
            excludesLabel.left = baseLeft;
            excludesLabel.textColor = FCStyle.fcSecondaryBlack;
            excludesLabel.font =  FCStyle.footnoteBold;
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
                    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0, self.view.width - 24 - 23, 0.5)];
                    line.backgroundColor = FCStyle.fcSeparator;
                    line.top = top + 47.5;
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
        _grantScrollView =  [[UIScrollView alloc] initWithFrame:CGRectMake(self.view.width, 0, self.view.width, self.view.height)];
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
        _actBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 50 + 20, 90, 25)];
#else
        _actBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 28 + 91, 90, 25)];
#endif
        
        _actBtn.font = FCStyle.footnoteBold;
        _actBtn.layer.cornerRadius = 12.5;
        _actBtn.right = self.view.width - 12;
        [_actBtn addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _actBtn;
}

- (UIView *)baseNote:(NSString *)title{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width - 24, 48)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width  - 24 - 23, 18)];
    label.font = FCStyle.footnote;
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
        _slideView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, btnWidth, 34)];
        _slideView.backgroundColor = [FCStyle.accent colorWithAlphaComponent:0.1];
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

//基础信息view
- (UIScrollView *)createBaseInfoView {
     UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 60)];
     scrollView.showsVerticalScrollIndicator = false;
     scrollView.showsHorizontalScrollIndicator = false;
     NSString *used =[NSString stringWithFormat:@"%ld", self.script.usedTimes ];
     NSMutableArray *array = [NSMutableArray arrayWithArray:  @[
          @{
              @"name":@"RUNS",
              @"desc": used,
              @"color":FCStyle.grayNoteColor
          },
          @{
              @"name":@"SCRIPT",
              @"desc":@"edit",
              @"color":FCStyle.accent,
              @"type":@"edit"
          },
          @{
              @"name":@"AUTHOR",
              @"desc":self.script.author,
              @"color":FCStyle.grayNoteColor,
          },
          @{
              @"name":@"VERSION",
              @"desc":self.script.version,
              @"color":FCStyle.grayNoteColor,
          },
          @{
               @"name":@"RUN AT",
               @"desc":self.script.runAt,
               @"color":FCStyle.grayNoteColor,
          }
         
          
      ]];
     
     if(self.script.license != NULL && self.script.license.length > 0) {
          [array addObject:@{
               @"name":@"LICENSE",
               @"desc":self.script.license,
               @"color":FCStyle.grayNoteColor,
          }];
     }
     
     if(self.script.homepage != NULL && self.script.homepage.length > 0) {
          [array addObject:@{
               @"name":@"HOMEPAGE",
               @"desc":self.script.homepage,
               @"color":FCStyle.grayNoteColor,
          }];
     }
     
     
     
     for(int i = 0; i < array.count; i++) {
          CGFloat left =  i * 90;
          UIView *view = [self createBaseSiteView:array[i]];
          view.left = left;
          view.top = 1;
          [scrollView addSubview:view];
          
          scrollView.contentSize = CGSizeMake(view.right + 15, 60);
          if(i != 0) {
            UIView *splitline = [[UIView alloc] initWithFrame:CGRectMake(left, 12, 0.5, 37)];
            splitline.backgroundColor = FCStyle.fcSeparator;
            [scrollView addSubview:splitline];
          }
          
     }
     
     return scrollView;
}


- (UIView *)createBaseSiteView:(NSDictionary *)dic {
     
     
     NSString *name = dic[@"name"];
     NSString *desc = dic[@"desc"];
     UIColor *descColor = dic[@"color"];
     NSString *type = dic[@"type"];

     
     UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 90, 58)];
     UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 90, 15)];
     title.text = name;
     title.font = FCStyle.footnote;
     title.textColor = FCStyle.fcSecondaryBlack;
     title.top = 12;
     title.centerX = 45;
     title.textAlignment = NSTextAlignmentCenter;
     [view addSubview:title];
     
     if([@"edit" isEqualToString:type]) {
          UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showScript:)];
          [view addGestureRecognizer:tapGesture];
          UIImage *image = [ImageHelper sfNamed:@"pencil"font: FCStyle.subHeadline color:descColor];
          UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
          imageView.frame = CGRectMake(0, 0, 18, 18);
          imageView.centerX = title.centerX;
          imageView.top = title.bottom + 6;
          [view addSubview:imageView];
     } else {
          UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 80, 15)];
          descLabel.font = FCStyle.subHeadlineBold;
          descLabel.textColor = descColor;
          descLabel.text = desc;
          descLabel.centerX = 45;
          descLabel.top = title.bottom + 6;
          descLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
          descLabel.textAlignment = NSTextAlignmentCenter;
          [view addSubview:descLabel];
     }
     return view;
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
    btn.right = self.view.width - 15 - 18;
    [btn addTarget:self action:@selector(updateSite:) forControlEvents:UIControlEventTouchUpInside];
    objc_setAssociatedObject (btn , @"site", site, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject (btn , @"type", type, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [view addSubview:btn];
    return view;
}

- (void)addBlackSite {
    [self.sYTextInputViewController updateNotificationName:@"blackSiteNotification"];
    [self.sYTextInputViewController show];
}

- (void)updateSite:(UIButton *)btn {
    NSString *site = objc_getAssociatedObject(btn,@"site");
    NSString *type = objc_getAssociatedObject(btn,@"type");
    
    

    if([type isEqualToString:@"black"]) {
        NSMutableArray *array =  [NSMutableArray arrayWithArray:self.script.blacklist];
        [array removeObject:site];
        self.script.blacklist = array;
        [[DataManager shareManager] updateScriptConfigBlackList:[array componentsJoinedByString:@","] numberId:self.script.uuid];
        [self initScrpitContent];
        [self buildBlackView];
    } else {
        NSMutableArray *array =  [NSMutableArray arrayWithArray:self.script.whitelist];
        [array removeObject:site];
        self.script.whitelist = array;
        [[DataManager shareManager] updateScriptConfigWhiteList:[array componentsJoinedByString:@","] numberId:self.script.uuid];
        [self initScrpitContent];
        [self buildWhiteView];
    }
    
    
    
}


- (void)blackSiteNotification:(NSNotification *)notification {
    if (![notification.userInfo[@"uuid"] isEqualToString:self.script.uuid]){
        return;
    }
    
    [self.sYTextInputViewController dismiss];
    self.sYTextInputViewController = nil;

    NSString *site = notification.object;
    NSMutableArray *array =  [NSMutableArray arrayWithArray:self.script.blacklist];
    [array addObject:site];
    self.script.blacklist = array;
    [[DataManager shareManager] updateScriptConfigBlackList:[array componentsJoinedByString:@","] numberId:self.script.uuid];
    [self initScrpitContent];
    [self buildBlackView];
}

- (void)whiteSiteNotification:(NSNotification *)notification {
    if (![notification.userInfo[@"uuid"] isEqualToString:self.script.uuid]){
        return;
    }
    
    [self.sYTextInputViewController dismiss];
    self.sYTextInputViewController = nil;

    NSString *site = notification.object;
    NSMutableArray *array =  [NSMutableArray arrayWithArray:self.script.whitelist];
    [array addObject:site];
    self.script.whitelist = array;
    [[DataManager shareManager] updateScriptConfigWhiteList:[array componentsJoinedByString:@","] numberId:self.script.uuid];
    [self initScrpitContent];
    [self buildWhiteView];
}

- (void)addWhiteSite {
    [self.sYTextInputViewController updateNotificationName:@"whiteSiteNotification"];
    [self.sYTextInputViewController show];
}


- (SYTextInputViewController *)sYTextInputViewController {
    if(nil == _sYTextInputViewController) {
        _sYTextInputViewController = [[SYTextInputViewController alloc] init];
        _sYTextInputViewController.uuid = self.script.uuid;
    }
    return _sYTextInputViewController;
}

- (UIView *)navigationBarCover{
    if (nil == _navigationBarCover){
        _navigationBarCover = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 50)];
        _navigationBarCover.backgroundColor = FCStyle.background;
        [self.view addSubview:_navigationBarCover];
    }
    
    return _navigationBarCover;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = DynamicColor(RGB(28, 28, 28),[UIColor whiteColor]);
        [self.view addSubview:_tableView];
    }
    
    return _tableView;
}



@end
