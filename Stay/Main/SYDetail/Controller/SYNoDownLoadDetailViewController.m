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

#ifdef Mac
#import "QuickAccess.h"
#endif

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
@property (nonatomic, strong) UIView *navigationBarCover;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) LoadingSlideController *loadingSlideController;
@property (nonatomic, assign) bool needExpand;
@property (nonatomic, strong) SYTextInputViewController *sYTextInputViewController;


@end

@implementation SYNoDownLoadDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = FCStyle.popup;

    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    
    [self queryData];
#ifndef Mac
//    [self createDetailView];
#endif
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(scriptSaveSuccess:) name:@"scriptSaveSuccess" object:nil];
//    self.navigationItem.rightBarButtonItem = [self rightIcon];
#ifdef Mac
    self.navigationController.navigationBarHidden = YES;
#endif
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
            });

                } failBlock:^(NSError * _Nonnull error) {
                    dispatch_async(dispatch_get_main_queue(),^{
//                        [self.simpleLoadingView stop];
//                        [self.tableView reloadData];
                    });
                }];
    });
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

- (void)navigateViewWillAppear:(BOOL)animated{
    [self reload];
}

- (void)reload{
    if(_saveSuceess) {
        [self.navigationController popViewControllerAnimated:TRUE];
    }
    self.navigationBarCover = nil;
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
    [self navigationBarCover];
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
    
    if(self.scriptDic == nil) {
        return cell;
    }

    CGFloat left = 15;
    CGFloat titleLabelLeftSize = 0;
    NSString *icon = self.scriptDic[@"icon_url"];
    
    if(icon != NULL && icon.length > 0) {
         UIView *imageBox = [[UIView alloc] initWithFrame:CGRectMake(left, 15, 57, 57)];
         imageBox.layer.cornerRadius = 10;
         imageBox.layer.borderWidth = 1;
         imageBox.layer.borderColor = FCStyle.borderColor.CGColor;
         UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 23, 23)];
         [imageView sd_setImageWithURL:[NSURL URLWithString:icon]];
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
     titleLabel.text = self.scriptDic[@"name"];
     [titleLabel sizeToFit];
     [cell.contentView addSubview:titleLabel];
     
   
     [self.actBtn setTitle:NSLocalizedString(@"Get", @"")  forState:UIControlStateNormal];
     self.actBtn.backgroundColor = FCStyle.background;
     [self.actBtn setTitleColor:FCStyle.accent forState:UIControlStateNormal];
 
     
     [cell.contentView addSubview:self.actBtn];
     self.actBtn.left = titleLabel.left;
     self.actBtn.top = titleLabel.bottom + 5;
     
     UIScrollView *scrollView =  [self createBaseInfoView];
     scrollView.left = left;
     scrollView.top = self.actBtn.bottom + 15;
     [cell.contentView addSubview:scrollView];
    
    UIView *topline = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 1)];
    topline.backgroundColor = FCStyle.fcSeparator;
    topline.top = scrollView.top -1;
    [cell.contentView addSubview:topline];

    UIView *bottomline = [[UIView alloc] initWithFrame:CGRectMake(0, 59, self.view.width, 1)];
    bottomline.backgroundColor = FCStyle.fcSeparator;
    bottomline.bottom = scrollView.bottom + 1;
    [cell.contentView addSubview:bottomline];
     
    UILabel *descDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(left,scrollView.bottom + 13,self.view.width - left * 2 ,200)];
    descDetailLabel.text = self.scriptDic[@"desc"];
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
              btn.right = self.view.width;
              [btn addTarget:self action:@selector(expand) forControlEvents:UIControlEventTouchUpInside];
              [cell.contentView addSubview:btn];
         }
    }
     [cell.contentView addSubview:descDetailLabel];
          
     CGFloat top = descDetailLabel.bottom + 10;
    
    
    NSArray *plafroms = self.scriptDic[@"platforms"];
     if(plafroms != nil && plafroms.count > 0) {
          UIView *availableView =  [self createAvailableView];
          availableView.left = 15;
          availableView.top = top;
          [cell.contentView addSubview:availableView];
          top = availableView.bottom + 10;
     }
    
    NSArray *notes = self.scriptDic[@"notes"];
    
        
     UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, top, self.view.width, 35)];
     [cell.contentView addSubview:buttonView];
     
     UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 34, self.view.width, 1)];
     lineView.backgroundColor = FCStyle.fcShadowLine;
     
     [buttonView addSubview:lineView];
     
     NSArray *selectedArray = @[@"Matches",@"Grants"];
     CGFloat btnLeft = 5;
     
     for(int i = 0; i < 2; i++) {
         CGFloat btnWidth =  (self.view.width - 10 - 42 ) / 2.0;
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
     self.matchScrollView.height = self.view.height- top;
    
     [self.scrollView addSubview:self.grantScrollView];
     self.grantScrollView.height = self.view.height - top;
    return cell;
}

- (void)deleteScript:(id)sender {
  

}

- (void)expand {
     _needExpand = true;
     [self.tableView reloadData];
}

- (void)showScript:(id)sender {
//    SYEditViewController *cer = [[SYEditViewController alloc] init];
//    cer.content = self.script.content;
//    cer.uuid = self.script.uuid;
//    cer.userScript = self.script;
//    cer.isEdit = true;
//    cer.isSearch = NO;
//#ifdef Mac
//    [[QuickAccess secondaryController] pushViewController:cer];
//#else
//    [self.navigationController pushViewController:cer animated:true];
//#endif
}

- (void)showNotes:(id)sender {
    SYNotesViewController *cer = [[SYNotesViewController alloc] init];
    cer.notes = self.scriptDic[@"notes"];
    [self.navigationController pushViewController:cer animated:true];
}


- (void) switchAction:(id)sender {
   
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
     label.textColor =  FCStyle.fcSecondaryBlack;
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
    
    bool stayOnly = self.scriptDic[@"stay_only"];
    if(stayOnly) {
        UIView *splitline = [[UIView alloc] initWithFrame:CGRectMake(0, 12, 1, 17)];
        splitline.backgroundColor = FCStyle.fcSeparator;
        splitline.bottom = label.bottom;
        [view addSubview:splitline];
        splitline.left = imageLeft + 10;
        UILabel *onlyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 19)];
        onlyLabel.text = @"Only on";
        onlyLabel.font = FCStyle.footnoteBold;
        onlyLabel.textColor =  FCStyle.fcSecondaryBlack;
        onlyLabel.left = splitline.right + 12;
        [view addSubview:onlyLabel];
        UIImageView *bzImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bz"]]; ;
        bzImageView.size = bzImageView.image.size;
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
        NSArray *matches = self.scriptDic[@"matches"];
        if (matches.count > 0) {
            UILabel *matchLabel = [self createDefaultLabelWithText:@"Matches"];
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
                    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0, self.view.width - 24 - 23, 1)];
                    line.backgroundColor = FCStyle.fcSeparator;
                    line.top = top + 47;
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
            
            top += 35;
            UILabel *includesLabel = [self createDefaultLabelWithText:@"includes"];
            includesLabel.top = top;
            includesLabel.left = baseLeft;
            includesLabel.textColor = FCStyle.fcPlaceHolder;
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
                    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0, self.view.width - 24 - 23, 1)];
                    line.backgroundColor = FCStyle.fcSeparator;
                    line.top = top + 47;
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
            top += 35;

            UILabel *excludesLabel =  [self createDefaultLabelWithText:@"excludes"];
            excludesLabel.top = top;
            excludesLabel.left = baseLeft;
            excludesLabel.textColor = FCStyle.fcPlaceHolder;
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
                    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0, self.view.width - 24 - 23, 1)];
                    line.backgroundColor = FCStyle.fcSeparator;
                    line.top = top + 47;
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
#ifdef Mac
        _actBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 50 + 20, 90, 25)];
#else
        _actBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 28 + 91, 90, 25)];
#endif
        
        _actBtn.font = FCStyle.footnoteBold;
        _actBtn.layer.cornerRadius = 12.5;
        _actBtn.right = self.view.width - 12;
        [_actBtn addTarget:self action:@selector(getDetail:) forControlEvents:UIControlEventTouchUpInside];

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
#ifdef Mac
                [[QuickAccess secondaryController] pushViewController:cer];
#else
                [self.navigationController pushViewController:cer animated:true];
#endif

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
        CGFloat btnWidth =  (self.view.width - 10 - 42 ) / 2.0;
        _slideView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, btnWidth, 31)];
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
     
     
     NSString *used = self.scriptDic[@"installs"] == nil? @"0": [NSString stringWithFormat:@"%@", self.scriptDic[@"installs"] ];
     
     NSMutableArray *array = [NSMutableArray arrayWithArray: @[
        @{
            @"name":@"INSTALLS",
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
            @"desc":self.scriptDic[@"author"],
            @"color":FCStyle.accent,
        },
        @{
            @"name":@"VERSION",
            @"desc":self.scriptDic[@"version"],
            @"color":FCStyle.grayNoteColor,
        }
    ]];
    
    
    NSString *runAt = self.scriptDic[@"run_at"];
    if(runAt != NULL && runAt.length > 0) {
         [array addObject:@{
              @"name":@"RUNAT",
              @"desc":runAt,
              @"color":FCStyle.grayNoteColor,
         }];
    }
    
    
    NSString *license = self.scriptDic[@"license"];
    
    if(license != NULL && license.length > 0) {
         [array addObject:@{
              @"name":@"LICENSE",
              @"desc":license,
              @"color":FCStyle.grayNoteColor,
         }];
    }
    
    NSString *homepage = self.scriptDic[@"homepage"];
    if(homepage != NULL && homepage.length > 0) {
         [array addObject:@{
              @"name":@"HOMEPAGE",
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
            UIView *splitline = [[UIView alloc] initWithFrame:CGRectMake(left, 12, 1, 37)];
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
     UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 15)];
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



- (SYTextInputViewController *)sYTextInputViewController {
    if(nil == _sYTextInputViewController) {
        _sYTextInputViewController = [[SYTextInputViewController alloc] init];
        _sYTextInputViewController.uuid = self.uuid;
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

- (LoadingSlideController *)loadingSlideController{
    if (nil == _loadingSlideController){
        _loadingSlideController = [[LoadingSlideController alloc] init];
        _loadingSlideController.originMainText = NSLocalizedString(@"settings.downloadScript", @"");
    }
    
    return _loadingSlideController;
}


@end
