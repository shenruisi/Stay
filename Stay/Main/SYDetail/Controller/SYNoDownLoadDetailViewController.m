//
//  SYDetailViewController.m
//  Stay
//
//  Created by zly on 2021/11/28.
//

#import "SYNoDownLoadDetailViewController.h"
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
#import "SYNetworkUtils.h"
#import "LoadingSlideController.h"
#import <SafariServices/SafariServices.h>
#import "Tampermonkey.h"
#import <CommonCrypto/CommonDigest.h>
#import "API.h"
#import "SYWebsiteViewController.h"
#import "SYScanImage.h"
#import "SYBigImageViewController.h"
#import "FCRoundedShadowView2.h";
#import "DefaultIcon.h"
#ifdef FC_MAC
#import "FCShared.h"
#import "Plugin.h"
#endif

#import "QuickAccess.h"
#import "DeviceHelper.h"

@interface SYNoDownLoadDetailViewController ()<UITextViewDelegate,UITableViewDelegate, UITableViewDataSource>

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

@property (nonatomic, strong) LoadingSlideController *loadingSlideController;
@property (nonatomic, assign) bool needExpand;
@property (nonatomic, strong) SYTextInputViewController *sYTextInputViewController;


@end

@implementation SYNoDownLoadDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = FCStyle.popup;
    self.hidesBottomBarWhenPushed = YES;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
 
    [self queryData];
  
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(scriptSaveSuccess:) name:@"scriptSaveSuccess" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeThemeColor:) name:@"changeThemeColor" object:nil];

    // Do any additional setup after loading the view.
}

- (void)scriptSaveSuccess:(id)sender{
    _saveSuceess = true;
//    [self createDetailView];
}


- (void)queryData{
//    [self.simpleLoadingView start];
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT),^{

        
        NSString *url = [NSString stringWithFormat:@"%@%@",@"https://api.shenyin.name/stay-fork/userscript/",self.uuid];
        
        [[SYNetworkUtils shareInstance] requestGET:url params:nil successBlock:^(NSString * _Nonnull responseObject) {
                NSData *jsonData = [responseObject dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
            options:NSJSONReadingMutableContainers
            error:nil];
            self.scriptDic = dic[@"biz"];
            dispatch_async(dispatch_get_main_queue(),^{
//                        [self.simpleLoadingView stop];
                        [self.tableView reloadData];
                if(self.scriptDic[@"icon_url"] != nil) {
                  
                    UIView *imageBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
                    imageBox.layer.cornerRadius = 8;
                    imageBox.layer.borderWidth = 1;
                    imageBox.layer.borderColor = FCStyle.borderColor.CGColor;
                    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 18, 18)];
                    [imageView sd_setImageWithURL:[NSURL URLWithString:self.scriptDic[@"icon_url"]]];
                    imageView.clipsToBounds = YES;
                    imageView.centerX = 15;
                    imageView.centerY = 15;
                   imageView.contentMode = UIViewContentModeScaleAspectFit;
                    [imageBox addSubview:imageView];
                    self.navigationItem.titleView = imageBox;
                    self.navigationItem.titleView.hidden = true;
                }
            });

                } failBlock:^(NSError * _Nonnull error) {
                  
                }];
    });
}


- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.tableView.frame = self.view.bounds;
    [self reload];
}

- (void)changeThemeColor:(NSNotification *)note{
     [self reload];
}

- (void)reload{
    if(_saveSuceess) {
        [self.navigationController popViewControllerAnimated:TRUE];
    }
    self.actBtn = nil;
    self.matchScrollView = nil;
    self.grantScrollView = nil;
    self.scrollView = nil;
    self.slideView = nil;
    self.slideLineView = nil;
//    for (UIView *subView in self.view.subviews) {
//        [subView removeFromSuperview];
//    }
//
   [self.tableView reloadData];
//    [self createDetailView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    if(_saveSuceess) {
        [self.navigationController popViewControllerAnimated:TRUE];
    }
}
 
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.scriptDic != nil && self.scriptDic[@"screenshots"] != nil) {
        return self.view.height + 540 + 30;
    } else {
     return self.view.height;
    }
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

    
    if(self.scriptDic == nil) {
        return cell;
    }

    CGFloat left = 15;
    CGFloat titleLabelLeftSize = 0;
    NSString *icon = self.scriptDic[@"icon_url"];
    
    UIView *imageBox = [[UIView alloc] initWithFrame:CGRectMake(left, 15, 118, 118)];
    imageBox.layer.cornerRadius = 30;
    imageBox.layer.borderWidth = 1;
    imageBox.layer.borderColor = FCStyle.borderColor.CGColor;
    imageBox.backgroundColor = FCStyle.fcWhite;

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 78, 78)];
    imageView.clipsToBounds = YES;
    if( icon.length <= 0) {
        [imageView setImage:[DefaultIcon iconWithTitle: self.scriptDic[@"name"] size:CGSizeMake(118, 118)]];
        imageView.size = CGSizeMake(118, 118);
    } else {
        [imageView sd_setImageWithURL:[NSURL URLWithString:icon]];
    }
     
    imageView.centerX = 59;
    imageView.centerY = 59;
   imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageBox addSubview:imageView];
    [cell.contentView addSubview:imageBox];

    titleLabelLeftSize = 15 + 118;
 
     UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(left + titleLabelLeftSize , 20, self.view.width - titleLabelLeftSize - left * 2, 21)];
     titleLabel.font = FCStyle.title3Bold;
     titleLabel.textColor = FCStyle.fcBlack;
     titleLabel.textAlignment = NSTextAlignmentLeft;
     titleLabel.lineBreakMode= NSLineBreakByTruncatingTail;
     titleLabel.numberOfLines = 2;
     titleLabel.text = self.scriptDic[@"name"];
     [titleLabel sizeToFit];
     [cell.contentView addSubview:titleLabel];
     
    
    UILabel *authourLabel = [[UILabel alloc]initWithFrame:CGRectMake(left + titleLabelLeftSize , titleLabel.bottom, self.view.width - titleLabelLeftSize - left * 2 , 19)];
    authourLabel.font = FCStyle.subHeadline;
    authourLabel.textColor = FCStyle.grayNoteColor;
    authourLabel.textAlignment = NSTextAlignmentLeft;
    authourLabel.lineBreakMode= NSLineBreakByTruncatingTail;
    authourLabel.text = self.scriptDic[@"author"];
    [cell.contentView addSubview:authourLabel];
   
     [self.actBtn setTitle:NSLocalizedString(@"Get", @"")  forState:UIControlStateNormal];
     self.actBtn.backgroundColor = FCStyle.background;
     self.actBtn.layer.borderWidth = 1;
     self.actBtn.layer.borderColor = FCStyle.accent.CGColor;
     [self.actBtn setTitleColor:FCStyle.accent forState:UIControlStateNormal];
    
    NSArray *plafroms = self.scriptDic[@"platforms"];

    if (plafroms != NULL && ![plafroms containsObject:[[API shared] queryDeviceType]] ) {
        [self.actBtn setTitle:NSLocalizedString(@"Not supported on this device", @"")  forState:UIControlStateNormal];
        [self.actBtn setTitleColor:FCStyle.fcSecondaryBlack forState:UIControlStateNormal];
        [self.actBtn sizeToFit];
        self.actBtn.userInteractionEnabled = NO;
        self.actBtn.width =  self.actBtn.width + 20;
    }
    
    
    
    UIImageView *shareImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 22, 24)];
    [shareImage setImage:[ImageHelper sfNamed:@"square.and.arrow.up" font:[UIFont systemFontOfSize:20] color:FCStyle.accent]];
    shareImage.right = self.view.width - 26;
    shareImage.bottom = 131;
    shareImage.contentMode = UIViewContentModeBottom;
    [cell.contentView addSubview:shareImage];
    shareImage.userInteractionEnabled = true;
    UITapGestureRecognizer * shareTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareUrl)];
    [shareImage addGestureRecognizer:shareTapGesture];
    
    
     
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
     
    CGFloat top = bottomline.bottom + 13;

    NSArray *notes = self.scriptDic[@"notes"];
    if(notes != nil && notes.count > 0) {
        UIView *notesView = [self createNoteView:notes];
        notesView.top = bottomline.bottom + 1;
        [cell.contentView addSubview:notesView];
        top = notesView.bottom + 10;
    }
    
     if(plafroms != nil && plafroms.count > 0) {
          UIView *availableView =  [self createAvailableView];
          availableView.left = 15;
          availableView.top = top;
          [cell.contentView addSubview:availableView];
         
         NSArray *tags = self.scriptDic[@"tags"];
         
         UIScrollView *tagScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, top, self.view.width ,25)];
     //    tagScrollView.clipsToBounds = YES;
         tagScrollView.showsVerticalScrollIndicator = false;
         tagScrollView.showsHorizontalScrollIndicator = false;
         if(tags != nil && tags.count > 0) {
             CGFloat tagLeft = 16;
             for (int i = 0; i < tags.count; i++) {
                 UILabel *tag = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 25)];
                 tag.text = tags[i];
                 tag.backgroundColor = [FCStyle.accent colorWithAlphaComponent:0.1];
                 tag.font = FCStyle.footnote;
                 tag.layer.cornerRadius = 8;
                 tag.layer.borderColor = FCStyle.accent.CGColor;
                 tag.layer.borderWidth = 1;
                 tag.textAlignment = NSTextAlignmentCenter;
                 [tag sizeToFit];
                 tag.width += 40;
                 tag.height = 25;
                 tag.left = tagLeft;
                 tag.clipsToBounds = YES;
                 tag.top = 0;
                 tagLeft = tag.right + 5;
                 [tagScrollView addSubview:tag];
             }
             
             tagScrollView.contentSize = CGSizeMake(tagLeft, 25);
         }
         [cell.contentView addSubview:tagScrollView];
         
         tagScrollView.top = availableView.bottom + 7;
         
         UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0,  self.view.width - 30, 0.5)];
         line.backgroundColor = FCStyle.fcSeparator;
         line.top =  tagScrollView.bottom + 20;
         line.left = 15;
         [cell.contentView addSubview:line];
         top = line.bottom + 10;
     }
    

    
    NSArray *picArray = self.scriptDic[@"screenshots"];
    if(picArray != nil) {
        UILabel *previewLabel = [[UILabel alloc]initWithFrame:CGRectMake(left , top, 250 , 28)];
        previewLabel.font = FCStyle.title3Bold;
        previewLabel.textColor = FCStyle.fcBlack;
        previewLabel.textAlignment = NSTextAlignmentLeft;
        previewLabel.lineBreakMode= NSLineBreakByTruncatingTail;
        previewLabel.text = NSLocalizedString(@"GuidePage2Text5", @"");
        [cell.contentView addSubview:previewLabel];
        
        UIScrollView *imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, previewLabel.bottom + 10, self.view.width, 540)];
        imageScrollView.showsHorizontalScrollIndicator = false;
        
        CGFloat imageleft = 15;
        for(int i = 0; i < picArray.count; i++) {
            FCRoundedShadowView2 *imageBackView = [[FCRoundedShadowView2 alloc] initWithRadius:25
                                                                                    borderWith:1 cornerMask:kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner];
            imageBackView.frame = CGRectMake(0, 0, 250, 540);
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 250, 540)];
            [imageView sd_setImageWithURL:picArray[i]];
            imageView.layer.cornerRadius = 25;
//            imageView.layer.borderWidth = 1;
            imageView.userInteractionEnabled = false;
            imageView.layer.masksToBounds = YES;
            imageBackView.left = imageleft;
            [imageBackView addSubview:imageView];
            [imageScrollView addSubview:imageBackView];

            imageleft += 27 + 250;
            imageScrollView.contentSize = CGSizeMake(imageleft + 15, 540);
            
            UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanBigImageClick1:)];
            [imageView addGestureRecognizer:tapGestureRecognizer1];
            //让UIImageView和它的父类开启用户交互属性
            [imageView setUserInteractionEnabled:YES];
        }
        
        imageScrollView.clipsToBounds = NO;
        imageScrollView.pagingEnabled = true;        
        imageScrollView.width = imageleft / picArray.count - 30;
        [cell.contentView addSubview:imageScrollView];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0,  self.view.width - 30, 0.5)];
        line.backgroundColor = FCStyle.fcSeparator;
        line.top =  imageScrollView.bottom + 25;
        line.left = 15;
        [cell.contentView addSubview:line];
        top = line.bottom + 15;
    }
    
    if(self.scriptDic[@"have_a_try"] != nil) {
        UILabel *previewLabel = [[UILabel alloc]initWithFrame:CGRectMake(left , top, 250 , 21)];
        previewLabel.font = FCStyle.title3Bold;
        previewLabel.textColor = FCStyle.fcBlack;
        previewLabel.textAlignment = NSTextAlignmentLeft;
        previewLabel.lineBreakMode= NSLineBreakByTruncatingTail;
        previewLabel.text = NSLocalizedString(@"haveTry", @"Have a try");
        [cell.contentView addSubview:previewLabel];
        

        UILabel *installLabel = [[UILabel alloc]initWithFrame:CGRectMake(left , top, 250 , 17)];
        installLabel.font = FCStyle.footnote;
        installLabel.textColor = FCStyle.accent;
        installLabel.textAlignment = NSTextAlignmentLeft;
        installLabel.lineBreakMode= NSLineBreakByTruncatingTail;
        installLabel.text =  NSLocalizedString(@"installAndOpen", @"Install & Open the sample link");
        installLabel.top = previewLabel.bottom + 7;
        [cell.contentView addSubview:installLabel];
        
        UIImageView *accessory = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 13)];
        UIImage *image = [UIImage systemImageNamed:@"chevron.right"
                                 withConfiguration:[UIImageSymbolConfiguration configurationWithFont:[UIFont systemFontOfSize:13]]];
        image = [image imageWithTintColor:FCStyle.fcSecondaryBlack renderingMode:UIImageRenderingModeAlwaysOriginal];
        accessory.right = self.view.width - 26;
        accessory.centerY = installLabel.centerY;
        [accessory setImage:image];
       
        UIView *tryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 17)];
        tryView.left = left;
        tryView.centerY = installLabel.centerY;
        tryView.userInteractionEnabled = true;
        [cell.contentView  addSubview:tryView];
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tryInstall:)];
        [tryView addGestureRecognizer:tapGesture];
        
        
        
        [cell.contentView addSubview:accessory];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0,  self.view.width - 30, 0.5)];
        line.backgroundColor = FCStyle.fcSeparator;
        line.top =  installLabel.bottom + 10;
        line.left = 15;
        [cell.contentView addSubview:line];
        top = line.bottom + 15;
    }
    
    
    
    UILabel *descDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(left,top,self.view.width - left * 2 - 25 ,200)];
    descDetailLabel.text = self.scriptDic[@"desc"];
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
    [cell.contentView addSubview:descDetailLabel];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0,  self.view.width - 30, 0.5)];
    line.backgroundColor = FCStyle.fcSeparator;
    line.top =  descDetailLabel.bottom + 15;
    line.left = 15;
    [cell.contentView addSubview:line];
    top = line.bottom + 15;
            
    
    
    UILabel *informationLabel = [[UILabel alloc]initWithFrame:CGRectMake(left , top, 250 , 21)];
    informationLabel.font = FCStyle.title3Bold;
    informationLabel.textColor = FCStyle.fcBlack;
    informationLabel.textAlignment = NSTextAlignmentLeft;
    informationLabel.lineBreakMode= NSLineBreakByTruncatingTail;
    informationLabel.text =NSLocalizedString(@"Information", @"");
    [cell.contentView addSubview:informationLabel];

    
    CGFloat infoTop = informationLabel.bottom + 13;
   
    NSArray *matches = self.scriptDic[@"matches"];
    if (matches.count > 0) {
        
        UILabel *matchesLabel = [[UILabel alloc]initWithFrame:CGRectMake(left , top, 250 , 21)];
        matchesLabel.font = FCStyle.footnote;
        matchesLabel.textColor = FCStyle.fcSecondaryBlack;
        matchesLabel.textAlignment = NSTextAlignmentLeft;
        matchesLabel.lineBreakMode= NSLineBreakByTruncatingTail;
        matchesLabel.text =NSLocalizedString(@"Matches", @"");
        matchesLabel.top = infoTop;
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

        infoTop = line1.bottom + 13;
    }

    
    

    
    NSArray *grants = self.scriptDic[@"grants"];
    if (grants.count > 0) {
        
        UILabel *grantsLabel = [[UILabel alloc]initWithFrame:CGRectMake(left , top, 250 , 21)];
        grantsLabel.font = FCStyle.footnote;
        grantsLabel.textColor = FCStyle.fcSecondaryBlack;
        grantsLabel.textAlignment = NSTextAlignmentLeft;
        grantsLabel.lineBreakMode= NSLineBreakByTruncatingTail;
        grantsLabel.text =NSLocalizedString(@"Grants", @"");
        grantsLabel.top = infoTop;
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

    }
    

    
 
    return cell;
}

- (void)showGrants{
    SYWebsiteViewController *cer = [[SYWebsiteViewController alloc] init];
    cer.type = @"grants";
    cer.scriptDic = self.scriptDic;
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
    cer.scriptDic = self.scriptDic;
    if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
        && [QuickAccess splitController].viewControllers.count >= 2){
        [[QuickAccess secondaryController] pushViewController:cer];
    }
    else{
         [self.navigationController pushViewController:cer animated:true];
    }
}

- (void)expand {
     _needExpand = true;
     [self.tableView reloadData];
}

- (void)tryInstall:(id)sender {
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
            NSMutableCharacterSet *set  = [[NSCharacterSet URLFragmentAllowedCharacterSet] mutableCopy];
             [set addCharactersInString:@"#"];
            if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[self.scriptDic[@"have_a_try"] stringByAddingPercentEncodingWithAllowedCharacters:set]]]){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.scriptDic[@"have_a_try"] stringByAddingPercentEncodingWithAllowedCharacters:set]]];
            }
            
            if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
                        && [QuickAccess splitController].viewControllers.count >= 2){
                        [[QuickAccess secondaryController] popViewController];
                    }
                    else{
                        [self.navigationController popViewControllerAnimated:YES];
                    }
            
        });
    });
    
}

- (void)showScript:(id)sender {
#ifdef FC_MAC
    NSMutableCharacterSet *set  = [[NSCharacterSet URLFragmentAllowedCharacterSet] mutableCopy];
     [set addCharactersInString:@"#"];
    NSURL *url = [NSURL URLWithString:[self.scriptDic[@"hosting_url"] stringByAddingPercentEncodingWithAllowedCharacters:set]];
    
    [FCShared.plugin.appKit openUrl:url];
#else
    
    if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
            && [QuickAccess splitController].viewControllers.count >= 2){
        NSMutableCharacterSet *set  = [[NSCharacterSet URLFragmentAllowedCharacterSet] mutableCopy];
         [set addCharactersInString:@"#"];
        NSURL *url = [NSURL URLWithString:[self.scriptDic[@"hosting_url"] stringByAddingPercentEncodingWithAllowedCharacters:set]];
        [[UIApplication sharedApplication] openURL:url options:nil completionHandler:nil];
    }
    else{
        NSMutableCharacterSet *set  = [[NSCharacterSet URLFragmentAllowedCharacterSet] mutableCopy];
         [set addCharactersInString:@"#"];
        NSURL *url = [NSURL URLWithString:[self.scriptDic[@"hosting_url"] stringByAddingPercentEncodingWithAllowedCharacters:set]];
        SFSafariViewController *safariVc = [[SFSafariViewController alloc] initWithURL:url];
        [self presentViewController:safariVc animated:YES completion:nil];
    }
    
    
#endif

}

- (void)showNotes:(id)sender {
    SYNotesViewController *cer = [[SYNotesViewController alloc] init];
    cer.notes = self.scriptDic[@"notes"];
    
    if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
            && [QuickAccess splitController].viewControllers.count >= 2){
        [[QuickAccess secondaryController] pushViewController:cer];
    }
    else{
        [self.navigationController pushViewController:cer animated:true];
    }
}

- (void)shareUrl {
    //分享的url
    NSArray *activityItems = @[self.scriptDic[@"hosting_url"]];
        
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];

    [self.navigationController presentViewController:activityVC animated:YES completion:nil];
}

- (UIView *)createNoteView:(NSArray *)notes{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 78)];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100,19)];
    title.text = @"What’s New";
    title.textColor = FCStyle.fcBlack;
    title.font = FCStyle.headlineBold;
    title.top = 10;
    title.left = 15;
    [view addSubview:title];
    
    UILabel *notesView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100,19)];
    notesView.text = @"Version Notes";
    notesView.textColor = FCStyle.accent;
    notesView.font = FCStyle.footnote;
    notesView.top = 13;
    notesView.right = self.view.width - 15;
    notesView.userInteractionEnabled = YES;
    [view addSubview:notesView];
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showNotes:)];
    [notesView addGestureRecognizer:tapGesture];
    UILabel *note = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width - 30,19)];
    note.text = notes[0];
    note.textColor = FCStyle.fcBlack;
    note.font = FCStyle.footnote;
    note.top = title.bottom + 10;
    note.left = 15;
    [view addSubview:note];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0,  self.view.width - 30, 0.5)];
    line.backgroundColor = FCStyle.fcSeparator;
    line.top =  77;
    line.left = 15;
    [view addSubview:line];
    
    return view;
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
     NSArray *plafroms = self.scriptDic[@"platforms"];
     for(int i = 0; i < plafroms.count; i++) {
         NSString *name = plafroms[i];
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
    
    bool stayOnly = [self.scriptDic[@"stay_only"] boolValue];
    if(stayOnly) {
        UIView *splitline = [[UIView alloc] initWithFrame:CGRectMake(0, 12, 1, 17)];
        splitline.backgroundColor = FCStyle.fcSeparator;
        splitline.bottom = label.bottom;
        [view addSubview:splitline];
        splitline.left = imageLeft + 10;
        UILabel *onlyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 19)];
        onlyLabel.text = @"Only on";
        onlyLabel.font = FCStyle.footnoteBold;
        onlyLabel.bottom = label.bottom;
        onlyLabel.textColor =  FCStyle.grayNoteColor;
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
    self.sYSelectTabViewController.url = self.scriptDic[@"hosting_url"];
    [self.sYSelectTabViewController show];
}

- (void)share{
    [self shareBtnClick];
}

- (UIBarButtonItem *)rightIcon {
    if (nil == _rightIcon){
        _rightIcon = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Get", @"")  style:UIBarButtonItemStylePlain target:self action:@selector(tryInstall:)];
        
        _rightIcon.tintColor = FCStyle.accent;
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
        NSArray *matches = self.scriptDic[@"matches"];
        if (matches.count > 0) {
            UILabel *matchLabel = [self createDefaultLabelWithText:@"MATCHES"];
            matchLabel.top = 13;
            matchLabel.left = baseLeft;
            matchLabel.textColor = FCStyle.fcSecondaryBlack;
            matchLabel.font = FCStyle.footnoteBold;
            top = matchLabel.bottom + 8;
            [_matchScrollView addSubview:matchLabel];
            for (int i = 0; i < matches.count; i++) {
                NSString *title  = matches[i];
                UIView *view = [self baseNote:title];
                if (i == 0) {
                    view.layer.cornerRadius = 8;
                    view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
                }
                view.top = top;
                view.left = baseLeft;
                [_matchScrollView addSubview:view];
                if (i != matches.count -1) {
                    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0, self.view.width - 24 - 23, 0.5)];
                    line.backgroundColor = FCStyle.fcSeparator;
                    line.top = top + 47.5;
                    line.left = baseLeft + 23;
                    [_matchScrollView addSubview:line];
                } else {
                    view.layer.cornerRadius = 8;
                    view.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMinXMaxYCorner;
                }
                if (matches.count == 1) {
                    view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMinXMaxYCorner;
                }
                
                top += 48;
            }
        }
        
        NSArray *includes = self.scriptDic[@"includes"];

        if (includes.count > 0) {
            if(top >13) {
              top += 35;
            }            UILabel *includesLabel = [self createDefaultLabelWithText:@"INCLUDES"];
            includesLabel.top = top;
            includesLabel.left = baseLeft;
            includesLabel.textColor = FCStyle.fcSecondaryBlack;
            includesLabel.font = FCStyle.footnoteBold;
            [_matchScrollView addSubview:includesLabel];
            top = includesLabel.bottom + 8;
            
            for (int i = 0; i < includes.count; i++) {
                NSString *title  = includes[i];
                UIView *view = [self baseNote:title];
                view.top = top;
                view.left = baseLeft;
                [_matchScrollView addSubview:view];
                if (i == 0) {
                    view.layer.cornerRadius = 8;
                    view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
                }
                if (i != includes.count -1) {
                    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0, self.view.width - 24 - 23, 0.5)];
                    line.backgroundColor = FCStyle.fcSeparator;
                    line.top = top + 47.5;
                    line.left = baseLeft + 23;
                    [_matchScrollView addSubview:line];
                }else {
                    view.layer.cornerRadius = 8;
                    view.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMinXMaxYCorner;
                }
                
                if (includes.count == 1) {
                    view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMinXMaxYCorner;
                }
                
                top += 48;
            }
        }
        
        
        NSArray *excludes = self.scriptDic[@"excludes"];


        if (excludes.count > 0) {
            if(top >13) {
              top += 35;
            }
            UILabel *excludesLabel =  [self createDefaultLabelWithText:@"EXCLUDES"];
            excludesLabel.top = top;
            excludesLabel.left = baseLeft;
            excludesLabel.textColor = FCStyle.fcSecondaryBlack;
            excludesLabel.font = FCStyle.footnoteBold;
            [_matchScrollView addSubview:excludesLabel];
            
            top = excludesLabel.bottom + 8;
            for (int i = 0; i < excludes.count; i ++) {
                NSString *title  = excludes[i];

                UIView *view = [self baseNote:title];
                view.top = top;
                view.left = baseLeft;
                [_matchScrollView addSubview:view];
                if (i == 0) {
                    view.layer.cornerRadius = 8;
                    view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
                }
                if (i != excludes.count -1) {
                    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0, self.view.width - 24 - 23, 0.5)];
                    line.backgroundColor = FCStyle.fcSeparator;
                    line.top = top + 47.5;
                    line.left = baseLeft + 23;
                    [_matchScrollView addSubview:line];
                }else {
                    view.layer.cornerRadius = 8;
                    view.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMinXMaxYCorner;
                }
                
                if (excludes.count == 1) {
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
        NSArray *grants = self.scriptDic[@"grants"];

        if (grants.count > 0) {
            for (int i = 0; i < grants.count; i++) {
                NSString *title  = grants[i];
                UIView *view = [self baseNote:title];
                view.top = top;
                view.left = baseLeft;
                [_grantScrollView addSubview:view];
                if (i == 0) {
                    view.layer.cornerRadius = 8;
                    view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
                }
                if (i != grants.count -1) {
                    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0, self.view.width - 24 - 23, 1)];
                    line.backgroundColor = FCStyle.fcSeparator;
                    line.top = top + 47;
                    line.left = baseLeft + 23;
                    [_grantScrollView addSubview:line];
                }else {
                    view.layer.cornerRadius = 8;
                    view.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMinXMaxYCorner;
                }
                
                if (grants.count == 1) {
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
        [_actBtn addTarget:self action:@selector(tryInstall:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _actBtn;
}


- (void)getDetail:(UIButton *)sender {

    NSString *downloadUrl = self.scriptDic[@"hosting_url"];
    NSString *name = objc_getAssociatedObject(sender,@"name");
    self.loadingSlideController.originSubText = name;
    [self.loadingSlideController show];
    NSMutableCharacterSet *set  = [[NSCharacterSet URLFragmentAllowedCharacterSet] mutableCopy];
     [set addCharactersInString:@"#"];
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT),^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[downloadUrl stringByAddingPercentEncodingWithAllowedCharacters:set]]];
        dispatch_async(dispatch_get_main_queue(),^{
            if(data != nil ) {

                if (self.loadingSlideController.isShown){
                    [self.loadingSlideController dismiss];
                    self.loadingSlideController = nil;
                }
                NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                SYEditViewController *cer = [[SYEditViewController alloc] init];
                cer.content = str;
                cer.downloadUrl = downloadUrl;
                
                if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
                        && [QuickAccess splitController].viewControllers.count >= 2){
                    [[QuickAccess secondaryController] pushViewController:cer];
                }
                else{
                    [self.navigationController pushViewController:cer animated:true];
                }

            }
            else{
                [self.loadingSlideController updateSubText:NSLocalizedString(@"Error", @"")];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),
                dispatch_get_main_queue(), ^{
                    if (self.loadingSlideController.isShown){
                        [self.loadingSlideController dismiss];
                        self.loadingSlideController = nil;
                    }
                });
            }
        });
    });
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
        CGFloat btnWidth =  (self.view.width - 10 - 42 ) / 2.0;
        _slideView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, btnWidth, 34)];
        _slideView.backgroundColor = [FCStyle.accent colorWithAlphaComponent:0.1];
        _slideView.layer.cornerRadius = 8;
        _slideView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    }
    
    return _slideView;
}

- (UIView *)slideLineView {
    if (_slideLineView == nil) {
        CGFloat btnWidth =  (self.view.width - 10 - 42 ) / 2.0;
        _slideLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 32, btnWidth, 3)];
        _slideLineView.backgroundColor = FCStyle.accent;
    }
    
    return _slideLineView;
}

-(void)scanBigImageClick1:(UITapGestureRecognizer *)tap{
    SYBigImageViewController *cer = [[SYBigImageViewController alloc] init];
    cer.modalPresentationStyle = 0;
    cer.imageList = self.scriptDic[@"screenshots"];
    
    [self.navigationController presentViewController:cer animated:true completion:^{
        
    }];
    
//    UIImageView *clickedImageView = (UIImageView *)tap.view;
//    [SYScanImage scanBigImageWithImageView:clickedImageView];
}


//基础信息view
- (UIScrollView *)createBaseInfoView {
     UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 60)];
    scrollView.showsVerticalScrollIndicator = false;
    scrollView.showsHorizontalScrollIndicator = false;
     
     NSString *used = self.scriptDic[@"installs"] == nil? @"0": [NSString stringWithFormat:@"%@", self.scriptDic[@"installs"] ];
     
     NSMutableArray *array = [NSMutableArray arrayWithArray: @[
        @{
            @"name":NSLocalizedString(@"INSTALLS", @""),
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
            @"desc":self.scriptDic[@"author"],
            @"color":FCStyle.grayNoteColor,
        },
        @{
            @"name":NSLocalizedString(@"VERSION", @""),
            @"desc":self.scriptDic[@"version"],
            @"color":FCStyle.grayNoteColor,
        }
    ]];
    
    
    NSString *runAt = self.scriptDic[@"run_at"];
    if(runAt != NULL && runAt.length > 0) {
         [array addObject:@{
              @"name":NSLocalizedString(@"RUNAT", @""),
              @"desc":runAt,
              @"color":FCStyle.grayNoteColor,
         }];
    }
    
    
    NSString *license = self.scriptDic[@"license"];
    
    if(license != NULL && license.length > 0) {
         [array addObject:@{
              @"name":NSLocalizedString(@"LICENSE",@""),
              @"desc":license,
              @"color":FCStyle.grayNoteColor,
         }];
    }
    
    NSString *homepage = self.scriptDic[@"homepage"];
    if(homepage != NULL && homepage.length > 0) {
         [array addObject:@{
              @"name":NSLocalizedString(@"HOMEPAGE",@""),
              @"desc":homepage,
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
     UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 18)];
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
          UIImage *image = [ImageHelper sfNamed:@"link" font: FCStyle.subHeadline color:descColor];
          UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
          imageView.frame = CGRectMake(0, 0, 18, 18);
          imageView.centerX = title.centerX;
          imageView.top = title.bottom + 6;
          [view addSubview:imageView];
     } else {
          UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 80, 18)];
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


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint offset = scrollView.contentOffset;
    
    float y = offset.y;

     float reload_distance = 10;
    
    
    if(y >  reload_distance) {
        if (FCDeviceTypeIPad == DeviceHelper.type || FCDeviceTypeMac == DeviceHelper.type){
            self.navigationItem.rightBarButtonItems = @[[self rightIcon]];

        }
        else{
             self.navigationItem.rightBarButtonItem = [self rightIcon];
        }
        
        self.navigationItem.titleView.hidden = false;
    } else {
        if (FCDeviceTypeIPad == DeviceHelper.type || FCDeviceTypeMac == DeviceHelper.type){
            self.navigationItem.rightBarButtonItems  = nil;
        }
        else{
            self.navigationItem.rightBarButtonItem = nil;
        }
        self.navigationItem.titleView.hidden = true;

    }
}


- (SYTextInputViewController *)sYTextInputViewController {
    if(nil == _sYTextInputViewController) {
        _sYTextInputViewController = [[SYTextInputViewController alloc] init];
        _sYTextInputViewController.uuid = self.uuid;
    }
    return _sYTextInputViewController;
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

- (LoadingSlideController *)loadingSlideController{
    if (nil == _loadingSlideController){
        _loadingSlideController = [[LoadingSlideController alloc] init];
        _loadingSlideController.originMainText = NSLocalizedString(@"settings.downloadScript", @"");
    }
    
    return _loadingSlideController;
}



@end
