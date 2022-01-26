//
//  SYHomeViewController.m
//  Stay
//
//  Created by zly on 2021/11/9.
//

#import "SYHomeViewController.h"
#import "JSDetailCell.h"
#import "DataManager.h"
#import "SYDetailViewController.h"
#import "SYEditViewController.h"
#import "SYCodeMirrorView.h"
#import <StoreKit/StoreKit.h>
#import "SYNetworkUtils.h"
#import "Tampermonkey.h"
#import "SYVersionUtils.h"


@interface SYHomeViewController ()<UITableViewDelegate, UITableViewDataSource,UISearchResultsUpdating,UISearchBarDelegate,UISearchControllerDelegate>

@property (nonatomic, strong) UIBarButtonItem *leftIcon;
@property (nonatomic, strong) UIBarButtonItem *rightIcon;

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) UITableView *tableView;
// 数据源数组
@property (nonatomic, strong) NSMutableArray *datas;
// 搜索结果数组
@property (nonatomic, strong) NSMutableArray *results;



@end

@implementation SYHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [SYCodeMirrorView shareCodeView];
    self.navigationItem.leftBarButtonItem = [self leftIcon];
    self.navigationItem.rightBarButtonItem = [self rightIcon];
    self.view.backgroundColor = [UIColor whiteColor];
    UISearchController *search = [[UISearchController alloc]initWithSearchResultsController:nil];
       // 设置结果更新代理
//    search.searchResultsUpdater = self;
    search.searchBar.placeholder = @"Search added userscripts";
    self.navigationItem.searchController = search;
    self.navigationItem.searchController.delegate = self;
    self.navigationItem.searchController.searchBar.delegate = self;
    self.navigationItem.searchController.obscuresBackgroundDuringPresentation = false;
    self.searchController = search;
    self.searchController.delegate = self;
    self.searchController.searchBar.delegate = self;
    [self.searchController.searchBar setTintColor:RGB(182, 32, 224)];
    
    self.navigationItem.hidesSearchBarWhenScrolling = false;

    [_datas removeAllObjects];
    [_datas addObjectsFromArray:[[DataManager shareManager] findScript:1]];
    [self initScrpitContent];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

//检测评分
- (void)checkShowTips{
    NSUserDefaults *groupUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dajiu.stay.pro"];
    if([groupUserDefaults objectForKey:@"tips"] != NULL){
        int count = [[groupUserDefaults objectForKey:@"tips"] intValue];
        if(count == 10) {
          [SKStoreReviewController requestReview];
        }
        count += 1;
        [groupUserDefaults setObject:@(count)  forKey:@"tips"];
    } else {
        [groupUserDefaults setObject:@(1) forKey:@"tips"];
        [groupUserDefaults synchronize];
    }
}

//后台唤起时处理与插件交互
- (void)onBecomeActive{
    [self checkShowTips];
    NSUserDefaults *groupUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dajiu.stay.pro"];
    if([groupUserDefaults arrayForKey:@"ACTIVE_CHANGE"] != NULL && [groupUserDefaults arrayForKey:@"ACTIVE_CHANGE"].count > 0){
        NSMutableArray<NSDictionary *> *datas = [NSMutableArray arrayWithArray:[groupUserDefaults arrayForKey:@"ACTIVE_CHANGE"]];
        for(int i = 0; i < datas.count; i++) {
            NSDictionary *dic = datas[i];
            [[DataManager shareManager] updateScrpitStatus:[dic[@"active"] intValue] numberId:dic[@"uuid"]];
        }
    }
    [groupUserDefaults setObject:nil forKey:@"ACTIVE_CHANGE"];
    [groupUserDefaults synchronize];
    [self reloadTableView];
    [self.tableView reloadData];
    [self initScrpitContent];
    NSArray *array = [[DataManager shareManager] findScript:1];
    [self updateScriptWhen:array type:false];
    NSArray *searchArray = [[DataManager shareManager] findScriptInLib];
    [self updateScriptWhen:searchArray type:true];
}

- (void)updateScriptWhen:(NSArray *)array type:(Boolean)isSearch {
    for(int i = 0; i < array.count; i++) {
        UserScript *scrpit = array[i];
        if(!isSearch && !scrpit.updateSwitch) {
            continue;
        }
        
        if(scrpit.updateUrl != NULL && scrpit.updateUrl.length > 0) {
            [[SYNetworkUtils shareInstance] requestGET:scrpit.updateUrl params:NULL successBlock:^(NSString * _Nonnull responseObject) {
                if(responseObject != nil) {
                    UserScript *userScript = [[Tampermonkey shared] parseWithScriptContent:responseObject];
                    if(userScript.version != NULL) {
                        NSInteger status =  [SYVersionUtils compareVersion:userScript.version toVersion:scrpit.version];
                        if(status == 1) {
                            if(userScript.downloadUrl == nil || userScript.downloadUrl.length <= 0){
                                if(userScript.content != nil && userScript.content.length > 0) {
                                    userScript.uuid = scrpit.uuid;
                                    userScript.active = scrpit.active;
                                    if(isSearch) {
                                        [[DataManager shareManager] updateScriptConfigByUserScript:userScript];
                                    } else {
                                        [[DataManager shareManager] updateUserScript:userScript];
                                        [self refreshScript];
                                    }
                                }
                            } else {
                                [[SYNetworkUtils shareInstance] requestGET:scrpit.downloadUrl params:nil successBlock:^(NSString * _Nonnull responseObject) {
                                    if(responseObject != nil) {
                                        UserScript *userScript = [[Tampermonkey shared] parseWithScriptContent:responseObject];
                                        userScript.uuid = scrpit.uuid;
                                        userScript.active = scrpit.active;
                                        if(userScript != nil && userScript.errorMessage != nil && userScript.errorMessage.length <= 0) {
                                            if(isSearch) {
                                                [[DataManager shareManager] updateScriptConfigByUserScript:userScript];
                                            } else {
                                                [[DataManager shareManager] updateUserScript:userScript];
                                                [self refreshScript];
                                            }
                                        }
                                    }
                                } failBlock:^(NSError * _Nonnull error) {
                                    
                                }];
                            }
                        }
                    }
                    
                }
            } failBlock:^(NSError * _Nonnull error) {
                        
            }];
        }
    }
}

- (void)refreshScript{
    [self initScrpitContent];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadTableView];
        [self.tableView reloadData];
    });
}

- (void)initScrpitContent{
    NSUserDefaults *groupUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dajiu.stay.pro"];
    NSMutableArray *array =  [[NSMutableArray alloc] init];
    for(int i = 0; i < self.datas.count; i++) {
        UserScript *scrpit = self.datas[i];
        [array addObject: [scrpit toDictionary]];
    }
    [groupUserDefaults setObject:array forKey:@"ACTIVE_SCRIPTS"];
    [groupUserDefaults synchronize];
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
    [_results removeAllObjects];
    [self reloadTableView];
    [self.tableView reloadData];

}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self.searchController setActive:YES];
    [_results removeAllObjects];
    [self.tableView reloadData];
    return YES;
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [_results removeAllObjects];
    if(searchText.length > 0) {
        [_results addObjectsFromArray:[[DataManager shareManager] selectScriptByKeywordByAdded:searchText]];
    }
    [self.tableView reloadData];

}


#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchController.active) {
        return self.results.count;
    }
    
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }
    for (UIView *subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    // 这里通过searchController的active属性来区分展示数据源是哪个
    UserScript *model = nil;
    if (self.searchController.active ) {
        model = _results[indexPath.row];
    } else {
        model = _datas[indexPath.row];
    }
    
    UIColor *bgColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return [UIColor whiteColor];
            }
            else {
                return [UIColor blackColor];
            }
        }];
    
    cell.contentView.backgroundColor = bgColor;
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, kScreenWidth / 3 * 2, 21)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.lineBreakMode= NSLineBreakByTruncatingTail;
    titleLabel.text = model.name;
    [titleLabel sizeToFit];
    [cell.contentView addSubview:titleLabel];
    
    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, kScreenWidth / 2, 21)];
    versionLabel.font = [UIFont boldSystemFontOfSize:18];
    versionLabel.textAlignment = NSTextAlignmentLeft;
    versionLabel.text = model.version;
    versionLabel.textColor = RGB(182, 32, 224);
    versionLabel.left = titleLabel.right + 5;
    versionLabel.centerY = titleLabel.centerY;
    [cell.contentView addSubview:versionLabel];

    UILabel *authorLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, kScreenWidth, 19)];
    authorLabel.font = [UIFont systemFontOfSize:16];
    authorLabel.textAlignment = NSTextAlignmentLeft;
    authorLabel.text = model.author;
    authorLabel.top = titleLabel.bottom + 10;
    [authorLabel sizeToFit];
    [cell.contentView addSubview:authorLabel];
    
    UILabel *descLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, kScreenWidth - 30, 19)];
    descLabel.font = [UIFont systemFontOfSize:15];
    descLabel.textAlignment = NSTextAlignmentLeft;
    descLabel.lineBreakMode= NSLineBreakByTruncatingTail;
    descLabel.text = model.desc;
    descLabel.top = authorLabel.bottom + 5;
    descLabel.textColor = [UIColor grayColor];
    [cell.contentView addSubview:descLabel];
    
    UILabel *actLabel = [[UILabel alloc]init];
    actLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightLight];
    actLabel.textColor = RGB(138, 138, 138);
    if(model.active == 0) {
        actLabel.text = @"Stopped";
    } else {
        actLabel.text = @"Activated";
    }
    [actLabel sizeToFit];
    actLabel.right = kScreenWidth - 35;
    actLabel.centerY = 47.5f;

    [cell.contentView addSubview:actLabel];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15,94,kScreenWidth - 10,1)];
    UIColor *lineBgcolor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return RGBA(216, 216, 216, 0.3);
            }
            else {
                return RGBA(37, 37, 40, 1);
            }
        }];
    [line setBackgroundColor:lineBgcolor];
    [cell.contentView addSubview:line];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.searchController.active) {
        UserScript *model = _results[indexPath.row];
        SYDetailViewController *cer = [[SYDetailViewController alloc] init];
        cer.isSearch = false;
        cer.script = model;
        [self.navigationController pushViewController:cer animated:true];
    } else {
        UserScript *model = _datas[indexPath.row];
        SYDetailViewController *cer = [[SYDetailViewController alloc] init];
        cer.script = model;
        cer.isSearch = false;
        [self.navigationController pushViewController:cer animated:true];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 95.0f;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    //Fixed retains self
    __weak SYHomeViewController *weakSelf = self;
    if (self.searchController.active) {
        UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            UserScript *model = weakSelf.results[indexPath.row];

            [[DataManager shareManager] deleteScriptInUserScriptByNumberId: model.uuid];
            [[DataManager shareManager]  updateLibScrpitStatus:0 numberId:model.uuid];
            [tableView setEditing:NO animated:YES];
            [self reloadTableView];
            [tableView reloadData];
            [self initScrpitContent];
        }];
        deleteAction.image = [UIImage imageNamed:@"delete"];
        deleteAction.backgroundColor = RGB(224, 32, 32);
        return [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];

    } else {
        UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            UserScript *model = weakSelf.datas[indexPath.row];
            [[DataManager shareManager] deleteScriptInUserScriptByNumberId: model.uuid];
            [[DataManager shareManager]  updateLibScrpitStatus:0 numberId:model.uuid];

            [tableView setEditing:NO animated:YES];
            [self reloadTableView];
            [tableView reloadData];
            [self initScrpitContent];

        }];
        deleteAction.image = [UIImage imageNamed:@"delete"];
        deleteAction.backgroundColor = RGB(224, 32, 32);
        
        UIContextualAction *stopAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            UserScript *model = weakSelf.datas[indexPath.row];
                if (model.active == 1) {
                    [[DataManager shareManager] updateScrpitStatus:0 numberId:model.uuid];
                } else if (model.active == 0) {
                    [[DataManager shareManager] updateScrpitStatus:1 numberId:model.uuid];
                }
                [tableView setEditing:NO animated:YES];
                [weakSelf reloadTableView];
                [weakSelf initScrpitContent];
                [tableView reloadData];
                [[DataManager shareManager]  updateLibScrpitStatus:1 numberId:model.uuid];
        }];
        UserScript *model = _datas[indexPath.row];
        if (model.active) {
            stopAction.image = [UIImage imageNamed:@"stop"];
            stopAction.backgroundColor = RGB(182, 32, 224);
        } else {
            stopAction.image = [UIImage imageNamed:@"play"];
            stopAction.backgroundColor = RGB(182, 32, 224);;
        }
        
        return [UISwipeActionsConfiguration configurationWithActions:@[deleteAction,stopAction]];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)addBtnClick:(id)sender {
    SYEditViewController *cer = [[SYEditViewController alloc] init];
    [self.navigationController pushViewController:cer animated:true];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadTableView];
    [self.tableView reloadData];
    [self initScrpitContent];
}


- (void) reloadTableView {
    [_datas removeAllObjects];
    [_datas addObjectsFromArray:[[DataManager shareManager] findScript:1]];
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_tableView];
    }
    
    return _tableView;
}

- (NSMutableArray *)datas {
    if (_datas == nil) {
        _datas = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _datas;
}

- (NSMutableArray *)results {
    if (_results == nil) {
        _results = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _results;
}

- (UIBarButtonItem *)leftIcon{
    if (nil == _leftIcon){
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon"]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        _leftIcon = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    }
    return _leftIcon;
}

- (UIBarButtonItem *)rightIcon {
    if (nil == _rightIcon){
        _rightIcon = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addBtnClick:)];
    }
    return _rightIcon;
}

@end
