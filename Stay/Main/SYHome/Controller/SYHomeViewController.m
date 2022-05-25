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
#import "UserscriptUpdateManager.h"
#import "SYAddScriptController.h"
#import "SYWebScriptViewController.h"
#import "ScriptMananger.h"
#import "ScriptEntity.h"
#import <objc/runtime.h>
#import "UIImageView+WebCache.h"

#import <UniformTypeIdentifiers/UTCoreTypes.h>

@interface SYHomeViewController ()<
 UITableViewDelegate,
 UITableViewDataSource,
 UISearchResultsUpdating,
 UISearchBarDelegate,
 UISearchControllerDelegate,
 UIPopoverPresentationControllerDelegate,
 UIDocumentPickerDelegate
>

@property (nonatomic, strong) UIBarButtonItem *leftIcon;
@property (nonatomic, strong) UIBarButtonItem *rightIcon;

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) UITableView *tableView;
// 数据源数组
@property (nonatomic, strong) NSMutableArray *datas;
// 搜索结果数组
@property (nonatomic, strong) NSMutableArray *results;

@property (strong, nonatomic) SYAddScriptController *itemPopVC;

@property (nonatomic, strong) UIView *loadingView;


@end

@implementation SYHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [ScriptMananger shareManager];
    self.loadingView.center = self.view.center;
    self.loadingView.hidden = YES;
//    [SYCodeMirrorView shareCodeView];
    self.navigationItem.leftBarButtonItem = [self leftIcon];
    self.navigationItem.rightBarButtonItem = [self rightIcon];
    self.view.backgroundColor = DynamicColor(RGB(28, 28, 28),[UIColor whiteColor]);;
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
    
    [self.view addSubview:self.loadingView];
    
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableDidSelected:) name:@"addScriptClick" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarChange) name:@"needUpdate" object:nil];
}

- (void)tableDidSelected:(NSNotification *)notification {
    NSIndexPath *indexpath = (NSIndexPath *)notification.object;
    if(indexpath.row == 0) {
        SYEditViewController *cer = [[SYEditViewController alloc] init];
        [self.navigationController pushViewController:cer animated:true];
        [self.itemPopVC dismissViewControllerAnimated:YES completion:nil];
        self.itemPopVC = nil;
    } else if(indexpath.row == 1) {
        [self.itemPopVC dismissViewControllerAnimated:YES completion:nil];
        self.itemPopVC = nil;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"从链接新增脚本" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *conform = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UITextField *titleTextField = alert.textFields.firstObject;
            NSString *url = titleTextField.text;
            self.loadingView.hidden = false;
            [self.view bringSubviewToFront:self.loadingView];
            if(url != nil && url.length > 0) {
                dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT),^{
                    NSMutableCharacterSet *set  = [[NSCharacterSet URLFragmentAllowedCharacterSet] mutableCopy];
                     [set addCharactersInString:@"#"];
                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[url stringByAddingPercentEncodingWithAllowedCharacters:set]]];
                                        
                    dispatch_async(dispatch_get_main_queue(),^{
                        if(data != nil ) {
                            NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                            SYEditViewController *cer = [[SYEditViewController alloc] init];
                            cer.content = str;
                            cer.downloadUrl = url;
                            [self.navigationController pushViewController:cer animated:true];
                        }else {
                            NSString *content = @"下载脚本失败";
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:content preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction *conform = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                    NSLog(@"点击了确认按钮");
                                }];
                            [alert addAction:conform];
                            [self presentViewController:alert animated:YES completion:nil];
                        }
                        self.loadingView.hidden = true;
                    });
                });
            }
        }];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
              textField.placeholder = @"请输入链接";
          }];
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];

        [alert addAction:cancle];
        [alert addAction:conform];
        [self presentViewController:alert animated:YES completion:nil];
    } else if (indexpath.row == 2) {
        SYWebScriptViewController *cer = [[SYWebScriptViewController alloc] init];
        [self.navigationController pushViewController:cer animated:true];
        [self.itemPopVC dismissViewControllerAnimated:YES completion:nil];
        self.itemPopVC = nil;
    }
    else if (indexpath.row == 3) {
        [self.itemPopVC dismissViewControllerAnimated:YES completion:nil];
        self.itemPopVC = nil;
        UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initForOpeningContentTypes:@[UTTypeItem] asCopy:YES];
        documentPicker.delegate = self;
        [self presentViewController:documentPicker animated:YES completion:nil];
    }
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray <NSURL *>*)urls{
    if (urls.count > 0){
        NSURL *url = urls[0];
        SYEditViewController *cer = [[SYEditViewController alloc] init];
        NSError *error = nil;
        cer.content = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
        if (!error){
            [self.navigationController pushViewController:cer animated:true];
        }
        else{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                           message:NSLocalizedString(@"unsupportedFileFormat", @"")
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *confirm = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"")
                                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alert addAction:confirm];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
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
- (void)statusBarChange{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tableView.frame = self.view.bounds;
        [self.tableView reloadData];
    });

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
    //自动更新代码保留先注释
    NSArray *array = [[DataManager shareManager] findScript:1];
    [self updateScriptWhen:array type:false];
}

- (void)updateScriptWhen:(NSArray *)array type:(bool)isSearch {
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
                                    [[DataManager shareManager] updateUserScript:userScript];
                                    [self refreshScript];
                                    
                                }
                            } else {
                                [[SYNetworkUtils shareInstance] requestGET:scrpit.downloadUrl params:nil successBlock:^(NSString * _Nonnull responseObject) {
                                    if(responseObject != nil) {
                                        UserScript *userScript = [[Tampermonkey shared] parseWithScriptContent:responseObject];
                                        userScript.uuid = scrpit.uuid;
                                        userScript.active = scrpit.active;
                                        if(userScript != nil && userScript.errorMessage != nil && userScript.errorMessage.length <= 0) {
                                            [[DataManager shareManager] updateUserScript:userScript];
                                            [self refreshScript];
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
        } else if(scrpit.downloadUrl != NULL && scrpit.downloadUrl.length > 0) {
            [[SYNetworkUtils shareInstance] requestGET:scrpit.downloadUrl params:nil successBlock:^(NSString * _Nonnull responseObject) {
                if(responseObject != nil) {
                    UserScript *userScript = [[Tampermonkey shared] parseWithScriptContent:responseObject];
                    if(userScript.version != NULL) {
                        NSInteger status = [SYVersionUtils compareVersion:userScript.version toVersion:scrpit.version];
                        if(status == 1) {
                            userScript.uuid = scrpit.uuid;
                            userScript.active = scrpit.active;
                            if(userScript != nil && userScript.errorMessage != nil && userScript.errorMessage.length <= 0) {
                                [[DataManager shareManager] updateUserScript:userScript];
                                [self refreshScript];
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
#pragma mark -popover
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller{
    return UIModalPresentationNone;
}

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController{
    return YES;   //点击蒙版popover不消失， 默认yes
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
    cell.backgroundColor = DynamicColor(RGB(28, 28, 28),[UIColor whiteColor]);
    cell.contentView.backgroundColor = DynamicColor(RGB(28, 28, 28),[UIColor whiteColor]);
    
    CGFloat leftWidth = kScreenWidth * 0.6 - 15;
        
    CGFloat titleLabelLeftSize = 0;
    if(model.icon != NULL && model.icon.length > 0) {
        if([model.icon containsString:@"base64"]) {
            NSString *icon = [model.icon stringByReplacingOccurrencesOfString:@"data:image/png;base64," withString:@""];
            NSData* data = [[NSData alloc] initWithBase64EncodedString:icon options:0];
            UIImage* image = [UIImage imageWithData:data];
            UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
            imageview.frame = CGRectMake(15,15,23,23);
            [cell.contentView addSubview:imageview];
        } else {
            UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(15,15,23,23)] ;
            [imageview sd_setImageWithURL:[NSURL URLWithString: model.icon] ];
            [cell.contentView addSubview:imageview];

        }
        
        titleLabelLeftSize = 27;
    }
    
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15 + titleLabelLeftSize , 15, leftWidth - titleLabelLeftSize, 45)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.lineBreakMode= NSLineBreakByTruncatingTail;
    titleLabel.numberOfLines = 2;
    titleLabel.text = model.name;
    [titleLabel sizeToFit];
    [cell.contentView addSubview:titleLabel];

    
    UILabel *descLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, leftWidth, 40)];
    descLabel.font = [UIFont systemFontOfSize:15];
    descLabel.textAlignment = NSTextAlignmentLeft;
    descLabel.lineBreakMode= NSLineBreakByTruncatingTail;
    descLabel.text = model.desc;
    descLabel.numberOfLines = 2;
    descLabel.bottom = 125;
    descLabel.textColor = [UIColor grayColor];
    [cell.contentView addSubview:descLabel];
    
    UILabel *authorLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, leftWidth , 19)];
    authorLabel.font = [UIFont systemFontOfSize:16];
    authorLabel.textAlignment = NSTextAlignmentLeft;
    authorLabel.text = model.author;
    authorLabel.bottom = descLabel.top - 5;
    [authorLabel sizeToFit];
    [cell.contentView addSubview:authorLabel];
    
    UIView *verticalLine = [[UIView alloc] initWithFrame:CGRectMake(0.62 * kScreenWidth, 14, 1, 113)];
    verticalLine.backgroundColor =  [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
        if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
            return RGBA(216, 216, 216, 0.3);
        }
        else {
            return RGBA(37, 37, 40, 1);
        }
    }];
    [cell.contentView addSubview:verticalLine];
    
    CGFloat left = 0.65 * kScreenWidth;
    CGFloat width = 0.3 * kScreenWidth;
    UILabel *version= [[UILabel alloc] initWithFrame:CGRectMake(left, 14,  width, 15)];
    version.text = @"version";
    version.font = [UIFont systemFontOfSize:12];
    version.textColor = RGB(138, 138, 138);
    [cell.contentView addSubview:version];

    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, kScreenWidth / 2, 21)];
    versionLabel.font = [UIFont boldSystemFontOfSize:15];
    versionLabel.textAlignment = NSTextAlignmentLeft;
    versionLabel.text = model.version;
    versionLabel.left = left;
    versionLabel.top = version.bottom + 2;
    [cell.contentView addSubview:versionLabel];
    
    UILabel *statusLab= [[UILabel alloc] initWithFrame:CGRectMake(left, 14,  width, 15)];
    statusLab.text = @"status";
    statusLab.font = [UIFont systemFontOfSize:12];
    statusLab.textColor = RGB(138, 138, 138);
    statusLab.top = versionLabel.bottom + 2;
    statusLab.left = left;
    [cell.contentView addSubview:statusLab];


    UILabel *actLabel = [[UILabel alloc]init];
    actLabel.font = [UIFont boldSystemFontOfSize:15];
    if(model.active == 0) {
        actLabel.text = @"Stopped";
    } else {
        actLabel.text = @"Activated";
    }
    [actLabel sizeToFit];
    actLabel.top = statusLab.bottom + 2;
    actLabel.left = left;
    [cell.contentView addSubview:actLabel];
    
    
    UILabel *updateLab= [[UILabel alloc] initWithFrame:CGRectMake(left, 14,  width, 15)];
    updateLab.text = @"Update time";
    updateLab.font = [UIFont systemFontOfSize:12];
    updateLab.textColor = RGB(138, 138, 138);
    updateLab.top = actLabel.bottom + 2;
    updateLab.left = left;
    [cell.contentView addSubview:updateLab];
    
    ScriptEntity *entity = [ScriptMananger shareManager].scriptDic[model.uuid];

    if(entity != nil && entity.needUpdate){

        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 60, 20);
        btn.backgroundColor = RGB(182,32,224);
        [btn setTitle:NSLocalizedString(@"settings.update","update") forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        btn.layer.cornerRadius = 4;
        btn.top = updateLab.bottom + 2;
        btn.left = left;
        [btn addTarget:self action:@selector(updateScript:) forControlEvents:UIControlEventTouchUpInside];
        
        objc_setAssociatedObject (btn , @"script", entity.updateScript.description, OBJC_ASSOCIATION_COPY_NONATOMIC);
        objc_setAssociatedObject (btn , @"scriptContent", entity.updateScript.content, OBJC_ASSOCIATION_COPY_NONATOMIC);
        objc_setAssociatedObject (btn , @"downloadUrl", entity.script.downloadUrl, OBJC_ASSOCIATION_COPY_NONATOMIC);

        [cell.contentView addSubview:btn];
    } else {
        UILabel *updateLabel = [[UILabel alloc]init];
        updateLabel.font = [UIFont boldSystemFontOfSize:15];
        updateLabel.text = [self timeWithTimeIntervalString:model.updateTime];
        [updateLabel sizeToFit];
        updateLabel.top = updateLab.bottom + 2;
        updateLabel.left = left;
        [cell.contentView addSubview:updateLabel];
    }
    
    
    
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15,143,kScreenWidth - 10,1)];
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
    return 144.0f;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    //Fixed retains self
    __weak SYHomeViewController *weakSelf = self;
    if (self.searchController.active) {
        UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            UserScript *model = weakSelf.results[indexPath.row];

            [[DataManager shareManager] deleteScriptInUserScriptByNumberId: model.uuid];
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
    self.itemPopVC = [[SYAddScriptController alloc] init];
    self.itemPopVC.modalPresentationStyle = UIModalPresentationPopover;
    self.itemPopVC.preferredContentSize = self.itemPopVC.view.bounds.size;
    self.itemPopVC.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;  //rect参数是以view的左上角为坐标原点（0，0）
    self.itemPopVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp; //箭头方向,如果是baritem不设置方向，会默认up，up的效果也是最理想的
    self.itemPopVC.popoverPresentationController.delegate = self;
    [self presentViewController:self.itemPopVC animated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadTableView];
    [self initScrpitContent];
    [[ScriptMananger shareManager] buildData];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tableView.frame = self.view.bounds;
        [self.tableView reloadData];
    });
    
}


- (void)updateScript:(UIButton *)sender {
    NSString *script = objc_getAssociatedObject(sender,@"script");
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:script preferredStyle:UIAlertControllerStyleAlert];
    
    NSString *scriptContent = objc_getAssociatedObject(sender,@"scriptContent");

    NSString *downloadUrl = objc_getAssociatedObject(sender,@"downloadUrl");

    UIAlertAction *conform = [UIAlertAction actionWithTitle:NSLocalizedString(@"settings.update","update") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            SYEditViewController *cer = [[SYEditViewController alloc] init];
            cer.content = scriptContent;
            cer.downloadUrl = downloadUrl;
            [self.navigationController pushViewController:cer animated:true];
        }];
    UIAlertAction *cancelconform = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel","Cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
        }];
    
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
       paraStyle.alignment = NSTextAlignmentLeft;

       NSMutableAttributedString *atrStr = [[NSMutableAttributedString alloc] initWithString:script attributes:@{NSParagraphStyleAttributeName:paraStyle,NSFontAttributeName:[UIFont systemFontOfSize:13.0]}];

    [alert setValue:atrStr forKey:@"attributedMessage"];
    [alert addAction:cancelconform];
    [alert addAction:conform];
    [self presentViewController:alert animated:YES completion:nil];

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
        _tableView.backgroundColor = DynamicColor(RGB(28, 28, 28),[UIColor whiteColor]);
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

- (UIView *)loadingView {
    if(_loadingView == nil) {
        _loadingView = [[UIView alloc] initWithFrame:CGRectMake(50, 0, kScreenWidth - 100, 80)];
        [_loadingView setBackgroundColor:RGB(230, 230, 230)];
        _loadingView.layer.cornerRadius = 10;
        _loadingView.layer.masksToBounds = 10;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = NSLocalizedString(@"settings.downloadScript","download script");
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.textColor = [UIColor blackColor];
        [titleLabel sizeToFit];

        titleLabel.top = 30;
        titleLabel.centerX = (kScreenWidth - 100) / 2;
        [_loadingView addSubview:titleLabel];
    }
    return _loadingView;
}

- (NSString *)timeWithTimeIntervalString:(NSString *)timeString
{
    
    if(timeString == NULL || [timeString doubleValue] < 20) {
        timeString = [self getNowDate];
    }
  // 格式化时间
  NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
  formatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
  [formatter setDateStyle:NSDateFormatterMediumStyle];
  [formatter setTimeStyle:NSDateFormatterShortStyle];
  [formatter setDateFormat:@"yyyy.MM.dd"];
  
  // 毫秒值转化为秒
  NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeString doubleValue]/ 1000.0];
  NSString* dateString = [formatter stringFromDate:date];
  return dateString;
}

- (NSString *)getNowDate {
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[date timeIntervalSince1970]*1000; // *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeString = [NSString stringWithFormat:@"%.0f", a];
    return timeString;
}

@end
