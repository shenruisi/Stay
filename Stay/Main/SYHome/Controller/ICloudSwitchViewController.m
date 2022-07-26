//
//  ICloudSwitchViewController.m
//  Stay
//
//  Created by ris on 2022/7/25.
//

#import "ICloudSwitchViewController.h"
#import "FCStyle.h"
#import "SYMoreViewController.h"
#import "FCConfig.h"

@interface ICloudSwitchViewController()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UISwitch *switchButton;
@end

@implementation ICloudSwitchViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"iCloudFeature", @"");
    UIView *cell = [[UIView alloc] initWithFrame:CGRectMake(15, 15, self.view.frame.size.width - 30, 45)];
    cell.layer.cornerRadius = 10;
    cell.backgroundColor = FCStyle.secondaryPopup;
    [cell addSubview:self.titleLabel];
    [cell addSubview:self.switchButton];
    self.switchButton.top = 8;
    self.switchButton.right = self.view.frame.size.width - 45;
    [self.view addSubview:cell];
}

- (void)viewWillAppear{
    [super viewWillAppear];
    self.switchButton.on = [[FCConfig shared] getBoolValueOfKey:GroupUserDefaultsKeySyncEnabled];
}

- (UILabel *)titleLabel{
    if (nil == _titleLabel){
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, (45 - 16) / 2, 100, 16)];
        _titleLabel.font =  FCStyle.body;
        _titleLabel.textColor = FCStyle.fcBlack;
        _titleLabel.text = @"iCloud";
    }
    
    return _titleLabel;
}

- (UISwitch *)switchButton{
    if (nil == _switchButton){
        _switchButton = [[UISwitch alloc] init];
        [_switchButton setOnTintColor:FCStyle.accent];
        [_switchButton addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _switchButton;
}

- (void)switchAction:(UISwitch *)sender{
    [[FCConfig shared] setBoolValueOfKey:GroupUserDefaultsKeySyncEnabled value:sender.on];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SYMoreViewReloadCellNotification object:nil userInfo:@{
        @"section":@(1),
        @"row":@(0),
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SYMoreViewReloadCellNotification object:nil userInfo:@{
        @"section":@(1),
        @"row":@(1),
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SYMoreViewICloudDidSwitchNotification object:nil];
}

- (CGSize)mainViewSize{
    return CGSizeMake(MIN(kScreenWidth - 30, 450), 150);
}

@end
