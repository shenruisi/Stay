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
#import "SYBrowseExpandViewController.h"
#import "SYNoDownLoadDetailViewController.h"
#import "SYDetailViewController.h"
#import "ScriptMananger.h"
#import "ScriptEntity.h"
#import <SDWebImageSVGKitPlugin/SDWebImageSVGKitPlugin.h>
#import <SVGKit/SVGKit.h>
#import "NSString+Urlencode.h"
#import "DownloadResource.h"
#import <CommonCrypto/CommonDigest.h>
#import "DownloadManager.h"
#import "SYDownloadSlideController.h"

#ifdef Mac
#import "Plugin.h"
#endif

#if iOS
#import "Stay-Swift.h"
#else
#import "Stay-Swift.h"
#endif

#import "QuickAccess.h"
#import "DeviceHelper.h"

#ifdef iOS
#import <Bugsnag/Bugsnag.h>
#endif

@interface AppDelegate()

@property (nonatomic, strong) LoadingSlideController *loadingSlideController;
@property (nonatomic, strong) SYDownloadSlideController *syDownloadSlideController;


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
#ifndef Mac
    [UMConfigure initWithAppkey:@"62b3dfc705844627b5c26bed" channel:@"App Store"];
    [Bugsnag start];
#endif
    
    
    SDImageSVGKCoder *SVGCoder = [SDImageSVGKCoder sharedCoder];
    [[SDImageCodersManager sharedManager] addCoder:SVGCoder];
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
                    
                    if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
                        && [QuickAccess splitController].viewControllers.count >= 2){
                        [[QuickAccess secondaryController] pushViewController:cer];
                    }
                    else{
                        UINavigationController *nav = [self getCurrentNCFrom:[UIApplication sharedApplication].keyWindow.rootViewController];
                        [nav pushViewController:cer animated:true];
                    }
                    
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
    
     
    [[IACManager sharedManager] handleAction:@"pay" withBlock:^(NSDictionary *inputParameters, IACSuccessBlock success, IACFailureBlock failure) {
#ifdef Mac
        if ([QuickAccess primaryController] != nil){
            [QuickAccess primaryController].selectedIndex = 3;
            [[QuickAccess primaryController].selectedViewController presentViewController:
             [[UINavigationController alloc] initWithRootViewController:[[SYSubscribeController alloc] init]]
                               animated:YES completion:^{}];
        }
#else
        if([UIApplication sharedApplication].keyWindow.rootViewController != nil) {
            ((UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController).selectedIndex = 3;
            [((UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController).selectedViewController  pushViewController:[[SYSubscribeController alloc] init] animated:YES];
        }
#endif
        
    }];
     
    
    
    [[IACManager sharedManager] handleAction:@"album" withBlock:^(NSDictionary *inputParameters, IACSuccessBlock success, IACFailureBlock failure) {
        
        NSString *themeId = inputParameters[@"id"];
        SYBrowseExpandViewController *cer = [[SYBrowseExpandViewController alloc] init];
        cer.url= [NSString stringWithFormat:@"https://api.shenyin.name/stay-fork/album/%@",themeId];
        #ifdef Mac
            [[QuickAccess secondaryController] pushViewController:cer];
        #else
            UINavigationController *nav = [self getCurrentNCFrom:[UIApplication sharedApplication].keyWindow.rootViewController];
            [nav pushViewController:cer animated:true];
        #endif
            
    }];
    
    [[IACManager sharedManager] handleAction:@"userscript" withBlock:^(NSDictionary *inputParameters, IACSuccessBlock success, IACFailureBlock failure) {
        NSString *uuid = inputParameters[@"id"];
        ScriptEntity *entity = [ScriptMananger shareManager].scriptDic[uuid];
        if(entity == nil) {
            SYNoDownLoadDetailViewController *cer = [[SYNoDownLoadDetailViewController alloc] init];
            cer.uuid = uuid;
            #ifdef Mac
                [[QuickAccess secondaryController] pushViewController:cer];
            #else
                UINavigationController *nav = [self getCurrentNCFrom:[UIApplication sharedApplication].keyWindow.rootViewController];
                [nav pushViewController:cer animated:true];
            #endif
        } else {
            SYDetailViewController *cer = [[SYDetailViewController alloc] init];
            cer.script = [[DataManager shareManager] selectScriptByUuid:uuid];
            #ifdef Mac
                [[QuickAccess secondaryController] pushViewController:cer];
            #else
                UINavigationController *nav = [self getCurrentNCFrom:[UIApplication sharedApplication].keyWindow.rootViewController];
                [nav pushViewController:cer animated:true];
            #endif
        }
        
    }];
    
    
    [[IACManager sharedManager] handleAction:@"snifferVideo" withBlock:^(NSDictionary *inputParameters, IACSuccessBlock success, IACFailureBlock failure) {
        
        //如果不是pro会员直接返回
        Boolean isPro = [[FCStore shared] getPlan:NO] == FCPlan.None?FALSE:TRUE;
        if(!isPro) {
            return;
        }

        if (self.syDownloadSlideController.isShown){
            [self.syDownloadSlideController dismiss];
        }
       NSString *listStr = inputParameters[@"list"];
//       NSString *listDecodeStr = [listStr decodeString];
       NSArray *arrays = [NSJSONSerialization JSONObjectWithData:[listStr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        
        if(arrays != nil && arrays.count > 0) {
            for(int i = 0;i < arrays.count; i++) {
                NSDictionary *dic = arrays[i];
                self.syDownloadSlideController = [[SYDownloadSlideController alloc] init];
                UINavigationController *nav = [self getCurrentNCFrom:[UIApplication sharedApplication].keyWindow.rootViewController];
                self.syDownloadSlideController.controller = nav;
                self.syDownloadSlideController.dic = [NSMutableDictionary dictionaryWithDictionary:dic];;
                [self.syDownloadSlideController show];
                break;

            }
        }
            
    }];
    
    
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
    else if ([vc isKindOfClass:[UISplitViewController class]]){
        UISplitViewController *svc = (UISplitViewController *)vc;
        if (svc.displayMode == UISplitViewControllerDisplayModeSecondaryOnly){
            svc.preferredDisplayMode = UISplitViewControllerDisplayModeOneBesideSecondary;
        }
        return [self getCurrentNCFrom:svc.viewControllers[0]];
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

- (void)applicationWillTerminate:(UIApplication *)application{}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window {
    return _orientationLock;
}

@end
