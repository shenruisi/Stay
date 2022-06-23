//
//  NavigateViewController.h
//  Stay-Mac
//
//  Created by ris on 2022/6/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NavigateViewController : UIViewController

- (void)navigateViewDidLoad;
- (void)navigateViewWillAppear:(BOOL)animated;
- (void)navigateViewDidAppear:(BOOL)animated;
- (void)navigateViewWillDisappear:(BOOL)animated;
- (void)navigateViewDidDisappear:(BOOL)animated;
- (void)relayout;
@end

NS_ASSUME_NONNULL_END
