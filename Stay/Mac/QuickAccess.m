//
//  QuickAccess.m
//  Stay-Mac
//
//  Created by ris on 2022/6/22.
//

#import "QuickAccess.h"
#ifdef Mac
#import "SceneCenter.h"
#endif
#import "FCApp.h"

@implementation QuickAccess

+ (nullable UISplitViewController *)splitController{
#ifdef Mac
    UIWindowScene *windowScene = [[SceneCenter shared] sceneForIdentifier:SCENE_Main];
    if (windowScene){
        return (UISplitViewController *)windowScene.windows[0].rootViewController;
    }
#endif
    return (UISplitViewController *)[FCApp keyWindow].rootViewController;
}

+ (nullable MainTabBarController *)primaryController{
    UISplitViewController *splitViewController = [self splitController];
    if (splitViewController){
        return splitViewController.viewControllers[0];
    }
    return nil;
}

+ (nullable SYNavigationController *)secondaryController{
    UISplitViewController *splitViewController = [self splitController];
    if (splitViewController){
        return splitViewController.viewControllers[1];
    }
    return nil;
}

+ (nullable SYHomeViewController *)homeViewController{
    return [self primaryController].homeController;
}


+ (nullable UIViewController *)rootController{
#ifdef Mac
    UIWindowScene *windowScene = [[SceneCenter shared] sceneForIdentifier:SCENE_Main];
    if (windowScene){
        return windowScene.windows[0].rootViewController;
    }
#endif
    return [FCApp keyWindow].rootViewController;
}


@end
