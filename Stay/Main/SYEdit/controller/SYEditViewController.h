//
//  SYEditViewController.h
//  Stay
//
//  Created by zly on 2021/12/3.
//

#import <UIKit/UIKit.h>
#import "UserScript.h"


#ifdef Mac
#import "NavigateViewController.h"
@interface SYEditViewController : NavigateViewController
#else
@interface SYEditViewController : UIViewController
#endif

@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) UserScript *userScript;
@property (nonatomic, assign) bool isEdit;
@property (nonatomic, assign) bool isSearch;
@property (nonatomic, strong) NSString *downloadUrl;

- (void)save;
@end

