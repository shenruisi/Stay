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
@property (nonatomic, assign) CGFloat naivgationBarBaseLine;
@property (nonatomic, weak) id<FCSearchUpdatingDelegate> searchUpdating;
@property (nonatomic, strong) UIViewController *searchViewController;

- (void)tabItemDidClick:(FCTabButtonItem *)item refresh:(BOOL)refresh;
- (void)searchTabItemDidClick;
- (void)endSearch;
@end

NS_ASSUME_NONNULL_END
