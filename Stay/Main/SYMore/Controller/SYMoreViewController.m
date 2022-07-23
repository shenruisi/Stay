//
//  ViewController.m
//  Stay
//
//  Created by ris on 2021/10/15.
//

#import "Tampermonkey.h"
#import "SYMoreViewController.h"
#import "FCStyle.h"
#import "FCConfig.h"
#if iOS
#import "Stay-Swift.h"
#else
#import "Stay_2-Swift.h"
#endif

NSNotificationName const _Nonnull SYMoreViewReloadCellNotification = @"app.stay.notification.SYMoreViewReloadCellNotification";

@interface _MoreTableViewCell : UITableViewCell
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *entity;
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

@interface _SubscriptionTableViewCell : _MoreTableViewCell{
    UIImageView *_goldenRccessory;
}

@end

@implementation _SubscriptionTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.textLabel.textColor = FCStyle.fcGolden;
        self.backgroundColor = FCStyle.backgroundGolden;
        self.layer.borderColor = FCStyle.borderGolden.CGColor;
        self.layer.borderWidth = 1;
        [self accessory];
    }
    
    return self;
}

- (void)setEntity:(NSDictionary<NSString *,NSString *> *)entity{
    [super setEntity:entity];
    
    NSMutableAttributedString *builder = [[NSMutableAttributedString alloc] init];
    NSString *title = entity[@"title"];
    [builder appendAttributedString:[[NSAttributedString alloc] initWithString:title attributes:@{
        NSForegroundColorAttributeName:FCStyle.fcGolden,
        NSFontAttributeName:FCStyle.body
    }]];
    
    self.textLabel.attributedText = builder;
}

- (UIImageView *)accessory{
    if (nil == _goldenRccessory){
        _goldenRccessory = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 13)];
        UIImage *image = [UIImage systemImageNamed:@"chevron.right"
                                 withConfiguration:[UIImageSymbolConfiguration configurationWithFont:[UIFont systemFontOfSize:13]]];
        image = [image imageWithTintColor:FCStyle.fcGolden renderingMode:UIImageRenderingModeAlwaysOriginal];
        [_goldenRccessory setImage:image];
        self.accessoryView =_goldenRccessory;
    }
    
    return _goldenRccessory;
}
@end

@interface _iCloudSwitchTableViewCell : _MoreTableViewCell{
    
}
@property (nonatomic, strong) UISwitch *switchButton;
@end

@implementation _iCloudSwitchTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self switchButton];
    }
    
    return self;
}

- (UISwitch *)switchButton{
    if (nil == _switchButton){
        _switchButton = [[UISwitch alloc] init];
        [_switchButton setOnTintColor:FCStyle.accent];
        [_switchButton setOn:[[FCConfig shared] getBoolValueOfKey:GroupUserDefaultsKeySyncEnabled]];
        [_switchButton addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
        self.accessoryView = _switchButton;
    }
    return _switchButton;
}

- (void)switchAction:(UISwitch *)sender{
    [[FCConfig shared] setBoolValueOfKey:GroupUserDefaultsKeySyncEnabled value:sender.on];
    [[NSNotificationCenter defaultCenter] postNotificationName:SYMoreViewReloadCellNotification
                                                        object:nil
                                                      userInfo:@{
        @"section":@(1),
        @"row":@(1)
    }];
}

@end

@interface _iCloudOperateTableViewCell : _MoreTableViewCell{
    
}
@property (nonatomic, strong) UIButton *syncNowButton;
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) UIButton *fullResyncButton;

@end

@implementation _iCloudOperateTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.accessoryView = nil;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self syncNowButton];
        [self line];
        [self fullResyncButton];
    }
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    self.line.frame = CGRectMake((self.width - self.line.width) / 2,
                                 (self.height - self.line.height) / 2,
                                 self.line.width, self.line.height);
    self.syncNowButton.frame = CGRectMake((self.width/2 - self.syncNowButton.width) / 2,
                                          (self.height - self.syncNowButton.height) / 2,
                                          self.syncNowButton.width,
                                          self.syncNowButton.height);
    self.fullResyncButton.frame = CGRectMake(self.width/2 + (self.width/2 - self.fullResyncButton.width) / 2,
                                          (self.height - self.fullResyncButton.height) / 2,
                                          self.fullResyncButton.width,
                                          self.fullResyncButton.height);
}

- (UIView *)line{
    if (nil == _line){
        _line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 20)];
        _line.backgroundColor = FCStyle.fcSeparator;
        [self addSubview:_line];
    }
    
    return _line;
}

- (UIButton *)syncNowButton{
    if (nil == _syncNowButton){
        _syncNowButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        
//        NSLog(@"GroupUserDefaultsKeySyncEnabled %ld",[[FCConfig shared] getBoolValueOfKey:GroupUserDefaultsKeySyncEnabled]);
        _syncNowButton.enabled = [[FCConfig shared] getBoolValueOfKey:GroupUserDefaultsKeySyncEnabled];
        
        [_syncNowButton setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"SyncNow", @"")
                                                                attributes:@{
            NSForegroundColorAttributeName : _syncNowButton.enabled ? FCStyle.accent : [UIColor systemGray3Color],
            NSFontAttributeName : FCStyle.body
        }] forState:UIControlStateNormal];
        
        [self addSubview:_syncNowButton];
    }
    return _syncNowButton;
}

- (UIButton *)fullResyncButton{
    if (nil == _fullResyncButton){
        _fullResyncButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        _fullResyncButton.enabled = [[FCConfig shared] getBoolValueOfKey:GroupUserDefaultsKeySyncEnabled];
        [_fullResyncButton setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"FullResync", @"")
                                                                attributes:@{
            NSForegroundColorAttributeName : _fullResyncButton.enabled ? FCStyle.accent : [UIColor systemGray3Color],
            NSFontAttributeName : FCStyle.body
        }] forState:UIControlStateNormal];
        [self addSubview:_fullResyncButton];
    }
    return _fullResyncButton;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadCell:)
                                                 name:SYMoreViewReloadCellNotification
                                               object:nil];
}

- (void)reloadCell:(NSNotification *)note{
    NSInteger section = [note.userInfo[@"section"] integerValue];
    NSInteger row = [note.userInfo[@"row"] integerValue];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:section]]
                          withRowAnimation:UITableViewRowAnimationNone];
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
    _MoreTableViewCell *cell = nil;
    NSDictionary *entity = self.dataSource[indexPath.section][@"cells"][indexPath.row];
    if ([entity[@"type"] isEqualToString:@"subscription"]){
        cell = [[_SubscriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    else if ([entity[@"type"] isEqualToString:@"iCloudSwitch"]){
        cell = [[_iCloudSwitchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    else if ([entity[@"type"] isEqualToString:@"iCloudOperate"]){
        cell = [[_iCloudOperateTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        [((_iCloudOperateTableViewCell *)cell).syncNowButton addTarget:self action:@selector(syncNowAction:) forControlEvents:UIControlEventTouchUpInside];
        [((_iCloudOperateTableViewCell *)cell).fullResyncButton addTarget:self action:@selector(fullResyncAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    else{
        cell = [[_MoreTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    cell.entity = entity;
    NSLog(@"SYMoreViewController %ld,%ld",indexPath.row,((NSArray *)self.dataSource[indexPath.section][@"cells"]).count - 1);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dict = self.dataSource[indexPath.section][@"cells"][indexPath.row];
    NSString *url = dict[@"url"];
    if (url.length > 0){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]
                                           options:@{} completionHandler:^(BOOL succeed){}];
    } else {
        NSString *type = dict[@"type"];
        if ([type isEqualToString:@"subscription"]) {
            [self.navigationController pushViewController:[[SYSubscribeController alloc] init] animated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
#ifdef Mac
    return 35.0;
#else
    return 45.0;
#endif
    
}

- (void)syncNowAction:(id)sender{
    
}

- (void)fullResyncAction:(id)sender{
    
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
                @"section":NSLocalizedString(@"Subscription",@""),
                @"cells":@[
                    @{@"title":NSLocalizedString(@"UpgradeTo",@""),
                      @"type":@"subscription"
                    }
                ]
            },
            @{
                @"section":NSLocalizedString(@"SYNC",@""),
                @"cells":@[
                    @{@"title":@"iCloud",
                      @"type":@"iCloudSwitch"
                    },
                    @{
                      @"type":@"iCloudOperate",
                    }
                ]
            },
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

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:SYMoreViewReloadCellNotification
                                                  object:nil];
}

@end
