//
//  SYAboutViewController.m
//  Stay
//
//  Created by zly on 2022/8/12.
//

#import "SYAboutViewController.h"
#import "FCStyle.h"
#import "FCConfig.h"
#import "API.h"

@interface _AbountTableViewCell : UITableViewCell
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *entity;
@property (nonatomic, strong) UIImageView *accessory;
@end

@implementation _AbountTableViewCell

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
@interface SYAboutViewController ()<
UITableViewDelegate,
UITableViewDataSource
>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSDictionary *> *dataSource;
@property (nonatomic, strong) UIBarButtonItem *closeBtn;


@end

@implementation SYAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = FCStyle.background;

    [self tableView];
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    self.title = NSLocalizedString(@"settings.about",@"About");
    
#if FC_MAC
    self.navigationItem.leftBarButtonItem = self.closeBtn;
#endif
    

    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:true];
    NSString *type = [[FCConfig shared] getStringValueOfKey:GroupUserDefaultsKeyAppearanceMode];
    if([@"System" isEqual:type]) {
        [[UIApplication sharedApplication].keyWindow setOverrideUserInterfaceStyle:UIUserInterfaceStyleUnspecified];
    } else if([@"Dark" isEqual:type]){
        [[UIApplication sharedApplication].keyWindow setOverrideUserInterfaceStyle:UIUserInterfaceStyleDark];
    }else if([@"Light" isEqual:type]){
        [[UIApplication sharedApplication].keyWindow setOverrideUserInterfaceStyle:UIUserInterfaceStyleLight];
    }
    [self.tableView setFrame:self.view.bounds];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSource.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }
    return ((NSArray *)self.dataSource[section - 1][@"cells"]).count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"";
    }
    return self.dataSource[section - 1][@"section"];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    
    if(indexPath.section == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        [cell.contentView addSubview:[self createAboutHeaderView]];
        cell.contentView.backgroundColor = FCStyle.background;
        return cell;
    } else {
        _AbountTableViewCell *cell = nil;
        NSDictionary *entity = self.dataSource[indexPath.section - 1][@"cells"][indexPath.row];
        cell = [[_AbountTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.entity = entity;
        return cell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0) {
        return 215;
    }
#ifdef FC_MAC
    return 35.0;
#else
    return 45.0;
#endif
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return 1.0F;
    }
    return 20;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 0) {
        return;
    }
    
    NSDictionary *dict = self.dataSource[indexPath.section - 1][@"cells"][indexPath.row];
    NSString *url = dict[@"url"];
    if (url.length > 0){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]
                                           options:@{} completionHandler:^(BOOL succeed){}];
    }
}

- (void)clickClose:(id)sender{
    [self dismissModalViewControllerAnimated:true];
}

- (NSArray *)dataSource{
    if (nil == _dataSource){
        _dataSource = @[
            @{
                @"section":NSLocalizedString(@"Social", @"Social"),
                @"cells":@[
                    @{@"title":NSLocalizedString(@"settings.joinTelegram",@"")
                      ,@"url":@"https://t.me/fastclipchat",
                      @"subtitle":@"t.me/fastclipchat",
                    },
                    @{@"title":NSLocalizedString(@"settings.joinQQ",@""),@"url":@"mqqapi://card/show_pslcard?src_type=internal&version=1&uin=714147685&key=c987123ea55d74e0b3fa84e3169d6be6d24fb1849e78f57c0f573e9d45e67217&card_type=group&source=external&jump_from=webapi"},
                    @{@"title":NSLocalizedString(@"settings.joinTwitter",@""),
                      @"url":@"https://mobile.twitter.com/stayfork",
                      @"subtitle":@"@stayfork"
                    }
                ]
            },
            @{
                @"section":NSLocalizedString(@"SendFeedback",@"SEND FEEDBACK"),
                @"cells":@[
                    @{@"title":NSLocalizedString(@"settings.plan",@"plan")
                      ,@"url":@"https://www.craft.do/s/N2icWbhYff2c3K"
                    },
                    @{@"title":NSLocalizedString(@"settings.sendFeedback",@"SEND FEEDBACK")
                      ,@"url":[[NSString stringWithFormat:@"mailto:feedback@fastclip.app?subject=Feedback - %@/%@",
                                [self appString],
                                [[API shared] deviceInfo]]
                               stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                      @"subtitle":@"feedback@fastclip.app",
                    },
                ]
            },
            @{
                @"section":NSLocalizedString(@"Legal",@"LEGAL"),
                @"cells":@[
                    @{@"title":NSLocalizedString(@"settings.termOfUse",@"Term Of User")
                      ,@"url":@"https://fastclip.app/policy/terms-stay.htm",
                    },
                    @{@"title":NSLocalizedString(@"settings.privacyPolicy",@"privacy policy")
                      ,@"url":@"https://www.privacypolicyonline.com/live.php?token=ZPXT0Jfv2diYUfbf5ciLDV9oYRgJ6Evc",
                    }
                ]
            }
        ];
    }
    
    return _dataSource;
}

- (UIView *)createAboutHeaderView {
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width - 30, 215)];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 160, 160)];
    imageView.image = [UIImage imageNamed:@"stay-mac1024-1"];
    imageView.centerX = (self.view.width - 30) / 2;
    [backView addSubview:imageView];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width - 30, 24)];
    title.text = @"Stay";
    title.font = FCStyle.title3Bold;
    title.top = imageView.bottom + 5;
    title.textAlignment = NSTextAlignmentCenter;
    [backView addSubview:title];
    
    UILabel *build = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width - 30, 18)];
    build.text = [NSString stringWithFormat:@"%@ (%@)",[infoDictionary objectForKey:@"CFBundleShortVersionString"],[infoDictionary objectForKey:@"CFBundleVersion"]];
    
    build.font = FCStyle.body;
    build.textAlignment = NSTextAlignmentCenter;
    build.textColor = FCStyle.fcSecondaryBlack;
    build.top = title.bottom + 5;
    [backView addSubview:build];
    return backView;
}

- (NSString *)appString{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    return [NSString stringWithFormat:@"%@ %@ (%@)",
            [infoDictionary objectForKey:@"CFBundleDisplayName"],
            [infoDictionary objectForKey:@"CFBundleShortVersionString"],
            [infoDictionary objectForKey:@"CFBundleVersion"]
    ];
}


- (UITableView *)tableView{
    if (nil == _tableView){
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleInsetGrouped];
//#if FC_MAC
//        _tableView.width = 540;
//#endif
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
