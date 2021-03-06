//
//  SceneCenter.h
//  Stay-Mac
//
//  Created by ris on 2022/6/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString * FCSceneIdentifier;
extern FCSceneIdentifier const _Nonnull SCENE_Main;

@interface SceneCenter : NSObject

+ (instancetype)shared;

- (void)connectScene:(FCSceneIdentifier)sceneIdentifier
         windowScene:(UIWindowScene *)windowScene
        sceneSession:(UISceneSession *)sceneSession;

@end

NS_ASSUME_NONNULL_END
