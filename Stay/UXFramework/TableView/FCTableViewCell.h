//
//  FCTableViewCell.h
//  Stay
//
//  Created by ris on 2023/3/23.
//

#import <UIKit/UIKit.h>
#import "FCRoundedShadowView2.h"
NS_ASSUME_NONNULL_BEGIN

@interface FCTableViewCell : UITableViewCell

@property (nonatomic, readonly) FCRoundedShadowView2 *fcContentView;
@property (nonatomic, strong) id element;
@property (nonatomic, copy) void (^action)(id);
+ (NSString *)identifier;
+ (UIEdgeInsets)contentInset;
@end

NS_ASSUME_NONNULL_END
