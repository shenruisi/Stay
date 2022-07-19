//
//  NavigateCollectionController.m
//  FastClip-iOS
//
//  Created by ris on 2022/3/17.
//

#import "NavigateCollectionController.h"
#import "NavigateViewController.h"

#ifdef Mac
#import "FCToolbar.h"
#import "QuickAccess.h"
#endif
#import "FCStyle.h"
#import "FCConfig.h"
#import "SYEditViewController.h"

NSNotificationName const _Nonnull NCCDidShowViewControllerNotification = @"app.stay.notification.NCCDidShowViewControllerNotification";

const NSInteger kPadTrackFixed = 100;

typedef enum  {
    PanTrackDirectionUndefined = 0,
    PanTrackDirectionStart,
    PanTrackDirectionLeft,
    PanTrackDirectionLeftAnimate,
    PanTrackDirectionRight,
    PanTrackDirectionRightAnimate,
}PanTrackDirection;

@interface _ShadowBorder : UIView

@end

@implementation _ShadowBorder
@end

@interface NavigateCollectionController ()<
 UIGestureRecognizerDelegate
>

@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, strong) NSMutableArray *forwardViewControllers;
@property (nonatomic, strong) NavigateViewController *rootViewController;
@property (nonatomic, assign) CGPoint panTrackStartPoint;
@property (nonatomic, assign) PanTrackDirection panTrackDirection;
@property (nonatomic, strong) _ShadowBorder *shadowBorder;
@property (nonatomic, strong) NSObject *panLock;
@end

@implementation NavigateCollectionController

- (instancetype)initWithRootViewController:(NavigateViewController *)rootViewController{
    if (self = [super init]){
        self.rootViewController = rootViewController;
    }
    return self;
}


- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
//    HomeSlideViewController *cer = [self.splitViewController viewControllerForColumn:UISplitViewControllerColumnPrimary];
//    [cer layoutSubViews];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = FCStyle.background;
    [self gestureLoad];
    [self shadowBorder];
    self.navigationController.navigationBarHidden = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(displayModeDidChange:)
                                                     name:SVCDisplayModeDidChangeNotification
                                                   object:nil];
}

- (void)gestureLoad{
    UIPanGestureRecognizer *panRecoginzier = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(padTrackGesture:)];
    panRecoginzier.minimumNumberOfTouches = 2;
    panRecoginzier.maximumNumberOfTouches = 2;
    panRecoginzier.allowedScrollTypesMask = UIScrollTypeMaskContinuous;
    [self.view addGestureRecognizer:panRecoginzier];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"NavigateViewController view %@",self.view);
    NSLog(@"%@ %f",[QuickAccess splitController].view,[QuickAccess splitController].preferredPrimaryColumnWidth);
    self.view.bounds = CGRectMake(0,0,[QuickAccess splitController].view.frame.size.width - ([QuickAccess splitController].preferredPrimaryColumnWidth), [QuickAccess splitController].view.frame.size.height);
    [self pushViewController:self.rootViewController removeUUID:nil inViewDidLoad:YES isForward:NO];
    
}

- (void)pushViewController:(NavigateViewController *)viewController{
    [self pushViewController:viewController removeUUID:nil inViewDidLoad:NO isForward:NO];
}

- (void)pushViewController:(NavigateViewController *)viewController isForward:(BOOL)isForward{
    [self pushViewController:viewController removeUUID:nil inViewDidLoad:NO isForward:isForward];
}

- (void)pushViewController:(NavigateViewController *)viewController removeUUID:(nullable NSString *)tabUUID{
    [self pushViewController:viewController removeUUID:tabUUID inViewDidLoad:NO isForward:NO];
}

- (void)pushViewController:(NavigateViewController *)viewController
                removeUUID:(nullable NSString *)tabUUID
             inViewDidLoad:(BOOL)inViewDidLoad
                 isForward:(BOOL)isForward{
    if (self.topViewController == viewController) return;
    
    viewController.view.frame = self.view.bounds;
    [viewController navigateViewDidLoad];
    
    NavigateViewController *previousController = self.topViewController;
    
    [viewController navigateViewWillAppear:NO];
    [self.view addSubview:viewController.view];
    [viewController navigateViewDidAppear:NO];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NCCDidShowViewControllerNotification
                                                        object:viewController];
    
    
    [previousController navigateViewWillDisappear:NO];
    [previousController.view removeFromSuperview];
    [previousController navigateViewDidDisappear:NO];
    
//    if (tabUUID.length > 0){
//        for (NSInteger i = 0; i < self.viewControllers.count; i++) {
//            UIViewController *viewController = self.viewControllers[i];
//            if ([viewController isKindOfClass:[BaseSnippetListController class]]){
//                BaseSnippetListController *snippetController =  (BaseSnippetListController *)viewController;
//                if (snippetController.isRecent && [tabUUID isEqualToString:AllSnippetsUUID]){
//                    [self.viewControllers removeObjectAtIndex:i];
//                    i--;
//                }
//                else if ([tabUUID isEqualToString:snippetController.pinTab.uuid]){
//                    [self.viewControllers removeObjectAtIndex:i];
//                    i--;
//                }
//            }
//        }
//    }
//
    [self.viewControllers addObject:viewController];
    
//    if (tabUUID.length > 0){ //Merge pushed controller from end to start;
//        for (NSInteger i = self.viewControllers.count - 1; i > 0; i--){
//            UIViewController *viewController2 = self.viewControllers[i];
//            UIViewController *viewController1 = self.viewControllers[i-1];
//            if (viewController1 != viewController2) break;
//            [self.viewControllers removeObjectAtIndex:i];
//        }
//
//    }
    
    if (!isForward){
        [self.forwardViewControllers removeAllObjects];
    }
    
    
    [self freshBackForwadItem];
}

- (void)removeViewControllerWithUUID:(NSString *)tabUUID{
    for (NSInteger i = 0; i < self.viewControllers.count; i++) {
        UIViewController *viewController = self.viewControllers[i];
//        if ([viewController isKindOfClass:[BaseSnippetListController class]]){
//            BaseSnippetListController *snippetController =  (BaseSnippetListController *)viewController;
//            if (snippetController.pinTab == nil && [tabUUID isEqualToString:AllSnippetsUUID]){
//                [self.viewControllers removeObjectAtIndex:i];
//                i--;
//            }
//            else if ([tabUUID isEqualToString:snippetController.pinTab.uuid]){
//                [self.viewControllers removeObjectAtIndex:i];
//                i--;
//            }
//        }
    }
    
    for (NSInteger i = self.viewControllers.count - 1; i > 0; i--){
        UIViewController *viewController2 = self.viewControllers[i];
        UIViewController *viewController1 = self.viewControllers[i-1];
        if (viewController1 != viewController2) break;
        [self.viewControllers removeObjectAtIndex:i];
    }
    [self freshBackForwadItem];
}

- (void)popViewController{
    if (self.viewControllers.count == 1) return;
    
    NavigateViewController *previousController = self.viewControllers[self.viewControllers.count - 2];
    [previousController navigateViewWillAppear:NO];
    previousController.view.frame = CGRectMake(previousController.view.frame.origin.x,
                                               previousController.view.frame.origin.y,
                                               self.view.frame.size.width,
                                               self.view.frame.size.height);
    [self.view insertSubview:previousController.view belowSubview:self.topViewController.view];
    
    [self.topViewController navigateViewWillDisappear:NO];
//    if ([self.topViewController isKindOfClass:[BaseSnippetListController class]]){
//        [(BaseSnippetListController *)self.topViewController setSelectModeWithIsOn:NO];
//    }
    [self.topViewController.view removeFromSuperview];
    [self.topViewController navigateViewDidDisappear:NO];
    [previousController navigateViewDidAppear:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:NCCDidShowViewControllerNotification
                                                        object:previousController];
    [self popStateFresh];
}

- (void)popStateFresh{
    UIViewController *previousController = self.viewControllers[self.viewControllers.count - 2];

    [self.forwardViewControllers addObject:self.topViewController];
    [self.viewControllers removeLastObject];
    [self freshBackForwadItem];
}

- (void)forward{
    if (self.forwardViewControllers.count > 0){
        UIViewController *viewController = [self.forwardViewControllers lastObject];
        [self pushViewController:viewController isForward:YES];
        [self.forwardViewControllers removeLastObject];
    }
    [self freshBackForwadItem];
}

- (void)freshBackForwadItem{
    if (self.viewControllers.count > 1){
        [[QuickAccess splitController] enableToolbarItem:Toolbar_Back];
    }
    else{
        [[QuickAccess splitController] disableToolbarItem:Toolbar_Back];
    }
    
    if (self.forwardViewControllers.count > 0){
        [[QuickAccess splitController] enableToolbarItem:Toolbar_Forward];
    }
    else{
        [[QuickAccess splitController] disableToolbarItem:Toolbar_Forward];
    }
}


- (NSMutableArray *)viewControllers{
    if (nil == _viewControllers){
        _viewControllers = [[NSMutableArray alloc] init];
    }
    
    return _viewControllers;
}

- (NSMutableArray *)forwardViewControllers{
    if (nil == _forwardViewControllers){
        _forwardViewControllers = [[NSMutableArray alloc] init];
    }
    
    return _forwardViewControllers;
}

- (UIViewController *)topViewController{
    return self.viewControllers.lastObject;
}

- (FCToolbar *)toolbar{
//    return ((FCHandoffSplitViewController *)self.splitViewController).toolbar;
    return nil;
}


- (void)padTrackGesture:(UIPanGestureRecognizer *)recognizer{
    if (UIGestureRecognizerStateBegan == recognizer.state){
//        CGPoint point = [recognizer translationInView:self.view];
//        NSLog(@"padTrackGesture %@",NSStringFromPoint(point));
//        if (point.x < kPadTrackFixed || point.x > self.view.frame.size.width - kPadTrackFixed) return;
     
        if (self.panTrackDirection != PanTrackDirectionUndefined) return;
        self.panTrackStartPoint = [recognizer translationInView:self.view];
        self.panTrackDirection = PanTrackDirectionStart;
//        NSLog(@"UIGestureRecognizerStateBegan");
    }
    else if (UIGestureRecognizerStateChanged == recognizer.state){
//        NSLog(@"UIGestureRecognizerStateChanged");
        CGPoint changedPoint = [recognizer translationInView:self.view];
        if (self.panTrackDirection == PanTrackDirectionStart){
            if (changedPoint.x - self.panTrackStartPoint.x > 0 && self.viewControllers.count > 1){
                self.panTrackDirection = PanTrackDirectionLeft;
            }
            else if (changedPoint.x - self.panTrackStartPoint.x < 0 && self.forwardViewControllers.count > 0){
                self.panTrackDirection = PanTrackDirectionRight;
            }
        }
        else{
            if (self.panTrackDirection == PanTrackDirectionLeft){
                UIViewController *previousController = self.viewControllers[self.viewControllers.count - 2];
                previousController.view.frame = CGRectMake(previousController.view.frame.origin.x,
                                                           previousController.view.frame.origin.y,
                                                           self.view.frame.size.width,
                                                           self.view.frame.size.height);
                [self.view insertSubview:previousController.view belowSubview:self.topViewController.view];
                if (self.shadowBorder.hidden){
                    [self.view bringSubviewToFront:self.shadowBorder];
                }
                self.shadowBorder.hidden = NO;
                UIView *targetView = self.topViewController.view;
                [targetView setFrame:CGRectMake(MAX(0, (changedPoint.x - self.panTrackStartPoint.x)),  targetView.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
                [self.shadowBorder setFrame:CGRectMake(MAX(-1,targetView.frame.origin.x-1),
                                                       self.shadowBorder.frame.origin.y,
                                                       self.shadowBorder.frame.size.width,
                                                       self.view.frame.size.height)];
            }
            else if (self.panTrackDirection == PanTrackDirectionRight){
                if (self.shadowBorder.hidden){
                    [self.view bringSubviewToFront:self.shadowBorder];
                }
                self.shadowBorder.hidden = NO;
                UIViewController *pushController = self.forwardViewControllers.lastObject;
                [pushController.view setFrame:CGRectMake(self.view.frame.size.width,
                                                         pushController.view.frame.origin.y,
                                                         self.view.frame.size.width,
                                                         self.view.frame.size.height)];
                [self.view addSubview:pushController.view];
                
                UIView *targetView = pushController.view;
                [targetView setFrame:CGRectMake(targetView.frame.size.width + (changedPoint.x - self.panTrackStartPoint.x), targetView.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
                [self.shadowBorder setFrame:CGRectMake(targetView.frame.origin.x-1,
                                                       self.shadowBorder.frame.origin.y,
                                                       self.shadowBorder.frame.size.width,
                                                       self.view.frame.size.height)];
            }
        }
        
    }
    else if (UIGestureRecognizerStateEnded == recognizer.state
             || UIGestureRecognizerStateCancelled == recognizer.state){
//        NSLog(@"UIGestureRecognizerStateEnded");
        CGPoint endPoint = [recognizer translationInView:self.view];
        if (self.panTrackDirection == PanTrackDirectionLeft){
            self.panTrackDirection = PanTrackDirectionLeftAnimate;
            if (endPoint.x - self.panTrackStartPoint.x <= self.view.frame.size.width / 5){
                //Cancel pop
                [UIView animateWithDuration:0.3 delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                    UIView *targetView = self.topViewController.view;
                    [targetView setFrame:CGRectMake(0, targetView.frame.origin.y, targetView.frame.size.width, targetView.frame.size.height)];
                    [self.shadowBorder setFrame:CGRectMake(-1,
                                                           self.shadowBorder.frame.origin.y,
                                                           self.shadowBorder.frame.size.width,
                                                           self.shadowBorder.frame.size.height)];
                } completion:^(BOOL finished) {
                    UIViewController *previousController = self.viewControllers[self.viewControllers.count - 2];
                    [previousController.view removeFromSuperview];
                    self.shadowBorder.hidden = YES;
                    self.panTrackStartPoint = CGPointZero;
                    self.panTrackDirection = PanTrackDirectionUndefined;
                    NSLog(@"UIGestureRecognizerStateEnded 1");
                }];
            }
            else{
                UIViewController *previousController = self.viewControllers[self.viewControllers.count - 2];
                [UIView animateWithDuration:0.3 delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                    [previousController viewWillAppear:YES];
                    [self.topViewController viewWillDisappear:YES];
                    UIView *targetView = self.topViewController.view;
                    [targetView setFrame:CGRectMake(targetView.frame.size.width, targetView.frame.origin.y, targetView.frame.size.width, targetView.frame.size.height)];
                    [self.shadowBorder setFrame:CGRectMake(targetView.frame.origin.x-1,
                                                           self.shadowBorder.frame.origin.y,
                                                           self.shadowBorder.frame.size.width,
                                                           self.shadowBorder.frame.size.height)];
                } completion:^(BOOL finished) {
                    [previousController viewDidAppear:YES];
                    
                    
                    [self.topViewController viewDidDisappear:YES];
                    [self.topViewController.view removeFromSuperview];
                    CGRect rect = self.topViewController.view.frame;
                    rect.origin.x = 0;
                    [self.topViewController.view setFrame:rect];
                    [self popStateFresh];
                    self.shadowBorder.hidden = YES;
                    self.panTrackStartPoint = CGPointZero;
                    self.panTrackDirection = PanTrackDirectionUndefined;
                    NSLog(@"UIGestureRecognizerStateEnded 2");
                    [[NSNotificationCenter defaultCenter] postNotificationName:NCCDidShowViewControllerNotification
                                                                        object:self.topViewController];
                }];
            }
        }
        else if (self.panTrackDirection == PanTrackDirectionRight){
            self.panTrackDirection = PanTrackDirectionRightAnimate;
            if (self.panTrackStartPoint.x - endPoint.x <= self.view.frame.size.width / 5){
                //Cancel push
                [UIView animateWithDuration:0.3 delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                    UIView *targetView = ((UIViewController *)self.forwardViewControllers.lastObject).view;
                    [targetView setFrame:CGRectMake(targetView.frame.size.width, targetView.frame.origin.y, targetView.frame.size.width, targetView.frame.size.height)];
                    [self.shadowBorder setFrame:CGRectMake(targetView.frame.origin.x-1,
                                                           self.shadowBorder.frame.origin.y,
                                                           self.shadowBorder.frame.size.width,
                                                           self.shadowBorder.frame.size.height)];
                } completion:^(BOOL finished) {
                    UIView *targetView = ((UIViewController *)self.forwardViewControllers.lastObject).view;
                    [targetView removeFromSuperview];
                    CGRect rect =  targetView.frame;
                    [targetView setFrame:rect];
                    self.shadowBorder.hidden = YES;
                    self.panTrackStartPoint = CGPointZero;
                    self.panTrackDirection = PanTrackDirectionUndefined;
                    NSLog(@"UIGestureRecognizerStateEnded 3");
                }];
            }
            else{
                UIViewController *pushController = self.forwardViewControllers.lastObject;
                [UIView animateWithDuration:0.3 delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                    [pushController viewWillAppear:YES];
                    [self.topViewController viewWillDisappear:YES];
                    UIView *targetView = pushController.view;
                    [targetView setFrame:CGRectMake(0, targetView.frame.origin.y, targetView.frame.size.width, targetView.frame.size.height)];
                    [self.shadowBorder setFrame:CGRectMake(-1,
                                                           self.shadowBorder.frame.origin.y,
                                                           self.shadowBorder.frame.size.width,
                                                           self.shadowBorder.frame.size.height)];
                } completion:^(BOOL finished) {
                    [pushController viewDidAppear:YES];
                    [self.topViewController viewDidDisappear:YES];
                    
                    
                    [self.topViewController.view removeFromSuperview];
                    
                    [self.viewControllers addObject:pushController];
                    [self.forwardViewControllers removeLastObject];
                    [self freshBackForwadItem];
                    self.shadowBorder.hidden = YES;
                    self.panTrackStartPoint = CGPointZero;
                    self.panTrackDirection = PanTrackDirectionUndefined;
                    NSLog(@"UIGestureRecognizerStateEnded 4");
                    [[NSNotificationCenter defaultCenter] postNotificationName:NCCDidShowViewControllerNotification
                                                                        object:pushController];
                }];
            }
        }
        
       
        
    }
    
}

- (void)displayModeDidChange:(NSNotification *)note{}

//- (void)displayModeDidChange:(NSNotification *)note{
//    NSString *operate = note.userInfo[@"operate"];
//    NSInteger preferredWidth = [[FCConfig shared] getIntegerValueOfKey:GroupUserDefaultsKeyMacPrimaryWidth];
//    if ([operate isEqualToString:@"hide"]){
//        NSLog(@"NavigateViewController %f",[QuickAccess homeViewController].view.frame.size.width);
//        self.view.frame = CGRectMake(0,0,[QuickAccess splitController].view.frame.size.width, [QuickAccess splitController].view.frame.size.height);
//        self.topViewController.view.bounds = self.view.bounds;
//        [self.topViewController relayout];
//    }
//    else if ([operate isEqualToString:@"show"]){
//        NSLog(@"NavigateViewController %f",[QuickAccess homeViewController].view.frame.size.width);
//        self.view.frame = CGRectMake(preferredWidth,0,[QuickAccess splitController].view.frame.size.width -preferredWidth, [QuickAccess splitController].view.frame.size.height);
//        self.topViewController.view.bounds = self.view.bounds;
//        [self.topViewController relayout];
//    }
//}

- (NSObject *)panLock{
    if (nil == _panLock){
        _panLock = [[NSObject alloc] init];
    }
    
    return _panLock;
}

- (_ShadowBorder *)shadowBorder{
    if (nil == _shadowBorder){
        _shadowBorder = [[_ShadowBorder alloc] initWithFrame:CGRectMake(1, 50, 1, self.view.frame.size.height - 50)];
        _shadowBorder.backgroundColor = FCStyle.fcSeparator;
        _shadowBorder.layer.shadowOpacity = 0.8;
        _shadowBorder.layer.shadowOffset = CGSizeMake(-1, 0);
        _shadowBorder.layer.shadowRadius = 1;
        _shadowBorder.layer.shadowColor = FCStyle.fcShadowLine.CGColor;
        _shadowBorder.layer.shadowPath = [UIBezierPath bezierPathWithRect:_shadowBorder.bounds].CGPath;
        _shadowBorder.layer.shouldRasterize = YES;
        _shadowBorder.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [self.view addSubview:_shadowBorder];
        _shadowBorder.hidden = YES;
    }
    
    return _shadowBorder;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    self.shadowBorder.layer.shadowColor = FCStyle.fcShadowLine.CGColor;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:SVCDisplayModeDidChangeNotification
                                                      object:nil];
}

@end
