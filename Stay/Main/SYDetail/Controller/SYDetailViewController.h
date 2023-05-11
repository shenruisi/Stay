//
//  SYDetailViewController.h
//  Stay
//
//  Created by zly on 2021/11/28.
//

#import <UIKit/UIKit.h>
#import "UserScript.h"
#import "SYSecondaryViewController.h"
#import "FCViewController.h"

@interface SYDetailViewController : SYSecondaryViewController

@property (nonatomic, strong) UserScript *script;
@property (nonatomic, assign) BOOL isSearch;
- (void)share;
@end


