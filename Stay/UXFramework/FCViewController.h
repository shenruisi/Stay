//
//  FCViewController.h
//  Stay
//
//  Created by ris on 2023/3/14.
//

#import <UIKit/UIKit.h>
#import "FCNavigationBar.h"

NS_ASSUME_NONNULL_BEGIN



@interface FCViewController : UIViewController<
 FCSearchUpdatingDelegate
>

@property (nonatomic, readonly) FCNavigationTabItem *navigationTabItem;
@property (nonatomic, assign) BOOL enableTabItem;
@property (nonatomic, assign) BOOL enableSearchTabItem;
@property (nonatomic, strong) NSString *searchPlaceholder;
@property (nonatomic, strong) UINavigationBarAppearance *appearance;
@property (nonatomic, assign) CGFloat navigationBarBaseLine;
@property (nonatomic, weak) id<FCSearchUpdatingDelegate> searchUpdating;
@property (nonatomic, strong) UIViewController *searchViewController;

@property (nonatomic, strong) FCNavigationBar *fcNavigationBar;

- (void)tabItemDidClick:(FCTabButtonItem *)item refresh:(BOOL)refresh;
- (void)searchTabItemDidClick;
- (void)endSearch;
- (UINavigationBarAppearance *)navigationBarEffect:(CGFloat)yOffset;
- (void)scrollEffectHandle:(UIScrollView *)scrollView;
@end

NS_ASSUME_NONNULL_END
