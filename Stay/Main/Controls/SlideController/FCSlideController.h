//
//  FCSlideController.h
//  FastClip-iOS
//
//  Created by ris on 2022/2/7.
//

#import "FCView.h"

#import "FCPresenting.h"
#import "FCBlockView.h"
#import "FCRoundedShadowView.h"

NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const _Nonnull FCSlideControllerDidDismissNotification;

@interface FCSlideController : NSObject<FCPresenting>

@property (nonatomic, strong) FCBlockView *blockView;
@property (nonatomic, weak) FCRoundedShadowView *navView;
- (void)layoutSubviews;
@end

NS_ASSUME_NONNULL_END

