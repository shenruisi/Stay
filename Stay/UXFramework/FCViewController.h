//
//  FCViewController.h
//  Stay
//
//  Created by ris on 2023/3/14.
//

#import <UIKit/UIKit.h>
#import "FCNavigationBar.h"

NS_ASSUME_NONNULL_BEGIN

@interface FCViewController : UIViewController

@property (nonatomic, readonly) FCNavigationTabItem *navigationTabItem;
@property (nonatomic, assign) BOOL enableTabItem;
@property (nonatomic, strong) UINavigationBarAppearance *appearance;

- (void)tabItemDidClick:(FCTabButtonItem *)item refresh:(BOOL)refresh;
@end

NS_ASSUME_NONNULL_END
