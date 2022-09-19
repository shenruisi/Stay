//
//  SYBrowseExpandViewController.h
//  Stay
//
//  Created by zly on 2022/9/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#ifdef Mac
#import "NavigateViewController.h"
@interface SYBrowseExpandViewController : NavigateViewController
#else
@interface SYBrowseExpandViewController : UIViewController
#endif

@property (nonatomic, strong) NSArray *data;
@end

NS_ASSUME_NONNULL_END
