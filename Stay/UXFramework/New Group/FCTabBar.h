//
//  FCTabBar.h
//  Stay
//
//  Created by ris on 2023/3/14.
//

#import <UIKit/UIKit.h>
#import "FCTabBarItem.h"
NS_ASSUME_NONNULL_BEGIN

typedef enum {
    FCTabBarStyleNormal,
    FCTabBarStyleSegment
}FCTabBarStyle;


@protocol FCTabBarDelegate;
@interface FCTabBar : UIView

@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) id<FCTabBarDelegate> delegate;
@property (readonly) BOOL isShown;
- (instancetype)initWithStyle:(FCTabBarStyle)style;

- (void)addItem:(FCTabBarItem *)item;
- (void)layout;
- (void)selectIndex:(NSInteger)index;
- (void)show;
- (void)dismiss;
@end

@protocol FCTabBarDelegate<NSObject>

- (void)tabBar:(FCTabBar *)tabBar didSelectIndex:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
