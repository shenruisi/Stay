//
//  SYSecondaryViewController.h
//  Stay
//
//  Created by ris on 2022/10/10.
//

#import <UIKit/UIKit.h>
#import "FCViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SYSecondaryViewController : FCViewController

@property (nonatomic, strong) UINavigationController *stNavigationController;
@property (nonatomic, strong) NSArray<UIBarButtonItem *> *rightBarButtonItems;
@end

NS_ASSUME_NONNULL_END
