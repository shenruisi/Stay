//
//  SYDetailViewController.h
//  Stay
//
//  Created by zly on 2021/11/28.
//

#import <UIKit/UIKit.h>
#import "UserScript.h"
NS_ASSUME_NONNULL_BEGIN

@interface SYDetailViewController : UIViewController
@property (nonatomic, strong) UserScript *script;
@property (nonatomic, assign) BOOL isSearch;
@end

NS_ASSUME_NONNULL_END
