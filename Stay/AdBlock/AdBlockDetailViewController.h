//
//  AdBlockDetailViewController.h
//  Stay
//
//  Created by ris on 2023/4/5.
//

#import "FCViewController.h"
#import "ContentFilter2.h"
#import "SYSecondaryViewController.h"

NS_ASSUME_NONNULL_BEGIN



@interface AdBlockDetailViewController : SYSecondaryViewController

@property (nonatomic, strong) ContentFilter *contentFilter;
- (void)refreshRules;
@end

NS_ASSUME_NONNULL_END
