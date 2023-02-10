//
//  SYSubmitScriptViewController.h
//  Stay
//
//  Created by zly on 2023/2/7.
//

#import "ModalViewController.h"
#import "UserScript.h"
NS_ASSUME_NONNULL_BEGIN

@interface SYSubmitScriptViewController : ModalViewController

@property(nonatomic,strong) UserScript *script;
@property(nonatomic,strong) UINavigationController *nav;

@end

NS_ASSUME_NONNULL_END
