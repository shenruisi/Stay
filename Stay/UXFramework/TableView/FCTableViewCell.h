//
//  FCTableViewCell.h
//  Stay
//
//  Created by ris on 2023/3/23.
//

#import <UIKit/UIKit.h>
#import "FCRoundedShadowView2.h"
NS_ASSUME_NONNULL_BEGIN

@interface FCTableViewCell<ElementType> : UITableViewCell

@property (nonatomic, readonly) FCRoundedShadowView2 *fcContentView;
@property (nonatomic, strong) ElementType element;
@property (nonatomic, copy) void (^tapAction)(id);
@property (nonatomic, copy) void (^doubleTapAction)(id);
@property (nonatomic, assign) BOOL active;
@property (nonatomic, weak) UIViewController *cer;
+ (NSString *)identifier;
+ (UIEdgeInsets)contentInset;
- (void)buildWithElement:(ElementType)element;
- (void)tap:(CGPoint)location;
- (void)doubleTap:(CGPoint)location;
@end

NS_ASSUME_NONNULL_END
