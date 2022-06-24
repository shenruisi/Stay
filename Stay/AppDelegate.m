//
//  AppDelegate.m
//  Stay
//
//  Created by ris on 2021/10/15.
//

#ifndef Mac
#import <UMCommon/UMCommon.h>
#endif
#import "AppDelegate.h"
#import "NavigationController.h"
#import "SceneDelegate.h"
#import "DataManager.h"
#import "IACManager.h"
#import "SYEditViewController.h"
#import "LoadingSlideController.h"
#import "FCShared.h"
#ifdef Mac
#import "QuickAccess.h"
#import "Plugin.h"
#endif

@interface AppDelegate()

@property (nonatomic, strong) LoadingSlideController *loadingSlideController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
#ifndef Mac
    [UMConfigure initWithAppkey:@"62b3dfc705844627b5c26bed" channel:@"App Store"];
#endif
    
    [IACManager sharedManager].callbackURLScheme = @"stay";
    [[IACManager sharedManager] handleAction:@"install" withBlock:^(NSDictionary *inputParameters, IACSuccessBlock success, IACFailureBlock failure) {
        [self.loadingSlideController show];
        NSString *url = inputParameters[@"scriptURL"];
        NSString *decodeUrl = [url stringByRemovingPercentEncoding];//编码
        NSMutableCharacterSet *set  = [[NSCharacterSet URLFragmentAllowedCharacterSet] mutableCopy];
         [set addCharactersInString:@"#"];
        dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT),^{

        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[decodeUrl stringByAddingPercentEncodingWithAllowedCharacters:set]]];
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
#ifdef Mac
                    [[QuickAccess secondaryController] pushViewController:cer];
                    
#else
                    UINavigationController *nav = [self getCurrentNCFrom:[UIApplication sharedApplication].keyWindow.rootViewController];
                    [nav pushViewController:cer animated:true];
#endif
                } else{
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
        }];
    
#ifdef Mac
    [FCShared.plugin load];
#endif
        
    
//    NSUserDefaults *groupUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dajiu.stay.pro"];
//
//    NSMutableArray<NSDictionary *> *datas = [NSMutableArray arrayWithArray:[groupUserDefaults arrayForKey:@"STAY_SCRIPTS"]];
    
    return YES;
}

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

//递归
- (UINavigationController *)getCurrentNCFrom:(UIViewController *)vc
{
    if ([vc isKindOfClass:[UITabBarController class]]) {
        UINavigationController *nc = ((UITabBarController *)vc).selectedViewController;
        return [self getCurrentNCFrom:nc];
    }
    else if ([vc isKindOfClass:[UINavigationController class]]) {
        if (((UINavigationController *)vc).presentedViewController) {
            return [self getCurrentNCFrom:((UINavigationController *)vc).presentedViewController];
        }
        return [self getCurrentNCFrom:((UINavigationController *)vc).topViewController];
    }
    else if ([vc isKindOfClass:[UIViewController class]]) {
        if (vc.presentedViewController) {
            return [self getCurrentNCFrom:vc.presentedViewController];
        }
        else {
            return vc.navigationController;
        }
    }
    else {
        NSAssert(0, @"未获取到导航控制器");
        return nil;
    }
}


- (LoadingSlideController *)loadingSlideController{
    if (nil == _loadingSlideController){
        _loadingSlideController = [[LoadingSlideController alloc] init];
        _loadingSlideController.originMainText = NSLocalizedString(@"settings.downloadScript", @"");
    }
    
    return _loadingSlideController;
}


@end
