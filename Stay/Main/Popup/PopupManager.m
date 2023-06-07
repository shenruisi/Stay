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

@interface PopupManager()

@property (nonatomic, strong) NSMutableDictionary<NSString *,NSNumber *> *shownUUIDsDic;
@property (nonatomic, strong) PopupSlideController *popupSlideController;
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
        //    [[NSNotificationCenter defaultCenter] addObserver:self
        //                                             selector:@selector(onBecomeActive:)
        //                                                 name:SVCDidBecomeActiveNotification
        //                                               object:nil];
#else
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onResignActive:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        
        //        UIApplicationWillResignActiveNotification
#endif
    }
    
    return self;
}

- (void)onBecomeActive:(NSNotification *)note{
    if (!self.ingorePopup){
        [[API shared] queryPath:@"/popups"
                            pro:[[FCStore shared] getPlan:NO]
                       deviceId:DeviceHelper.uuid
                            biz:nil completion:^(NSInteger statusCode, NSError * _Nonnull error, NSDictionary * _Nonnull server, NSDictionary * _Nonnull biz) {
            if (200 == statusCode){
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
