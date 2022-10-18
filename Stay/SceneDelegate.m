//
//  SceneDelegate.m
//  Stay
//
//  Created by ris on 2021/10/15.
//

#import "SceneDelegate.h"
#import "NavigationController.h"
//#import "ViewController.h"
#import "MainTabBarController.h"
#import "IACManager.h"
#ifdef Mac
#import "SceneCenter.h"
#else
#import "PadSplitViewController.h"
#endif
#if iOS
#import "Stay-Swift.h"
#else
#import "Stay-Swift.h"
#endif

#import "DeviceHelper.h"
#import "SYNavigationController.h"
#import "EmptyViewController.h"

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {

    UIWindowScene *windowScene = (UIWindowScene *)scene;
#ifdef Mac
    UIWindow *window = [[SceneCenter shared] connectScene:@"app.stay.scene.main"
                           windowScene:windowScene
                          sceneSession:session];
    self.window = window;
#else
    UINavigationBar.appearance.prefersLargeTitles = YES;
    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
    self.window.frame = windowScene.coordinateSpace.bounds;
    if (FCDeviceTypeIPad == [DeviceHelper type]){
        PadSplitViewController *splitViewController = [[PadSplitViewController alloc] init];
        MainTabBarController *primaryController = [[MainTabBarController alloc] init];
        SYNavigationController *secondaryController = [[SYNavigationController alloc]
                                                             initWithRootViewController:[[EmptyViewController alloc] init]];
        splitViewController.viewControllers = @[
            primaryController,secondaryController
        ];
        
        self.window.rootViewController = splitViewController;
    }
    else{
        self.window.rootViewController = [[MainTabBarController alloc] init];
    }
    [self.window makeKeyAndVisible];
#endif
    
    if(connectionOptions.URLContexts != NULL) {
        [self scene:scene openURLContexts:connectionOptions.URLContexts];
    }
    
}

- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts{
    UIOpenURLContext *context =  URLContexts.anyObject;
    
    if (context){
        [[IACManager sharedManager] handleOpenURL:context.URL];
    }
}


- (void)sceneDidBecomeActive:(UIScene *)scene{
    
}

@end
