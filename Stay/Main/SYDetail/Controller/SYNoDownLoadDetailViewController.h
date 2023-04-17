//
//  SYNoDownLoadDetailViewController.h
//  Stay
//
//  Created by zly on 2022/9/14.
//

#import <UIKit/UIKit.h>
#import "UserScript.h"
#import "SYSecondaryViewController.h"
#import "FCViewController.h"

@interface SYNoDownLoadDetailViewController : FCViewController

@property (nonatomic, strong) NSDictionary *scriptDic;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, assign) BOOL saveSuceess;
@property (nonatomic, strong) UITableView *tableView;
@end
