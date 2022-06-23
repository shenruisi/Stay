//
//  SceneCenter.m
//  Stay-Mac
//
//  Created by ris on 2022/6/15.
//

#import "SceneCenter.h"
#import "FCShared.h"
#import "Plugin.h"
#import "FCStyle.h"
#import "FCToolbar.h"
#import "FCConfig.h"
#import "FCSplitViewController.h"
#import "MainTabBarController.h"
#import "NavigateViewController.h"
#import "SegmentViewController.h"
#import "EmptyViewController.h"

FCSceneIdentifier const _Nonnull SCENE_Main = @"app.stay.scene.main";

@interface FCScene: NSObject
@property (nonatomic, weak) UISceneSession *session;
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, assign) BOOL sizeable;
@end

@implementation FCScene
@end

@interface SceneCenter()

@property (nonatomic, strong) NSMutableDictionary<FCSceneIdentifier, FCScene *> *fcSceneDic;
@property (nonatomic, strong) NSMutableSet<FCSceneIdentifier> *openWindows;

@end

@implementation SceneCenter

+ (instancetype)shared{
    static dispatch_once_t once;
    static SceneCenter *instance;
    dispatch_once(&once, ^{
        if (!instance){
            instance = [[self alloc] init];
        }
    });
   
    return instance;
}

- (UIWindow *)connectScene:(FCSceneIdentifier)sceneIdentifier
         windowScene:(UIWindowScene *)windowScene
        sceneSession:(UISceneSession *)sceneSession{
    [self.openWindows addObject:sceneIdentifier];
    FCScene *fcScene = self.fcSceneDic[sceneIdentifier];
    if (fcScene){
        [FCShared.plugin.appKit openWindow:fcScene.session.persistentIdentifier
                           sceneIdentifier:sceneIdentifier
                         activeScreenInfo:FCShared.plugin.carbon.activeScreenInfo
                                    opened:NO];
        return fcScene.window;
    }
    
    fcScene = [[FCScene alloc] init];
    NSDictionary *origin = nil;
    
    UIWindow *window = nil;
    if ([sceneIdentifier isEqualToString:SCENE_Main]){
        fcScene.sizeable = YES;
        UITitlebar *titlebar = windowScene.titlebar;
        titlebar.titleVisibility = UITitlebarTitleVisibilityHidden;
        titlebar.toolbar = [[FCToolbar alloc] initWithIdentifier:@"main"];
        titlebar.toolbar.displayMode = NSToolbarDisplayModeIconOnly;
        titlebar.toolbarStyle = UITitlebarToolbarStyleUnified;
        
        
        window = [[UIWindow alloc] initWithWindowScene:windowScene];
        window.backgroundColor = FCStyle.background;
        windowScene.sizeRestrictions.minimumSize = CGSizeMake(425, 480);
        NSDictionary *frame = [[FCConfig shared] getValueOfKey:GroupUserDefaultsKeyMacMainWindowFrame];
        
        if ([frame[@"width"] integerValue] != 0 && [frame[@"height"] integerValue] != 0){
            origin = @{@"x":frame[@"x"],@"y":frame[@"y"]};
            windowScene.sizeRestrictions.maximumSize = CGSizeMake([frame[@"width"] floatValue], [frame[@"height"] floatValue]);
            [[FCConfig shared] setValueOfKey:GroupUserDefaultsKeyMacMainWindowFrame
                                       value:@{@"x":@(-1),@"y":@(-1),@"width":@(0),@"height":@(0)}];
        }
        
        
        FCSplitViewController *splitViewController = [[FCSplitViewController alloc] init];
        splitViewController.toolbar = titlebar.toolbar;
        
        MainTabBarController *primaryController = [[MainTabBarController alloc] init];
//        [splitViewController setViewController:primaryController forColumn:UISplitViewControllerColumnPrimary];
        
        UserScript *userscript = [[UserScript alloc] init];
        userscript.uuid = @"123";
        NavigateViewController *secondaryController = [[NavigateViewController alloc]
                                                                      initWithRootViewController:[[EmptyViewController alloc] init]];
//        [splitViewController setViewController:secondaryController forColumn:UISplitViewControllerColumnSecondary];
        splitViewController.viewControllers = @[
            primaryController,secondaryController
        ];
        window.rootViewController = splitViewController;
        fcScene.window = window;
        fcScene.session = sceneSession;
        [window makeKeyAndVisible];
    }
    
    if (fcScene.window && fcScene.session){
        [[NSUserDefaults standardUserDefaults] setObject:sceneIdentifier forKey:fcScene.session.persistentIdentifier];
        self.fcSceneDic[sceneIdentifier] = fcScene;
      
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)),
        dispatch_get_main_queue(), ^{
            [FCShared.plugin.appKit styleWindow:fcScene.session.persistentIdentifier origin:origin];
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)),
        dispatch_get_main_queue(), ^{
            if (fcScene.sizeable){
                CGFloat screenWidth = fcScene.window.windowScene.screen.nativeBounds.size.width;
                CGFloat screenHeight = fcScene.window.windowScene.screen.nativeBounds.size.height;
                fcScene.window.windowScene.sizeRestrictions.maximumSize = CGSizeMake(screenWidth, screenHeight);
            }
        });
        
        [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:YES block:^(NSTimer * _Nonnull timer) {
            if ([FCShared.plugin.appKit titlebarAppearsTransparent:fcScene.session.persistentIdentifier]){
                [timer invalidate];
            }
        }];
        
       
    }
    
    return window;
}

- (UIWindowScene *)sceneForIdentifier:(FCSceneIdentifier)identifier{
    return self.fcSceneDic[identifier].window.windowScene;
}

- (NSMutableDictionary *)fcSceneDic{
    if (nil == _fcSceneDic){
        _fcSceneDic = [[NSMutableDictionary alloc] init];
    }
    
    return _fcSceneDic;
}

- (NSMutableSet<FCSceneIdentifier> *)openWindows{
    if (nil == _openWindows){
        _openWindows = [[NSMutableSet alloc] init];
    }
    
    return _openWindows;
}


@end
