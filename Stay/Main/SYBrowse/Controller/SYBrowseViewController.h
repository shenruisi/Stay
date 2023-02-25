//
//  SYBrowseViewController.h
//  Stay
//
//  Created by zly on 2022/9/6.
//

#import <UIKit/UIKit.h>

#ifdef FC_MAC
#import "NavigateViewController.h"
@interface SYBrowseViewController : NavigateViewController
#else
@interface SYBrowseViewController : UIViewController
#endif
@end
