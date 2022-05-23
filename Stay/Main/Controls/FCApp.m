//
//  FCApp.m
//  FastClip-iOS
//
//  Created by ris on 2022/2/8.
//

#import "FCApp.h"

@implementation FCApp

+ (UIWindow *)keyWindow{
    if (@available(ios 15.0, *)) {
        NSSet<UIScene *> *connectedScenes = [[UIApplication sharedApplication] connectedScenes];
        for (UIScene *scene in connectedScenes){
            if (scene.activationState == UISceneActivationStateForegroundActive){
                return ((UIWindowScene *)scene).keyWindow;
            }
        }
        if ([UIApplication sharedApplication].windows.count > 0){
            return [UIApplication sharedApplication].windows[0];
        }
        else return nil;
    } else {
        return [UIApplication sharedApplication].keyWindow;
    }
}

@end
