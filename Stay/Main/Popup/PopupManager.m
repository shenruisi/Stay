//
//  PopupManager.m
//  Stay
//
//  Created by ris on 2023/5/31.
//

#import "PopupManager.h"
#ifdef FC_MAC
#import "FCSplitViewController.h"
#endif
#import "FCConfig.h"
#import "API.h"
#import "FCStore.h"
#import "DeviceHelper.h"
#import "PopupSlideController.h"
#import "SharedStorageManager.h"
#import "CommitCodeSlideController.h"
#import "FCApp.h"

NSNotificationName const _Nonnull PopupShouldShowCodeCommitNotification = @"app.stay.notification.PopupShouldShowCodeCommitNotification";

@interface PopupManager()

@property (nonatomic, strong) NSMutableDictionary<NSString *,NSNumber *> *shownUUIDsDic;
@property (nonatomic, strong) PopupSlideController *popupSlideController;
@property (nonatomic, strong) CommitCodeSlideController *commitCodeSlideController;
@end

@implementation PopupManager

+ (instancetype)shared{
    static dispatch_once_t once;
    static PopupManager *instance;
    dispatch_once(&once, ^{
        if (!instance){
            instance = [[self alloc] init];
        }
    });
    
    return instance;
}

- (instancetype)init{
    if (self = [super init]){
#ifdef FC_MAC
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(onBecomeActive:)
                                                         name:SVCDidBecomeActiveNotification
                                                       object:nil];
#else
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onResignActive:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(showCodeCommitHandler:)
                                                     name:PopupShouldShowCodeCommitNotification
                                                   object:nil];
        
        //        UIApplicationWillResignActiveNotification
#endif
    }
    
    return self;
}

- (void)setIngorePopup:(BOOL)ingorePopup{
    _ingorePopup = ingorePopup;
    if (_ingorePopup){
#if FC_IOS || FC_MAC
    [[NSNotificationCenter defaultCenter] postNotificationName:DeviceHelperConsumePointsDidChangeNotification
                                                        object:nil
                                                      userInfo:nil];
#endif
    }
}

- (void)onBecomeActive:(NSNotification *)note{
    [SharedStorageManager shared].userDefaults = nil;
    CGFloat tagConsumed = [SharedStorageManager shared].userDefaults.tagConsumed;
    [DeviceHelper consumePoints:tagConsumed];
    [SharedStorageManager shared].userDefaults.tagConsumed = 0;
    [SharedStorageManager shared].userDefaultsExRO.availablePoints = [SharedStorageManager shared].userDefaultsExRO.availablePoints - tagConsumed;
    
    if (!self.ingorePopup){
        [[API shared] queryPath:@"/popups"
                            pro:[[FCStore shared] getPlan:NO] != FCPlan.None
                       deviceId:DeviceHelper.uuid
                            biz:nil completion:^(NSInteger statusCode, NSError * _Nonnull error, NSDictionary * _Nonnull server, NSDictionary * _Nonnull biz) {
            if (200 == statusCode){
                NSInteger points = [biz[@"points"] integerValue];
                NSInteger giftPoints = [biz[@"gift_points"] integerValue];
                
                [SharedStorageManager shared].userDefaultsExRO.availablePoints = (CGFloat)points - DeviceHelper.totalConsumePoints;
                [SharedStorageManager shared].userDefaultsExRO.availableGiftPoints = (CGFloat)giftPoints;
                
                NSArray *pointsConsumeConfig = biz[@"points_consume_config"];
                for (NSDictionary *consume in pointsConsumeConfig){
                    NSString *type = consume[@"type"];
                    if ([type isEqualToString:@"download"]){
                        [SharedStorageManager shared].userDefaultsExRO.downloadConsumePoints = [consume[@"value"] floatValue];
                    }
                    else if ([type isEqualToString:@"tag"]){
                        [SharedStorageManager shared].userDefaultsExRO.tagConsumePoints = [consume[@"value"] floatValue];
                    }
                }
                
                NSLog(@"availablePoints: %f, availableGiftPoints: %f, downloadConsumePoints: %f, tagConsumePoints: %f",
                      [SharedStorageManager shared].userDefaultsExRO.availablePoints,
                      [SharedStorageManager shared].userDefaultsExRO.availableGiftPoints,
                      [SharedStorageManager shared].userDefaultsExRO.downloadConsumePoints,
                      [SharedStorageManager shared].userDefaultsExRO.tagConsumePoints);
                
                
                BOOL rc = [biz[@"rc"] boolValue];
                if (rc){
                    
                }
                
                NSDictionary *popup = biz[@"popup"];
                NSUserDefaults *groupUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dajiu.stay.pro"];
                if (popup && !(nil == [groupUserDefaults objectForKey:@"tips"] && nil ==  [groupUserDefaults objectForKey:@"userDefaults.firstGuide"])){
                    if ([self.shownUUIDsDic objectForKey:popup[@"uuid"]]){
                        return;
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([self.popupSlideController isShown]){
                            [self.popupSlideController dismiss];
                        }
                        self.popupSlideController = [[PopupSlideController alloc] initWithDic:popup];
                        [self.popupSlideController show];
                        [self.shownUUIDsDic setObject:@(1) forKey:popup[@"uuid"]];
                        [self persistShownUUIDsDic];
                    });
                }
            }
        }];
        
       
    }
}

- (void)showCodeCommitHandler:(NSNotification *)note{
    if ([[FCConfig shared] getBoolValueOfKey:GroupUserDefaultsKeyNewDevice]){
        self.commitCodeSlideController = [[CommitCodeSlideController alloc] init];
        self.commitCodeSlideController.baseCer = FCApp.keyWindow.rootViewController;
        [self.commitCodeSlideController show];
    }   
}

- (void)onResignActive:(NSNotification *)note{
    self.ingorePopup = NO;
}

- (NSMutableDictionary<NSString *,NSNumber *> *)shownUUIDsDic{
    if (nil == _shownUUIDsDic){
        _shownUUIDsDic = [NSMutableDictionary dictionaryWithDictionary:[[FCConfig shared] getValueOfKey:GroupUserDefaultsKeyShownUUIDs]];
    }
    
    return _shownUUIDsDic;
}

- (void)persistShownUUIDsDic{
    [[FCConfig shared] setValueOfKey:GroupUserDefaultsKeyShownUUIDs value:self.shownUUIDsDic];
}

@end
