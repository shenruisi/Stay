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

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}



- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSUserDefaults *groupUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dajiu.stay.pro"];
    if([groupUserDefaults arrayForKey:@"ACTIVE_CHANGE"] != NULL && [groupUserDefaults arrayForKey:@"ACTIVE_CHANGE"].count > 0){
        NSMutableArray<NSDictionary *> *datas = [NSMutableArray arrayWithArray:[groupUserDefaults arrayForKey:@"ACTIVE_CHANGE"]];
        for(int i = 0; i < datas.count; i++) {
            NSDictionary *dic = datas[i];
            [[DataManager shareManager] updateScrpitStatus:[dic[@"active"] intValue] numberId:dic[@"uuid"]];
        }
    }
}
@end
