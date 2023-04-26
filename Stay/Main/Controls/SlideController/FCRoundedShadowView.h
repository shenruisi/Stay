//
//  FCRoundedShadowView.h
//  FastClip-iOS
//
//  Created by ris on 2022/2/9.
//

#import "FCView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FCRoundedShadowView : FCView

@property (readonly) FCView *containerView;


- (instancetype)initWithRadius:(CGFloat)radius;

- (instancetype)initWithNoShadowRadius:(CGFloat)radius
                            borderWith:(CGFloat)borderWith
                            cornerMask:(CACornerMask)cornerMask;
- (instancetype)initWithRadius:(CGFloat)radius
                    borderWith:(CGFloat)borderWith
                    cornerMask:(CACornerMask)cornerMask;
@end

NS_ASSUME_NONNULL_END
