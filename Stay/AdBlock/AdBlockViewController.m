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
        
        [contentFilter convertToJOSNRules];
        
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70 + [ContentFilterTableVewCell contentInset].top + [ContentFilterTableVewCell contentInset].bottom;
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
