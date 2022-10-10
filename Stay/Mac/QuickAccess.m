//
//  QuickAccess.m
//  Stay-Mac
//
//  Created by ris on 2022/6/22.
//

#import "QuickAccess.h"
#import "SceneCenter.h"

@implementation QuickAccess

+ (nullable MacSplitViewController *)splitController{
    UIWindowScene *windowScene = [[SceneCenter shared] sceneForIdentifier:SCENE_Main];
    if (windowScene){
        return (MacSplitViewController *)windowScene.windows[0].rootViewController;
    }
    return nil;
}

+ (nullable MainTabBarController *)primaryController{
    UISplitViewController *splitViewController = [self splitController];
    if (splitViewController){
        return splitViewController.viewControllers[0];
    }
    return nil;
}

+ (nullable NavigateCollectionController *)secondaryController{
    UISplitViewController *splitViewController = [self splitController];
    if (splitViewController){
        return splitViewController.viewControllers[1];
    }
    return nil;
}

+ (nullable SYHomeViewController *)homeViewController{
    return [self primaryController].homeController;
}


@end
