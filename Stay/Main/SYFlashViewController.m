//
//  SYFlashViewController.m
//  Stay
//
//  Created by zly on 2022/7/24.
//

#import "SYFlashViewController.h"
#import "FirstFlashView.h"
#import "FCStyle.h"
#import "SharedStorageManager.h"
#import "DeviceHelper.h"
#import "QuickAccess.h"

@interface SYFlashViewController ()

@property (nonatomic, strong) FirstFlashView *firstView;



@end

@implementation SYFlashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = FCStyle.fcWhite;
    [self.view addSubview:self.firstView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(closeFlash) name:@"closeFlash" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(downloadError:) name:@"downloadError" object:nil];

}

- (void)onBecomeActive{
    [SharedStorageManager shared].userDefaults = nil;
    if([SharedStorageManager shared].userDefaults.safariExtensionEnabled) {
        self.firstView.activite = YES;
        [self.firstView createFirstView];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)closeFlash {
    [self dismissViewControllerAnimated:YES completion:nil];
#ifdef FC_MAC
        if ([QuickAccess primaryController] != nil){
            [QuickAccess primaryController].selectedIndex = 1;
        }
#else
    if (FCDeviceTypeIPhone == [DeviceHelper type]){
        if([UIApplication sharedApplication].keyWindow.rootViewController != nil) {
            [((FCTabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController).fcTabBar selectIndex:2];
        }
    }
#endif
}

- (void)downloadError:(NSNotification *)notification {
    NSString *str = notification.object;
    if(str.length > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:str
                                                                           message:nil
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *conform = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"")
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
            [alert addAction:conform];
            [self presentViewController:alert animated:YES completion:nil];
        });
    }
}

- (FirstFlashView *)firstView {
    if (_firstView == nil) {
        CGFloat top = 40;
        if(self.isMore) {
            top = 0;
        }
        
        _firstView = [[FirstFlashView alloc] initWithFrame:CGRectMake(0, top, self.view.width * 3,  self.view.height)];
        if (FCDeviceTypeIPad == DeviceHelper.type){
            _firstView.width =704 * 3;
            _firstView.contentSize = CGSizeMake(_firstView.width, 850);
            _firstView.scrollEnabled = YES;
        } else {
            _firstView.scrollEnabled = NO;
        }
        _firstView.selectedCount = 0;
        [SharedStorageManager shared].userDefaults = nil;
        if([SharedStorageManager shared].userDefaults.safariExtensionEnabled) {
            _firstView.activite = YES;
        }
        [_firstView createFirstView];
    }
    
    return _firstView;
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"closeFlash"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"downloadError"
                                                  object:nil];
}

@end
