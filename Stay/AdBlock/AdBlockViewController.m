//
//  AdBlockViewController.m
//  Stay
//
//  Created by ris on 2023/3/14.
//

#import "AdBlockViewController.h"
#import "ImageHelper.h"
#import "FCStyle.h"
#import "ContentFilter.h"
#import "ContentFilterTableVewCell.h"

@interface AdBlockViewController ()<
 UITableViewDelegate,
 UITableViewDataSource
>

@property (nonatomic, strong) UIBarButtonItem *addItem;
@property (nonatomic, strong) FCTabButtonItem *activatedTabItem;
@property (nonatomic, strong) FCTabButtonItem *stoppedTabItem;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<ContentFilter *> *activatedSource;
@end

@implementation AdBlockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.leftTitle = NSLocalizedString(@"AdBlock", @"");
    self.enableTabItem = YES;
    self.navigationItem.rightBarButtonItem = self.addItem;
    self.navigationTabItem.leftTabButtonItems = @[self.activatedTabItem, self.stoppedTabItem];
    [self tableView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ContentFilter *contentFilter = self.activatedSource[indexPath.row];
    ContentFilterTableVewCell *cell = [tableView dequeueReusableCellWithIdentifier:[ContentFilterTableVewCell identifier]];
    if (nil == cell){
        return [[ContentFilterTableVewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    cell.element = contentFilter;
    cell.action = ^(id element) {
        
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70 + [ContentFilterTableVewCell contentInset].top + [ContentFilterTableVewCell contentInset].bottom;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.activatedSource.count;
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

- (NSArray<ContentFilter *> *)activatedSource{
    ContentFilter *test1 = [[ContentFilter alloc] init];
    test1.name = @"Test1";
    ContentFilter *test2 = [[ContentFilter alloc] init];
    test2.name = @"Test2";
    return @[
        test1,test2
    ];
}

- (void)addAction:(id)sender{
    
}

- (void)tabItemDidClick:(FCTabButtonItem *)item refresh:(BOOL)refresh{
    
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
