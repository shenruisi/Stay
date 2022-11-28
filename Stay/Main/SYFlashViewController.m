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
#ifdef Mac
        if ([QuickAccess primaryController] != nil){
            [QuickAccess primaryController].selectedIndex = 2;         
        }
#else
        if([UIApplication sharedApplication].keyWindow.rootViewController != nil) {
            ((UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController).selectedIndex = 1;
        }
#endif
//    nav.tabBarController.selectedIndex = 1;
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


@end
