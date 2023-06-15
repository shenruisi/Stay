//
//  SYInviteTaskController.m
//  Stay
//
//  Created by zly on 2023/6/12.
//

#import "SYInviteTaskController.h"
#import "FCStyle.h"
#import "API.h"
#import "DeviceHelper.h"
#import "FCApp.h"
#import "SYInviteViewController.h"
#import <SafariServices/SafariServices.h>

@interface InviteTaskCell:UITableViewCell
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) UILabel *pointLabel;

@property (nonatomic, strong) NSDictionary *dic;
@property (nonatomic, strong) UIImageView *accessory;
@end


@implementation InviteTaskCell
- (void)setUpUI {
    [self backView];
    self.titleLabel.text = _dic[@"title"];
    self.subTitleLabel.text = _dic[@"desc"];
    [self accessory];
    [self pointLabel];
}

- (UIView *)backView {
    if(nil == _backView) {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = FCStyle.secondaryPopup;
        _backView.layer.cornerRadius = 10;
        _backView.layer.masksToBounds = YES;
        _backView.translatesAutoresizingMaskIntoConstraints = NO;

        [self.contentView addSubview:_backView];
        [NSLayoutConstraint activateConstraints:@[
            [_backView.heightAnchor constraintEqualToConstant:70],
            [_backView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:15],
            [_backView.topAnchor constraintEqualToAnchor:self.backView.topAnchor constant:15],
            [_backView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-15],

        ]];
    }
    
    return _backView;
}

- (UILabel *)titleLabel{
    if (nil == _titleLabel){
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = FCStyle.bodyBold;
        _titleLabel.textColor = FCStyle.fcBlack;
        _titleLabel.userInteractionEnabled = NO;
        _titleLabel.translatesAutoresizingMaskIntoConstraints = false;
        [self.backView addSubview:_titleLabel];
        [NSLayoutConstraint activateConstraints:@[
            [_titleLabel.heightAnchor constraintEqualToConstant:19],
            [_titleLabel.leadingAnchor constraintEqualToAnchor:self.backView.leadingAnchor constant:10],
            [_titleLabel.topAnchor constraintEqualToAnchor:self.backView.topAnchor constant:13]
        ]];
    }
    
    return _titleLabel;
}

- (UILabel *)subTitleLabel {
    if (nil == _subTitleLabel){
        _subTitleLabel = [[UILabel alloc] init];
        _subTitleLabel.font = FCStyle.footnote;
        _subTitleLabel.textColor = FCStyle.subtitleColor;
        _subTitleLabel.userInteractionEnabled = NO;
        _subTitleLabel.translatesAutoresizingMaskIntoConstraints = false;
        [self.backView addSubview:_subTitleLabel];
        [NSLayoutConstraint activateConstraints:@[
            [_subTitleLabel.heightAnchor constraintEqualToConstant:20],
            [_subTitleLabel.leadingAnchor constraintEqualToAnchor:self.backView.leadingAnchor constant:10],
            [_subTitleLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:4]
        ]];
    }
    
    return _subTitleLabel;
}

- (UIImageView *)accessory{
    if (nil == _accessory){
        _accessory = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 13, 18)];
        _accessory.translatesAutoresizingMaskIntoConstraints = false;

        UIImage *image = [UIImage systemImageNamed:@"chevron.right"
                                 withConfiguration:[UIImageSymbolConfiguration configurationWithFont:[UIFont systemFontOfSize:13]]];
        image = [image imageWithTintColor:FCStyle.fcSecondaryBlack renderingMode:UIImageRenderingModeAlwaysOriginal];
        [_accessory setImage:image];
        [self.backView addSubview:_accessory];
        [NSLayoutConstraint activateConstraints:@[
            [_accessory.heightAnchor constraintEqualToConstant:13],
            [_accessory.widthAnchor constraintEqualToConstant:10],
            [_accessory.trailingAnchor constraintEqualToAnchor:self.backView.trailingAnchor constant:-13],
            [_accessory.centerYAnchor constraintEqualToAnchor:self.backView.centerYAnchor]
        ]];
        
    }
    
    return _accessory;
}

- (UILabel *)pointLabel {
    if(nil == _pointLabel) {
        _pointLabel = [[UILabel alloc] init];
        _pointLabel.textColor = FCStyle.accent;
        _pointLabel.font = FCStyle.bodyBold;
        _pointLabel.text =  [NSString stringWithFormat:@"%ld Points",[_dic[@"point_value"] integerValue]] ;
        _pointLabel.translatesAutoresizingMaskIntoConstraints = false;
        [self.backView addSubview:_pointLabel];
        [NSLayoutConstraint activateConstraints:@[
            [_pointLabel.heightAnchor constraintEqualToConstant:19],
            [_pointLabel.rightAnchor constraintEqualToAnchor:self.accessory.leftAnchor constant:-13],
            [_pointLabel.centerYAnchor constraintEqualToAnchor:self.backView.centerYAnchor]
        ]];

    }
    return _pointLabel;
}


@end

@interface SYInviteTaskController()<
UITableViewDelegate,
UITableViewDataSource
>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *taskArray;
@property (nonatomic, strong) UIButton *subButton;
@property (nonatomic, strong) NSMutableDictionary *rewardBlockDic;
@property (nonatomic, strong) NSMutableDictionary *webRewardBlockDic;
@property (nonatomic, strong) UILabel *pointRules;


@end
@implementation SYInviteTaskController

- (void)viewDidLoad {
    self.navigationBar.hidden = NO;
    self.navigationBar.showCancel = YES;

    self.title = NSLocalizedString(@"GetMorePoint", @"");
    [[API shared] queryPath:@"/tasks"
                        pro:NO
                   deviceId:DeviceHelper.uuid
                        biz:nil
                 completion:^(NSInteger statusCode, NSError * _Nonnull error, NSDictionary * _Nonnull server, NSDictionary * _Nonnull biz) {


        _taskArray = biz[@"tasks"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    }];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(SYViewWillAppear:)
                                                 name:@"SYViewWillAppear"
                                               object:nil];
    [self subButton];
    
    [self pointRules];
    self.pointRules.bottom = self.subButton.top - 15;
    self.pointRules.centerX = self.subButton.centerX;
}

- (void)howPoint {
    NSString *url = @"https://www.craft.do/s/waHJPeiNdBTuli";
    
#ifdef FC_MAC
        [FCShared.plugin.appKit openUrl:[NSURL URLWithString:url stringByAddingPercentEncodingWithAllowedCharacters:set]]];
#else
        if (FCDeviceTypeIPhone == DeviceHelper.type){
            SFSafariViewController *safariVc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:url]];
            [self.nav presentViewController:safariVc animated:YES completion:nil];
        }
#endif
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    InviteTaskCell *cell = [[InviteTaskCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SYTaskCell"];
    cell.backgroundColor = FCStyle.popup;
    cell.dic = _taskArray[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setUpUI];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(_taskArray == NULL) {
        return 0;
    } else {
        return  _taskArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 85;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = _taskArray[indexPath.row];
    if([@"invite" isEqualToString: dic[@"type"]]) {
#ifdef FC_MAC
            [self presentViewController:
             [[UINavigationController alloc] initWithRootViewController:[[SYInviteViewController alloc] init]]
                               animated:YES completion:^{}];
#else
            [self.nav pushViewController:[[SYInviteViewController alloc] init] animated:YES];
#endif
        
        [self.navigationController.slideController dismiss];
    } else if ([@"generic" isEqualToString: dic[@"type"]]) {
        
        
        NSData *jsonData = [dic[@"action_json"] dataUsingEncoding:NSUTF8StringEncoding];


        NSDictionary *action = [NSJSONSerialization JSONObjectWithData:jsonData

        options:NSJSONReadingMutableContainers

        error:nil];
        
        if([@"app" isEqualToString:action[@"type"]]) {
            if(self.rewardBlockDic[dic[@"uuid"]] == NULL) {
                
       
                
                if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:action[@"url"]]]){
                    
                    [[API shared] queryPath:@"/generic-task/init"
                                        pro:NO
                                   deviceId:DeviceHelper.uuid
                                        biz:@{@"task_id":dic[@"uuid"]}
                                 completion:^(NSInteger statusCode, NSError * _Nonnull error, NSDictionary * _Nonnull server, NSDictionary * _Nonnull biz) {
                    }];
                    
                    
                    dispatch_block_t rewardBlock =  dispatch_block_create(0, ^{
                        [[API shared] queryPath:@"/generic-task/commit"
                                            pro:NO
                                       deviceId:DeviceHelper.uuid
                                            biz:@{@"task_id":dic[@"uuid"]}
                                     completion:^(NSInteger statusCode, NSError * _Nonnull error, NSDictionary * _Nonnull server, NSDictionary * _Nonnull biz) {
                        }];
                    });
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([action[@"duration"] floatValue] * NSEC_PER_SEC)), dispatch_get_main_queue(), rewardBlock);
                    self.rewardBlockDic[dic[@"uuid"]] = rewardBlock;
                    
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:action[@"url"]]];
                }
            
            }
        } else if([@"web" isEqualToString:action[@"type"]]) {
            
            [[API shared] queryPath:@"/generic-task/init"
                                pro:NO
                           deviceId:DeviceHelper.uuid
                                biz:@{@"task_id":dic[@"uuid"]}
                         completion:^(NSInteger statusCode, NSError * _Nonnull error, NSDictionary * _Nonnull server, NSDictionary * _Nonnull biz) {
            }];
            
            dispatch_block_t rewardBlock =  dispatch_block_create(0, ^{
                [[API shared] queryPath:@"/generic-task/commit"
                                    pro:NO
                               deviceId:DeviceHelper.uuid
                                    biz:@{@"task_id":dic[@"uuid"]}
                             completion:^(NSInteger statusCode, NSError * _Nonnull error, NSDictionary * _Nonnull server, NSDictionary * _Nonnull biz) {
                    
                    NSLog(@"请求成功了");
                }];
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([action[@"duration"] floatValue] * NSEC_PER_SEC)), dispatch_get_main_queue(), rewardBlock);
            self.webRewardBlockDic[dic[@"uuid"]] = rewardBlock;
#ifdef FC_MAC
        [FCShared.plugin.appKit openUrl:[NSURL URLWithString:action[@"url"] stringByAddingPercentEncodingWithAllowedCharacters:set]]];
#else
        if (FCDeviceTypeIPhone == DeviceHelper.type){
            SFSafariViewController *safariVc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:action[@"url"]]];
            [self.nav presentViewController:safariVc animated:YES completion:nil];
        }
#endif
        }
        
    }
}


- (void)backLast:(UIButton *)sender {
    if(_needBack) {
        [self.navigationController popModalViewController];
    } else {
        [self.navigationController.slideController dismiss];
    }
}

- (UITableView *)tableView{
    if (nil == _tableView){
        _tableView = [[UITableView alloc] init];
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        //TODO:
        if (@available(ios 15.0, *)){
           _tableView.sectionHeaderTopPadding = 0;
        }
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.sectionFooterHeight = 0;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.backgroundColor = FCStyle.popup;
        [self.view addSubview:_tableView];
        [[_tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor] setActive:YES];
        [[_tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor] setActive:YES];
        [[_tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:10] setActive:YES];
        [[_tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-10-10-45 - 40] setActive:YES];
    }
    return _tableView;
}

- (UIButton *)subButton{
    if (nil == _subButton){
        _subButton = [[UIButton alloc] initWithFrame:CGRectMake(15, self.view.height - 10 - 45, self.view.frame.size.width - 30, 45)];

        [_subButton setAttributedTitle:[[NSAttributedString alloc] initWithString:_needBack?NSLocalizedString(@"BacktoDownload", @""):NSLocalizedString(@"TryAgain", @"")
                                                                                 attributes:@{
                             NSForegroundColorAttributeName : FCStyle.accent,
                             NSFontAttributeName : FCStyle.bodyBold}]
                                        forState:UIControlStateNormal];
        [_subButton addTarget:self
                                 action:@selector(backLast:)
                       forControlEvents:UIControlEventTouchUpInside];
        _subButton.backgroundColor = UIColor.clearColor;
        _subButton.layer.borderColor = FCStyle.accent.CGColor;
        _subButton.layer.borderWidth = 1;
        _subButton.layer.cornerRadius = 10;
        _subButton.layer.masksToBounds = YES;
        [self.view addSubview:_subButton];
    }
    
    return _subButton;
}

- (NSMutableDictionary *)rewardBlockDic {
    if(nil == _rewardBlockDic) {
        _rewardBlockDic = [NSMutableDictionary dictionary];
    }
    return _rewardBlockDic;
}

- (NSMutableDictionary *)webRewardBlockDic {
    if(nil == _webRewardBlockDic) {
        _webRewardBlockDic = [NSMutableDictionary dictionary];
    }
    return _webRewardBlockDic;
}

- (UILabel *)pointRules {
    if(nil == _pointRules) {
        _pointRules = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 18)];
        
        NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"PonitRules", @"")];
        NSRange contentRange = {0, [content length] - 1};
        [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
          
        _pointRules.attributedText = content;
        _pointRules.textColor = FCStyle.accent;
        _pointRules.font = FCStyle.bodyBold;
        _pointRules.textAlignment = NSTextAlignmentCenter;
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(howPoint)];
        [_pointRules addGestureRecognizer:gesture];
        [self.view addSubview:_pointRules];

    }
    return _pointRules;
    
}

- (CGSize)mainViewSize{
    return CGSizeMake(MIN(FCApp.keyWindow.frame.size.width - 30, 360), 487);
}

- (void)SYViewWillAppear:(NSNotification *)notification {
    if(self.webRewardBlockDic.count > 0) {
        for (dispatch_block_t rewardBlock in self.webRewardBlockDic.allValues) {
            dispatch_block_cancel(rewardBlock);
        }
        [self.webRewardBlockDic removeAllObjects];
        
        
        [[API shared] queryPath:@"/tasks"
                            pro:NO
                       deviceId:DeviceHelper.uuid
                            biz:nil
                     completion:^(NSInteger statusCode, NSError * _Nonnull error, NSDictionary * _Nonnull server, NSDictionary * _Nonnull biz) {


            _taskArray = biz[@"tasks"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
        }];
    }
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    if(self.rewardBlockDic.count > 0) {
        for (dispatch_block_t rewardBlock in self.rewardBlockDic.allValues) {
            dispatch_block_cancel(rewardBlock);
        }
        [self.rewardBlockDic removeAllObjects];
        [[API shared] queryPath:@"/tasks"
                            pro:NO
                       deviceId:DeviceHelper.uuid
                            biz:nil
                     completion:^(NSInteger statusCode, NSError * _Nonnull error, NSDictionary * _Nonnull server, NSDictionary * _Nonnull biz) {


            _taskArray = biz[@"tasks"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
        }];
    }
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
