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
@property (nonatomic, weak) UIViewController *baseCer;
@property (nonatomic, strong) UIView *specificParentView;
@property (nonatomic) CGSize keyboardSize;
@property (nonatomic, assign) BOOL relayoutByKeyboard;
- (void)layoutSubviews;
- (void)startLoading;
- (void)stopLoading;
- (void)touched;
@end

NS_ASSUME_NONNULL_END

