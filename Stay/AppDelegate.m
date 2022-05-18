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

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [IACManager sharedManager].callbackURLScheme = @"stay";
    [[IACManager sharedManager] handleAction:@"install" withBlock:^(NSDictionary *inputParameters, IACSuccessBlock success, IACFailureBlock failure) {
        NSString *url = inputParameters[@"scriptURL"];
    }];
    return YES;
}

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}




@end
