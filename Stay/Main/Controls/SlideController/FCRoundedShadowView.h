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
@end

NS_ASSUME_NONNULL_END
