//
//  SYHomeViewController.m
//  Stay
//
//  Created by zly on 2021/11/9.
//

#import "SYHomeViewController.h"
#import "JSDetailCell.h"
#import "DataManager.h"
#import "SYDetailViewController.h"
#import "SYEditViewController.h"
#import "SYCodeMirrorView.h"
#import <StoreKit/StoreKit.h>
#import "SYNetworkUtils.h"
#import "Tampermonkey.h"
#import "SYVersionUtils.h"
#import "UserscriptUpdateManager.h"
#import "SYAddScriptController.h"
#import "SYWebScriptViewController.h"
#import "ScriptMananger.h"
#import "ScriptEntity.h"
#import <objc/runtime.h>
#import "UIImageView+WebCache.h"
#import "MatchPattern.h"
#import "SYSelectTabViewController.h"

#import <UniformTypeIdentifiers/UTCoreTypes.h>

#import "SharedStorageManager.h"
#import "FCStyle.h"
#import <CommonCrypto/CommonDigest.h>

#ifdef Mac
#import "ToolbarTrackView.h"
#import "FCSplitViewController.h"
#endif

#import "QuickAccess.h"

#import "ImportSlideController.h"
#import "SYTextInputViewController.h"
#import "LoadingSlideController.h"
#import "SYFlashViewController.h"

#import "FCShared.h"
#import "ImageHelper.h"
#import "UIView+Rotate.h"

#import "FCStore.h"
#import "FCConfig.h"

#import "SYMoreViewController.h"
#import "ICloudSyncSlideController.h"
#import "AlertHelper.h"
#import "TimeHelper.h"

#import "API.h"
#import "HomeDetailCell.h"
#import "DeviceHelper.h"
#import "ToastDebugger.h"
//#import <Bugsnag/Bugsnag.h>

static CGFloat kMacToolbar = 50.0;
static NSString *kRateKey = @"rate.2.3.0";
NSNotificationName const _Nonnull HomeViewShouldReloadDataNotification = @"app.stay.notification.HomeViewShouldReloadDataNotification";

@interface _iCloudView : UIView

@property (nonatomic, strong) UIImageView *sfImageView;
@property (nonatomic, strong) UIImageView *syncImageView;
@property (nonatomic, strong) NSString *sfName;
- (void)refreshIcon;
- (void)startAnimate;
- (void)stopAnimate;

@end

@implementation _iCloudView

- (void)startAnimate{
    self.sfName = @"icloud";
    self.sfImageView.image = [ImageHelper sfNamed:self.sfName font:FCStyle.sfNavigationBar color:FCStyle.fcMacIcon];
    self.syncImageView.hidden = NO;
    [self.syncImageView rotateWithDuration:1];
}

- (void)stopAnimate{
    self.sfName = @"checkmark.icloud";
    [self.syncImageView stopRotating];
    self.syncImageView.hidden = YES;
    self.sfImageView.image = [ImageHelper sfNamed:self.sfName font:FCStyle.sfNavigationBar color:FCStyle.fcMacIcon];
    
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    self.sfImageView.frame = self.bounds;
    self.syncImageView.frame = CGRectMake((self.sfImageView.frame.size.width - self.syncImageView.size.width) / 2+1,
                                          (self.sfImageView.frame.size.height - self.syncImageView.size.height) / 2+1, self.syncImageView.size.width, self.syncImageView.size.height);
    [self refreshIcon];
}

- (void)refreshIcon{
    FCPlan *plan = [[FCStore shared] getPlan:NO];
    if (plan == FCPlan.None){
        self.sfName = nil;
        self.sfImageView.image = nil;
    }
    else{
        BOOL iCloudEnabled = [[FCConfig shared] getBoolValueOfKey:GroupUserDefaultsKeySyncEnabled];
        if (iCloudEnabled){
            [FCShared.iCloudService refreshWithCompletionHandler:^(NSError *error) {
                if (nil == error){
                    self.sfName = FCShared.iCloudService.isLogin ?  @"checkmark.icloud" : @"person.icloud";
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.sfImageView.image = [ImageHelper sfNamed:self.sfName font:FCStyle.sfNavigationBar color:FCStyle.fcMacIcon];
                    });
                }
            }];
            
        }
        else{
            self.sfName = @"icloud.slash";
            self.sfImageView.image = [ImageHelper sfNamed:self.sfName font:FCStyle.sfNavigationBar color:FCStyle.fcMacIcon];
        }
        
    }
}

- (UIImageView *)sfImageView{
    if (nil == _sfImageView){
        _sfImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_sfImageView];
    }
    
    return _sfImageView;
}

- (UIImageView *)syncImageView{
    if (nil == _syncImageView){
        _syncImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 13, 13)];
        _syncImageView.contentMode = UIViewContentModeScaleAspectFit;
        _syncImageView.image = [ImageHelper sfNamed:@"arrow.2.circlepath" font:[UIFont boldSystemFontOfSize:13] color:FCStyle.fcMacIcon];
        [self.sfImageView addSubview:_syncImageView];
        _syncImageView.hidden = YES;
        [self addSubview:_syncImageView];
    }
    
    return _syncImageView;
}

@end

@interface _EmptyTipsView : UIView

@property (nonatomic, strong) UILabel *part1Label;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) UILabel *part2Label;
@end

@implementation _EmptyTipsView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        [self part1Label];
        [self.part1Label sizeToFit];
        [self addButton];
        [self part2Label];
        [self.part2Label sizeToFit];
    }
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    CGFloat width = self.part1Label.width + self.part2Label.width + self.addButton.width;
    CGFloat left = (self.width - width) / 2;
    CGFloat y = (self.height - self.addButton.height) / 2;
    self.part1Label.frame = CGRectMake(left, y, self.part1Label.width, self.part1Label.height);
    self.addButton.frame = CGRectMake(self.part1Label.right, y, self.addButton.width, self.addButton.height);
    self.part2Label.frame = CGRectMake(self.addButton.right, y, self.part2Label.width, self.part2Label.height);
}

- (UILabel *)part1Label{
    if (nil == _part1Label){
        _part1Label = [[UILabel alloc] init];

        NSMutableAttributedString *builder = [[NSMutableAttributedString alloc] init];
        [builder appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"HomeEmptyTips1", @"") attributes:@{
            NSForegroundColorAttributeName:FCStyle.fcSecondaryBlack,
            NSFontAttributeName:FCStyle.body,
            NSObliquenessAttributeName:@(0.2)
            
        }]];
        _part1Label.attributedText = builder;
        [self addSubview:_part1Label];
    }
    
    return _part1Label;
}

- (UIButton *)addButton{
    if (nil == _addButton){
        _addButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
        [_addButton setImage:[ImageHelper sfNamed:@"plus" font:[UIFont boldSystemFontOfSize:16] color:FCStyle.accent] forState:UIControlStateNormal];
        [self addSubview:_addButton];
    }
    
    return _addButton;
}

- (UILabel *)part2Label{
    if (nil == _part2Label){
        _part2Label = [[UILabel alloc] init];

        NSMutableAttributedString *builder = [[NSMutableAttributedString alloc] init];
        [builder appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"HomeEmptyTips2", @"") attributes:@{
            NSForegroundColorAttributeName:FCStyle.fcSecondaryBlack,
            NSFontAttributeName:FCStyle.body,
            NSObliquenessAttributeName:@(0.2)
            
        }]];
        _part2Label.attributedText = builder;
        [self addSubview:_part2Label];
    }
    
    return _part2Label;
}

@end

@interface SYHomeViewController ()<
 UITableViewDelegate,
 UITableViewDataSource,
 UISearchResultsUpdating,
 UISearchBarDelegate,
 UISearchControllerDelegate,
 UIPopoverPresentationControllerDelegate,
 UIDocumentPickerDelegate
>

@property (nonatomic, strong) UIBarButtonItem *leftIcon;
@property (nonatomic, strong) UIBarButtonItem *iCloudIcon;
@property (nonatomic, strong) UIBarButtonItem *rightIcon;

@property (nonatomic, strong) _iCloudView *customView;

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *datas;
// 搜索结果数组
@property (nonatomic, strong) NSMutableArray *results;

@property (nonatomic, strong) SYSelectTabViewController *sYSelectTabViewController;

@property (nonatomic, assign) CGFloat safeAreaInsetsLeft;

@property (nonatomic, strong) UIView *line;

@property (nonatomic, copy) NSString *selectedUUID;

@property (nonatomic, strong) ImportSlideController *importSlideController;
@property (nonatomic, strong) ICloudSyncSlideController *iCloudSyncSlideController;

@property (nonatomic, strong) SYTextInputViewController *sYTextInputViewController;

@property (nonatomic, strong) LoadingSlideController *loadingSlideController;

@property (nonatomic, assign) NSInteger selectedRow;

@property (nonatomic, strong) _EmptyTipsView *emptyTipsView;
@end

@implementation SYHomeViewController

- (void)loadView{
#ifdef Mac
    ToolbarTrackView *view = [[ToolbarTrackView alloc] init];
//    view.toolbar = ((FCSplitViewController *)self.splitViewController).toolbar;
    self.view = view;
#else
    self.view = [[UIView alloc] init];
#endif
    
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    NSString *type = [[FCConfig shared] getStringValueOfKey:GroupUserDefaultsKeyAppearanceMode];
    if([@"System" isEqual:type]) {
        [[UIApplication sharedApplication].keyWindow setOverrideUserInterfaceStyle:UIUserInterfaceStyleUnspecified];
    } else if([@"Dark" isEqual:type]){
        [[UIApplication sharedApplication].keyWindow setOverrideUserInterfaceStyle:UIUserInterfaceStyleDark];
    }else if([@"Light" isEqual:type]){
        [[UIApplication sharedApplication].keyWindow setOverrideUserInterfaceStyle:UIUserInterfaceStyleLight];
    }
    
    self.selectedRow = -1;
    self.navigationItem.leftBarButtonItem = [self leftIcon];
    self.navigationItem.rightBarButtonItems = @[[self rightIcon],[self iCloudIcon]];
    self.view.backgroundColor = DynamicColor(RGB(28, 28, 28),[UIColor whiteColor]);
    UISearchController *search = [[UISearchController alloc]initWithSearchResultsController:nil];
       // 设置结果更新代理
//    search.searchResultsUpdater = self;
    search.searchBar.placeholder = NSLocalizedString(@"SearchAddedUserscripts", @"");
    self.navigationItem.searchController = search;
    self.navigationItem.searchController.delegate = self;
    self.navigationItem.searchController.searchBar.delegate = self;
    self.navigationItem.searchController.obscuresBackgroundDuringPresentation = false;
    self.searchController = search;
    self.searchController.delegate = self;
    self.searchController.searchBar.delegate = self;
    [self.searchController.searchBar setTintColor:FCStyle.accent];
    
    self.navigationItem.hidesSearchBarWhenScrolling = false;
    [_datas removeAllObjects];
    [_datas addObjectsFromArray:[[DataManager shareManager] findScript:1]];
    [self initScrpitContent];
    
#ifdef Mac
    [self line];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(navigateViewDidShow:)
                                                 name:@"app.stay.notification.NCCDidShowViewControllerNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(homeViewShouldReloadData:)
                                                 name:HomeViewShouldReloadDataNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onBecomeActive)
                                                 name:SVCDidBecomeActiveNotification
                                               object:nil];
#else
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(remoteSyncStart)
                                                 name:iCloudServiceSyncStartNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(remoteSyncEnd)
                                                 name:iCloudServiceSyncEndNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(subscibeDidChangeHandler:)
                                                 name:@"app.stay.notification.SYSubscibeChangeNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(iCloudDidChangeHandler:)
                                                 name:SYMoreViewICloudDidSwitchNotification
                                               object:nil];
    
#endif
    
   
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userscriptDidDeleteHandler:)
                                                 name:@"app.stay.notification.userscriptDidDeleteNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userscriptDidActiveHandler:)
                                                 name:@"app.stay.notification.userscriptDidActiveNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userscriptDidStopHandler:)
                                                 name:@"app.stay.notification.userscriptDidStopNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userscriptDidAddHandler:)
                                                 name:@"app.stay.notification.userscriptDidAddNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userscriptDidUpdateHandler:)
                                                 name:@"app.stay.notification.userscriptDidUpdateNotification"
                                               object:nil];
    
    self.view.backgroundColor = FCStyle.background;
    
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableDidSelected:) name:@"addScriptClick" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarChange) name:@"needUpdate" object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(linkAction:) name:@"linkAction" object:nil];

#ifndef Mac
    NSUserDefaults *groupUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dajiu.stay.pro"];
    if(nil == [groupUserDefaults objectForKey:@"tips"] && nil ==  [groupUserDefaults objectForKey:@"userDefaults.firstGuide"]){
        SYFlashViewController *cer = [[SYFlashViewController alloc] init];
        cer.modalPresentationStyle = 0;
        [self presentViewController:cer animated:YES completion:nil];
        [groupUserDefaults setObject:@(YES) forKey:@"userDefaults.firstGuide"];
    }
#endif
    
    self.tableView.sectionHeaderTopPadding = 0;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;

}



- (void)iCloudDidChangeHandler:(NSNotification *)note{
    [self.customView refreshIcon];
}

- (void)subscibeDidChangeHandler:(NSNotification *)note{
    UIImageView *imageView = self.leftIcon.customView;
    [imageView setImage:[[FCStore shared] getPlan:NO] != FCPlan.None ? [UIImage imageNamed:@"NavProIcon"] : [UIImage imageNamed:@"NavIcon"]];
    [self.customView refreshIcon];
}

- (void)userscriptDidDeleteHandler:(NSNotification *)note{
    BOOL iCloudEnabled = [[FCConfig shared] getBoolValueOfKey:GroupUserDefaultsKeySyncEnabled];
    if (iCloudEnabled && [[FCStore shared] getPlan:NO] != FCPlan.None && FCShared.iCloudService.isLogin){
        [[NSNotificationCenter defaultCenter] postNotificationName:iCloudServiceSyncStartNotification object:nil];
        NSString *uuid = note.userInfo[@"uuid"]; 
        [FCShared.iCloudService removeUserscript:uuid
                            completionHandler:^(NSError *error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:iCloudServiceSyncEndNotification object:nil];
            if (error){
                [FCShared.iCloudService showError:error inCer:self];
            }
            else{
                [[FCConfig shared] setStringValueOfKey:GroupUserDefaultsKeyLastSync value:[TimeHelper current]];
            }
        }];
    }
    
    if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
        && [QuickAccess splitController].viewControllers.count >= 2){
        [self reloadTableView];
        [self.tableView reloadData];
    }
}

- (void)userscriptDidActiveHandler:(NSNotification *)note{
    BOOL iCloudEnabled = [[FCConfig shared] getBoolValueOfKey:GroupUserDefaultsKeySyncEnabled];
    if (iCloudEnabled && [[FCStore shared] getPlan:NO] != FCPlan.None && FCShared.iCloudService.isLogin){
        [[NSNotificationCenter defaultCenter] postNotificationName:iCloudServiceSyncStartNotification object:nil];
        NSString *uuid = note.userInfo[@"uuid"];
        UserScript *userscript = [[DataManager shareManager] selectScriptByUuid:uuid];
        [FCShared.iCloudService addUserscript:userscript
                            completionHandler:^(NSError *error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:iCloudServiceSyncEndNotification object:nil];
            if (error){
                [FCShared.iCloudService showError:error inCer:self];
            }
            else{
                [[FCConfig shared] setStringValueOfKey:GroupUserDefaultsKeyLastSync value:[TimeHelper current]];
            }
        }];
    }
    if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
        && [QuickAccess splitController].viewControllers.count >= 2){
        [self reloadTableView];
        [self.tableView reloadData];
    }
}

- (void)userscriptDidStopHandler:(NSNotification *)note{
    BOOL iCloudEnabled = [[FCConfig shared] getBoolValueOfKey:GroupUserDefaultsKeySyncEnabled];
    if (iCloudEnabled && [[FCStore shared] getPlan:NO] != FCPlan.None && FCShared.iCloudService.isLogin){
        [[NSNotificationCenter defaultCenter] postNotificationName:iCloudServiceSyncStartNotification object:nil];
        NSString *uuid = note.userInfo[@"uuid"];
        UserScript *userscript = [[DataManager shareManager] selectScriptByUuid:uuid];
        [FCShared.iCloudService addUserscript:userscript
                            completionHandler:^(NSError *error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:iCloudServiceSyncEndNotification object:nil];
            if (error){
                [FCShared.iCloudService showError:error inCer:self];
            }
            else{
                [[FCConfig shared] setStringValueOfKey:GroupUserDefaultsKeyLastSync value:[TimeHelper current]];
            }
        }];
    }
    if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
        && [QuickAccess splitController].viewControllers.count >= 2){
        [self reloadTableView];
        [self.tableView reloadData];
    }
}

- (void)userscriptDidAddHandler:(NSNotification *)note{
    BOOL iCloudEnabled = [[FCConfig shared] getBoolValueOfKey:GroupUserDefaultsKeySyncEnabled];
    if (iCloudEnabled && [[FCStore shared] getPlan:NO] != FCPlan.None && FCShared.iCloudService.isLogin){
        [FCShared.iCloudService checkFirstInit:^(BOOL firstInit, NSError * _Nonnull error) {
            if (error){
                [FCShared.iCloudService showError:error inCer:self];
            }
            else{
                if (firstInit){
                    dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"iCloud"
                                                                                   message:NSLocalizedString(@"icloud.firstInit", @"")
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *conform = [UIAlertAction actionWithTitle:NSLocalizedString(@"icloud.syncNow", @"")
                                                                      style:UIAlertActionStyleDefault
                                                                    handler:^(UIAlertAction * _Nonnull action) {
                        [FCShared.iCloudService initUserscripts:self.userscripts completionHandler:^(NSError * _Nonnull error) {
                            if (error){
                                [FCShared.iCloudService showError:error inCer:self];
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
                        [self.navigationController popViewControllerAnimated:YES];
                    }];
                    [alert addAction:cancel];
                    [self presentViewController:alert animated:YES completion:nil];
                });
                }
                else{
                    [[NSNotificationCenter defaultCenter] postNotificationName:iCloudServiceSyncStartNotification object:nil];
                    NSString *uuid = note.userInfo[@"uuid"];
                    UserScript *userscript = [[DataManager shareManager] selectScriptByUuid:uuid];
                    [FCShared.iCloudService addUserscript:userscript
                                        completionHandler:^(NSError *error) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:iCloudServiceSyncEndNotification object:nil];
                        if (error){
                            [FCShared.iCloudService showError:error inCer:self];
                        }
                        else{
                            [[FCConfig shared] setStringValueOfKey:GroupUserDefaultsKeyLastSync value:[TimeHelper current]];
                        }
                    }];
                }
            }
        }];
    }
    
    if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
        && [QuickAccess splitController].viewControllers.count >= 2){
        [self reloadTableView];
        [self.tableView reloadData];
    }
}

- (void)userscriptDidUpdateHandler:(NSNotification *)note{
    BOOL iCloudEnabled = [[FCConfig shared] getBoolValueOfKey:GroupUserDefaultsKeySyncEnabled];
    if (iCloudEnabled && [[FCStore shared] getPlan:NO] != FCPlan.None && FCShared.iCloudService.isLogin){
        [[NSNotificationCenter defaultCenter] postNotificationName:iCloudServiceSyncStartNotification object:nil];
        NSString *uuid = note.userInfo[@"uuid"];
        UserScript *userscript = [[DataManager shareManager] selectScriptByUuid:uuid];
        [FCShared.iCloudService addUserscript:userscript
                            completionHandler:^(NSError *error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:iCloudServiceSyncEndNotification object:nil];
            if (error){
                [FCShared.iCloudService showError:error inCer:self];
            }
            else{
                [[FCConfig shared] setStringValueOfKey:GroupUserDefaultsKeyLastSync value:[TimeHelper current]];
            }
        }];
    }
    
    if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
        && [QuickAccess splitController].viewControllers.count >= 2){
        [self reloadTableView];
        [self.tableView reloadData];
    }

    
}

- (void)linkAction:(NSNotification *)notification {
    [self.sYTextInputViewController dismiss];
    self.sYTextInputViewController = nil;
   NSString *url = notification.object;
   if(url != nil && url.length > 0) {
       [self.loadingSlideController show];
       dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT),^{
           NSMutableCharacterSet *set  = [[NSCharacterSet URLFragmentAllowedCharacterSet] mutableCopy];
            [set addCharactersInString:@"#"];
           NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[url stringByAddingPercentEncodingWithAllowedCharacters:set]]];
            
           dispatch_async(dispatch_get_main_queue(),^{
               if(data != nil ) {
                   if (self.loadingSlideController.isShown){
                       [self.loadingSlideController dismiss];
                       self.loadingSlideController = nil;
                   }
                   NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                   SYEditViewController *cer = [[SYEditViewController alloc] init];
                   cer.content = str;
                   cer.downloadUrl = url;
                   
                   if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
                       && [QuickAccess splitController].viewControllers.count >= 2){
                       [[QuickAccess secondaryController] pushViewController:cer];
                   }
                   else{
                       [self.navigationController pushViewController:cer animated:true];
                   }
               }else {
                   [self.loadingSlideController updateSubText:NSLocalizedString(@"Error", @"")];
                   dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       if (self.loadingSlideController.isShown){
                           [self.loadingSlideController dismiss];
                           self.loadingSlideController = nil;
                       }
                   });
               }
           });
       });
   }
}

- (void)tableDidSelected:(NSNotification *)notification {
    NSInteger index = [(NSNumber *)notification.object integerValue];
    if(index == 0) {
        SYEditViewController *cer = [[SYEditViewController alloc] init];
        if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
            && [QuickAccess splitController].viewControllers.count >= 2){
             [[QuickAccess secondaryController] pushViewController:cer];
        }
        else{
             [self.navigationController pushViewController:cer animated:true];
        }
        
    } else if(index == 1) {
        [self.sYTextInputViewController show];
    } else if (index == 2) {
        SYWebScriptViewController *cer = [[SYWebScriptViewController alloc] init];
        if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
            && [QuickAccess splitController].viewControllers.count >= 2){
             [[QuickAccess secondaryController] pushViewController:cer];
        }
        else{
             [self.navigationController pushViewController:cer animated:true];
        }
    }
    else if (index == 3) {
        UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initForOpeningContentTypes:@[UTTypeItem] asCopy:YES];
        documentPicker.delegate = self;
        [self presentViewController:documentPicker animated:YES completion:nil];
    }
    [self.importSlideController dismiss];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray <NSURL *>*)urls{
    if (urls.count > 0){
        NSURL *url = urls[0];
        SYEditViewController *cer = [[SYEditViewController alloc] init];
        NSError *error = nil;
        cer.content = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
        if (!error){
            if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
                && [QuickAccess splitController].viewControllers.count >= 2){
                 [[QuickAccess secondaryController] pushViewController:cer];
            }
            else{
                 [self.navigationController pushViewController:cer animated:true];
            }
            
        }
        else{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                           message:NSLocalizedString(@"unsupportedFileFormat", @"")
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *confirm = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"")
                                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alert addAction:confirm];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}


//检测评分
- (void)checkShowTips{
    NSUserDefaults *groupUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dajiu.stay.pro"];
    if([groupUserDefaults objectForKey:kRateKey] != NULL){
        int count = [[groupUserDefaults objectForKey:kRateKey] intValue];
        if(count == 5) {
          [SKStoreReviewController requestReview];
        }
        count += 1;
        [groupUserDefaults setObject:@(count)  forKey:kRateKey];
    } else {
        [groupUserDefaults setObject:@(1) forKey:kRateKey];
        [groupUserDefaults synchronize];
    }
}
- (void)statusBarChange{
    dispatch_async(dispatch_get_main_queue(), ^{
#ifdef Mac
        self.tableView.frame =  CGRectMake(0, kMacToolbar, self.view.frame.size.width, self.view.frame.size.height - kMacToolbar);
#else
        self.tableView.frame = self.view.bounds;
#endif
        [self.tableView reloadData];
    });

}

//后台唤起时处理与插件交互
- (void)onBecomeActive{
//    [Bugsnag notifyError:[NSError errorWithDomain:@"com.example" code:408 userInfo:nil]];
    [self checkShowTips];
    [ToastDebugger log:@"checkShowTips"];
    NSLog(@"onBecomeActive-------");
    [SharedStorageManager shared].activateChanged = nil;
    NSDictionary *activateChanged = [SharedStorageManager shared].activateChanged.content;
    if (activateChanged.count > 0){
        NSArray *uuidArrray = activateChanged.allKeys;
        for (NSString *uuid in uuidArrray){
            [[DataManager shareManager] updateScrpitStatus:[activateChanged[uuid] boolValue] ? 1:0 numberId:uuid];
        }
    }
    [SharedStorageManager shared].activateChanged.content = @{};
    [[SharedStorageManager shared].activateChanged flush];
    [ToastDebugger log:@"activateChanged"];
    
    [SharedStorageManager shared].runsRecord = nil;
    for (NSString *uuid in [SharedStorageManager shared].runsRecord.contentDic.allKeys){
        [[DataManager shareManager] updateUsedTimesByUuid:uuid count:[SharedStorageManager shared].runsRecord.contentDic[uuid].intValue];
    }
    [SharedStorageManager shared].runsRecord.contentDic = [NSMutableDictionary dictionary];
    [[SharedStorageManager shared].runsRecord flush];
    [ToastDebugger log:@"runsRecord"];
    
    [self reloadTableView];
    [self.tableView reloadData];
    [self initScrpitContent];
    [ToastDebugger log:@"initScrpitContent"];
    
    [ToastDebugger log:@"iCloudSyncIfNeeded Start"];
    [self iCloudSyncIfNeeded];
    
    [[API shared] active:[[FCConfig shared] getStringValueOfKey:GroupUserDefaultsKeyDeviceUUID]
                   isPro:[[FCStore shared] getPlan:NO] != FCPlan.None
             isExtension:NO];
    [ToastDebugger log:@"API"];
}

- (void)iCloudSyncIfNeeded{
    BOOL iCloudEnabled = [[FCConfig shared] getBoolValueOfKey:GroupUserDefaultsKeySyncEnabled];
    FCPlan *plan = [[FCStore shared] getPlan:YES];
    if (plan != FCPlan.None){
        [self.customView refreshIcon];
        [FCShared.iCloudService refreshWithCompletionHandler:^(NSError *error) {
            if (iCloudEnabled){
                if (error){
                    [FCShared.iCloudService showError:error inCer:self];
                    NSArray *array = [[DataManager shareManager] findScript:1];
                    [self updateScriptWhen:array type:false];
                    return;
                }
                
                if (FCShared.iCloudService.isLogin){
                    [[NSNotificationCenter defaultCenter] postNotificationName:iCloudServiceSyncStartNotification object:nil];
                    NSArray *array = [[DataManager shareManager] findScript:1];
                    
                    [FCShared.iCloudService checkFirstInit:^(BOOL firstInit, NSError * _Nonnull error) {
                        if (error || firstInit){
                            if (error){
                                [FCShared.iCloudService showError:error inCer:self];
                            }
                            [self updateScriptWhen:array type:false];
                            [[NSNotificationCenter defaultCenter] postNotificationName:iCloudServiceSyncEndNotification object:nil];
                            return;
                        }
                        
                        for (UserScript *userscriptInDB in array){
                            if (![userscriptInDB.iCloudIdentifier isEqualToString:FCShared.iCloudService.identifier]){
                                [[DataManager shareManager] deleteScriptInUserScriptByNumberId:userscriptInDB.uuid];
                            }
                        }
                        
                        [FCShared.iCloudService fetchUserscriptWithCompletionHandler:
                         ^(NSDictionary<NSString *,UserScript *> *changedUserscripts, NSArray<NSString *> *deletedUUIDs) {
                            if (changedUserscripts.count > 0 || deletedUUIDs.count > 0){
                                NSArray *changedUUIDs = [changedUserscripts allKeys];
                                for (NSString *uuid in changedUUIDs){
                                    UserScript *changedUserscript = changedUserscripts[uuid];
                                    if (changedUserscript.name.length == 0){
                                        continue;
                                    }
                                    UserScript *userscriptInDB = [[DataManager shareManager] selectScriptByUuid:uuid];
                                    if (nil == userscriptInDB || userscriptInDB.uuid.length == 0){
                                        [[DataManager shareManager] insertUserConfigByUserScript:changedUserscript];
                                        [ToastDebugger log:@"insertUserConfigByUserScript"];
                                    }
                                    else{
                                        [[DataManager shareManager] updateUserScriptByIcloud:changedUserscript];
                                        [ToastDebugger log:@"updateUserScriptByIcloud"];
                                        //TODO:
                                    }
    //                                dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT),^{
    //
    //                                });
                                    
                                    UserScriptStatus status =  UserScriptStatusOK;
                                    [[UserscriptUpdateManager shareManager] saveIcon:changedUserscript];
                                    BOOL requireSucceed = [[UserscriptUpdateManager shareManager] saveRequireUrl:changedUserscript];
                                    status = status | (requireSucceed ? UserScriptStatusOK :  UserScriptStatusNeedRequire);
                                    BOOL resourceSucceed = [[UserscriptUpdateManager shareManager] saveResourceUrl:changedUserscript];
                                    status = status | (resourceSucceed ? UserScriptStatusOK :  UserScriptStatusNeedResource);
                                }
                                
                                for (NSString *deletedUUID in deletedUUIDs){
                                    [[DataManager shareManager] deleteScriptInUserScriptByNumberId:deletedUUID];
                                }
                                
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self reloadTableView];
                                    [self.tableView reloadData];
                                    [self initScrpitContent];
                                    [self updateScriptWhen:array type:false];
                                    [[NSNotificationCenter defaultCenter] postNotificationName:iCloudServiceSyncEndNotification object:nil];
                                });
                            }
                            else{
                                [self updateScriptWhen:array type:false];
                                [[NSNotificationCenter defaultCenter] postNotificationName:iCloudServiceSyncEndNotification object:nil];
                            }
                            
                            
                            [[FCConfig shared] setStringValueOfKey:GroupUserDefaultsKeyLastSync value:[TimeHelper current]];
                            [[NSNotificationCenter defaultCenter] postNotificationName:SYMoreViewReloadCellNotification
                                                                                object:nil
                                                                              userInfo:@{
                                @"section":@(1),
                                @"row":@(0)
                            }];
                        }];
                        
                    }];
                }
                else{
                    NSArray *array = [[DataManager shareManager] findScript:1];
                    [self updateScriptWhen:array type:false];
                }
            }
            else{
                NSArray *array = [[DataManager shareManager] findScript:1];
                [self updateScriptWhen:array type:false];
            }
            
        }];
        
    }
    else{
        NSArray *array = [[DataManager shareManager] findScript:1];
        [self updateScriptWhen:array type:false];
    }
}

- (void)updateScriptWhen:(NSArray *)array type:(bool)isSearch {
    [ToastDebugger log:[NSString stringWithFormat:@"updateScriptWhen Start %d",isSearch]];
    for(int i = 0; i < array.count; i++) {
        UserScript *scrpit = array[i];
        if(!isSearch && !scrpit.updateSwitch) {
            continue;
        }
            
        if(scrpit.updateUrl != NULL && scrpit.updateUrl.length > 0) {
            [[SYNetworkUtils shareInstance] requestGET:scrpit.updateUrl params:NULL successBlock:^(NSString * _Nonnull responseObject) {
                if(responseObject != nil) {
                    UserScript *userScript = [[Tampermonkey shared] parseWithScriptContent:responseObject];
                    if(userScript.version != NULL) {
                        NSInteger status =  [SYVersionUtils compareVersion:userScript.version toVersion:scrpit.version];
                        if(status == 1) {
                            if(userScript.downloadUrl == nil || userScript.downloadUrl.length <= 0){
                                if(userScript.content != nil && userScript.content.length > 0) {
                                    userScript.uuid = scrpit.uuid;
                                    userScript.active = scrpit.active;
                                    userScript.updateSwitch = scrpit.updateSwitch;
                                    userScript.whitelist = scrpit.whitelist;
                                    userScript.blacklist = scrpit.blacklist;
                                    userScript.injectInto = scrpit.injectInto;
                                    userScript.iCloudIdentifier = scrpit.iCloudIdentifier;
                                    if(scrpit.downloadUrl != NULL ) {
                                        NSURL *url = [NSURL URLWithString:scrpit.downloadUrl];
                                        if([url.host isEqualToString:@"res.stayfork.app"]) {
                                            userScript.downloadUrl = scrpit.downloadUrl;
                                            userScript.updateUrl = scrpit.downloadUrl;
                                        }
                                    }
                                    [[DataManager shareManager] updateUserScript:userScript];
                                    [[DataManager shareManager] updateUserScriptTime:scrpit.uuid];
                                    [self refreshScript];
                                    NSNotification *notification = [NSNotification notificationWithName:@"app.stay.notification.userscriptDidUpdateNotification" object:nil userInfo:@{@"uuid":userScript.uuid}];
                                            [[NSNotificationCenter defaultCenter]postNotification:notification];
                                }
                            } else {
                                [[SYNetworkUtils shareInstance] requestGET:scrpit.downloadUrl params:nil successBlock:^(NSString * _Nonnull responseObject) {
                                    if(responseObject != nil) {
                                        UserScript *userScript = [[Tampermonkey shared] parseWithScriptContent:responseObject];
                                        userScript.uuid = scrpit.uuid;
                                        userScript.active = scrpit.active;
                                        userScript.updateSwitch = scrpit.updateSwitch;
                                        userScript.whitelist = scrpit.whitelist;
                                        userScript.blacklist = scrpit.blacklist;
                                        userScript.injectInto = scrpit.injectInto;
                                        userScript.iCloudIdentifier = scrpit.iCloudIdentifier;
                                        if(scrpit.downloadUrl != NULL ) {
                                            NSURL *url = [NSURL URLWithString:scrpit.downloadUrl];
                                            if([url.host isEqualToString:@"res.stayfork.app"]) {
                                                userScript.downloadUrl = scrpit.downloadUrl;
                                                userScript.updateUrl = scrpit.downloadUrl;
                                            }
                                        }
                                        if(userScript != nil && userScript.errorMessage != nil && userScript.errorMessage.length <= 0) {
                                            [[DataManager shareManager] updateUserScript:userScript];
                                            [[DataManager shareManager] updateUserScriptTime:scrpit.uuid];
                                            [self refreshScript];
                                            NSNotification *notification = [NSNotification notificationWithName:@"app.stay.notification.userscriptDidUpdateNotification" object:nil userInfo:@{@"uuid":userScript.uuid}];
                                                    [[NSNotificationCenter defaultCenter]postNotification:notification];
                                        }
                                    }
                                } failBlock:^(NSError * _Nonnull error) {

                                }];
                            }
                        }
                    }

                }
            } failBlock:^(NSError * _Nonnull error) {

            }];
        } else if(scrpit.downloadUrl != NULL && scrpit.downloadUrl.length > 0) {
            [[SYNetworkUtils shareInstance] requestGET:scrpit.downloadUrl params:nil successBlock:^(NSString * _Nonnull responseObject) {
                if(responseObject != nil) {
                    UserScript *userScript = [[Tampermonkey shared] parseWithScriptContent:responseObject];
                    if(userScript.version != NULL) {
                        NSInteger status = [SYVersionUtils compareVersion:userScript.version toVersion:scrpit.version];
                        if(status == 1) {
                            userScript.uuid = scrpit.uuid;
                            userScript.active = scrpit.active;
                            userScript.updateSwitch = scrpit.updateSwitch;
                            userScript.whitelist = scrpit.whitelist;
                            userScript.blacklist = scrpit.blacklist;
                            userScript.injectInto = scrpit.injectInto;
                            userScript.iCloudIdentifier = scrpit.iCloudIdentifier;
                            if(userScript.downloadUrl == NULL || userScript.downloadUrl.length <= 0) {
                                userScript.downloadUrl = scrpit.downloadUrl;
                            }

                            NSURL *url = [NSURL URLWithString:scrpit.downloadUrl];
                            if([url.host isEqualToString:@"res.stayfork.app"]) {
                                userScript.downloadUrl = scrpit.downloadUrl;
                                userScript.updateUrl = scrpit.downloadUrl;
                            }
                            
                
                            
                            if(userScript != nil && userScript.errorMessage != nil && userScript.errorMessage.length <= 0) {
                                [[DataManager shareManager] updateUserScript:userScript];
                                [[DataManager shareManager] updateUserScriptTime:scrpit.uuid];
                                [self refreshScript];
                                NSNotification *notification = [NSNotification notificationWithName:@"app.stay.notification.userscriptDidUpdateNotification" object:nil userInfo:@{@"uuid":userScript.uuid}];
                                        [[NSNotificationCenter defaultCenter]postNotification:notification];
                            }
                        }
                    }
                }
            } failBlock:^(NSError * _Nonnull error) {

            }];
        }
    }
    
    [ToastDebugger log:@"updateScriptWhen End"];
}

- (void)refreshScript{
    [self initScrpitContent];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadTableView];
        [self.tableView reloadData];
    });
}

- (void)initScrpitContent{
    
    NSMutableArray *array =  [[NSMutableArray alloc] init];
    for(int i = 0; i < self.datas.count; i++) {
        UserScript *script = self.datas[i];
        UserscriptInfo *info = [[SharedStorageManager shared] getInfoOfUUID:script.uuid];
        info.content = [script toDictionary];
        [info flush];
        script.parsedContent = @"";
        script.otherContent = @"";
        [array addObject: [script toDictionary]];
    }
    [SharedStorageManager shared].userscriptHeaders.content = array;
    [[SharedStorageManager shared].userscriptHeaders flush];
    
    [[ScriptMananger shareManager] buildData];
    
}
#pragma mark -popover
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller{
    return UIModalPresentationNone;
}

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController{
    return YES;   //点击蒙版popover不消失， 默认yes
}

#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(nonnull UISearchController *)searchController {
    NSString *inputStr = searchController.searchBar.text;
    return;
}

#pragma mark -searchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
//    [searchBar resignFirstResponder];
    [self.searchController setActive:NO];
    [_results removeAllObjects];
    [self reloadTableView];
    [self.tableView reloadData];

}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self.searchController setActive:YES];
    [_results removeAllObjects];
    [self.tableView reloadData];
    return YES;
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [_results removeAllObjects];
    if(searchText.length > 0) {
        [_results addObjectsFromArray:[[DataManager shareManager] selectScriptByKeywordByAdded:searchText]];
    }
    [self.tableView reloadData];

}

- (CGFloat)safeAreaInsetsLeft{
#ifdef Mac
    return 250.0;
#else
    return 0.0;
#endif
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
#ifdef Mac
    [self.tableView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
#endif
    
    if (FCDeviceTypeIPad == DeviceHelper.type || FCDeviceTypeMac == DeviceHelper.type){
        [self.tableView reloadData];
    }
}


#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchController.active) {
        return self.results.count;
    }
    
    return self.datas.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (cell == nil) {
        cell = [[HomeDetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
    }
    for (UIView *subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    // 这里通过searchController的active属性来区分展示数据源是哪个
    UserScript *model = nil;
    if (self.searchController.active ) {
        model = _results[indexPath.row];
    } else {
        model = _datas[indexPath.row];
    }
//#ifndef Mac
////    cell.backgroundColor = FCStyle.secondaryBackground;
//#endif
    cell.contentView.backgroundColor = FCStyle.secondaryBackground;
    cell.contentView.width = self.view.width;
    cell.controller = self;
    cell.scrpit = model;

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (FCDeviceTypeIPad == DeviceHelper.type || FCDeviceTypeMac == DeviceHelper.type){
        if (nil == self.splitViewController || self.splitViewController.viewControllers.count < 2){
            [cell setSelected:NO animated:NO];
        }
        else{
            if (self.selectedRow >= 0){
                NSLog(@"selectedRow willDisplayCell%ld",self.selectedRow);
                [cell setSelected:indexPath.row == self.selectedRow animated:NO];
            }
        }
    }
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
        && self.splitViewController.viewControllers.count >= 2){
        if (self.selectedRow != indexPath.row){
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedRow inSection:0]];
            cell.selected = NO;
        }
        UserScript *userscript = _datas[indexPath.row];
        self.selectedRow = indexPath.row;
        self.selectedUUID = userscript.uuid;
        [[QuickAccess secondaryController] pushViewController:
         [[QuickAccess secondaryController] produceDetailViewControllerWithUserScript:userscript]];
    }
    else{
        if (self.searchController.active) {
            UserScript *model = _results[indexPath.row];
            SYDetailViewController *cer = [[SYDetailViewController alloc] init];
            cer.isSearch = false;
            cer.script = model;
            [self.navigationController pushViewController:cer animated:true];
        } else {
            UserScript *model = _datas[indexPath.row];
            SYDetailViewController *cer = [[SYDetailViewController alloc] init];
            cer.script = model;
            cer.isSearch = false;
            [self.navigationController pushViewController:cer animated:true];
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100.f;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    //Fixed retains self
    __weak SYHomeViewController *weakSelf = self;
    if (self.searchController.active) {
        UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"needDelete", @"")
                                                                           message:@""
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *conform = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"")
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * _Nonnull action) {
                
                
                UserScript *model = weakSelf.datas[indexPath.row];
                [[DataManager shareManager] deleteScriptInUserScriptByNumberId: model.uuid];
                [tableView setEditing:NO animated:YES];
                [self reloadTableView];
                [tableView reloadData];
                [self initScrpitContent];
                
                if (self.selectedRow == indexPath.row){
                    if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
                        && [QuickAccess splitController].viewControllers.count >= 2){
                        [[QuickAccess secondaryController] popViewController];
                        if (weakSelf.datas.count > 0){
                            self.selectedRow = 0;
                            [[QuickAccess secondaryController] pushViewController:
                             [[QuickAccess secondaryController] produceDetailViewControllerWithUserScript:weakSelf.datas[0]]];
                        }
                        else{
                            self.selectedRow = -1;
                        }
                    }
                }
                
                NSNotification *notification = [NSNotification notificationWithName:@"app.stay.notification.userscriptDidDeleteNotification" object:nil userInfo:@{@"uuid":model.uuid}];
                [[NSNotificationCenter defaultCenter]postNotification:notification];
                
                
            }];
            [alert addAction:conform];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"")
                 style:UIAlertActionStyleCancel
                 handler:^(UIAlertAction * _Nonnull action) {
             }];
             [alert addAction:cancel];
            [self presentViewController:alert animated:YES completion:nil];
        }];
        deleteAction.image = [UIImage imageNamed:@"delete"];
        deleteAction.backgroundColor = RGB(224, 32, 32);
        return [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];

    } else {
        UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            
            
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"needDelete", @"")
                                                                           message:@""
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *conform = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"")
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * _Nonnull action) {
                
                UserScript *model = weakSelf.datas[indexPath.row];
                [[DataManager shareManager] deleteScriptInUserScriptByNumberId: model.uuid];
                [tableView setEditing:NO animated:YES];
                [self reloadTableView];
                [tableView reloadData];
                [self initScrpitContent];
                
                if (self.selectedRow == indexPath.row){
                    if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
                        && [QuickAccess splitController].viewControllers.count >= 2){
                        [[QuickAccess secondaryController] popViewController];
                        if (weakSelf.datas.count > 0){
                            self.selectedRow = 0;
                            [[QuickAccess secondaryController] pushViewController:
                             [[QuickAccess secondaryController] produceDetailViewControllerWithUserScript:weakSelf.datas[0]]];
                        }
                        else{
                            self.selectedRow = -1;
                        }
                    }
                }
                
                NSNotification *notification = [NSNotification notificationWithName:@"app.stay.notification.userscriptDidDeleteNotification" object:nil userInfo:@{@"uuid":model.uuid}];
                [[NSNotificationCenter defaultCenter]postNotification:notification];
            }];
            [alert addAction:conform];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"")
                 style:UIAlertActionStyleCancel
                 handler:^(UIAlertAction * _Nonnull action) {
             }];
             [alert addAction:cancel];
            [self presentViewController:alert animated:YES completion:nil];
            
        }];
        deleteAction.image = [UIImage imageNamed:@"delete"];
        deleteAction.backgroundColor = RGB(224, 32, 32);
        
        UIContextualAction *stopAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            UserScript *model = weakSelf.datas[indexPath.row];
                if (model.active == 1) {
                    [[DataManager shareManager] updateScrpitStatus:0 numberId:model.uuid];
                    NSNotification *notification = [NSNotification notificationWithName:@"app.stay.notification.userscriptDidUpdateNotification" object:nil userInfo:@{
                        @"uuid":model.uuid
                    }];
                    [[NSNotificationCenter defaultCenter]postNotification:notification];
                } else if (model.active == 0) {
                    [[DataManager shareManager] updateScrpitStatus:1 numberId:model.uuid];
                    NSNotification *notification = [NSNotification notificationWithName:@"app.stay.notification.userscriptDidUpdateNotification" object:nil userInfo:@{
                        @"uuid":model.uuid
                    }];
                    [[NSNotificationCenter defaultCenter]postNotification:notification];
                }
                [tableView setEditing:NO animated:YES];
                [weakSelf reloadTableView];
                [weakSelf initScrpitContent];
                [tableView reloadData];
        }];
        UserScript *model = _datas[indexPath.row];
        if (model.active) {
            stopAction.image = [UIImage imageNamed:@"stop"];
            stopAction.backgroundColor = FCStyle.accent;
        } else {
            stopAction.image = [UIImage imageNamed:@"play"];
            stopAction.backgroundColor = FCStyle.accent;
        }
        
        UIImage *image = [UIImage systemImageNamed:@"square.and.arrow.up" withConfiguration:[UIImageSymbolConfiguration configurationWithFont:[UIFont systemFontOfSize:15]]];
     
        UIContextualAction *shareAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            self.sYSelectTabViewController = nil;
            UserScript *model = weakSelf.datas[indexPath.row];
            self.sYSelectTabViewController.url = model.downloadUrl;
            self.sYSelectTabViewController.content = model.content;
            [tableView setEditing:NO animated:YES];
            [self.sYSelectTabViewController show];
        }];
        shareAction.image = image;
        shareAction.backgroundColor = FCStyle.fcBlue;

        
        return [UISwipeActionsConfiguration configurationWithActions:@[deleteAction,shareAction,stopAction]];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)import{
    [self addBtnClick:nil];
}

- (void)addBtnClick:(id)sender {
    if (!self.importSlideController.isShown){
        [self.importSlideController show];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadTableView];
    [self initScrpitContent];
    dispatch_async(dispatch_get_main_queue(), ^{
#ifdef Mac
        self.tableView.frame =  CGRectMake(0, kMacToolbar, self.view.frame.size.width, self.view.frame.size.height - kMacToolbar);
#else
        self.tableView.frame = self.view.bounds;
#endif
        [self.tableView reloadData];
    });
    [self emptyTipsView];
    
    NSLog(@"SYHomeViewController view %@",self.view);
    
}


- (void)updateScript:(UIButton *)sender {
    NSString *script = objc_getAssociatedObject(sender,@"script");
    if (@available(macCatalyst 16, *)){
        script = NSLocalizedString(@"UpdateAlert", @"");
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:script preferredStyle:UIAlertControllerStyleAlert];

    NSString *scriptContent = objc_getAssociatedObject(sender,@"scriptContent");

    NSString *downloadUrl = objc_getAssociatedObject(sender,@"downloadUrl");

    
    UIAlertAction *conform = [UIAlertAction actionWithTitle:NSLocalizedString(@"settings.update","update") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url = [NSURL URLWithString:downloadUrl];
        if([url.host isEqualToString:@"res.stayfork.app"]) {
            [self.loadingSlideController show];
            UserScript *userScript =  [[Tampermonkey shared] parseWithScriptContent:scriptContent];
            int count = 0;

            NSString *uuidName = [NSString stringWithFormat:@"%@%@",userScript.name,userScript.namespace];
            NSString *uuid = [self md5HexDigest:uuidName];
            userScript.uuid = uuid;
            userScript.active = true;
            if(userScript != nil && userScript.requireUrls != nil) {
                count += userScript.requireUrls.count;
            }

            if(userScript != nil && userScript.resourceUrls != nil) {
                count += userScript.resourceUrls.count;
            }
            if(count > 0) {
                NSNotification *notification = [NSNotification notificationWithName:@"startSave" object:[NSString stringWithFormat:@"%d",count]];
                [[NSNotificationCenter defaultCenter]postNotification:notification];
            }
            BOOL saveSuccess = [[UserscriptUpdateManager shareManager] saveRequireUrl:userScript];
            BOOL saveResourceSuccess = [[UserscriptUpdateManager shareManager] saveResourceUrl:userScript];

            if(!saveSuccess) {
//                [self saveError:@"requireUrl下载失败,请检查后重试"];
                return;
            }
            if(!saveResourceSuccess) {
//                [self saveError:@"resourceUrl下载失败,请检查后重试"];
                return;
            }
            
            UserScript *tmpScript = [[DataManager shareManager] selectScriptByUuid:userScript.uuid];

            if(tmpScript.downloadUrl != NULL ) {
                NSURL *url = [NSURL URLWithString:tmpScript.downloadUrl];
                if([url.host isEqualToString:@"res.stayfork.app"]) {
                    userScript.downloadUrl = tmpScript.downloadUrl;
                    userScript.updateUrl = tmpScript.downloadUrl;
                }
            }
            
            userScript.iCloudIdentifier = tmpScript.iCloudIdentifier;
            
           if(userScript != nil && userScript.errorMessage != nil && userScript.errorMessage.length <= 0) {
               [[DataManager shareManager] updateUserScript:userScript];
               [[DataManager shareManager] updateUserScriptTime:userScript.uuid];
               [self reloadTableView];

               [self initScrpitContent];
            
               [[NSNotificationCenter defaultCenter] postNotificationName:CMVDidFinishContentNotification
                                                                   object:nil
                                                                 userInfo:@{
                   @"operate":@"update"
               }];
               
               [self.tableView reloadData];

           }
            
            if (self.loadingSlideController.isShown){
                [self.loadingSlideController dismiss];
                self.loadingSlideController = nil;
            }
            
            
        }  else {
            SYEditViewController *cer = [[SYEditViewController alloc] init];
            cer.content = scriptContent;
            cer.downloadUrl = downloadUrl;
            cer.isEdit = YES;
            if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
                && [QuickAccess splitController].viewControllers.count >= 2){
                [[QuickAccess secondaryController] pushViewController:cer];
            }
            else{
                [self.navigationController pushViewController:cer animated:true];
            }
        }
        }];

    UIAlertAction *cancelconform = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel","Cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        }];

    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
       paraStyle.alignment = NSTextAlignmentLeft;

       NSMutableAttributedString *atrStr = [[NSMutableAttributedString alloc] initWithString:script attributes:@{NSParagraphStyleAttributeName:paraStyle,NSFontAttributeName:[UIFont systemFontOfSize:13.0]}];

    [alert setValue:atrStr forKey:@"attributedMessage"];
    [alert addAction:cancelconform];
    [alert addAction:conform];

    [self presentViewController:alert animated:YES completion:nil];
    

}

- (void) reloadTableView {
    
    [_datas removeAllObjects];
    [_datas addObjectsFromArray:[[DataManager shareManager] findScript:1]];
    
    self.tableView.hidden = _datas.count == 0;
    self.emptyTipsView.hidden = _datas.count > 0;
    
    NSString *scriptCount = @"";
    if (_datas.count > 0){
        scriptCount = [NSString stringWithFormat:@"(%ld)",_datas.count];
    }
    self.navigationItem.title = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"settings.library","Library"),scriptCount];
    
}

- (void)remoteSyncStart{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.customView startAnimate];
    });
}

- (void)remoteSyncEnd{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.customView stopAnimate];
    });
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = DynamicColor(RGB(28, 28, 28),[UIColor whiteColor]);
        [self.view addSubview:_tableView];
    }
    
    return _tableView;
}

- (NSMutableArray *)datas {
    if (_datas == nil) {
        _datas = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _datas;
}

- (NSArray<UserScript *> *)userscripts{
    return [self.datas copy];
}

- (NSMutableArray *)results {
    if (_results == nil) {
        _results = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _results;
}

- (UIBarButtonItem *)leftIcon{
    if (nil == _leftIcon){
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        [imageView setImage:[[FCStore shared] getPlan:NO] != FCPlan.None ? [UIImage imageNamed:@"NavProIcon"] : [UIImage imageNamed:@"NavIcon"]];
        imageView.layer.cornerRadius = 6;
        imageView.layer.masksToBounds = YES;
        imageView.contentMode = UIViewContentModeCenter;
        _leftIcon = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    }
    return _leftIcon;
}

- (UIBarButtonItem *)rightIcon {
    if (nil == _rightIcon){
        _rightIcon = [[UIBarButtonItem alloc] initWithImage:[ImageHelper sfNamed:@"plus"
                                                                            font:FCStyle.sfNavigationBar
                                                                           color:FCStyle.fcMacIcon]
                                                      style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(addBtnClick:)];
    }
    return _rightIcon;
}

- (_iCloudView *)customView{
    if (nil == _customView){
#ifdef Mac
        _customView = [[_iCloudView alloc] initWithFrame:CGRectMake(0, 0, 25, 18)];
#else
        _customView = [[_iCloudView alloc] initWithFrame:CGRectMake(0, 0, 30, 22)];
#endif
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iCloudAction:)];
        [_customView addGestureRecognizer:tapGesture];
    }
    
    return _customView;;
}

- (UIBarButtonItem *)iCloudIcon{
    if (nil == _iCloudIcon){
        _iCloudIcon = [[UIBarButtonItem alloc] initWithCustomView:self.customView];
    }
    
    return _iCloudIcon;
}

- (void)iCloudAction:(id)sender{
    if ([self.customView.sfName isEqualToString:@"checkmark.icloud"]){
        [self remoteSyncStart];
        [FCShared.iCloudService checkFirstInit:^(BOOL firstInit, NSError * error) {
            [self remoteSyncEnd];
            if (error){
                [FCShared.iCloudService showErrorWithMessage:NSLocalizedString(@"TryAgainLater", @"") inCer:self];
            }
            else{
                if (firstInit){
                        dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"iCloud"
                                                                                       message:NSLocalizedString(@"icloud.firstInit", @"")
                                                                                preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *conform = [UIAlertAction actionWithTitle:NSLocalizedString(@"icloud.syncNow", @"")
                                                                          style:UIAlertActionStyleDefault
                                                                        handler:^(UIAlertAction * _Nonnull action) {
                            [self remoteSyncStart];
                            [FCShared.iCloudService initUserscripts:self.userscripts completionHandler:^(NSError * _Nonnull error) {
                                [self remoteSyncEnd];
                                if (error){
                                    [FCShared.iCloudService showError:error inCer:self];
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
                            [self.navigationController popViewControllerAnimated:YES];
                        }];
                        [alert addAction:cancel];
                        [self presentViewController:alert animated:YES completion:nil];
                    });
                    
                }
                else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"iCloud"
                                                                                       message:NSLocalizedString(@"icloud.syncNow", @"")
                                                                                preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *conform = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"")
                                                                          style:UIAlertActionStyleDefault
                                                                        handler:^(UIAlertAction * _Nonnull action) {
                            [self iCloudSyncIfNeeded];
                        }];
                        [alert addAction:conform];
                        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"")
                                                                          style:UIAlertActionStyleCancel
                                                                        handler:^(UIAlertAction * _Nonnull action) {
                            [self.navigationController popViewControllerAnimated:YES];
                        }];
                        [alert addAction:cancel];
                        [self presentViewController:alert animated:YES completion:nil];
                    });
                    
                }
            }
        }];
    }
    else if ([self.customView.sfName isEqualToString:@"icloud.slash"]){
        if (!self.iCloudSyncSlideController.isShown){
            [self.iCloudSyncSlideController show];
        }
    }
    else if ([self.customView.sfName isEqualToString:@"person.icloud"]){
        [AlertHelper simpleWithTitle:NSLocalizedString(@"Tips", @"")
                             message:NSLocalizedString(@"iCloudLogin", @"")
                               inCer:self];
    }
}


- (NSString *)timeWithTimeIntervalString:(NSString *)timeString
{
    
    if(timeString == NULL || [timeString doubleValue] < 20) {
        timeString = [self getNowDate];
    }
  // 格式化时间
  NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
  formatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
  [formatter setDateStyle:NSDateFormatterMediumStyle];
  [formatter setTimeStyle:NSDateFormatterShortStyle];
  [formatter setDateFormat:@"yyyy.MM.dd"];
  
  // 毫秒值转化为秒
  NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeString doubleValue]/ 1000.0];
  NSString* dateString = [formatter stringFromDate:date];
  return dateString;
}

- (_EmptyTipsView *)emptyTipsView{
    if (nil == _emptyTipsView){
#ifdef Mac
        _emptyTipsView = [[_EmptyTipsView alloc] initWithFrame:CGRectMake(0, kMacToolbar, self.view.width, self.view.height - kMacToolbar)];
#else
        _emptyTipsView = [[_EmptyTipsView alloc] initWithFrame:self.view.bounds];
#endif
        _emptyTipsView.hidden = YES;
        [_emptyTipsView.addButton addTarget:self action:@selector(addBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _emptyTipsView.backgroundColor = FCStyle.secondaryBackground;
        [self.view addSubview:_emptyTipsView];
    }
    
    return _emptyTipsView;
}

- (NSString *)getNowDate {
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[date timeIntervalSince1970]*1000; // *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeString = [NSString stringWithFormat:@"%.0f", a];
    return timeString;
}

- (UIView *)line{
    if (nil == _line){
        _line = [[UIView alloc] initWithFrame:CGRectMake(0, kMacToolbar-1, self.view.frame.size.width, 1)];
        _line.backgroundColor = FCStyle.fcSeparator;
        [self.view addSubview:_line];
    }
    
    return _line;
}

- (SYSelectTabViewController *)sYSelectTabViewController {
    if(_sYSelectTabViewController == nil) {
        _sYSelectTabViewController = [[SYSelectTabViewController alloc] init];
    }
    return _sYSelectTabViewController;
}

#ifdef Mac
- (void)navigateViewDidShow:(NSNotification *)note{
    UIViewController *viewController = note.object;
    if ([viewController isKindOfClass:[SYDetailViewController class]]){
//        SYDetailViewController *detailViewController = (SYDetailViewController *)viewController;
//        self.selectedUUID = detailViewController.script.uuid;
//        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedRow inSection:0]
//                                    animated:YES
//                              scrollPosition:UITableViewScrollPositionMiddle];
    }
    else{
        if (self.selectedRow >= 0){
            [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedRow inSection:0] animated:NO];
            self.selectedRow = -1;
        }
    }
}
#endif

- (NSIndexPath *)indexPathOfUUID:(NSString *)uuid{
    @synchronized (self.datas) {
        for (NSInteger i = 0; i < self.datas.count; i++){
            UserScript *scrpit = self.datas[i];
            if ([scrpit.uuid isEqualToString:uuid]){
                return [NSIndexPath indexPathForRow:i inSection:0];
            }
        }
    }
    
    return nil;
}

- (void)homeViewShouldReloadData:(NSNotification *)note{
    [self refreshScript];
}

- (ImportSlideController *)importSlideController{
    if (nil == _importSlideController){
        _importSlideController = [[ImportSlideController alloc] init];
    }
    
    return _importSlideController;
}

- (ICloudSyncSlideController *)iCloudSyncSlideController{
    if (nil == _iCloudSyncSlideController){
        _iCloudSyncSlideController = [[ICloudSyncSlideController alloc] init];
        _iCloudSyncSlideController.cer = self;
    }
    
    return _iCloudSyncSlideController;
}


- (SYTextInputViewController *)sYTextInputViewController {
    if(nil == _sYTextInputViewController) {
        _sYTextInputViewController = [[SYTextInputViewController alloc] init];
       _sYTextInputViewController.notificationName = @"linkAction";

    }
    return _sYTextInputViewController;
}

- (LoadingSlideController *)loadingSlideController{
    if (nil == _loadingSlideController){
        _loadingSlideController = [[LoadingSlideController alloc] init];
        _loadingSlideController.originMainText = NSLocalizedString(@"settings.downloadScript", @"");
    }
    
    return _loadingSlideController;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"app.stay.notification.userscriptDidDeleteNotification"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"app.stay.notification.userscriptDidActiveNotification"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"app.stay.notification.userscriptDidStopNotification"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"app.stay.notification.userscriptDidAddNotification"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"app.stay.notification.userscriptDidUpdateNotification"
                                                  object:nil];
    
#ifdef Mac
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"app.stay.notification.NCCDidShowViewControllerNotification"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:SVCDidBecomeActiveNotification
                                                  object:nil];
#else
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:iCloudServiceSyncStartNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:iCloudServiceSyncEndNotification
                                               object:nil];
#endif
}

- (NSString* )md5HexDigest:(NSString* )input {
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02X", digest[i]];
    }
    return result;
}

@end
