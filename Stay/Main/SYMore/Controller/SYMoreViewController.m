//
//  ViewController.m
//  Stay
//
//  Created by ris on 2021/10/15.
//

#import "Tampermonkey.h"
#import "SYMoreViewController.h"
#import "FCStyle.h"

@interface _MoreTableViewCell : UITableViewCell
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *entity;
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) UIImageView *accessory;
@end

@implementation _MoreTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.textLabel.font = FCStyle.body;
        self.textLabel.textColor = FCStyle.fcBlack;
        self.backgroundColor = FCStyle.secondaryBackground;
        [self accessory];
    }
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
}


- (void)setEntity:(NSDictionary<NSString *, NSString *>  *)entity{
    _entity = entity;
    
    NSMutableAttributedString *builder = [[NSMutableAttributedString alloc] init];
    NSString *title = entity[@"title"];
    [builder appendAttributedString:[[NSAttributedString alloc] initWithString:title attributes:@{
        NSForegroundColorAttributeName:FCStyle.fcBlack,
        NSFontAttributeName:FCStyle.body
        
    }]];
    
    NSString *subtitle = entity[@"subtitle"];
    if (subtitle.length > 0){
        [builder appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",subtitle] attributes:@{
            NSForegroundColorAttributeName:FCStyle.fcSecondaryBlack,
            NSFontAttributeName:FCStyle.footnote,
            NSObliquenessAttributeName:@(0.2)
            
        }]];
    }
    
    
    self.textLabel.attributedText = builder;
    self.imageView.image = entity[@"icon"].length > 0 ? [UIImage imageNamed:entity[@"icon"]] : nil;
    self.imageView.layer.cornerRadius = 8;
    self.imageView.layer.masksToBounds = YES;
}

- (UIImageView *)accessory{
    if (nil == _accessory){
        _accessory = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 13)];
        UIImage *image = [UIImage systemImageNamed:@"chevron.right"
                                 withConfiguration:[UIImageSymbolConfiguration configurationWithFont:[UIFont systemFontOfSize:13]]];
        image = [image imageWithTintColor:FCStyle.fcSecondaryBlack renderingMode:UIImageRenderingModeAlwaysOriginal];
        [_accessory setImage:image];
        self.accessoryView =_accessory;
    }
    
    return _accessory;
}


@end

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
    self.view.backgroundColor = FCStyle.background;
    [self tableView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.tableView.frame = self.view.bounds;
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return ((NSArray *)self.dataSource[section][@"cells"]).count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSString *identifier = [NSString stringWithFormat:@"settings.%ld.cell",indexPath.section];
    _MoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell){
        cell = [[_MoreTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
//        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.entity = self.dataSource[indexPath.section][@"cells"][indexPath.row];
    NSLog(@"SYMoreViewController %ld,%ld",indexPath.row,((NSArray *)self.dataSource[indexPath.section][@"cells"]).count - 1);
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
#ifdef Mac
    return 35.0;
#else
    return 45.0;
#endif
    
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
                @"section":NSLocalizedString(@"Interaction",@""),
                @"cells":@[
                    @{@"title":NSLocalizedString(@"settings.rateApp",@""),
                      @"url":@"https://apps.apple.com/app/id1591620171?action=write-review",
                      @"subtitle":@"Stay 2"
                    },
                    @{@"title":NSLocalizedString(@"settings.openSource",@""),
                      @"url":@"https://github.com/shenruisi/Stay",
                      @"subtitle":@"shenruisi/Stay"
                    },
                ]
            },
            @{
                @"section":NSLocalizedString(@"Social", @""),
                @"cells":@[
                    @{@"title":NSLocalizedString(@"settings.joinTelegram",@"")
                      ,@"url":@"https://t.me/fastclipchat",
                      @"subtitle":@"t.me/fastclipchat",
                    },
                    @{@"title":NSLocalizedString(@"settings.joinQQ",@""),@"url":@"mqqapi://card/show_pslcard?src_type=internal&version=1&uin=714147685&key=c987123ea55d74e0b3fa84e3169d6be6d24fb1849e78f57c0f573e9d45e67217&card_type=group&source=external&jump_from=webapi"},
                    @{@"title":NSLocalizedString(@"settings.joinTwitter",@""),
                      @"url":@"https://twitter.com/fastclip1",
                      @"subtitle":@"@fastclip1"
                    }
                ]
            },
            @{
                @"section":NSLocalizedString(@"MoreApp",@""),
                @"cells":@[
                    @{@"icon":@"FastClipIcon",@"title":@"FastClip 3",
                      @"url":@"https://apps.apple.com/cn/app/fastclip-copy-paste-enhancer/id1476085650?l=en",
                      @"subtitle":@"Snippets Editor"
                    }
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
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
        _tableView.separatorColor = FCStyle.fcSeparator;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = FCStyle.background;
        [self.view addSubview:_tableView];
    }
    
    return _tableView;
}


@end
