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

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {

#ifdef Mac
    
#else
    UINavigationBar.appearance.prefersLargeTitles = YES;
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
    self.window.frame = windowScene.coordinateSpace.bounds;
    self.window.rootViewController = [[MainTabBarController alloc] init];
    [self.window makeKeyAndVisible];
#endif
    
}

- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts{
    UIOpenURLContext *context =  URLContexts.anyObject;
    if (context){
        [[IACManager sharedManager] handleOpenURL:context.URL];
    }
}


@end
