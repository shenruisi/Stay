//
//  FCRoundedShadowView2.h
//  Stay
//
//  Created by ris on 2023/3/23.
//

#import "FCView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FCRoundedShadowView2 : FCView

- (instancetype)initWithRadius:(CGFloat)radius
                    borderWith:(CGFloat)borderWith
                    cornerMask:(CACornerMask)cornerMask;
@property (nonatomic, strong) FCView *containerView;
@end

NS_ASSUME_NONNULL_END
