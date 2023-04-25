//
//  FCNavigationBar.h
//  Stay
//
//  Created by ris on 2023/3/14.
//

#import <UIKit/UIKit.h>
#import "FCView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FCTabButtonItem : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *image;
@end

@interface FCNavigationTabItem : FCView

@property (nonatomic, strong) NSArray<FCTabButtonItem *> *leftTabButtonItems;
@property (nonatomic, strong) NSArray<FCTabButtonItem *> *rightTabButtonItems;
- (void)activeItem:(FCTabButtonItem *)tagetItem;
@end

@interface FCSearchBar : UIView

@property (nonatomic, strong) UITextField *textField;
@end

@interface FCNavigationBar : UINavigationBar

@property (nonatomic, strong, nullable) FCNavigationTabItem *navigationTabItem;
@property (nonatomic, assign) BOOL enableTabItem;
@property (nonatomic, assign) BOOL enableTabItemSearch;
@property (nonatomic, strong) FCSearchBar *searchBar;
- (void)rightItemClick:(FCTabButtonItem *)item;
- (void)showSearchWithOffset:(CGFloat)offset;
- (void)startSearch;
@end

NS_ASSUME_NONNULL_END
