//
//  SYBrowseViewController.h
//  Stay
//
//  Created by zly on 2022/9/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
#ifdef Mac
#import "NavigateViewController.h"
@interface SYBrowseViewController : NavigateViewController
#else
@interface SYBrowseViewController : UIViewController
#endif
@end

NS_ASSUME_NONNULL_END
