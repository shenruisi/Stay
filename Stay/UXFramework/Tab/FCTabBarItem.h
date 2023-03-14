//
//  FCTabBarItem.h
//  Stay
//
//  Created by ris on 2023/3/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FCTabBarItem : UIView

+ (instancetype)ofDescriptor:(NSDictionary *)descriptor;

@property (nonatomic, readonly) UIImage *selectImage;
@property (nonatomic, readonly) UIImage *deselectImage;
@property (nonatomic, readonly) CGFloat offsetY;
@end

NS_ASSUME_NONNULL_END
