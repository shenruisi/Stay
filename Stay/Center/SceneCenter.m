//
//  SceneCenter.m
//  Stay-Mac
//
//  Created by ris on 2022/6/15.
//

#import "SceneCenter.h"

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

- (void)connectScene:(FCSceneIdentifier)sceneIdentifier
         windowScene:(UIWindowScene *)windowScene
        sceneSession:(UISceneSession *)sceneSession{
    [self.openWindows addObject:sceneIdentifier];
    FCScene *fcScene = self.fcSceneDic[sceneIdentifier];
    if (fcScene){
        
        return;
    }
    
    fcScene = [[FCScene alloc] init];
    NSDictionary *origin = nil;
}

@end
