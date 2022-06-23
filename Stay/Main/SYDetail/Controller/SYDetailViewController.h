//
//  SYDetailViewController.h
//  Stay
//
//  Created by zly on 2021/11/28.
//

#import <UIKit/UIKit.h>
#import "UserScript.h"

#ifdef Mac
#import "NavigateViewController.h"
@interface SYDetailViewController : NavigateViewController
#else
@interface SYDetailViewController : UIViewController
#endif

@property (nonatomic, strong) UserScript *script;
@property (nonatomic, assign) BOOL isSearch;
@end


