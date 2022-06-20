//
//  FCSplitViewController.h
//  Stay-Mac
//
//  Created by ris on 2022/6/15.
//

#import <UIKit/UIKit.h>
#import "FCToolbar.h"

NS_ASSUME_NONNULL_BEGIN

@interface FCSplitViewController : UISplitViewController

@property (nonatomic, strong, nullable) FCToolbar *toolbar;
@end

NS_ASSUME_NONNULL_END
