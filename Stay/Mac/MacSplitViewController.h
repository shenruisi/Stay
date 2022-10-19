//
//  MacSplitViewController.h
//  Stay-Mac
//
//  Created by ris on 2022/10/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MacSplitViewController : UISplitViewController

- (id)toolbar;
@property (nonatomic, strong) UIView *placeHolderTitleView;
@end

NS_ASSUME_NONNULL_END
