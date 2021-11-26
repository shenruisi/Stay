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

- (void)testParseUserScript{
    UserScript *userScript =  [[Tampermonkey shared] parseScript:@"newuserscript.user"];
    NSUserDefaults *groupUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dajiu.stay.pro"];
    [groupUserDefaults setObject:@[[userScript toDictionary]] forKey:@"ACTIVE_SCRIPTS"];
    [groupUserDefaults synchronize];
//    NSMutableArray<NSDictionary *> *datas = [NSMutableArray arrayWithArray:[groupUserDefaults arrayForKey:@"ACTIVE_SCRIPTS"]];
//    NSLog([userScript toDictionary]);
    
}

- (void)viewDidLoad {
//    [self testParseUserScript];
    [super viewDidLoad];
    [self tableView];
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
                    @{@"title":NSLocalizedString(@"settings.joinTelegram",""),@"url":@"https://t.me/fastclipchat"}
                ]
            },
            @{
                @"section":@"",
                @"cells":@[
                    @{@"title":NSLocalizedString(@"settings.enableStay",""),@"url":@"App-prefs:root=SAFARI"}
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
        [self.view addSubview:_tableView];
    }
    
    return _tableView;
}


@end
