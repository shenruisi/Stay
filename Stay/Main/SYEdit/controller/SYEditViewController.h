//
//  SYEditViewController.h
//  Stay
//
//  Created by zly on 2021/12/3.
//

#import <UIKit/UIKit.h>
#import "UserScript.h"

NS_ASSUME_NONNULL_BEGIN

@interface SYEditViewController : UIViewController

@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) UserScript *userScript;
@property (nonatomic, assign) bool isEdit;
@end

NS_ASSUME_NONNULL_END
