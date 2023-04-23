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

@interface AdBlockViewController ()<
 UITableViewDelegate,
 UITableViewDataSource
>

@property (nonatomic, strong) UIBarButtonItem *addItem;
@property (nonatomic, strong) FCTabButtonItem *activatedTabItem;
@property (nonatomic, strong) FCTabButtonItem *stoppedTabItem;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<ContentFilter *> *activatedSource;
@property (nonatomic, strong) NSMutableArray<ContentFilter *> *stoppedSource;
@property (nonatomic, strong) NSArray<ContentFilter *> *selectedDataSource;
@property (nonatomic, strong) UpgradeSlideController *upgradeSlideController;
@end

@implementation AdBlockViewController

- (instancetype)init{
    if (self = [super init]){
        [self setupDataSource];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            for (ContentFilter *contentFilter in self.activatedSource){
                if (contentFilter.type != ContentFilterTypeCustom
                    && contentFilter.type != ContentFilterTypeTag){
                    if (![[ContentFilterManager shared] existRuleJson:contentFilter.rulePath]){
                        [contentFilter reloadContentBlockerWithCompletion:^(NSError * _Nonnull error) {
                            NSLog(@"reloadContentBlockerWithCompletion %@",error);
                        }];
                    }
                }
            }
            
            for (ContentFilter *contentFilter in self.stoppedSource){
                if (contentFilter.type != ContentFilterTypeCustom
                    && contentFilter.type != ContentFilterTypeTag){
                    if (![[ContentFilterManager shared] existRuleJson:contentFilter.rulePath]){
                        [contentFilter reloadContentBlockerWithCompletion:^(NSError * _Nonnull error) {
                            NSLog(@"reloadContentBlockerWithCompletion %@",error);
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
    self.navigationItem.rightBarButtonItem = self.addItem;
    self.navigationTabItem.leftTabButtonItems = @[self.activatedTabItem, self.stoppedTabItem];
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
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ContentFilter *contentFilter = self.selectedDataSource[indexPath.row];
    ContentFilterTableVewCell<ContentFilter *> *cell = [tableView dequeueReusableCellWithIdentifier:[ContentFilterTableVewCell identifier]];
    if (nil == cell){
        cell = [[ContentFilterTableVewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
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
        [self.navigationController pushViewController:cer animated:YES];
    };
    
    __weak AdBlockViewController *weakSelf = (AdBlockViewController *)self;
    cell.doubleTapAction = ^(id element) {
        ContentFilter *contentFilter = (ContentFilter *)element;
        [weakSelf updateStatus:contentFilter];
    };
    
    return cell;
}

- (void)updateStatus:(ContentFilter *)contentFilter{
    if (contentFilter.active){
        contentFilter.status = 0;
        [[DataManager shareManager] updateContentFilterStatus:0 uuid:contentFilter.uuid];
        [self.activatedSource removeObject:contentFilter];
        [self.stoppedSource addObject:contentFilter];
        
        [self.stoppedSource sortUsingComparator:^NSComparisonResult(ContentFilter *obj1, ContentFilter *obj2) {
            if (obj1.sort < obj2.sort) return NSOrderedAscending;
            else if (obj1.sort > obj2.sort) return NSOrderedDescending;
            return NSOrderedSame;
        }];
    }
    else{
        contentFilter.status = 1;
        [[DataManager shareManager] updateContentFilterStatus:1 uuid:contentFilter.uuid];
        [self.stoppedSource removeObject:contentFilter];
        [self.activatedSource addObject:contentFilter];
        
        [self.activatedSource sortUsingComparator:^NSComparisonResult(ContentFilter *obj1, ContentFilter *obj2) {
            if (obj1.sort < obj2.sort) return NSOrderedAscending;
            else if (obj1.sort > obj2.sort) return NSOrderedDescending;
            return NSOrderedSame;
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ContentFilter *contentFilter = self.selectedDataSource[indexPath.row];
    return (contentFilter.enable ? 70 : 90) + [ContentFilterTableVewCell contentInset].top + [ContentFilterTableVewCell contentInset].bottom;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.selectedDataSource.count;
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
                                    targetView.backgroundColor = [UIColor clearColor];
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
    BOOL isActivatedSelected = self.selectedDataSource == self.activatedSource;
    ContentFilter *contentFilter = self.selectedDataSource[indexPath.row];
    FCTableViewCell *cell = (FCTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    UIContextualAction *reloadAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        // 处理删除操作
        completionHandler(YES);
    }];
    reloadAction.image = [ImageHelper sfNamed:@"arrow.triangle.2.circlepath" font:FCStyle.headline color:FCStyle.accent];
    reloadAction.backgroundColor = [UIColor clearColor];
    if (isActivatedSelected){
        [actions addObject:reloadAction];
    }
    
    UIContextualAction *activeOrStopAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [cell doubleTap:cell.fcContentView.center];
        completionHandler(YES);
    }];
    activeOrStopAction.image = [ImageHelper sfNamed: isActivatedSelected ? @"stop.fill" : @"play.fill" font:FCStyle.headline color:FCStyle.accent];
    activeOrStopAction.backgroundColor = [UIColor clearColor];
    [actions addObject:activeOrStopAction];
    
    UISwipeActionsConfiguration *configuration = [UISwipeActionsConfiguration configurationWithActions:actions];
    
    return configuration;
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

- (void)addAction:(id)sender{
    
}

- (void)tabItemDidClick:(FCTabButtonItem *)item refresh:(BOOL)refresh{
    if (item == self.activatedTabItem){
        self.selectedDataSource = self.activatedSource;
    }
    else{
        self.selectedDataSource = self.stoppedSource;
    }
    
    if (!refresh){
        [self.tableView reloadData];
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

- (UpgradeSlideController *)upgradeSlideController{
    if (nil == _upgradeSlideController){
        _upgradeSlideController = [[UpgradeSlideController alloc] initWithMessage:@""];
    }
    
    return _upgradeSlideController;
}

@end
