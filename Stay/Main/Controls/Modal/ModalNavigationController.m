//
//  ModalNavigationController.m
//  FastClip-iOS
//
//  Created by ris on 2022/2/7.
//

#import "ModalNavigationController.h"
#import "ModalViewController.h"
#import "FCRoundedShadowView.h"
#import "FCApp.h"

@interface ModalNavigationController(){
    ModalViewController *_currentModalViewController;
    NSMutableArray<ModalViewController *> *_controllers;
}

@property (nonatomic, strong) ModalViewController *currentModalViewController;
@property (nonatomic, strong) NSMutableArray<ModalViewController *> *controllers;
@property (nonatomic, strong) FCRoundedShadowView *view;
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) CACornerMask cornerMask;
@property (nonatomic, assign) BOOL noRoundShadow;
@end

@implementation ModalNavigationController

- (instancetype)initWithRootModalViewController:(ModalViewController *)modalViewController radius:(CGFloat)radius{
    if (self = [super init]){
        self.cornerMask = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
        self.radius = radius;
        [self view];
        self.rootModalViewController = modalViewController;
        modalViewController.navigationController = self;
        modalViewController.isRoot = YES;
        [self pushModalViewController:modalViewController];
    }
    
    return self;
}

- (instancetype)initWithRootModalViewController:(ModalViewController *)modalViewController{
    if (self = [super init]){
        self.cornerMask = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
        [self view];
        self.rootModalViewController = modalViewController;
        modalViewController.navigationController = self;
        modalViewController.isRoot = YES;
        [self pushModalViewController:modalViewController];
    }
    
    return self;
}

- (instancetype)initWithRootModalViewController:(ModalViewController *)modalViewController
                                slideController:(FCSlideController *)slideController{
    if (self = [super init]){
        self.cornerMask = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
        [self view];
        self.rootModalViewController = modalViewController;
        modalViewController.navigationController = self;
        modalViewController.isRoot = YES;
        self.slideController = slideController;
        [self pushModalViewController:modalViewController];
    }
    
    return self;
}

- (instancetype)initWithRootModalViewControllerAndNoRoundShadow:(ModalViewController *)modalViewController{
    if (self = [super init]){
        self.cornerMask = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
        self.noRoundShadow = YES;
        [self view];
        self.rootModalViewController = modalViewController;
        modalViewController.navigationController = self;
        modalViewController.isRoot = YES;
        [self pushModalViewController:modalViewController];
    }
    
    return self;
}

- (instancetype)initWithRootModalViewController:(ModalViewController *)modalViewController
                                slideController:(FCSlideController *)slideController
                                         radius:(CGFloat)radius
                                     boderWidth:(CGFloat)borderWidth
                                    contentMode:(ModalContentMode)contentMode
                                  noShadowRound:(BOOL)noShadowRound
                                     cornerMask:(CACornerMask)cornerMask{
    if (self = [super init]){
        self.contentMode = contentMode;
        self.radius = radius;
        self.borderWidth = borderWidth;
        self.noRoundShadow = noShadowRound;
        self.cornerMask = cornerMask;
        [self view];
        self.rootModalViewController = modalViewController;
        modalViewController.navigationController = self;
        modalViewController.isRoot = YES;
        self.slideController = slideController;
        [self pushModalViewController:modalViewController];
    }
    
    return self;
}

- (void)pushModalViewController:(ModalViewController *)modalViewController{
    modalViewController.navigationController = self;
    [modalViewController willSee];
    [modalViewController viewDidLoad];
    
    [modalViewController viewWillAppear];
    [self.currentModalViewController viewWillDisappear];
    [self.controllers addObject:modalViewController];
    
    [self _pushView:[modalViewController getMainView]];
    
}

- (void)popModalViewControllerWithCompletion:(nullable void(^)(void))completionHandler{
    [self.currentModalViewController viewWillDisappear];
    ModalViewController *willSeeController = [_controllers objectAtIndex:_controllers.count -  2];
    [willSeeController willSee];
    [self _popView:[willSeeController getMainView] toRoot:NO completion:completionHandler];
    [willSeeController viewWillAppear];
}

- (void)popModalViewController{
    [self popModalViewControllerWithCompletion:nil];
}

- (void)popToRootControllerWithDismiss{
    if (self.currentModalViewController.isRoot){
        [self.currentModalViewController viewWillDisappear];
        [self.currentModalViewController viewDidDisappear];
        return;
    }
    [self.currentModalViewController viewWillDisappear];
    
    [self _popView:[[_controllers firstObject] getMainView] toRoot:YES completion:nil];
    [[self.controllers firstObject] viewWillAppear];
}

- (void)popToRootController{
    if (self.currentModalViewController.isRoot){
        return;
    }
    [self.currentModalViewController viewWillDisappear];
    
    [self _popView:[[_controllers firstObject] getMainView] toRoot:YES completion:nil];
    [[self.controllers firstObject] viewWillAppear];
}

- (void)_pushView:(UIView *)pushedView{
    if (nil == self.currentModalViewController){
        [self.view.containerView addSubview:pushedView];
        [self.view setFrame:CGRectMake(0, 0, pushedView.frame.size.width, pushedView.frame.size.height)];
        [[self.controllers lastObject] viewDidAppear];
        self.currentModalViewController = [self.controllers lastObject];
    }
    else{
        [self.view.containerView addSubview:pushedView];
        [self.currentModalViewController getMainView].hidden = YES;
        CGRect oldFrame = self.view.frame;
        CGSize newSize = pushedView.frame.size;
        pushedView.transform = CGAffineTransformMakeScale(0.9, 0.9);
        
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
            pushedView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
            if (self.contentMode == ModalContentModeBottom){
                CGPoint newOrigin = CGPointMake(oldFrame.origin.x - (newSize.width - oldFrame.size.width), oldFrame.origin.y - (newSize.height - oldFrame.size.height));
                [self.view setFrame:CGRectMake(newOrigin.x, newOrigin.y, pushedView.frame.size.width, pushedView.frame.size.height)];
            }
            else if (self.contentMode == ModalContentModeLeft){
                CGPoint newOrigin = CGPointMake(oldFrame.origin.x, oldFrame.origin.y - (newSize.height - oldFrame.size.height));
                [self.view setFrame:CGRectMake(newOrigin.x, newOrigin.y, pushedView.frame.size.width, pushedView.frame.size.height)];
            }
        }
                         completion:^(BOOL finished) {
                [self.currentModalViewController viewDidDisappear];
                [[self.currentModalViewController getMainView] removeFromSuperview];
                [self.currentModalViewController getMainView].hidden = NO;
                [[self.controllers lastObject] viewDidAppear];
                self.currentModalViewController = [self.controllers lastObject];
        }];
    }
    
}

- (void)_popView:(UIView *)incomingView toRoot:(BOOL)toRoot completion:(void(^)(void))completionHandler{
    [self.view.containerView insertSubview:incomingView belowSubview:[self.currentModalViewController getMainView]];
    
    CGRect oldFrame = self.view.frame;
    CGSize newSize = incomingView.frame.size;
    incomingView.transform = CGAffineTransformMakeScale(1.1, 1.1);
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        incomingView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
        [[self.currentModalViewController getMainView] removeFromSuperview];
        CGPoint newOrigin = CGPointMake(oldFrame.origin.x - (newSize.width - oldFrame.size.width), (self.view.frame.origin.y - oldFrame.origin.y)+oldFrame.origin.y - (newSize.height - oldFrame.size.height));
        [self.view setFrame:CGRectMake(newOrigin.x, newOrigin.y, newSize.width, newSize.height)];
    } completion:^(BOOL finished) {
        [self.currentModalViewController viewDidDisappear];
        [self.currentModalViewController getMainView].transform = CGAffineTransformIdentity;
        
        if (completionHandler){
            completionHandler();
        }
        
        [self.controllers removeLastObject];
        if (toRoot){
            for (int i = 1; i < self.controllers.count; i++){
                [[[self.controllers objectAtIndex:i] getMainView] removeFromSuperview];
            }
            [self.controllers removeObjectsInRange:NSMakeRange(1, self.controllers.count-1)];
        }
        [[self.controllers lastObject] viewDidAppear];
        self.currentModalViewController = [self.controllers lastObject];
    }];
}


- (FCRoundedShadowView *)view{
    if (nil == _view){
        if (self.noRoundShadow){
            _view = [[FCRoundedShadowView alloc] initWithNoShadowRadius:self.radius
                                                             borderWith:self.borderWidth
                                                             cornerMask:self.cornerMask];
        }
        else{
            _view = [[FCRoundedShadowView alloc] initWithRadius:self.radius
                                                     borderWith:self.borderWidth
                                                     cornerMask:self.cornerMask];
        }
        
    }
    
    return _view;
}


- (NSMutableArray *)controllers{
    if (nil == _controllers){
        _controllers = [[NSMutableArray alloc] init];
    }
    
    return _controllers;
}

@end
