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
#import "DeviceHelper.h"
#import "SYWebsiteViewController.h"
#import "SYSubmitScriptSlideController.h"
#import "SYReportSlideController.h"
#import "DefaultIcon.h"

#import "QuickAccess.h"

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
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) bool needExpand;

@property (nonatomic, strong) SYTextInputViewController *sYTextInputViewController;
@property (nonatomic, strong) SYSubmitScriptSlideController *sYSubmitScriptSlideController;
@property (nonatomic, strong) SYReportSlideController *sYReportSlideController;

@end

@implementation SYDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = FCStyle.popup;

     self.hidesBottomBarWhenPushed = YES;
     
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(scriptSaveSuccess:) name:@"scriptSaveSuccess" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deleteScript:) name:@"deleteDetail" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(whiteSiteNotification:) name:@"whiteSiteNotification" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(blackSiteNotification:) name:@"blackSiteNotification" object:nil];
     if (FCDeviceTypeIPad == DeviceHelper.type || FCDeviceTypeMac == DeviceHelper.type){
//          self.rightBarButtonItems = @[[self rightIcon]];
     }
     else{
          self.navigationItem.rightBarButtonItem = [self rightIcon];
     }
     
   

     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeThemeColor:) name:@"changeThemeColor" object:nil];
}

- (void)changeThemeColor:(NSNotification *)note{
     [self reload];
}

- (void)viewWillLayoutSubviews{
     [super viewWillLayoutSubviews];
     self.tableView.frame = self.view.bounds;
     [self reload];
}

- (void)reload{
    self.actBtn = nil;
    self.matchScrollView = nil;
    self.grantScrollView = nil;
    self.whiteTableView = nil;
    self.blackTableView = nil;
    self.scrollView = nil;
    self.slideView = nil;
    self.slideLineView = nil;
     [self.tableView reloadData];
     
   
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
     dispatch_async(dispatch_get_main_queue(), ^{
          [self.tableView reloadData];
     });
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
     
     cell.contentView.backgroundColor = [UIColor clearColor];
     cell.backgroundColor = [UIColor clearColor];
     CGFloat left = 15;
     CGFloat titleLabelLeftSize = 0;
     UIView *imageBox = [[UIView alloc] initWithFrame:CGRectMake(left, 15, 118, 118)];
     imageBox.layer.cornerRadius = 30;
     imageBox.layer.borderWidth = 1;
     imageBox.layer.borderColor = FCStyle.borderColor.CGColor;
     imageBox.backgroundColor = FCStyle.fcWhite;
     UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 78, 78)];
 //    [imageView sd_setImageWithURL:[NSURL URLWithString: dic[@"icon_url"]]];

     imageView.clipsToBounds = YES;
     imageView.centerX = 59;
     imageView.centerY = 59;
     imageView.contentMode = UIViewContentModeScaleAspectFit;
     [imageBox addSubview:imageView];
     [cell.contentView addSubview:imageBox];
    titleLabelLeftSize = 15 + 118;

     
     if( self.script.icon.length <= 0) {
         [imageView setImage:[DefaultIcon iconWithTitle: self.script.name size:CGSizeMake(78, 78)]];
     } else {
          [imageView sd_setImageWithURL:[NSURL URLWithString:self.script.icon]];
     }
     
     UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(left + titleLabelLeftSize , 15, self.view.width - titleLabelLeftSize - left * 2, 21)];
     titleLabel.font = FCStyle.title3Bold;
     titleLabel.textColor = FCStyle.fcBlack;
     titleLabel.textAlignment = NSTextAlignmentLeft;
     titleLabel.lineBreakMode= NSLineBreakByTruncatingTail;
     titleLabel.numberOfLines = 2;
     titleLabel.text = self.script.name;
     [titleLabel sizeToFit];
     [cell.contentView addSubview:titleLabel];
     
     
     UILabel *authourLabel = [[UILabel alloc]initWithFrame:CGRectMake(left + titleLabelLeftSize , titleLabel.bottom , self.view.width - titleLabelLeftSize - left * 2 , 19)];
     authourLabel.font = FCStyle.subHeadline;
     authourLabel.textColor = FCStyle.grayNoteColor;
     authourLabel.textAlignment = NSTextAlignmentLeft;
     authourLabel.lineBreakMode= NSLineBreakByTruncatingTail;
     authourLabel.text = self.script.author;
     [cell.contentView addSubview:authourLabel];
     
     if(self.script.active) {
         [self.actBtn setTitle:NSLocalizedString(@"Activated", @"") forState:UIControlStateNormal];
          self.actBtn.layer.borderWidth = 1;
          self.actBtn.layer.borderColor = FCStyle.accent.CGColor;
         [self.actBtn setTitleColor:FCStyle.accent forState:UIControlStateNormal];
     } else {
         [self.actBtn setTitle:NSLocalizedString(@"Stopped", @"")  forState:UIControlStateNormal];
          self.actBtn.layer.borderWidth = 1;
          self.actBtn.layer.borderColor = FCStyle.fcBlack.CGColor;
          [self.actBtn setTitleColor:FCStyle.fcBlack forState:UIControlStateNormal];
     }
     
     [cell.contentView addSubview:self.actBtn];
     self.actBtn.left = titleLabel.left;
     self.actBtn.bottom = 131;

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
      #ifdef FC_MAC
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
     
     UILabel *informationLabel = [[UILabel alloc]initWithFrame:CGRectMake(left , top, 250 , 21)];
     informationLabel.font = FCStyle.title3Bold;
     informationLabel.textColor = FCStyle.fcBlack;
     informationLabel.textAlignment = NSTextAlignmentLeft;
     informationLabel.lineBreakMode= NSLineBreakByTruncatingTail;
     informationLabel.text =NSLocalizedString(@"Information", @"");
     [cell.contentView addSubview:informationLabel];

     top = informationLabel.bottom + 13;
     
     
     NSArray *matches = self.script.matches;
     if (matches.count > 0) {
         
         UILabel *matchesLabel = [[UILabel alloc]initWithFrame:CGRectMake(left , top, 250 , 21)];
         matchesLabel.font = FCStyle.footnote;
         matchesLabel.textColor = FCStyle.fcSecondaryBlack;
         matchesLabel.textAlignment = NSTextAlignmentLeft;
         matchesLabel.lineBreakMode= NSLineBreakByTruncatingTail;
         matchesLabel.text =NSLocalizedString(@"Matches", @"");
         matchesLabel.top = top;
         [cell.contentView addSubview:matchesLabel];
         
         UILabel *countLabel = [[UILabel alloc]initWithFrame:CGRectMake(left , top, 25 , 15)];
         countLabel.font = FCStyle.footnote;
         countLabel.textColor = FCStyle.fcBlack;
         countLabel.textAlignment = NSTextAlignmentLeft;
         countLabel.text = [NSString stringWithFormat:@"%ld",matches.count];
          [countLabel sizeToFit];

         countLabel.right =  self.view.width - 42;
         countLabel.centerY = matchesLabel.centerY;
         [cell.contentView addSubview:countLabel];

         UIImageView *accessory = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 13)];
         UIImage *image = [UIImage systemImageNamed:@"chevron.right"
                                  withConfiguration:[UIImageSymbolConfiguration configurationWithFont:[UIFont systemFontOfSize:13]]];
         image = [image imageWithTintColor:FCStyle.fcSecondaryBlack renderingMode:UIImageRenderingModeAlwaysOriginal];
         accessory.right = self.view.width - 26;
         accessory.centerY = matchesLabel.centerY;
         [accessory setImage:image];
         accessory.userInteractionEnabled = true;
         UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMatches)];
         [cell.contentView addSubview:accessory];
         
         UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0,  0,  self.view.width - 30, 0.5)];
         line1.backgroundColor = FCStyle.fcSeparator;
         line1.top =  matchesLabel.bottom + 8;
         line1.left = 15;
         [cell.contentView addSubview:line1];
         
         UIView *matchesListView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 21)];
         matchesListView.left = left;
         matchesListView.centerY = matchesLabel.centerY;
         matchesListView.userInteractionEnabled = true;
         [cell.contentView  addSubview:matchesListView];
         
         [matchesListView addGestureRecognizer:tapGesture];

          top = line1.bottom + 13;
     }

     

     NSArray *grants = self.script.grants;
     if (grants.count > 0) {
         
         UILabel *grantsLabel = [[UILabel alloc]initWithFrame:CGRectMake(left , top, 250 , 21)];
         grantsLabel.font = FCStyle.footnote;
         grantsLabel.textColor = FCStyle.fcSecondaryBlack;
         grantsLabel.textAlignment = NSTextAlignmentLeft;
         grantsLabel.lineBreakMode= NSLineBreakByTruncatingTail;
         grantsLabel.text =NSLocalizedString(@"Grants", @"");
         grantsLabel.top = top;
         [cell.contentView addSubview:grantsLabel];
         
         UILabel *countLabel = [[UILabel alloc]initWithFrame:CGRectMake(left , top, 25 , 15)];
         countLabel.font = FCStyle.footnote;
         countLabel.textColor = FCStyle.fcBlack;
         countLabel.textAlignment = NSTextAlignmentLeft;
         countLabel.text = [NSString stringWithFormat:@"%ld",grants.count];
          
          [countLabel sizeToFit];
         countLabel.centerY = grantsLabel.centerY;
         countLabel.right =  self.view.width - 42;
         [cell.contentView addSubview:countLabel];
         
         UIImageView *accessory = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 13)];
         UIImage *image = [UIImage systemImageNamed:@"chevron.right"
                                  withConfiguration:[UIImageSymbolConfiguration configurationWithFont:[UIFont systemFontOfSize:13]]];
         image = [image imageWithTintColor:FCStyle.fcSecondaryBlack renderingMode:UIImageRenderingModeAlwaysOriginal];
         accessory.right = self.view.width - 26;
         accessory.centerY = grantsLabel.centerY;
         [accessory setImage:image];
         accessory.userInteractionEnabled = true;
         UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showGrants)];
         [cell.contentView addSubview:accessory];
         
         UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0,  0,  self.view.width - 30, 0.5)];
         line2.backgroundColor = FCStyle.fcSeparator;
         line2.top =  grantsLabel.bottom + 8;
         line2.left = 15;
         [cell.contentView addSubview:line2];
         
         UIView *grantsListView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 21)];
         grantsListView.left = left;
         grantsListView.centerY = grantsLabel.centerY;
         grantsListView.userInteractionEnabled = true;
         [cell.contentView  addSubview:grantsListView];
         
         [grantsListView addGestureRecognizer:tapGesture];
          top = line2.bottom + 13;
     }
     
     NSArray *disabledWebsites = self.script.disabledWebsites;
     if (disabledWebsites.count > 0) {
         UILabel *grantsLabel = [[UILabel alloc]initWithFrame:CGRectMake(left , top, 250 , 21)];
         grantsLabel.font = FCStyle.footnote;
         grantsLabel.textColor = FCStyle.fcSecondaryBlack;
         grantsLabel.textAlignment = NSTextAlignmentLeft;
         grantsLabel.lineBreakMode= NSLineBreakByTruncatingTail;
         grantsLabel.text =NSLocalizedString(@"DisabledWebsites", @"");
         grantsLabel.top = top;
         [cell.contentView addSubview:grantsLabel];
         
         UILabel *countLabel = [[UILabel alloc]initWithFrame:CGRectMake(left , top, 25 , 15)];
         countLabel.font = FCStyle.footnote;
         countLabel.textColor = FCStyle.fcBlack;
         countLabel.textAlignment = NSTextAlignmentLeft;
         countLabel.text = [NSString stringWithFormat:@"%ld",disabledWebsites.count];
          [countLabel sizeToFit];

         countLabel.centerY = grantsLabel.centerY;
         countLabel.right =  self.view.width - 42;
         [cell.contentView addSubview:countLabel];
         
         UIImageView *accessory = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 13)];
         UIImage *image = [UIImage systemImageNamed:@"chevron.right"
                                  withConfiguration:[UIImageSymbolConfiguration configurationWithFont:[UIFont systemFontOfSize:13]]];
         image = [image imageWithTintColor:FCStyle.fcSecondaryBlack renderingMode:UIImageRenderingModeAlwaysOriginal];
         accessory.right = self.view.width - 26;
         accessory.centerY = grantsLabel.centerY;
         [accessory setImage:image];
         accessory.userInteractionEnabled = true;
         UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDisabledWebsites)];
         [cell.contentView addSubview:accessory];
         
         UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0,  0,  self.view.width - 30, 0.5)];
         line2.backgroundColor = FCStyle.fcSeparator;
         line2.top =  grantsLabel.bottom + 8;
         line2.left = 15;
         [cell.contentView addSubview:line2];
         
         UIView *grantsListView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 21)];
         grantsListView.left = left;
         grantsListView.centerY = grantsLabel.centerY;
         grantsListView.userInteractionEnabled = true;
         [cell.contentView  addSubview:grantsListView];
         
         [grantsListView addGestureRecognizer:tapGesture];
          top = line2.bottom + 13;
     
     }

     
     UILabel *interactionLabel = [[UILabel alloc]initWithFrame:CGRectMake(left , top, 250 , 21)];
     interactionLabel.font = FCStyle.title3Bold;
     interactionLabel.textColor = FCStyle.fcBlack;
     interactionLabel.textAlignment = NSTextAlignmentLeft;
     interactionLabel.lineBreakMode= NSLineBreakByTruncatingTail;
     interactionLabel.text =NSLocalizedString(@"InteractionDetail", @"");
     [cell.contentView addSubview:interactionLabel];

     top = interactionLabel.bottom + 13;

    
     if(self.script.downloadUrl != NULL && self.script.downloadUrl.length > 0) {
          NSMutableCharacterSet *set  = [[NSCharacterSet URLFragmentAllowedCharacterSet] mutableCopy];
           [set addCharactersInString:@"#"];
          NSURL *url = [NSURL URLWithString:[self.script.downloadUrl stringByAddingPercentEncodingWithAllowedCharacters:set]];
          if(![url.host containsString:@"stayfork.app"]) {
               UILabel *grantsLabel = [[UILabel alloc]initWithFrame:CGRectMake(left , top, 250 , 21)];
               grantsLabel.font = FCStyle.body;
               grantsLabel.textColor = FCStyle.accent;
               grantsLabel.textAlignment = NSTextAlignmentLeft;
               grantsLabel.lineBreakMode= NSLineBreakByTruncatingTail;
               grantsLabel.text =NSLocalizedString(@"SubmittoStayFork", @"");
               grantsLabel.top = top;
               [cell.contentView addSubview:grantsLabel];
               
               
               UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0,  0,  self.view.width - 30, 0.5)];
               line2.backgroundColor = FCStyle.fcSeparator;
               line2.top =  grantsLabel.bottom + 8;
               line2.left = 15;
               [cell.contentView addSubview:line2];
               top = line2.bottom + 13;
               UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showSubmitView)];
               UIView *grantsListView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 21)];
               grantsListView.left = left;
               grantsListView.centerY = grantsLabel.centerY;
               grantsListView.userInteractionEnabled = true;
               [grantsListView addGestureRecognizer:tapGesture];
               [cell.contentView  addSubview:grantsListView];
               
               UIImageView *upImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 19)];
               UIImage *image = [UIImage systemImageNamed:@"arrow.up"
                                        withConfiguration:[UIImageSymbolConfiguration configurationWithFont:[UIFont systemFontOfSize:13]]];
               image = [image imageWithTintColor:FCStyle.accent renderingMode:UIImageRenderingModeAlwaysOriginal];
               upImageView.right = self.view.width - 26;
               upImageView.centerY = grantsLabel.centerY;
               [upImageView setImage:image];
               [cell.contentView addSubview:upImageView];
               
          }
          
     }
     
     UILabel *reportLabel = [[UILabel alloc]initWithFrame:CGRectMake(left , top, 250 , 21)];
     reportLabel.font = FCStyle.body;
     reportLabel.textColor = FCStyle.accent;
     reportLabel.textAlignment = NSTextAlignmentLeft;
     reportLabel.lineBreakMode= NSLineBreakByTruncatingTail;
     reportLabel.text =NSLocalizedString(@"Reportaproblem", @"");
     reportLabel.top = top;
     [cell.contentView addSubview:reportLabel];
     
     UIView *line3 = [[UIView alloc] initWithFrame:CGRectMake(0,  0,  self.view.width - 30, 0.5)];
     line3.backgroundColor = FCStyle.fcSeparator;
     line3.top =  reportLabel.bottom + 8;
     line3.left = 15;
     [cell.contentView addSubview:line3];
     
     UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showReportView)];
     UIView *reportView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 21)];
     reportView.left = left;
     reportView.centerY = reportLabel.centerY;
     reportView.userInteractionEnabled = true;
     [reportView addGestureRecognizer:tapGesture];
     [cell.contentView  addSubview:reportView];
     
     
     UIImageView *upImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 21, 19)];
     UIImage *image = [UIImage systemImageNamed:@"exclamationmark.bubble"
                              withConfiguration:[UIImageSymbolConfiguration configurationWithFont:[UIFont systemFontOfSize:13]]];
     image = [image imageWithTintColor:FCStyle.accent renderingMode:UIImageRenderingModeAlwaysOriginal];
     upImageView.right = self.view.width - 26;
     upImageView.centerY = reportLabel.centerY;
     [upImageView setImage:image];
     [cell.contentView addSubview:upImageView];
     
     
     
     
    return cell;
}

- (void)showReportView {
     if(!self.sYReportSlideController.isShown) {
          self.sYReportSlideController.script = self.script;
          self.sYReportSlideController.controller = self.navigationController;
          [self.sYReportSlideController show];
     }
}

- (void)showSubmitView {
     if(!self.sYSubmitScriptSlideController.isShown) {
          self.sYSubmitScriptSlideController.controller = self.navigationController;
          self.sYSubmitScriptSlideController.script = self.script;
          [self.sYSubmitScriptSlideController show];
     }
}

- (void)showDisabledWebsites {
     SYWebsiteViewController *cer = [[SYWebsiteViewController alloc] init];
     cer.type = @"disabledWebsites";
     cer.scriptDic = self.script.toDictionary;
     if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
         && [QuickAccess splitController].viewControllers.count >= 2){
         [[QuickAccess secondaryController] pushViewController:cer];
     }
     else{
          [self.navigationController pushViewController:cer animated:true];
     }
}

- (void)showGrants{
    SYWebsiteViewController *cer = [[SYWebsiteViewController alloc] init];
    cer.type = @"grants";
    cer.scriptDic = self.script.toDictionary;
    if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
        && [QuickAccess splitController].viewControllers.count >= 2){
        [[QuickAccess secondaryController] pushViewController:cer];
    }
    else{
         [self.navigationController pushViewController:cer animated:true];
    }
}

- (void)showMatches{
    SYWebsiteViewController *cer = [[SYWebsiteViewController alloc] init];
    cer.type = @"matches";
    cer.scriptDic = self.script.toDictionary;
    if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
        && [QuickAccess splitController].viewControllers.count >= 2){
        [[QuickAccess secondaryController] pushViewController:cer];
    }
    else{
         [self.navigationController pushViewController:cer animated:true];
    }
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
     
     if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
         && [QuickAccess splitController].viewControllers.count >= 2){
          [[QuickAccess secondaryController] pushViewController:cer];
     }
     else{
          [self.navigationController pushViewController:cer animated:true];
     }
}

- (void)showNotes:(id)sender {
    SYNotesViewController *cer = [[SYNotesViewController alloc] init];
    cer.notes = self.script.notes;
     if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
         && [QuickAccess splitController].viewControllers.count >= 2){
          [[QuickAccess secondaryController] pushViewController:cer];
     }
     else{
          [self.navigationController pushViewController:cer animated:true];
     }
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
         [self.actBtn setTitle:NSLocalizedString(@"Activated", @"") forState:UIControlStateNormal];
          self.actBtn.layer.borderWidth = 1;
          self.actBtn.layer.borderColor = FCStyle.accent.CGColor;
         [self.actBtn setTitleColor:FCStyle.accent forState:UIControlStateNormal];
     } else {
         [self.actBtn setTitle:NSLocalizedString(@"Stopped", @"")  forState:UIControlStateNormal];
          self.actBtn.layer.borderWidth = 1;
          self.actBtn.layer.borderColor = FCStyle.fcBlack.CGColor;
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
        _rightIcon = [[UIBarButtonItem alloc] initWithImage:[ImageHelper sfNamed:@"ellipsis.circle.fill"
                                                                            font:FCStyle.sfNavigationBar
                                                                           color:FCStyle.fcMacIcon]
                                                      style:UIBarButtonItemStylePlain target:self action:@selector(shareBtnClick)];
    }
    return _rightIcon;
}

- (SYSelectTabViewController *)sYSelectTabViewController {
    if(_sYSelectTabViewController == nil) {
        _sYSelectTabViewController = [[SYSelectTabViewController alloc] init];
    }
    return _sYSelectTabViewController;
}


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
#ifdef FC_MAC
        _actBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 50 + 20, 90, 30)];
#else
        _actBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 28 + 91, 90, 30)];
#endif
        
        _actBtn.font = FCStyle.subHeadlineBold;
        _actBtn.layer.cornerRadius = 15;
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
     NSString *used =[NSString stringWithFormat:@"%ld", self.script.usedTimes];
     NSMutableArray *array = [NSMutableArray arrayWithArray:  @[
          @{
              @"name":NSLocalizedString(@"RUNS", @""),
              @"desc": used,
              @"color":FCStyle.grayNoteColor
          },
          @{
              @"name":NSLocalizedString(@"SCRIPT", @""),
              @"desc":@"edit",
              @"color":FCStyle.accent,
              @"type":@"edit"
          },
          @{
              @"name":NSLocalizedString(@"AUTHOR", @""),
              @"desc":self.script.author,
              @"color":FCStyle.grayNoteColor,
          },
          @{
              @"name":NSLocalizedString(@"VERSION", @""),
              @"desc":self.script.version,
              @"color":FCStyle.grayNoteColor,
          },
          @{
               @"name":NSLocalizedString(@"RUNAT", @""),
               @"desc":self.script.runAt,
               @"color":FCStyle.grayNoteColor,
          }
         
          
      ]];
     
     if(self.script.license != NULL && self.script.license.length > 0) {
          [array addObject:@{
               @"name":NSLocalizedString(@"LICENSE", @""),
               @"desc":self.script.license,
               @"color":FCStyle.grayNoteColor,
          }];
     }
     
     if(self.script.homepage != NULL && self.script.homepage.length > 0) {
          [array addObject:@{
               @"name":NSLocalizedString(@"HOMEPAGE", @""),
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
     UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 90, 17)];
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
          UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 80, 17)];
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

- (SYSubmitScriptSlideController *)sYSubmitScriptSlideController {
     if(nil == _sYSubmitScriptSlideController) {
          _sYSubmitScriptSlideController = [[SYSubmitScriptSlideController alloc] init];
     }
     return _sYSubmitScriptSlideController;
}

- (SYReportSlideController *)sYReportSlideController {
     if(nil == _sYReportSlideController) {
          _sYReportSlideController = [[SYReportSlideController alloc] init];
     }
     return _sYReportSlideController;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
         _tableView.backgroundColor = [UIColor clearColor];
         [self.view addSubview:_tableView];
    }
    
    return _tableView;
}



@end
