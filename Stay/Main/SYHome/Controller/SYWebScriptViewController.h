//
//  SYWebScriptViewController.h
//  Stay
//
//  Created by zly on 2022/4/7.
//

#import <UIKit/UIKit.h>

#ifdef Mac
#import "NavigateViewController.h"
@interface SYWebScriptViewController : NavigateViewController
#else
@interface SYWebScriptViewController : UIViewController
#endif

- (BOOL)canGoback;
- (void)goback;
@end
