//
//  FCTableViewHeadCell.h
//  Stay
//
//  Created by ris on 2023/5/15.
//

#import <UIKit/UIKit.h>
#import "FCView.h"
NS_ASSUME_NONNULL_BEGIN

@interface FCTableViewHeadMenuItem : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) void(^action)(void);
@end


@interface FCTableViewHeadCell : UITableViewCell

@property (nonatomic, readonly) FCView *menuView;
@property (nonatomic, strong) NSArray<FCTableViewHeadMenuItem *> *menus;
@end

NS_ASSUME_NONNULL_END
