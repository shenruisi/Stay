//
//  SYEditViewController.h
//  Stay
//
//  Created by zly on 2021/12/3.
//

#import <UIKit/UIKit.h>
#import "UserScript.h"
#import "SYSecondaryViewController.h"
#import "FCViewController.h"


@interface SYEditViewController : SYSecondaryViewController

@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) UserScript *userScript;
@property (nonatomic, assign) bool isEdit;
@property (nonatomic, assign) bool isSearch;
@property (nonatomic, strong) NSString *downloadUrl;
@property (nonatomic, strong) NSArray *platforms;

- (void)save;
@end

