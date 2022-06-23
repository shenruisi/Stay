//
//  SYSearchViewController.m
//  Stay
//
//  Created by zly on 2021/11/9.
//

#import "SYSearchViewController.h"
#import "DataManager.h"
#import "SYDetailViewController.h"
#import "JSDetailCell.h"
#import "UserscriptUpdateManager.h"
#import "BrowseView.h"
#import "ScriptMananger.h"
#import "FCStyle.h"
#import "SYExpandViewController.h"
#import <objc/runtime.h>

#ifdef Mac
#import "ToolbarTrackView.h"
#import "FCSplitViewController.h"
#import "QuickAccess.h"
#endif

CGFloat kMacToolbar = 50.0;

@interface SimpleLoadingView : UIView

@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) UILabel *label;
- (void)start;
- (void)stop;
@end

@implementation SimpleLoadingView

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


@interface SYSearchViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
// 数据源数组
@property (nonatomic, strong) NSMutableArray *datas;
@property (nonatomic, strong) SimpleLoadingView *simpleLoadingView;
@property (nonatomic, strong) UIView *line;
@end

@implementation SYSearchViewController

- (void)loadView{
#ifdef Mac
    ToolbarTrackView *view = [[ToolbarTrackView alloc] init];
    view.toolbar = ((FCSplitViewController *)self.splitViewController).toolbar;
    self.view = view;
#else
    self.view = [[UIView alloc] init];
#endif
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self simpleLoadingView];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = FCStyle.background;
#ifdef Mac
    self.navigationController.navigationBarHidden = YES;
#endif

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(statusBarChange) name:@"scriptSaveSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
#ifdef Mac
    if (self.datas.count > 0){
        [self.line setFrame:CGRectMake(0,kMacToolbar-1,self.view.frame.size.width,1)];
        [self.tableView setFrame:CGRectMake(0, kMacToolbar, self.view.frame.size.width, self.view.frame.size.height - kMacToolbar)];
        [self.tableView reloadData];
    }
#endif
    
}

- (void)queryData{
    if (self.datas.count == 0){
        [self.simpleLoadingView start];
    }
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT),^{
    
        NSMutableCharacterSet *set  = [[NSCharacterSet URLFragmentAllowedCharacterSet] mutableCopy];
         [set addCharactersInString:@"#"];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[@"https://fastclip.app/stay/browser.json" stringByAddingPercentEncodingWithAllowedCharacters:set]]];

        if (data.length > 0) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            self.datas = dic[@"categories"];
        }

        dispatch_async(dispatch_get_main_queue(),^{
            [self.simpleLoadingView stop];
            [self.tableView reloadData];
        });
    });
}

- (void)onBecomeActive {
    [self queryData];
}


- (void)statusBarChange{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[ScriptMananger shareManager] refreshData];
#ifdef Mac
        self.tableView.frame =  CGRectMake(0, kMacToolbar, self.view.frame.size.width, self.view.frame.size.height - kMacToolbar);
#else
        self.tableView.frame = self.view.bounds;
#endif
        [self.tableView reloadData];
    });

}



#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    return self.datas.count;
}

//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 30;
//}
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return self.datas.count;
//}

//- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
//    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
//    [header.textLabel setFont:[UIFont boldSystemFontOfSize:20]];
//    [header.textLabel setTextColor:DynamicColor([UIColor whiteColor],[UIColor blackColor])];
//
//    header.contentView.backgroundColor = DynamicColor(RGB(20, 20, 20),RGB(246, 246, 246));
//
//
//}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.backgroundColor = DynamicColor(RGB(20, 20, 20),RGB(246, 246, 246));
    cell.contentView.backgroundColor =DynamicColor(RGB(20, 20, 20),RGB(246, 246, 246));
    for (UIView *subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    
    NSArray *array = self.datas[indexPath.row][@"userscripts"];

    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, kScreenWidth - 30, 30)];
    lab.text = self.datas[indexPath.row][@"name"];
    lab.font = FCStyle.title3Bold;
    
    [cell.contentView addSubview:lab];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 60, 18);
    [btn setTitle:@"See all" forState:UIControlStateNormal];
    [btn setTitleColor:FCStyle.accent forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(seeAll:) forControlEvents:UIControlEventTouchUpInside];
    btn.right = kScreenWidth - 5;
    btn.font = FCStyle.headline;
    btn.centerY = lab.centerY;
    objc_setAssociatedObject (btn , @"array", array, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject (btn , @"titleName", self.datas[indexPath.row][@"name"], OBJC_ASSOCIATION_COPY_NONATOMIC);

    [cell.contentView addSubview:btn];

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 55, self.view.frame.size.width, 145)];
    scrollView.showsHorizontalScrollIndicator = NO;

    if(array != nil && array.count > 0) {
        CGFloat width = 15;
        
        for (int i = 0;i < array.count; i++) {
            BrowseView *browseView = [[BrowseView alloc] initWithFrame:CGRectMake(width, 0, 230, 145)];
            browseView.navigationController = self.navigationController;
            browseView.layer.cornerRadius = 12;
            [browseView loadView:array[i]];
            [scrollView addSubview:browseView];
            width = width + 245;
        }
        scrollView.contentSize = CGSizeMake(width, 145);
    }
    
    [cell.contentView addSubview:scrollView];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 200.0f;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[ScriptMananger shareManager] refreshData];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.datas.count > 0){
            self.tableView.frame = self.view.bounds;
            [self.tableView reloadData];
        }
        
    });

    
    [self queryData];
}


- (void)seeAll:(UIButton *)sender {
    NSArray *array = objc_getAssociatedObject(sender,@"array");
    NSString *titleName = objc_getAssociatedObject(sender,@"titleName");
    SYExpandViewController *cer = [[SYExpandViewController alloc] init];
    cer.data = array;
    cer.title = titleName;
    [self.navigationController pushViewController:cer animated:true];
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor =  DynamicColor(RGB(20, 20, 20),RGB(246, 246, 246));
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

- (SimpleLoadingView *)simpleLoadingView{
    if (nil == _simpleLoadingView){

        _simpleLoadingView = [[SimpleLoadingView alloc] initWithFrame:CGRectMake(0,
                                                                                 (self.view.frame.size.height - 50) / 2,
                                                                                 self.view.frame.size.width, 50)];
        
        [self.view addSubview:_simpleLoadingView];
    }
    
    return _simpleLoadingView;
}

- (UIView *)line{
    if (nil == _line){
        _line = [[UIView alloc] initWithFrame:CGRectMake(0, kMacToolbar-1, self.view.frame.size.width, 1)];
        _line.backgroundColor = FCStyle.fcSeparator;
        [self.view addSubview:_line];
    }
    
    return _line;
}

@end
