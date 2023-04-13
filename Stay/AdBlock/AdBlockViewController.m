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
@end

@implementation AdBlockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.leftTitle = NSLocalizedString(@"AdBlock", @"");
    self.enableTabItem = YES;
    self.navigationItem.rightBarButtonItem = self.addItem;
    self.navigationTabItem.leftTabButtonItems = @[self.activatedTabItem, self.stoppedTabItem];
    [self tableView];
    [self setupDataSource];
    [self.navigationTabItem activeItem:self.activatedTabItem];
//    NSString *filters = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"EasyList" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
//    NSArray<NSString *> *lines = [filters componentsSeparatedByString:@"\n"];
//    for (NSString *line in lines){
//        FilterTokenParser *parser = [[FilterTokenParser alloc] initWithChars:line];
//        [parser nextToken];
//        while(![parser isEOF]){
//            NSLog(@"token: %@",parser.curToken);
//            [parser nextToken];
//        }
//    }
    
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
    return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray<ContentFilter *> *contentFilters = [[DataManager shareManager] selectContentFilters];
        NSMutableArray *activatedSource = [[NSMutableArray alloc] init];
        NSMutableArray *stoppedSource = [[NSMutableArray alloc] init];
        for (ContentFilter *contentFilter in contentFilters){
            dispatch_time_t deadline = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            
            [SFContentBlockerManager getStateOfContentBlockerWithIdentifier:contentFilter.contentBlockerIdentifier completionHandler:^(SFContentBlockerState * _Nullable state, NSError * _Nullable error) {
                if (state.enabled){
                    contentFilter.status = 1;
                    [activatedSource addObject:contentFilter];
                    [[DataManager shareManager] updateContentFilterStatus:1 uuid:contentFilter.uuid];
                }
                else{
                    contentFilter.status = 0;
                    [stoppedSource addObject:contentFilter];
                    [[DataManager shareManager] updateContentFilterStatus:0 uuid:contentFilter.uuid];
                }
            }];
            
            dispatch_semaphore_wait(semaphore, deadline);
        }
        
        [self.activatedSource removeAllObjects];
        [self.activatedSource addObjectsFromArray:activatedSource];
        [self.stoppedSource removeAllObjects];
        [self.stoppedSource addObjectsFromArray:stoppedSource];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            NSLog(@"SFContentBlockerState reload");
        });
    });
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
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
    cell.action = ^(id element) {
        ContentFilter *contentFilter = (ContentFilter *)element;
//        AdBlockDetailViewController *cer = [[AdBlockDetailViewController alloc] init];
//        cer.contentFilter = contentFilter;
//        [self.navigationController pushViewController:cer animated:YES];
        
        [contentFilter reloadContentBlocker];
        
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ContentFilter *contentFilter = self.selectedDataSource[indexPath.row];
    return (contentFilter.enable ? 70 : 90) + [ContentFilterTableVewCell contentInset].top + [ContentFilterTableVewCell contentInset].bottom;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.selectedDataSource.count;
}


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

@end
