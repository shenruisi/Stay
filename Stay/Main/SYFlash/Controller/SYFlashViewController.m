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

    // Do any additional setup after loading the view.
}

- (void)onBecomeActive{

    [SharedStorageManager shared].userDefaults = nil;
    if([SharedStorageManager shared].userDefaults.safariExtensionEnabled) {
        self.firstView.activite = true;
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
}

- (FirstFlashView *)firstView {
    if (_firstView == nil) {
        _firstView = [[FirstFlashView alloc] initWithFrame:CGRectMake(0, 0, self.view.width * 2,  self.view.height)];
        _firstView.scrollEnabled = NO;
        _firstView.selectedCount = 0;
        [_firstView createFirstView];
    }
    
    return _firstView;
}


@end