//
//  SYInviteViewController.m
//  Stay
//
//  Created by zly on 2023/5/26.
//

#import "SYInviteViewController.h"
#import "InviteProgressView.h"
#import "FCStyle.h"
#import "API.h"
#import "DeviceHelper.h"
#import "InviteDetail.h"
#import "SYInviteCardController.h"
#import "UserScript.h"
#import "FCImageView.h"

@interface InviteImageView:UIView
@property (nonatomic, strong) UIView *inviteView;
@property (nonatomic, strong) FCImageView *iconImageView;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) UILabel *nameLabel;
@end

@implementation InviteImageView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}
- (void)setupUI {
    
}
@end

@interface InviteRulesView:UIView

@end

@implementation InviteRulesView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 13, 100, 21)];
    titleLab.text = NSLocalizedString(@"InviteRule",@"InviteFriend");
    titleLab.font = FCStyle.headlineBold;
    titleLab.textColor = FCStyle.fcBlack;
    titleLab.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLab];
    titleLab.centerX = self.width / 2;
    
    UILabel *descLab = [[UILabel alloc] initWithFrame:CGRectMake(11, 0, 322, 100)];
    descLab.text = NSLocalizedString(@"InviteRuleDesc",@"InviteFriend");
    descLab.font = FCStyle.footnote;
    descLab.numberOfLines = 0;
    descLab.textColor = FCStyle.subtitleColor;
    descLab.textAlignment = NSTextAlignmentCenter;
    [descLab sizeToFit];
    [self addSubview:descLab];
    
    descLab.top = titleLab.bottom + 12;
    descLab.centerX = self.width / 2;
    
    self.height = descLab.bottom + 27;
}

@end


@interface HowToInviteView:UIView

@end

@implementation HowToInviteView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 13, 100, 21)];
    titleLab.text = NSLocalizedString(@"HowToInvite",@"");
    titleLab.font = FCStyle.headlineBold;
    titleLab.textColor = FCStyle.fcBlack;
    titleLab.textAlignment = NSTextAlignmentLeft;
    [titleLab sizeToFit];
    [self addSubview:titleLab];
//    titleLab.centerX = self.width / 2;
    
    UILabel *descLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 322, 100)];
    descLab.text = NSLocalizedString(@"HowToInviteDesc",@"InviteFriend");
    descLab.font = FCStyle.footnote;
    descLab.numberOfLines = 0;
    descLab.textColor = FCStyle.subtitleColor;
    descLab.textAlignment = NSTextAlignmentLeft;
    [descLab sizeToFit];
    [self addSubview:descLab];
    
    descLab.top = titleLab.bottom + 12;
    self.height = descLab.bottom + 15;
    
    
    
}

@end


@interface SYInviteViewController () <
UITableViewDelegate,
UITableViewDataSource
>
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) InviteProgressView *inviteView;
@property (nonatomic, strong) UILabel *pointLabel;
@property (nonatomic, strong) UILabel *inviteLabel;
@property (nonatomic, strong) InviteRulesView *inviteRulesView;
@property (nonatomic, strong) HowToInviteView *howToInviteView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *inviteBtn;
@property (nonatomic, assign) Boolean *started;
@property (nonatomic, strong) SYInviteCardController *inviteCardController;


@end

@implementation SYInviteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.hidesBottomBarWhenPushed = true;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    self.title = NSLocalizedString(@"InviteFriend",@"InviteFriend");
    [self tableView];
    
    
    [[API shared]  queryPath:@"/invite-task/detail"
                        pro:NO
                   deviceId:DeviceHelper.uuid
                        biz:nil
                 completion:^(NSInteger statusCode, NSError * _Nonnull error, NSDictionary * _Nonnull server, NSDictionary * _Nonnull biz) {
        NSLog(@"%@",biz);
        
        if(biz != NULL) {
            InviteDetail *inviteDetail = [InviteDetail ofDictionary:biz];
            if(inviteDetail.inviteCode.length > 0) {
                self.started = true;
            }
            dispatch_async(dispatch_get_main_queue(), ^{

                    self.inviteView.titleArray = inviteDetail.process;
                    if (! [[UserScript localeCodeLanguageCodeOnly] isEqualToString:@"zh"]) {
                        self.inviteCardController.dateStr = inviteDetail.sinceEn;
                    } else {
                        self.inviteCardController.dateStr = inviteDetail.sinceCn;
                    }
                    self.inviteCardController.imageList = inviteDetail.candidateCovers;
                    [self.inviteView updateProgress:0.5];
            });
        }
    }];
    
   
}

- (void)inviteCreate:(UIButton *)sender {
    if (!self.inviteCardController.isShown){
        [self.inviteCardController show];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                       reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:self.iconImageView];
        [cell.contentView addSubview:self.pointLabel];
        self.pointLabel.top = self.iconImageView.bottom + 24;
        [cell.contentView addSubview:self.inviteView];
        self.inviteView.top = self.pointLabel.bottom + 11;
        [cell.contentView addSubview:self.inviteLabel];
        self.inviteLabel.top = self.inviteView.bottom + 21;
        [cell.contentView addSubview:self.inviteRulesView];
        self.inviteRulesView.top = self.inviteView.bottom + 21;

 
        [cell.contentView addSubview:self.howToInviteView];
        self.howToInviteView.top = self.inviteRulesView.bottom + 15;
        
        [cell.contentView addSubview:self.inviteBtn];
         
        if(_started) {
                
        } else {
            self.inviteBtn.top = self.howToInviteView.bottom + 23;
        }
        return cell;
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(_started) {
        return 1375;
    } else {
        return 647;
    }
}


- (UIImageView *)iconImageView {
    if(_iconImageView == nil) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 25, 100, 100)];
        _iconImageView.centerX = self.view.centerX;
        [_iconImageView setImage:[UIImage imageNamed:@"InviteBigIcon"]];
    }
    return _iconImageView;
}


- (InviteProgressView *)inviteView {
    if(_inviteView == nil) {
        _inviteView = [[InviteProgressView alloc] initWithFrame:CGRectMake(21, 0, 348, 69)];
        _inviteView.backgroundColor = FCStyle.fcWhite;
        _inviteView.layer.cornerRadius = 10;
    }
    
    return _inviteView;
}

- (UILabel *)pointLabel {
    if(_pointLabel == nil) {
        _pointLabel = [[UILabel alloc] initWithFrame:CGRectMake(19, 149, 120, 18)];
        _pointLabel.font = FCStyle.subHeadlineBold;
        _pointLabel.textColor = FCStyle.subtitleColor;
        _pointLabel.text = NSLocalizedString(@"PointProgress", @"");
        _pointLabel.top = self.iconImageView.bottom + 24;
    }
    return _pointLabel;
}

- (UILabel *)inviteLabel {
    if(_inviteLabel == nil) {
        _inviteLabel = [[UILabel alloc] initWithFrame:CGRectMake(19, 0, 240, 18)];
        _inviteLabel.font = FCStyle.subHeadlineBold;
        _inviteLabel.textColor = FCStyle.subtitleColor;
        _inviteLabel.text = NSLocalizedString(@"InviteToGetPoint", @"");
        _inviteLabel.top = self.inviteView.bottom + 21;
    }
    return _inviteLabel;
}

- (InviteRulesView *)inviteRulesView {
    if(_inviteRulesView == nil) {
        _inviteRulesView = [[InviteRulesView alloc] initWithFrame:CGRectMake(19, 0, self.view.width - 38, 300)];
        _inviteRulesView.layer.cornerRadius = 10;
        _inviteRulesView.backgroundColor = FCStyle.fcWhite;
    }
    return _inviteRulesView;
}

- (HowToInviteView *)howToInviteView {
    if(_howToInviteView == nil) {
        _howToInviteView = [[HowToInviteView alloc] initWithFrame:CGRectMake(19, 0, self.view.width - 38, 70)];
        _howToInviteView.layer.cornerRadius = 10;
        _howToInviteView.backgroundColor = FCStyle.fcWhite;
    }
    return _howToInviteView;
}

- (UIButton *)inviteBtn {
    if(_inviteBtn == nil) {
        _inviteBtn = [[UIButton alloc] initWithFrame:CGRectMake(19, 0, self.view.width - 38, 45)];
        [_inviteBtn setTitle:@"Start Gifting" forState:UIControlStateNormal];
        [_inviteBtn setTitleColor:FCStyle.accent forState:UIControlStateNormal];
        [_inviteBtn addTarget:self action:@selector(inviteCreate:) forControlEvents:UIControlEventTouchUpInside];
        _inviteBtn.font = FCStyle.bodyBold;
        _inviteBtn.layer.borderColor = FCStyle.accent.CGColor;
        _inviteBtn.layer.borderWidth = 1;
        _inviteBtn.layer.cornerRadius = 10;
    }
    return _inviteBtn;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        if (@available(iOS 15.0, *)){
           _tableView.sectionHeaderTopPadding = 0;
        }
        _tableView.sectionFooterHeight = 0;
        [self.view addSubview:_tableView];
                
        [NSLayoutConstraint activateConstraints:@[
            [_tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
            [_tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
            [_tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
            [_tableView.heightAnchor constraintEqualToConstant:self.view.height - self.navigationController.tabBarController.tabBar.height]
        ]];
        
    }
    return _tableView;
}


- (SYInviteCardController *)inviteCardController {
    if(_inviteCardController == nil) {
        _inviteCardController = [[SYInviteCardController alloc] init];
        
    }
    return _inviteCardController;
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
