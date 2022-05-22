//
//  AppDelegate.m
//  Stay
//
//  Created by ris on 2021/10/15.
//

#import "AppDelegate.h"
#import "NavigationController.h"
#import "SceneDelegate.h"
#import "DataManager.h"
#import "IACManager.h"
#import "SYEditViewController.h"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [IACManager sharedManager].callbackURLScheme = @"stay";
    [[IACManager sharedManager] handleAction:@"install" withBlock:^(NSDictionary *inputParameters, IACSuccessBlock success, IACFailureBlock failure) {
        NSString *url = inputParameters[@"scriptURL"];
        NSString *decodeUrl = [url stringByRemovingPercentEncoding];//编码
        NSMutableCharacterSet *set  = [[NSCharacterSet URLFragmentAllowedCharacterSet] mutableCopy];
         [set addCharactersInString:@"#"];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[decodeUrl stringByAddingPercentEncodingWithAllowedCharacters:set]]];
            dispatch_async(dispatch_get_main_queue(),^{

                if(data != nil ) {
                    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                    SYEditViewController *cer = [[SYEditViewController alloc] init];
                    cer.content = str;
                    UINavigationController *nav = [self getCurrentNCFrom:[UIApplication sharedApplication].keyWindow.rootViewController];
                    [nav pushViewController:cer animated:true];
                }
            });

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



@end
