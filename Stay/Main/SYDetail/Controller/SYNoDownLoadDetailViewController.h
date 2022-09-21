//
//  SYNoDownLoadDetailViewController.h
//  Stay
//
//  Created by zly on 2022/9/14.
//

#import <UIKit/UIKit.h>
#import "UserScript.h"

#ifdef Mac
#import "NavigateViewController.h"
@interface SYNoDownLoadDetailViewController : NavigateViewController
#else
@interface SYNoDownLoadDetailViewController : UIViewController
#endif

@property (nonatomic, strong) NSDictionary *scriptDic;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, assign) BOOL saveSuceess;
@end
