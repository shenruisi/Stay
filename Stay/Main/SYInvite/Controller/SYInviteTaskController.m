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
        _pointLabel.text = @"10 Points";
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
@end
@implementation SYInviteTaskController

- (void)viewDidLoad {
    self.navigationBar.hidden = NO;
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
    [self subButton];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    InviteTaskCell *cell = [[InviteTaskCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SYTaskCell"];
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
        [[_tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor] setActive:YES];
        [[_tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-10-10-45] setActive:YES];
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

- (CGSize)mainViewSize{
    return CGSizeMake(MIN(FCApp.keyWindow.frame.size.width - 30, 360), 447);
}

@end
