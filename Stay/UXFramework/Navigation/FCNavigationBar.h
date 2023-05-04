//
//  FCNavigationBar.h
//  Stay
//
//  Created by ris on 2023/3/14.
//

#import <UIKit/UIKit.h>
#import "FCView.h"

NS_ASSUME_NONNULL_BEGIN


@protocol FCSearchUpdatingDelegate <NSObject>

- (void)willBeginSearch;
- (void)didBeganSearch;
- (void)willEndSearch;
- (void)didEndSearch;
- (void)searchTextDidChange:(NSString *)text;
@end

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
@property (nonatomic, assign) BOOL inSearch;
- (void)rightItemClick:(FCTabButtonItem *)item;
- (void)showSearchWithOffset:(CGFloat)offset;
- (void)startSearch;
- (void)cancelSearch;
@end

NS_ASSUME_NONNULL_END
