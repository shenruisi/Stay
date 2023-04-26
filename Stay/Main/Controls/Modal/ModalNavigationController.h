//
//  ModalNavigationController.h
//  FastClip-iOS
//
//  Created by ris on 2022/2/7.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FCSlideController.h"
NS_ASSUME_NONNULL_BEGIN

typedef enum {
    ModalContentModeBottom,
    ModalContentModeLeft
}ModalContentMode;


@class ModalViewController,FCRoundedShadowView;
@interface ModalNavigationController : NSObject{
}

@property (nonatomic, strong) ModalViewController *rootModalViewController;
@property (readonly) NSMutableArray *controllers;
@property (readonly) FCRoundedShadowView *view;
@property (nonatomic, weak) FCSlideController *slideController;
@property (nonatomic, assign) ModalContentMode contentMode;

- (instancetype)initWithRootModalViewController:(ModalViewController *)modalViewController;
- (instancetype)initWithRootModalViewController:(ModalViewController *)modalViewController
                                slideController:(FCSlideController *)slideController;
- (instancetype)initWithRootModalViewController:(ModalViewController *)modalViewController radius:(CGFloat)radius;
- (instancetype)initWithRootModalViewControllerAndNoRoundShadow:(ModalViewController *)modalViewController;

- (instancetype)initWithRootModalViewController:(ModalViewController *)modalViewController
                                slideController:(FCSlideController *)slideController
                                         radius:(CGFloat)radius
                                     boderWidth:(CGFloat)borderWidth
                                    contentMode:(ModalContentMode)contentMode
                                  noShadowRound:(BOOL)noShadowRound
                                     cornerMask:(CACornerMask)cornerMask;

- (void)pushModalViewController:(ModalViewController *)modalViewController;
- (void)popModalViewController;
- (void)popModalViewControllerWithCompletion:(nullable void(^)(void))completionHandler;
- (void)popToRootController;
- (void)popToRootControllerWithDismiss;


@end

NS_ASSUME_NONNULL_END
