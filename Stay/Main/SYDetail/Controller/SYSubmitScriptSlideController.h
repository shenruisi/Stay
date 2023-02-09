//
//  SYSubmitScriptSlideController.h
//  Stay
//
//  Created by zly on 2023/2/7.
//

#import "FCSlideController.h"
#import "UserScript.h"
NS_ASSUME_NONNULL_BEGIN

@interface SYSubmitScriptSlideController : FCSlideController
@property(nonatomic,strong) UINavigationController *controller;
@property(nonatomic,strong) UserScript *script;
@end

NS_ASSUME_NONNULL_END
