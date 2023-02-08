//
//  SYConcurrencyViewController.m
//  Stay
//
//  Created by Jin on 2023/2/7.
//

#import "SYConcurrencyViewController.h"
#import "FCStyle.h"
#import "FCConfig.h"
#import "DownloadManager.h"

@interface _ConcurrencyTableViewCell : UITableViewCell
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *entity;
@property (nonatomic, strong) UIImageView *accessory;

@end

@implementation _ConcurrencyTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.textLabel.font = FCStyle.body;
        self.textLabel.textColor = FCStyle.fcBlack;
        self.backgroundColor = FCStyle.secondaryBackground;
    }
    
    return self;
}

- (void)setEntity:(NSDictionary<NSString *, NSString *>  *)entity{
    _entity = entity;
    
    NSMutableAttributedString *builder = [[NSMutableAttributedString alloc] init];
    NSString *title = entity[@"title"];
    if (title.length > 0){
        [builder appendAttributedString:[[NSAttributedString alloc] initWithString:title attributes:@{
            NSForegroundColorAttributeName:FCStyle.fcBlack,
            NSFontAttributeName:FCStyle.body
            
        }]];
    }
    
    NSString *subtitle = entity[@"subtitle"];
    if (subtitle.length > 0){
        [builder appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",subtitle] attributes:@{
            NSForegroundColorAttributeName:FCStyle.fcSecondaryBlack,
            NSFontAttributeName:FCStyle.footnote,
        }]];
    }

    self.textLabel.attributedText = builder;
    
    NSString *type = entity[@"type"];
    if (type != nil && type.length > 0) {
        NSInteger concurrency = [[FCConfig shared] getIntegerValueOfKey:GroupUserDefaultsKeyM3U8Concurrency];
        if (type.intValue == concurrency) {
            [self accessory];
        }
    }
}

- (UIImageView *)accessory{
    if (nil == _accessory){
        _accessory = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 17)];
        UIImage *image = [UIImage systemImageNamed:@"checkmark"
                                 withConfiguration:[UIImageSymbolConfiguration configurationWithFont:[UIFont systemFontOfSize:13]]];
        image = [image imageWithTintColor:FCStyle.accent renderingMode:UIImageRenderingModeAlwaysOriginal];
        [_accessory setImage:image];
        self.accessoryView =_accessory;
    }
    
    return _accessory;
}

@end


@interface SYConcurrencyViewController ()<
UITableViewDelegate,
UITableViewDataSource
>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSDictionary *> *dataSource;
@property (nonatomic, strong) UIBarButtonItem *closeBtn;
@end

@implementation SYConcurrencyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = FCStyle.background;
    [self tableView];
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    self.title = NSLocalizedString(@"settings.Concurrency",@"Concurrency");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarChange) name:UIDeviceOrientationDidChangeNotification object:nil];
#if Mac
    self.navigationItem.leftBarButtonItem = self.closeBtn;
#endif
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:true];
    
    [self.tableView setFrame:self.view.bounds];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return ((NSArray *)self.dataSource[section][@"cells"]).count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return self.dataSource[section][@"section"];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    _ConcurrencyTableViewCell *cell = nil;
    NSDictionary *entity = self.dataSource[indexPath.section][@"cells"][indexPath.row];
    cell = [[_ConcurrencyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.entity = entity;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
#ifdef Mac
    return 35.0;
#else
    return 45.0;
#endif
}

- (void)clickClose:(id)sender{
    [self dismissModalViewControllerAnimated:true];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dict = self.dataSource[indexPath.section][@"cells"][indexPath.row];
    NSString *url = dict[@"url"];
    NSString *type = dict[@"type"];
    if (url.length > 0){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]
                                           options:@{} completionHandler:^(BOOL succeed){}];
    } else if([@"3" isEqual:type]) {
        [[FCConfig shared] setIntegerValueOfKey:GroupUserDefaultsKeyM3U8Concurrency value:3];
        [DownloadManager.shared setM3U8Concurrency:3];
    } else if([@"5" isEqual:type]) {
        [[FCConfig shared] setIntegerValueOfKey:GroupUserDefaultsKeyM3U8Concurrency value:5];
        [DownloadManager.shared setM3U8Concurrency:5];
    } else if([@"10" isEqual:type]) {
        [[FCConfig shared] setIntegerValueOfKey:GroupUserDefaultsKeyM3U8Concurrency value:10];
        [DownloadManager.shared setM3U8Concurrency:10];
    }
    
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return 0.0F;
    }
    return 20;
}

- (NSArray *)dataSource{
    if (nil == _dataSource){
        _dataSource = @[
            @{
                @"cells":@[
                    @{@"title":@"3",
                      @"type":@"3"
                    },
                    @{@"title":@"5",
                      @"type":@"5"

                    },
                    @{@"title":@"10",
                      @"type":@"10"
                    }
                ]
            },
        ];
    }
    
    return _dataSource;
}

- (void)statusBarChange{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tableView.frame = self.view.bounds;
        [self.tableView reloadData];
    });
}


- (UITableView *)tableView{
    if (nil == _tableView){
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleInsetGrouped];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorInset = UIEdgeInsetsMake(0, 20, 0, 0);
        _tableView.separatorColor = FCStyle.fcSeparator;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = FCStyle.background;
        [self.view addSubview:_tableView];
    }
    
    return _tableView;
}

- (UIBarButtonItem *)closeBtn {
    if(_closeBtn == nil) {
        _closeBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"settings.close","close") style:UIBarButtonItemStylePlain target:self action:@selector(clickClose:)];
        _closeBtn.tintColor = FCStyle.accent;
    }
    return _closeBtn;
}

@end

