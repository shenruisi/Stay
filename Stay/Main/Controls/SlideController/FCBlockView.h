//
//  FCBlockView.h
//  FastClip-iOS
//
//  Created by ris on 2022/2/8.
//

#import "FCView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FCBlockViewDelegate <NSObject>

- (void)touched;

@end

@interface FCBlockView : FCView

@property (nonatomic, assign) id<FCBlockViewDelegate> delegate;

- (instancetype)initWithAlpha:(CGFloat)alpha;
@end

NS_ASSUME_NONNULL_END
