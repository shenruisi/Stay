//
//  FCPresenting.h
//  FastClip-iOS
//
//  Created by ris on 2022/2/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class ModalNavigationController;
typedef enum {
    FCPresentingFromBottom,
    FCPresentingFromTop,
}FCPresentingFrom;

@protocol  FCPresenting<NSObject>

- (void)show;
- (void)showWithParams:(NSArray *)params;
- (void)dismiss;
- (BOOL)isShown;
- (FCPresentingFrom)from;
- (CGFloat)marginToFrom;
- (CGFloat)keyboardMargin;
- (BOOL)blockAction;
- (ModalNavigationController *)modalNavigationController;
- (BOOL)disableRoundShadow;
- (BOOL)preventShortcuts;
- (BOOL)dismissable;
- (CGFloat)maxHeight;
@end

NS_ASSUME_NONNULL_END
