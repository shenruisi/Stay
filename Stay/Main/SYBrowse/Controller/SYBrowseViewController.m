//
//  SYBrowseViewController.m
//  Stay
//
//  Created by zly on 2022/9/6.
//

#import "SYBrowseViewController.h"
#import "DataManager.h"
#import "SYDetailViewController.h"
#import "JSDetailCell.h"
#import "UserscriptUpdateManager.h"
#import "BrowseView.h"
#import "ScriptMananger.h"
#import "FCStyle.h"
#import "SYExpandViewController.h"
#import <objc/runtime.h>
#import "UIImageView+WebCache.h"
#import "SYNetworkUtils.h"
#import "ScriptEntity.h"
#import "SYBrowseExpandViewController.h"
#import "SYNoDownLoadDetailViewController.h"
#import "BrowseDetailTableViewCell.h"
#import "SYEditViewController.h"
#import "LoadingSlideController.h"


#ifdef Mac
#import "ToolbarTrackView.h"
#import "FCSplitViewController.h"
#import "QuickAccess.h"
#endif

@interface _FeaturedBannerTableViewCell : UITableViewCell
@property (nonatomic, strong) NSArray *entity;
@property (nonatomic, strong) UIScrollView *bannerView;
@end

@implementation _FeaturedBannerTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.backgroundColor = FCStyle.secondaryBackground;
        self.contentView.backgroundColor = FCStyle.secondaryBackground;
    }
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
}

- (void)setEntity:(NSArray *)entity{
    for (UIView *subView in self.contentView.subviews) {
        [subView removeFromSuperview];
    }
    _entity = entity;
    NSArray *blocks = entity;
//    NSMutableArray *blocks = [NSMutableArray arrayWithObjects:entity[0],entity[0],entity[0],entity[0],entity[0],entity[0],entity[0],entity[0],entity[0],entity[0], nil];
    if(blocks.count == 0 ) {
        return;
    }
    _bannerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 15, self.contentView.width - 30 , 56 + (self.contentView.width - 40) / 2.25F)];
    _bannerView.scrollEnabled = true;
    _bannerView.pagingEnabled = true;
    _bannerView.clipsToBounds = NO;
    _bannerView.showsVerticalScrollIndicator = false;
    _bannerView.showsHorizontalScrollIndicator = false;
    _bannerView.backgroundColor = FCStyle.secondaryBackground;
    CGFloat left = 0;
    for (int i = 0; i < blocks.count; i++) {
        UIView *banner = [self createBlockView:blocks[i]];
        
        banner.left = (banner.width + 10) * i + 20 ;
        
        [_bannerView addSubview:banner];
        left = banner.right;
    }
    
    _bannerView.contentSize = CGSizeMake(left ,56 + (self.contentView.width - 40) / 2.25F);
    
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0,  self.contentView.width - 20, 1)];
    line.backgroundColor = FCStyle.fcSeparator;
    line.top =  (self.contentView.width - 40) / 2.25F + 71;
    line.left = 20;
    [self.contentView addSubview:line];
    
    [self.contentView addSubview:_bannerView];
}

- (UIView *)createBlockView:(NSDictionary *)dic{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width - 40, 56 + (self.contentView.width - 40) / 2.25F)];
    view.clipsToBounds = YES;
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width - 40, 18)];
    headerLabel.font = FCStyle.title3Bold;
    headerLabel.textColor = FCStyle.fcBlack;
    headerLabel.text = dic[@"title"];
    [view addSubview:headerLabel];
    
    UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width- 40, 15)];
    subLabel.font = FCStyle.subHeadline;
    subLabel.textColor = FCStyle.fcSecondaryBlack;
    subLabel.text = dic[@"subtitle"];
    subLabel.top = headerLabel.bottom + 5;
    [view addSubview:subLabel];
    
    UIImageView *bannerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width - 40, (self.contentView.width - 40) / 2.25F)];
    [bannerImageView sd_setImageWithURL:[NSURL URLWithString: dic[@"imageUrl"]]];
    bannerImageView.layer.cornerRadius = 10;
    bannerImageView.clipsToBounds = YES;
    bannerImageView.top = subLabel.bottom + 5;

    bool border = dic[@"border"];
    if (border) {
        bannerImageView.layer.borderColor = FCStyle.borderColor.CGColor;
        bannerImageView.layer.borderWidth = 1;
    }
    
    [view addSubview:bannerImageView];
    view.backgroundColor = FCStyle.secondaryBackground;
    return view;
}



@end


@interface _FeaturedAlubmTableViewCell : UITableViewCell
@property (nonatomic, strong) NSArray *entity;
@property (nonatomic, strong) NSString *headTitle;
@property (nonatomic, strong) UIScrollView *bannerView;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) UIViewController *controller;

@end

@implementation _FeaturedAlubmTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.backgroundColor = FCStyle.secondaryBackground;
        self.contentView.backgroundColor = FCStyle.secondaryBackground;
    }
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
}

- (void)setEntity:(NSArray *)entity{
    for (UIView *subView in self.contentView.subviews) {
        [subView removeFromSuperview];
    }
    
    _entity = entity;
    NSArray *blocks = entity;

    if(blocks.count == 0 ) {
        return;
    }
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, 320, 19)];
    titleLabel.text = _headTitle;
    titleLabel.font = FCStyle.title3Bold;
    titleLabel.textColor = FCStyle.fcBlack;
    [self.contentView addSubview:titleLabel];
//    titleLabel.
    
    
    UIButton *seeAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [seeAllBtn setTitleColor:FCStyle.accent forState:UIControlStateNormal];
    [seeAllBtn setTitle:NSLocalizedString(@"See All", @"") forState:UIControlStateNormal];
    seeAllBtn.frame = CGRectMake(0, 0, 47, 17);
    seeAllBtn.centerY = titleLabel.centerY;
    seeAllBtn.right = self.contentView.width -11;
    seeAllBtn.font = FCStyle.subHeadline;
    [seeAllBtn addTarget:self action:@selector(clickSeeAll:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:seeAllBtn];
    
    long rowSize =  (blocks.count - 1) / 3 + 1;
    
    CGFloat width = self.contentView.width;
    if(rowSize >= 2) {
        width = self.contentView.width - 30;
    }
    CGFloat heigth = 174;
    if(blocks.count >= 3) {
        heigth = 78 * 3;
    } else {
        heigth = 78 * blocks.count;
    }
    _bannerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, titleLabel.bottom, width , heigth)];
    _bannerView.scrollEnabled = true;
    _bannerView.pagingEnabled = true;
    _bannerView.clipsToBounds = NO;
    _bannerView.showsVerticalScrollIndicator = false;
    _bannerView.showsHorizontalScrollIndicator = false;
    _bannerView.backgroundColor = FCStyle.secondaryBackground;
    CGFloat left = 0;
  
    for (int i = 0; i < blocks.count; i+=3) {
        UIView *blockView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width - 40, heigth)];
        blockView.clipsToBounds = YES;
        for(int j = 0; j <= 2; j++) {
            if(i + j >= blocks.count) {
                break;
            }
            UIView *cellView = [self createCellView:blocks[i + j]];
            cellView.top = j * 78;
            [blockView addSubview:cellView];
        }
        blockView.left = (blockView.width + 10) * (i / 3) + 20 ;
        [_bannerView addSubview:blockView];
        left = blockView.right;
    }
    
    _bannerView.contentSize = CGSizeMake(left ,heigth);
    [self.contentView addSubview:_bannerView];
}

- (UIView *)createCellView:(NSDictionary *)dic{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width - 40, 78)];
    UIView *imageBox = [[UIView alloc] initWithFrame:CGRectMake(0, 10, 48, 48)];
    imageBox.layer.cornerRadius = 10;
    imageBox.layer.borderWidth = 1;
    imageBox.layer.borderColor = FCStyle.borderColor.CGColor;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 26, 26)];
    [imageView sd_setImageWithURL:[NSURL URLWithString: dic[@"icon_url"]]];
//    [imageView sd_setImageWithURL:[NSURL URLWithString: @"https://res.stayfork.app/scripts/8E61538B6D32E64E6F38BF2AB4416C73/icon.png"]];

    imageView.clipsToBounds = YES;
    imageView.centerX = 24;
    imageView.centerY = 24;
    [imageBox addSubview:imageView];
    [view addSubview:imageBox];
    view.backgroundColor = FCStyle.secondaryBackground;
    
    CGFloat left = 0;
    NSString *icon = dic[@"icon_url"];
    if( icon != nil && icon.length > 0){
        left = imageBox.right + 10;
    } else {
        imageBox.hidden = true;
    }
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 18, 234, 16)];
    headerLabel.font = FCStyle.body;
    headerLabel.textColor = FCStyle.fcBlack;
    headerLabel.text = dic[@"name"];
    [view addSubview:headerLabel];
    
    UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 234, 13)];
    subLabel.font = FCStyle.footnote;
    subLabel.textColor = FCStyle.fcSecondaryBlack;
    subLabel.text = dic[@"desc"];
    subLabel.top = headerLabel.bottom + 5;
    [view addSubview:subLabel];
    headerLabel.left = subLabel.left = left;
    subLabel.top = headerLabel.bottom + 5;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0,  self.contentView.width - 40 - 40 - 10, 1)];
    line.backgroundColor = FCStyle.fcSeparator;
    line.top =  subLabel.bottom + 23;
    line.left = left;
    line.width = self.contentView.width - 40 - 10 - left;
    [view addSubview:line];
    
    NSString *uuid = dic[@"uuid"];
    
    ScriptEntity *entity = [ScriptMananger shareManager].scriptDic[uuid];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 67, 25);
    btn.backgroundColor = FCStyle.background;
    if(entity != nil) {
        [btn setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Detail", @"")
                                                                attributes:@{
            NSForegroundColorAttributeName : FCStyle.accent,
            NSFontAttributeName : FCStyle.footnoteBold
        }] forState:UIControlStateNormal];
        [btn addTarget:self.controller action:@selector(queryDetail:) forControlEvents:UIControlEventTouchUpInside];
        objc_setAssociatedObject (btn , @"uuid", uuid, OBJC_ASSOCIATION_COPY_NONATOMIC);
    } else {
        [btn setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Get", @"")
                                                                attributes:@{
            NSForegroundColorAttributeName : FCStyle.accent,
            NSFontAttributeName : FCStyle.footnoteBold
        }] forState:UIControlStateNormal];
        [btn addTarget:self.controller action:@selector(getDetail:) forControlEvents:UIControlEventTouchUpInside];
        objc_setAssociatedObject (btn , @"downloadUrl", dic[@"hosting_url"], OBJC_ASSOCIATION_COPY_NONATOMIC);
        objc_setAssociatedObject (btn , @"name", dic[@"name"], OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    
    btn.top = headerLabel.top;
    btn.right = self.contentView.width - 40 - 10;
    btn.layer.cornerRadius = 12.5;
    
    [view addSubview:btn];
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(noDownloadDetail:)];
    if(entity != nil) {
        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self.controller action:@selector(queryDetail:)];
        objc_setAssociatedObject (tapGesture , @"uuid", uuid, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    [tapGesture setName:uuid];
    
    [view addGestureRecognizer:tapGesture];
    
    
    return view;
}
-(void)noDownloadDetail:(UITapGestureRecognizer *)tap {
    NSString* uuid = tap.name;
    SYNoDownLoadDetailViewController *cer = [[SYNoDownLoadDetailViewController alloc] init];
    cer.uuid = uuid;
#ifdef Mac
    [[QuickAccess secondaryController] pushViewController:cer];
#else
    [self.navigationController pushViewController:cer animated:true];
#endif
    
}

-(void)clickSeeAll:(id)sender{
    SYBrowseExpandViewController *cer = [[SYBrowseExpandViewController alloc] init];
    cer.data = self.entity;
    cer.title = self.headTitle;
#ifdef Mac
    [[QuickAccess secondaryController] pushViewController:cer];
#else
    [self.navigationController pushViewController:cer animated:true];
#endif
    
}

@end

@interface BroSimpleLoadingView : UIView

@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) UILabel *label;
- (void)start;
- (void)stop;
@end

@implementation BroSimpleLoadingView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        [self indicator];
        [self label];
    }

    return self;
}

- (void)start{
    [self.superview bringSubviewToFront:self];
    self.hidden = NO;
    [self.indicator startAnimating];
}

- (void)stop{
    [self.superview sendSubviewToBack:self];
    self.hidden = YES;
    [self.indicator stopAnimating];
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    [self.label sizeToFit];
    CGFloat width = self.indicator.frame.size.width + self.label.frame.size.width;
    CGFloat left = (self.frame.size.width - width) / 2;
    [self.indicator setFrame:CGRectMake(left,
                                        (self.frame.size.height - self.indicator.frame.size.height)/2,
                                        self.indicator.frame.size.width,
                                        self.indicator.frame.size.height)];
    [self.label setFrame:CGRectMake(self.indicator.frame.origin.x + self.indicator.frame.size.width + 15,
                                    (self.frame.size.height - self.label.frame.size.height)/2,
                                    self.label.frame.size.width,
                                    self.label.frame.size.height)];
    [self.indicator startAnimating];
}

- (UIActivityIndicatorView *)indicator{
    if (nil == _indicator){
        _indicator = [[UIActivityIndicatorView alloc] init];
        [self addSubview:_indicator];
    }
    return _indicator;
}

- (UILabel *)label{
    if (nil == _label){
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        _label.font = FCStyle.body;
        _label.textColor = FCStyle.fcBlack;
        _label.text = NSLocalizedString(@"Loading", @"");
        [self addSubview:_label];
    }

    return _label;
}


- (void)setHidden:(BOOL)hidden{
    [super setHidden:hidden];

}

@end

@interface SYBrowseViewController ()<
UITableViewDelegate,
UITableViewDataSource,
UISearchResultsUpdating,
UISearchBarDelegate,
UISearchControllerDelegate,
UIPopoverPresentationControllerDelegate
>
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray *datas; //featuredata
@property (nonatomic, strong) NSMutableArray *allDatas;
@property (nonatomic, strong) NSMutableArray *searchDatas;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) BroSimpleLoadingView *simpleLoadingView;
@property (nonatomic, assign) NSInteger selectedIdx;
@property (nonatomic, assign) NSInteger pageNo;
@property (nonatomic, assign) NSInteger searchPageNo;

@property (nonatomic, strong) LoadingSlideController *loadingSlideController;
@property (nonatomic, assign) bool inSearch;
@property (nonatomic, assign) bool allDataEnd;
@property (nonatomic, assign) bool allDataQuerying;
@property (nonatomic, assign) bool searchDataEnd;
@property (nonatomic, assign) bool searchDataQuerying;

@end

@implementation SYBrowseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = FCStyle.background;
#ifdef Mac
    self.navigationController.navigationBarHidden = YES;
#endif
    _selectedIdx = 0;
    UISearchController *search = [[UISearchController alloc]initWithSearchResultsController:nil];
       // 设置结果更新代理
//    search.searchResultsUpdater = self;
    search.searchBar.placeholder = @"Search Userscripts";
    self.navigationItem.searchController = search;
    self.navigationItem.searchController.delegate = self;
    self.navigationItem.searchController.searchBar.delegate = self;
    self.navigationItem.searchController.obscuresBackgroundDuringPresentation = false;
    self.navigationItem.hidesSearchBarWhenScrolling = false;

    self.searchController = search;
    self.searchController.delegate = self;
    self.searchController.searchBar.delegate = self;
    [self.searchController.searchBar setTintColor:FCStyle.accent];
    // Do any additional setup after loading the view.
//    [self.view addSubview:self.segmentedControl];
    [self tableView];
    [self queryData];
    self.tableView.sectionHeaderTopPadding = 0;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
}


- (UIView *)createTableHeaderView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 16 + 15 + 35)];
    [view addSubview:self.segmentedControl];
    view.backgroundColor = FCStyle.background;
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0,  self.view.width, 1)];
    line.backgroundColor = FCStyle.fcSeparator;
    line.top = 65;
    [view addSubview:line];
//    self.tableView.tableHeaderView = view;
    return  view;
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.tableView.frame = self.view.bounds;
    [self.tableView reloadData];
}

#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(nonnull UISearchController *)searchController {
    NSString *inputStr = searchController.searchBar.text;
    return;
}

#pragma mark -searchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
//    [searchBar resignFirstResponder];
    [self.searchController setActive:NO];
    _inSearch = false;
    [_searchDatas removeAllObjects];
    [self.tableView reloadData];
//    [self.tableView reloadData];

}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self.searchController setActive:YES];
    _searchPageNo = 1;
    _inSearch = true;
    [self.tableView reloadData];
    return YES;
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [_searchDatas removeAllObjects];
    if(searchText.length > 0) {
        _searchPageNo = 1;
//        [_results addObjectsFromArray:[[DataManager shareManager] selectScriptByKeywordByAdded:searchText]];
       [self querySearchData:searchText];
    }
    [self.tableView reloadData];
}


#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if(_inSearch == TRUE) {
        return nil;
    } else {
        return [self createTableHeaderView];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(_inSearch == TRUE) {
        return self.searchDatas.count;
    } else if(_selectedIdx == 1) {
        return  self.allDatas.count;
    } else {
        return  self.datas.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(!_inSearch) {
        if(_selectedIdx == 0) {
            NSDictionary *dic = self.datas[indexPath.row];
            if([dic[@"type"] isEqualToString:@"banner"]) {
                _FeaturedBannerTableViewCell *cell = [[_FeaturedBannerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
                cell.contentView.width = self.view.width;
                cell.width = self.view.width;
                cell.entity = dic[@"blocks"];
                cell.contentView.backgroundColor = FCStyle.secondaryBackground;
                return cell;
            } else if([dic[@"type"] isEqualToString:@"album"]){
                _FeaturedAlubmTableViewCell *cell = [[_FeaturedAlubmTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellALBUM"];
                cell.contentView.width = self.view.width;
                cell.width = self.view.width;
                cell.controller = self;
                cell.navigationController = self.navigationController;
                cell.headTitle = dic[@"title"];
                cell.entity = dic[@"userscripts"];
                cell.contentView.backgroundColor = FCStyle.secondaryBackground;
                return cell;
            } else {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID3"];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID3"];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                cell.contentView.backgroundColor = FCStyle.secondaryBackground;
                return cell;
            }
            
        } else {
//            BrowseDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIBD"];
//            if (cell == nil) {
//                cell = [[BrowseDetailTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellIBD"];
//                cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            }
            BrowseDetailTableViewCell * cell = [[BrowseDetailTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellIBD"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            cell.contentView.width = self.view.width;
            cell.controller = self;
            cell.navigationController = self.navigationController;
            cell.entity = self.allDatas[indexPath.row];
            return cell;
        }
    } else {
        BrowseDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIBD"];
        if (cell == nil) {
            cell = [[BrowseDetailTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellIBD"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.contentView.width = self.view.width;
        cell.controller = self;
        cell.navigationController = self.navigationController;
        cell.entity = self.searchDatas[indexPath.row];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(_inSearch == TRUE) {
        return 138.0f;
    }else if(_selectedIdx == 1) {
        return 138.0f;
    } else {
        NSDictionary *dic = self.datas[indexPath.row];
        if([dic[@"type"] isEqualToString:@"banner"]) {
            return (self.view.width - 40) / 2.25f + 72.0f;
        } else if([dic[@"type"] isEqualToString:@"album"]) {
            NSArray *array =  dic[@"userscripts"];
            if(array.count >= 3) {
                return 33 + 78 * 3;
            } else {
                return 33 + 78 * array.count;
            }
        }
        
        return 1.0f;
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_segmentedControl != NULL) {
        [_segmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName:FCStyle.accent,NSFontAttributeName:FCStyle.subHeadlineBold} forState:UIControlStateSelected];
    }
    [self.tableView reloadData];
}

- (void)queryData{
    if (self.datas.count == 0){
        [self.simpleLoadingView start];
    }
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT),^{
    
        [[SYNetworkUtils shareInstance] requestPOST:@"https://api.shenyin.name/stay-fork/browse/featured" params:@{@"client":@{@"pro":@true}} successBlock:^(NSString * _Nonnull responseObject) {
            
                NSData *jsonData = [responseObject dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
            options:NSJSONReadingMutableContainers
            error:nil];
                    self.datas = dic[@"biz"];
                    dispatch_async(dispatch_get_main_queue(),^{
                        [self.simpleLoadingView stop];
                        [self.tableView reloadData];
                    });
                } failBlock:^(NSError * _Nonnull error) {
                    dispatch_async(dispatch_get_main_queue(),^{
                        [self.simpleLoadingView stop];
                        [self.tableView reloadData];
                    });
                }];

  
    });
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(_inSearch == TRUE) {
        return 0.1;
    }
    return 65;
}

- (void)queryAllData{
    if (self.allDatas.count == 0){
        [self.simpleLoadingView start];
    }
    
    if(_allDataQuerying) {
        return;
    }
    
    _allDataQuerying = true;
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT),^{
        
        [[SYNetworkUtils shareInstance] requestGET:[NSString stringWithFormat: @"https://api.shenyin.name/stay-fork/browse/all?page=%d",_pageNo] params:nil successBlock:^(NSString * _Nonnull responseObject) {
            
            NSData *jsonData = [responseObject dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
            options:NSJSONReadingMutableContainers
            error:nil];
            if(_pageNo == 1) {
                [self.allDatas removeAllObjects];
            }
            _allDataQuerying = false;
            NSArray *array = dic[@"biz"];
            if(array.count == 0) {
                _allDataEnd = true;
            }
            [self.allDatas addObjectsFromArray:dic[@"biz"]];
                    dispatch_async(dispatch_get_main_queue(),^{
                        [self.simpleLoadingView stop];
                        [self.tableView reloadData];
                    });
                } failBlock:^(NSError * _Nonnull error) {
                    dispatch_async(dispatch_get_main_queue(),^{
                        [self.simpleLoadingView stop];
                        [self.tableView reloadData];
                    });
                    _allDataQuerying = false;
                }];

  
    });
}

- (void)querySearchData:(NSString *)key{
    if(_searchDataQuerying) {
        return;
    }
    
    _searchDataQuerying = true;
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT),^{
        [[SYNetworkUtils shareInstance] requestPOST:[NSString stringWithFormat: @"https://api.shenyin.name/stay-fork/search?page=%d",_searchPageNo] params:@{@"biz":@{@"keywords":key}} successBlock:^(NSString * _Nonnull responseObject) {
            
            NSData *jsonData = [responseObject dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
            options:NSJSONReadingMutableContainers
            error:nil];
            if(_searchPageNo == 1) {
                [self.searchDatas removeAllObjects];
            }
            _searchDataQuerying = false;
            
           
            [self.searchDatas addObjectsFromArray:dic[@"biz"]];
                    dispatch_async(dispatch_get_main_queue(),^{
                        [self.tableView reloadData];
                    });
                } failBlock:^(NSError * _Nonnull error) {
                    dispatch_async(dispatch_get_main_queue(),^{
                        [self.tableView reloadData];
                    });
                    
                    _searchDataQuerying = false;
                }];
    });
}


- (void)getDetail:(UIButton *)sender {

    NSString *downloadUrl = objc_getAssociatedObject(sender,@"downloadUrl");
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

- (void)queryDetail:(id )sender {
    NSString *uuid = objc_getAssociatedObject(sender,@"uuid");
    UserScript *model = [[DataManager shareManager] selectScriptByUuid:uuid];
    SYDetailViewController *cer = [[SYDetailViewController alloc] init];
    cer.isSearch = false;
    cer.script = model;
#ifdef Mac
    [[QuickAccess secondaryController] pushViewController:cer];
#else
    [self.navigationController pushViewController:cer animated:true];
#endif
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint offset = scrollView.contentOffset;
     CGRect bounds = scrollView.bounds;
     CGSize size = scrollView.contentSize;
     UIEdgeInsets inset = scrollView.contentInset;
     float y = offset.y + bounds.size.height - inset.bottom;
     float h = size.height;
     float reload_distance = 10;
     if(y > h + reload_distance) {
         if (_inSearch) {
             
         } else if(self.selectedIdx == 1 && !_allDataEnd) {
             _pageNo++;
             [self queryAllData];
         }
         NSLog(@"load more rows");
     }
}

- (void)segmentControllerAction:(UISegmentedControl *)segment
{
    NSInteger index = segment.selectedSegmentIndex;
    if(index == 1) {
        _selectedIdx = 1;
        if(self.allDatas.count > 0) {
            [self.tableView reloadData];
        } else {
            if(_allDatas.count == 0) {
                _pageNo = 1;
                [self queryAllData];
            }
        }
    
    } else {
        _selectedIdx = 0;
        [self.tableView reloadData];
    }
}

- (UISegmentedControl *)segmentedControl {
    if(_segmentedControl == nil) {
        NSArray *segmentedArray = [[NSArray alloc]initWithObjects:NSLocalizedString(@"Featured", @""),NSLocalizedString(@"All", @""),nil];
        _segmentedControl = [[UISegmentedControl alloc]initWithItems:segmentedArray];
        [_segmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName:FCStyle.accent,NSFontAttributeName:FCStyle.footnoteBold} forState:UIControlStateSelected];
        [_segmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName:FCStyle.fcBlack,NSFontAttributeName:FCStyle.footnoteBold} forState:UIControlStateNormal];
        _segmentedControl.backgroundColor = FCStyle.secondaryPopup;
        _segmentedControl.selectedSegmentTintColor = FCStyle.fcWhite;
        _segmentedControl.selectedSegmentIndex = 0;
        CGFloat left = (self.view.width - 200) / 2;
        _segmentedControl.frame =  CGRectMake(left, 15, 200, 30);
        [_segmentedControl addTarget:self action:@selector(segmentControllerAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _segmentedControl;
}


- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = FCStyle.background;
        [self.view addSubview:_tableView];
    }
    
    return _tableView;
}

- (BroSimpleLoadingView *)simpleLoadingView{
    if (nil == _simpleLoadingView){
        _simpleLoadingView = [[BroSimpleLoadingView alloc] initWithFrame:CGRectMake(0,
                                                                                 (self.view.frame.size.height - 50) / 2,
                                                                                 self.view.frame.size.width, 50)];
        
        [self.view addSubview:_simpleLoadingView];
    }
    
    return _simpleLoadingView;
}

- (NSMutableArray *)datas {
    if (_datas == nil) {
        _datas = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _datas;
}

- (NSMutableArray *)allDatas {
    if (_allDatas == nil) {
        _allDatas = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _allDatas;
}

- (NSMutableArray *)searchDatas {
    if (_searchDatas == nil) {
        _searchDatas = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _searchDatas;
}

- (LoadingSlideController *)loadingSlideController{
    if (nil == _loadingSlideController){
        _loadingSlideController = [[LoadingSlideController alloc] init];
        _loadingSlideController.originMainText = NSLocalizedString(@"settings.downloadScript", @"");
    }
    
    return _loadingSlideController;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
