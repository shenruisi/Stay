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




@interface SYSearchViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
// 数据源数组
@property (nonatomic, strong) NSMutableArray *datas;

@property (nonatomic, strong) UIView *loadingView;

@property (nonatomic, strong) UIActivityIndicatorView  *indicatorView;



@end

@implementation SYSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = DynamicColor(RGB(28, 28, 28),RGB(240, 240, 245));
    self.loadingView.center = self.view.center;
    self.loadingView.hidden = YES;
    [self.view addSubview:self.loadingView];

    [self queryData];
    [self.view addSubview:self.indicatorView];
    [self.view bringSubviewToFront:self.indicatorView];
    [self.indicatorView startAnimating];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(statusBarChange) name:@"scriptSaveSuccess" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(needShowLoading) name:@"needShowLoading" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(needStopLoading) name:@"needStopLoading" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}


- (void)queryData{
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT),^{
    
        NSMutableCharacterSet *set  = [[NSCharacterSet URLFragmentAllowedCharacterSet] mutableCopy];
         [set addCharactersInString:@"#"];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[@"https://fastclip.app/stay/browser.json" stringByAddingPercentEncodingWithAllowedCharacters:set]]];

        if (data.length > 0) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            self.datas = dic[@"categories"];
        }

        dispatch_async(dispatch_get_main_queue(),^{
            [self.tableView reloadData];
            [self.indicatorView stopAnimating];
        });
    });
}

- (void)onBecomeActive {
    [self queryData];
}

- (void)needShowLoading {
    dispatch_async(dispatch_get_main_queue(),^{
        [self.view bringSubviewToFront:self.loadingView];
        self.loadingView.hidden = NO;
    });
}
- (void)needStopLoading {
    dispatch_async(dispatch_get_main_queue(),^{
        
        self.loadingView.hidden = YES;
    });
}


- (void)statusBarChange{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[ScriptMananger shareManager] refreshData];
        self.tableView.frame = self.view.bounds;
        [self.tableView reloadData];
    });

}



#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.datas.count;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [header.textLabel setTextColor:DynamicColor([UIColor whiteColor],[UIColor blackColor])];

    header.contentView.backgroundColor = DynamicColor(RGB(28, 28, 28),RGB(240, 240, 245));

    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.datas[section][@"name"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.backgroundColor = DynamicColor(RGB(28, 28, 28),RGB(240, 240, 245));
    cell.contentView.backgroundColor = DynamicColor(RGB(28, 28, 28),RGB(240, 240, 245));
    for (UIView *subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 145)];
    scrollView.showsHorizontalScrollIndicator = FALSE;
    NSArray *array = self.datas[indexPath.section][@"userscripts"];

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
    return 160.0f;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tableView.frame = self.view.bounds;
    
        [self.tableView reloadData];
    });
    
    [self queryData];
}


- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor =  DynamicColor(RGB(28, 28, 28),RGB(240, 240, 245));
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

- (UIActivityIndicatorView *)indicatorView {
    if (_indicatorView == nil) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicatorView.color = [UIColor blackColor];
        _indicatorView.frame = CGRectMake(200, 200, 50, 50);
        _indicatorView.backgroundColor = [UIColor blackColor];
    }
    return _indicatorView;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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

@end
