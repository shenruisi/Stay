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
#import "FCShared.h"
#import "SYHomeViewController.h"
#import "ICloudSyncSlideController.h"
#import "TimeHelper.h"

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
    __block BOOL on = sender.on;
    UIViewController *cer = ((ICloudSyncSlideController *)self.navigationController.slideController).cer;
    if (!on){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"iCloud"
                                                                       message:NSLocalizedString(@"iCloudTrunOffTips", @"")
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *conform = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"")
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
            [self saveICloudStatusAndPostNotification:on];
        }];
        [alert addAction:conform];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"")
                                                          style:UIAlertActionStyleCancel
                                                        handler:^(UIAlertAction * _Nonnull action) {
            on = YES;
            [self saveICloudStatusAndPostNotification:on];
            [cer.navigationController popViewControllerAnimated:YES];
        }];
        [alert addAction:cancel];
        [cer presentViewController:alert animated:YES completion:nil];
    }
    else{
        if (FCShared.iCloudService.isLogin){
            [FCShared.iCloudService checkFirstInit:^(BOOL firstInit, NSError * _Nonnull error) {
                if (error){
                    on = NO;
                    [self saveICloudStatusAndPostNotification:on];
                    [FCShared.iCloudService showError:error inCer:cer];
                    return;
                }
                
                if (firstInit){
                    dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"iCloud"
                                                                                   message:NSLocalizedString(@"icloud.firstInit", @"")
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *conform = [UIAlertAction actionWithTitle:NSLocalizedString(@"icloud.syncNow", @"")
                                                                      style:UIAlertActionStyleDefault
                                                                    handler:^(UIAlertAction * _Nonnull action) {
                        [FCShared.iCloudService initUserscripts:((SYHomeViewController *)cer).userscripts completionHandler:^(NSError * _Nonnull error) {
                            if (error){
                                [FCShared.iCloudService showError:error inCer:cer];
                            }
                            else{
                                [[FCConfig shared] setStringValueOfKey:GroupUserDefaultsKeyLastSync value:[TimeHelper current]];
                            }
                        }];
                    }];
                    [alert addAction:conform];
                    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"")
                                                                      style:UIAlertActionStyleCancel
                                                                    handler:^(UIAlertAction * _Nonnull action) {
                        [cer.navigationController popViewControllerAnimated:YES];
                    }];
                    [alert addAction:cancel];
                    [cer presentViewController:alert animated:YES completion:nil];
                });
                }
                [self saveICloudStatusAndPostNotification:on];
            }];
        }
    }
    
    
}

- (void)saveICloudStatusAndPostNotification:(BOOL)status{
    [[FCConfig shared] setBoolValueOfKey:GroupUserDefaultsKeySyncEnabled value:status];
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
