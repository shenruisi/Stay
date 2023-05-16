//
//  AdBlockViewController.m
//  Stay
//
//  Created by ris on 2023/3/14.
//

#import "AdBlockViewController.h"
#import "ImageHelper.h"
#import "FCStyle.h"
#import "ContentFilterTableVewCell.h"
#import "FilterTokenParser.h"
#import "ContentFilter2.h"
#import "DataManager.h"
#import "AdBlockDetailViewController.h"
#import <SafariServices/SafariServices.h>
#import "FCStore.h"
#import "UpgradeSlideController.h"
#import "ContentFilterManager.h"
#import "UIColor+Convert.h"
#import "ImageHelper.h"
#import "SharedStorageManager.h"
#import "DeviceHelper.h"
#import "QuickAccess.h"
#import "TrustedSite.h"
#import "TrustedSitesTableViewCell.h"
#import "TrustedSitesTableViewHeadCell.h"
#import "AddTrustedSiteSlideController.h"
#import "AddTrustedSiteModalViewController.h"
#import "UIColor+Convert.h"
#import <WebKit/WebKit.h>

@interface AdBlockViewController ()<
 UITableViewDelegate,
 UITableViewDataSource
>

@property (nonatomic, strong) UIBarButtonItem *addItem;
@property (nonatomic, strong) FCTabButtonItem *activatedTabItem;
@property (nonatomic, strong) FCTabButtonItem *stoppedTabItem;
@property (nonatomic, strong) FCTabButtonItem *trustedSitesTabItem;
@property (nonatomic, strong) FCTabButtonItem *sharedRulesTabItem;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITableView *trustedSitesTableView;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) NSMutableArray<ContentFilter *> *activatedSource;
@property (nonatomic, strong) NSMutableArray<ContentFilter *> *stoppedSource;
@property (nonatomic, strong) NSMutableArray<TrustedSite *> *trustedSitesSource;
@property (nonatomic, strong) NSArray<ContentFilter *> *selectedDataSource;
@property (nonatomic, strong) UpgradeSlideController *upgradeSlideController;
@property (nonatomic, strong) FCTableViewHeadMenuItem *trustedSiteMenuItem;

@property (nonatomic, strong) AddTrustedSiteSlideController *addTrustedSiteSlideController;
@end

@implementation AdBlockViewController

- (instancetype)init{
    if (self = [super init]){
        [self setupDataSource];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            for (ContentFilter *contentFilter in self.activatedSource){
                if (contentFilter.type != ContentFilterTypeCustom
                    && contentFilter.type != ContentFilterTypeTag){
                    if (![[ContentFilterManager shared] existRuleJSON:contentFilter.rulePath]){
                        [contentFilter reloadContentBlockerWithCompletion:^(NSError * _Nonnull error) {
                            NSLog(@"init load content %@ %@",contentFilter.title,error);
                        }];
                    }
                }
            }
            
            for (ContentFilter *contentFilter in self.stoppedSource){
                if (contentFilter.type != ContentFilterTypeCustom
                    && contentFilter.type != ContentFilterTypeTag){
                    if (![[ContentFilterManager shared] existRuleJSON:contentFilter.rulePath]){
                        [contentFilter reloadContentBlockerWithCompletion:^(NSError * _Nonnull error) {
                            NSLog(@"init load content %@ %@",contentFilter.title,error);
                        }];
                    }
                }
            }
        });
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.leftTitle = NSLocalizedString(@"AdBlock", @"");
    self.enableTabItem = YES;
    self.navigationTabItem.leftTabButtonItems = @[self.activatedTabItem,
                                                  self.stoppedTabItem,
                                                  self.trustedSitesTabItem,
                                                  self.sharedRulesTabItem
    ];
    [self tableView];
    
    [self.navigationTabItem activeItem:self.activatedTabItem];
    
#ifdef FC_MAC
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onBecomeActive:)
                                                 name:SVCDidBecomeActiveNotification
                                               object:nil];
#else
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
#endif
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentFilterDidUpdateHandler:) name:ContentFilterDidUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trustedSiteDidAddHandler:) name:TrustedSiteDidAddNotification object:nil];
}

- (void)trustedSiteDidAddHandler:(NSNotification *)note{
    if (_trustedSitesTableView){
        self.trustedSitesSource = nil;
        [self.trustedSitesTableView reloadData];
    }
    
    [self startHeadLoading];
    NSUInteger totalReload = self.activatedSource.count;
    __block NSUInteger completionCount = 0;
    for (ContentFilter *contentFilter in  self.activatedSource){
        [contentFilter reloadContentBlockerWithCompletion:^(NSError * _Nonnull error) {
            completionCount++;
            if (completionCount == totalReload){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self stopHeadLoading];
                });
            }
        }];
    }
    
}

- (void)onBecomeActive:(NSNotification *)note{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (ContentFilter *contentFilter in self.activatedSource){
            dispatch_time_t deadline = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            
            [SFContentBlockerManager getStateOfContentBlockerWithIdentifier:contentFilter.contentBlockerIdentifier completionHandler:^(SFContentBlockerState * _Nullable state, NSError * _Nullable error) {
                if (state.enabled){
                    contentFilter.enable = 1;
                    [[DataManager shareManager] updateContentFilterEnable:1 uuid:contentFilter.uuid];
                    if (0 == contentFilter.load){
                        [SFContentBlockerManager reloadContentBlockerWithIdentifier:contentFilter.contentBlockerIdentifier completionHandler:^(NSError * _Nullable error) {
                            if (nil == error){
                                contentFilter.load = 1;
                                [[DataManager shareManager] updateContentFilterLoad:1 uuid:contentFilter.uuid];
                                NSLog(@"load content %@ successful",contentFilter.title);
                            }
                            else{
                                NSLog(@"load content %@ failure",contentFilter.title);
                            }
                        }];
                    }
                }
                else{
                    contentFilter.enable = 0;
                    [[DataManager shareManager] updateContentFilterEnable:0 uuid:contentFilter.uuid];
                }
                [contentFilter checkUpdatingIfNeeded:NO completion:nil];
                dispatch_semaphore_signal(semaphore);
            }];
            
            dispatch_semaphore_wait(semaphore, deadline);
        }
        
        for (ContentFilter *contentFilter in self.stoppedSource){
            dispatch_time_t deadline = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            
            [SFContentBlockerManager getStateOfContentBlockerWithIdentifier:contentFilter.contentBlockerIdentifier completionHandler:^(SFContentBlockerState * _Nullable state, NSError * _Nullable error) {
                if (state.enabled){
                    contentFilter.enable = 1;
                    [[DataManager shareManager] updateContentFilterEnable:1 uuid:contentFilter.uuid];
                }
                else{
                    contentFilter.enable = 0;
                    [[DataManager shareManager] updateContentFilterEnable:0 uuid:contentFilter.uuid];
                }
                dispatch_semaphore_signal(semaphore);
            }];
            
            dispatch_semaphore_wait(semaphore, deadline);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            NSLog(@"SFContentBlockerState reload");
        });
    });
}

- (void)contentFilterDidUpdateHandler:(NSNotification *)note{
    [self.tableView reloadData];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.upgradeSlideController){
        [self.upgradeSlideController dismiss];
    }
}
    

- (void)setupDataSource{
    NSArray<ContentFilter *> *contentFilters = [[DataManager shareManager] selectContentFilters];
    for (ContentFilter *contentFilter in contentFilters){
        if (contentFilter.active){
            [self.activatedSource addObject:contentFilter];
        }
        else{
            [self.stoppedSource addObject:contentFilter];
        }
    }
    
    [self trustedSitesSource];
}


- (NSMutableArray<TrustedSite *> *)trustedSitesSource{
    if (nil == _trustedSitesSource){
        _trustedSitesSource = [[NSMutableArray alloc] initWithArray:[[ContentFilterManager shared] trustedSites]];
    }
    
    return _trustedSitesSource;
}

- (void)updateStatus:(ContentFilter *)contentFilter{
    if (contentFilter.active){
        contentFilter.status = 0;
        if (ContentFilterTypeTag == contentFilter.type){
            [SharedStorageManager shared].extensionConfig.tagStatus = @(contentFilter.status);
        }
        [[DataManager shareManager] updateContentFilterStatus:0 uuid:contentFilter.uuid];
        [[ContentFilterManager shared] updateRuleJSON:contentFilter.rulePath status:0];
        [contentFilter reloadContentBlockerWihtoutRebuild];
    }
    else{
        contentFilter.status = 1;
        if (ContentFilterTypeTag == contentFilter.type){
            [SharedStorageManager shared].extensionConfig.tagStatus = @(contentFilter.status);
        }
        [[DataManager shareManager] updateContentFilterStatus:1 uuid:contentFilter.uuid];
        [[ContentFilterManager shared] updateRuleJSON:contentFilter.rulePath status:1];
        [contentFilter reloadContentBlockerWihtoutRebuild];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_tableView == tableView){
        ContentFilter *contentFilter = self.selectedDataSource[indexPath.row];
        ContentFilterTableVewCell<ContentFilter *> *cell = [tableView dequeueReusableCellWithIdentifier:[ContentFilterTableVewCell identifier]];
        if (nil == cell){
            cell = [[ContentFilterTableVewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        }
        cell.cer = self;
        cell.element = contentFilter;
        cell.tapAction = ^(id element) {
            ContentFilter *contentFilter = (ContentFilter *)element;
            if (contentFilter.type == ContentFilterTypeCustom
                ||contentFilter.type == ContentFilterTypeTag){
                if ([[FCStore shared] getPlan:NO] == FCPlan.None){
                    if (self.upgradeSlideController){
                        [self.upgradeSlideController dismiss];
                    }
                    
                    self.upgradeSlideController = [[UpgradeSlideController alloc] initWithMessage:[NSString stringWithFormat:NSLocalizedString(@"UpgradeMessage", @""),contentFilter.title]];
                    [self.upgradeSlideController show];
                    return;
                }
            }
            
            AdBlockDetailViewController *cer = [[AdBlockDetailViewController alloc] init];
            cer.contentFilter = contentFilter;
            if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
                && self.splitViewController.viewControllers.count >= 2){
                [[QuickAccess secondaryController] pushViewController:cer];
            }
            else{
                [self.navigationController pushViewController:cer animated:YES];
            }
            
           
        };
        
        __weak AdBlockViewController *weakSelf = (AdBlockViewController *)self;
        cell.doubleTapAction = ^(id element) {
            ContentFilter *contentFilter = (ContentFilter *)element;
            [weakSelf updateStatus:contentFilter];
        };
        
        return cell;
    }
    else if (_trustedSitesTableView == tableView){
        if (0 == indexPath.row){
            TrustedSitesTableViewHeadCell *cell = [[TrustedSitesTableViewHeadCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.menus = @[self.trustedSiteMenuItem];
            return cell;
        }
        else{
            TrustedSitesTableViewCell<TrustedSite *> *cell = [tableView dequeueReusableCellWithIdentifier:[TrustedSitesTableViewCell identifier]];
            if (nil == cell){
                cell = [[TrustedSitesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            }
            
            cell.element = self.trustedSitesSource[indexPath.row - 1];
            return cell;
        }
        
    }
    else{
        return [[UITableViewCell alloc] init];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_tableView == tableView){
        ContentFilter *contentFilter = self.selectedDataSource[indexPath.row];
        return (contentFilter.enable ? 70 : 90) + [ContentFilterTableVewCell contentInset].top + [ContentFilterTableVewCell contentInset].bottom;
    }
    else if (_trustedSitesTableView == tableView){
        if (0 == indexPath.row){
            return 40 + [ContentFilterTableVewCell contentInset].top + [ContentFilterTableVewCell contentInset].bottom;
        }
        else{
            return 45 + [ContentFilterTableVewCell contentInset].top + [ContentFilterTableVewCell contentInset].bottom;
        }
    }
    else{
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_tableView == tableView){
        return self.selectedDataSource.count;
    }
    else if (_trustedSitesTableView == tableView){
        return self.trustedSitesSource.count + 1;
    }
    else{
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    for (UIView *view in tableView.subviews){
        if ([view isKindOfClass:NSClassFromString(@"_UITableViewCellSwipeContainerView")]){
            for (UIView *pullView in view.subviews){
                if ([pullView isKindOfClass:NSClassFromString(@"UISwipeActionPullView")]) {
                    for (UIView *buttonView in pullView.subviews){
                        if ([buttonView isKindOfClass:NSClassFromString(@"UISwipeActionStandardButton")]) {
                            for (UIView *targetView in buttonView.subviews){
                                if (![targetView isKindOfClass:NSClassFromString(@"UIButtonLabel")]){
                                    targetView.backgroundColor = [[FCStyle.accent colorWithAlphaComponent:0.1] rgba2rgb:FCStyle.secondaryBackground];
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_tableView == tableView){
        BOOL isActivatedSelected = self.selectedDataSource == self.activatedSource;
        ContentFilter *contentFilter = self.selectedDataSource[indexPath.row];
        FCTableViewCell *cell = (FCTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        NSMutableArray *actions = [[NSMutableArray alloc] init];
        UIContextualAction *reloadAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"AdBlock", @"")
                                                                           message:NSLocalizedString(@"ReloadRulesMessage", @"")
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *confirm = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"")
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * _Nonnull action) {
                [self startHeadLoading];
                [contentFilter reloadContentBlockerWithCompletion:^(NSError * error) {
                    [self stopHeadLoading];
                    NSLog(@"reloadContentBlockerWithCompletion %@",error);
                }];
                completionHandler(YES);
            }];
            [alert addAction:confirm];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"")
                 style:UIAlertActionStyleCancel
                 handler:^(UIAlertAction * _Nonnull action) {
                completionHandler(YES);
             }];
             [alert addAction:cancel];
            [self presentViewController:alert animated:YES completion:nil];
            
        }];
        reloadAction.image = [ImageHelper sfNamed:@"arrow.triangle.2.circlepath" font:FCStyle.headline color:FCStyle.accent];
        reloadAction.backgroundColor = [[FCStyle.accent colorWithAlphaComponent:0.1] rgba2rgb:FCStyle.secondaryBackground];
        if (isActivatedSelected){
            [actions addObject:reloadAction];
        }
        
        UIContextualAction *activeOrStopAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            [cell doubleTap:cell.fcContentView.center];
            completionHandler(YES);
        }];
        activeOrStopAction.image = [ImageHelper sfNamed: isActivatedSelected ? @"stop.fill" : @"play.fill" font:FCStyle.headline color:FCStyle.accent];
        activeOrStopAction.backgroundColor = [[FCStyle.accent colorWithAlphaComponent:0.1] rgba2rgb:FCStyle.secondaryBackground];
        [actions addObject:activeOrStopAction];
        
        UISwipeActionsConfiguration *configuration = [UISwipeActionsConfiguration configurationWithActions:actions];
        
        return configuration;
    }
    else if (_trustedSitesTableView == tableView){
        if (0 == indexPath.row){
            return nil;
        }
        else{
            TrustedSite *site = self.trustedSitesSource[indexPath.row - 1];
            NSMutableArray *actions = [[NSMutableArray alloc] init];
            UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"AdBlock",@"")
                                                                               message:NSLocalizedString(@"TrustedSiteDeleteAlert", @"")
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *confirm = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"")
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * _Nonnull action) {
                    [[ContentFilterManager shared] deleteTrustSiteWithDomain:site.domain];
                    [self trustedSiteDidAddHandler:nil];
                    completionHandler(YES);
                }];
                [alert addAction:confirm];
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"")
                     style:UIAlertActionStyleCancel
                     handler:^(UIAlertAction * _Nonnull action) {
                    completionHandler(YES);
                 }];
                 [alert addAction:cancel];
                [self presentViewController:alert animated:YES completion:nil];
                
            }];
            deleteAction.image = [ImageHelper sfNamed:@"trash" font:FCStyle.headline color:UIColor.redColor];
            deleteAction.backgroundColor = [[FCStyle.accent colorWithAlphaComponent:0.1] rgba2rgb:FCStyle.secondaryBackground];
            [actions addObject:deleteAction];
            
            UISwipeActionsConfiguration *configuration = [UISwipeActionsConfiguration configurationWithActions:actions];
            
            return configuration;
        }
    }
    else{
        return nil;
    }
    
}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        // 处理删除操作
//    }
//}
//
//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return UITableViewCellEditingStyleNone;
//}

- (UIBarButtonItem *)addItem{
    if (nil == _addItem){
        _addItem = [[UIBarButtonItem alloc] initWithImage:[ImageHelper sfNamed:@"plus"
                                                                           font:FCStyle.headline
                                                                          color:FCStyle.accent]
                                                     style:UIBarButtonItemStylePlain
                                                    target:self
                                                    action:@selector(addAction:)];
    }
    
    return _addItem;
}

- (FCTabButtonItem *)activatedTabItem{
    if (nil == _activatedTabItem){
        _activatedTabItem = [[FCTabButtonItem alloc] init];
        _activatedTabItem.title = NSLocalizedString(@"Activated", @"");
    }
    
    return _activatedTabItem;
}

- (FCTabButtonItem *)stoppedTabItem{
    if (nil == _stoppedTabItem){
        _stoppedTabItem = [[FCTabButtonItem alloc] init];
        _stoppedTabItem.title = NSLocalizedString(@"Stopped", @"");
    }
    
    return _stoppedTabItem;
}

- (FCTabButtonItem *)trustedSitesTabItem{
    if (nil == _trustedSitesTabItem){
        _trustedSitesTabItem = [[FCTabButtonItem alloc] init];
        _trustedSitesTabItem.title = NSLocalizedString(@"TrustedSites", @"");
    }
    
    return _trustedSitesTabItem;
}

- (FCTabButtonItem *)sharedRulesTabItem{
    if (nil == _sharedRulesTabItem){
        _sharedRulesTabItem = [[FCTabButtonItem alloc] init];
        _sharedRulesTabItem.title = NSLocalizedString(@"SharedRules", @"");
    }
    
    return _sharedRulesTabItem;
}

- (void)addAction:(id)sender{
    
}

//- (void)searchTabItemDidClick{
//        UISearchController *search = [[UISearchController alloc]initWithSearchResultsController:nil];
////        search.searchResultsUpdater = self;
//        search.searchBar.placeholder = NSLocalizedString(@"SearchAddedUserscripts", @"");
//        self.navigationItem.searchController = search;
////        self.navigationItem.searchController.delegate = self;
////        self.navigationItem.searchController.searchBar.delegate = self;
//        self.navigationItem.searchController.obscuresBackgroundDuringPresentation = false;
////        self.searchController = search;
////        self.searchController.delegate = self;
////        self.searchController.searchBar.delegate = self;
////        [self.searchController.searchBar setTintColor:FCStyle.accent];
//    search.active = YES;
//}

- (void)tabItemDidClick:(FCTabButtonItem *)item refresh:(BOOL)refresh{
    if (item == self.activatedTabItem || item == self.stoppedTabItem){
        NSMutableArray *newActivatedSource = [[NSMutableArray alloc] init];
        NSMutableArray *newStoppedSource = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < self.activatedSource.count; i++){
            ContentFilter *contentFilter = self.activatedSource[i];
            if (contentFilter.active){
                [newActivatedSource addObject:contentFilter];
            }
            else{
                [newStoppedSource addObject:contentFilter];
            }
        }
        
        for (int i = 0; i < self.stoppedSource.count; i++){
            ContentFilter *contentFilter = self.stoppedSource[i];
            if (contentFilter.active){
                [newActivatedSource addObject:contentFilter];
            }
            else{
                [newStoppedSource addObject:contentFilter];
            }
        }
        
        [newActivatedSource sortUsingComparator:^NSComparisonResult(ContentFilter *obj1, ContentFilter *obj2) {
            if (obj1.sort < obj2.sort) return NSOrderedAscending;
            else if (obj1.sort > obj2.sort) return NSOrderedDescending;
            return NSOrderedSame;
        }];
        
        [newStoppedSource sortUsingComparator:^NSComparisonResult(ContentFilter *obj1, ContentFilter *obj2) {
            if (obj1.sort < obj2.sort) return NSOrderedAscending;
            else if (obj1.sort > obj2.sort) return NSOrderedDescending;
            return NSOrderedSame;
        }];
        
        self.activatedSource = newActivatedSource;
        self.stoppedSource = newStoppedSource;
        
        if (item == self.activatedTabItem){
            self.selectedDataSource = self.activatedSource;
        }
        else if (item == self.stoppedTabItem){
            self.selectedDataSource = self.stoppedSource;
        }
        
        _trustedSitesTableView.hidden = YES;
        _webView.hidden = YES;
        self.tableView.hidden = NO;
        if (!refresh){
            [self.tableView reloadData];
        }
    }
    else if (item == self.trustedSitesTabItem){
        _tableView.hidden = YES;
        _webView.hidden = YES;
        self.trustedSitesTableView.hidden = NO;
        if (!refresh){
            [self.trustedSitesTableView reloadData];
        }
    }
    else if (item == self.sharedRulesTabItem){
        _tableView.hidden = YES;
        _trustedSitesTableView.hidden = YES;
        self.webView.hidden = NO;
        [self reloadSharedRules];
    }
}

- (NSMutableArray<ContentFilter *> *)activatedSource{
    if (nil == _activatedSource){
        _activatedSource = [[NSMutableArray alloc] init];
    }
    
    return _activatedSource;
}

- (NSMutableArray<ContentFilter *> *)stoppedSource{
    if (nil == _stoppedSource){
        _stoppedSource = [[NSMutableArray alloc] init];
    }
    
    return _stoppedSource;
}

- (UITableView *)tableView{
    if (nil == _tableView){
        _tableView = [[UITableView alloc] init];
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = YES;
        _tableView.keyboardDismissMode =  UIScrollViewKeyboardDismissModeOnDrag;
        //TODO:
        if (@available(iOS 15.0, *)){
           _tableView.sectionHeaderTopPadding = 0;
        }
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.sectionFooterHeight = 0;
        _tableView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_tableView];
        
        [NSLayoutConstraint activateConstraints:@[
            [_tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
            [_tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
            [_tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
            [_tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
        ]];
    }
    
    return _tableView;
}

- (UITableView *)trustedSitesTableView{
    if (nil == _trustedSitesTableView){
        _trustedSitesTableView = [[UITableView alloc] init];
        _trustedSitesTableView.translatesAutoresizingMaskIntoConstraints = NO;
        _trustedSitesTableView.delegate = self;
        _trustedSitesTableView.dataSource = self;
        _trustedSitesTableView.showsVerticalScrollIndicator = YES;
        _trustedSitesTableView.keyboardDismissMode =  UIScrollViewKeyboardDismissModeOnDrag;
        //TODO:
        if (@available(iOS 15.0, *)){
            _trustedSitesTableView.sectionHeaderTopPadding = 0;
        }
        _trustedSitesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _trustedSitesTableView.sectionFooterHeight = 0;
        _trustedSitesTableView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_trustedSitesTableView];
        
        [NSLayoutConstraint activateConstraints:@[
            [_trustedSitesTableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
            [_trustedSitesTableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
            [_trustedSitesTableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
            [_trustedSitesTableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
        ]];
    }
    
    return _trustedSitesTableView;
}

- (void)reloadSharedRules{
    if (_webView){
        NSURL *url = [NSURL URLWithString:@"https://www.craft.do/s/S24KRmdGZ9RuDw"];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [_webView loadRequest:request];
    }
}

- (WKWebView *)webView{
    if (nil == _webView){
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        WKPreferences *preferences = [[WKPreferences alloc] init];
        preferences.javaScriptEnabled = true;
        [preferences setValue:@YES forKey:@"allowFileAccessFromFileURLs"];
        [config setPreferences:preferences];
        config.applicationNameForUserAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1";
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
        _webView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_webView];
        
        [NSLayoutConstraint activateConstraints:@[
            [_webView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
            [_webView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
            [_webView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
            [_webView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
        ]];
    }
    
    return _webView;
}

- (FCTableViewHeadMenuItem *)trustedSiteMenuItem{
    if (nil == _trustedSiteMenuItem){
        _trustedSiteMenuItem = [[FCTableViewHeadMenuItem alloc] init];
        _trustedSiteMenuItem.title = NSLocalizedString(@"NewSite", @"");
        _trustedSiteMenuItem.image = [ImageHelper sfNamed:@"note.text.badge.plus" font:FCStyle.body color:FCStyle.accent];
        __weak AdBlockViewController *weakSelf = self;
        _trustedSiteMenuItem.action = ^{
            weakSelf.addTrustedSiteSlideController = [[AddTrustedSiteSlideController alloc] init];
            weakSelf.addTrustedSiteSlideController.baseCer = weakSelf;
            [weakSelf.addTrustedSiteSlideController show];
        };
    }
    
    return _trustedSiteMenuItem;
}

- (UpgradeSlideController *)upgradeSlideController{
    if (nil == _upgradeSlideController){
        _upgradeSlideController = [[UpgradeSlideController alloc] initWithMessage:@""];
    }
    
    return _upgradeSlideController;
}

@end
