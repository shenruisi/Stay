//
//  ViewController.m
//  Stay
//
//  Created by ris on 2021/10/15.
//

#import "Tampermonkey.h"
#import "SYMoreViewController.h"

@interface SYMoreViewController ()<
 UITableViewDelegate,
 UITableViewDataSource
>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSDictionary *> *dataSource;
@property (nonatomic, strong) UIBarButtonItem *leftIcon;
@end

@implementation SYMoreViewController

- (void)statusBarChange{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tableView.frame = self.view.bounds;
        [self.tableView reloadData];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tableView.frame = self.view.bounds;
        [self.tableView reloadData];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
#ifdef Mac
    self.navigationController.navigationBarHidden = YES;
#endif
    [self tableView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return ((NSArray *)self.dataSource[section][@"cells"]).count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSString *identifier = [NSString stringWithFormat:@"settings.%ld.cell",indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    
    NSString *icon = cell.textLabel.text = self.dataSource[indexPath.section][@"cells"][indexPath.row][@"icon"];
    cell.imageView.image = icon.length > 0 ? [UIImage imageNamed:icon] : nil;
    cell.textLabel.text = self.dataSource[indexPath.section][@"cells"][indexPath.row][@"title"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *url = self.dataSource[indexPath.section][@"cells"][indexPath.row][@"url"];
    if (url.length > 0){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]
                                           options:@{} completionHandler:^(BOOL succeed){}];
    }
}


- (BOOL)joinGroup:(NSString *)groupUin key:(NSString *)key{
    NSString *urlStr = [NSString stringWithFormat:@"mqqapi://card/show_pslcard?src_type=internal&version=1&uin=%@&key=%@&card_type=group&source=external&jump_from=webapi", @"714147685",@"c987123ea55d74e0b3fa84e3169d6be6d24fb1849e78f57c0f573e9d45e67217"];
    NSURL *url = [NSURL URLWithString:urlStr];
    if([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url];
    return YES;
    }
    else return NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return self.dataSource[section][@"section"];
}


- (NSArray *)dataSource{
    if (nil == _dataSource){
        _dataSource = @[
            @{
                @"section":@"",
                @"cells":@[
                    @{@"title":NSLocalizedString(@"settings.rateApp",""),@"url":@"https://apps.apple.com/app/id1591620171?action=write-review"},
                    @{@"title":NSLocalizedString(@"settings.openSource",""),@"url":@"https://github.com/shenruisi/Stay"},
                    @{@"title":NSLocalizedString(@"settings.joinTelegram",""),@"url":@"https://t.me/fastclipchat"},
                    @{@"title":NSLocalizedString(@"settings.joinQQ",""),@"url":@"mqqapi://card/show_pslcard?src_type=internal&version=1&uin=714147685&key=c987123ea55d74e0b3fa84e3169d6be6d24fb1849e78f57c0f573e9d45e67217&card_type=group&source=external&jump_from=webapi"},
                    @{@"title":NSLocalizedString(@"settings.joinTwitter","joinTwitter"),@"url":@"https://twitter.com/fastclip1"}
                ]
            },
            @{
                @"section":NSLocalizedString(@"settings.section.otherApps",""),
                @"cells":@[
                    @{@"icon":@"fastclip-icon",@"title":NSLocalizedString(@"settings.section.otherApps.fastclip",""),@"url":@"https://apps.apple.com/cn/app/fastclip-copy-paste-enhancer/id1476085650?l=en"}
                ]
            }
        ];
    }
    
    return _dataSource;
}

- (UITableView *)tableView{
    if (nil == _tableView){
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleInsetGrouped];
        _tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = DynamicColor(RGB(20, 20, 20),RGB(246, 246, 246));
        [self.view addSubview:_tableView];
    }
    
    return _tableView;
}


@end
