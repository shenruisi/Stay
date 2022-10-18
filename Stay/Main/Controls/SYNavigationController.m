//
//  SYNavigationController.m
//  Stay
//
//  Created by ris on 2022/10/9.
//

#import "SYNavigationController.h"

#import "ImageHelper.h"
#import "FCStyle.h"
#import "SYDetailViewController.h"
#import "SYNoDownLoadDetailViewController.h"
#import "QuickAccess.h"

@interface PlaceholderController : UIViewController
@property (nonatomic, strong) UIView *line;
@end
 
@implementation PlaceholderController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = FCStyle.background;
    self.navigationController.navigationBar.tintColor = FCStyle.fcMacIcon;
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.line.hidden = self.navigationController.navigationBarHidden;
    [self.line setFrame:CGRectMake(0, 20 + 49, self.view.frame.size.width, 1)];
}

- (UIView *)line{
    if (nil == _line){
        _line = [[UIView alloc] init];
        _line.backgroundColor = FCStyle.fcNavigationLineColor;
        [self.view addSubview:_line];
    }
    
    return _line;
}

@end

typedef enum  {
    PanTrackDirectionUndefined = 0,
    PanTrackDirectionStart,
    PanTrackDirectionLeft,
    PanTrackDirectionLeftAnimate,
    PanTrackDirectionRight,
    PanTrackDirectionRightAnimate,
}PanTrackDirection;



@interface SYNavigationController ()<
 UIGestureRecognizerDelegate
>

@property (nonatomic, strong) NSMutableDictionary<NSString *,SYDetailViewController *> *detailViewControllerDic;
@property (nonatomic, strong) NSMutableArray *stViewControllers;
@property (nonatomic, strong) UIViewController *stTopViewController;
@property (nonatomic, strong) NSMutableArray *forwardViewControllers;
@property (nonatomic, strong) PlaceholderController *placeholderController;
@property (nonatomic, strong) UIViewController *stRootViewController;

@property (nonatomic, strong) UIBarButtonItem *sideItem;
@property (nonatomic, strong) UIBarButtonItem *backItem;
@property (nonatomic, strong) UIBarButtonItem *forwardItem;
@property (nonatomic, assign) CGPoint panTrackStartPoint;
@property (nonatomic, assign) PanTrackDirection panTrackDirection;
@property (nonatomic, strong) UIView *shadowBorder;
@end

@implementation SYNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    UINavigationItem *navigationItem = self.placeholderController.navigationItem;
    navigationItem.leftBarButtonItems = @[self.sideItem,self.backItem,self.forwardItem];
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController{
    if (self = [super initWithRootViewController:self.placeholderController]){
        self.stRootViewController = rootViewController;
        [self gestureLoad];
        [self shadowBorder];
        [self pushViewController:self.stRootViewController];
    }
    
    return self;
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.placeholderController.view.frame = self.view.frame;
    [self.stTopViewController viewWillLayoutSubviews];
}

- (void)pushViewController:(UIViewController *)viewController{
    [self pushViewController:viewController removeUUID:nil inViewDidLoad:NO isForward:NO];
}

- (void)pushViewController:(UIViewController *)viewController isForward:(BOOL)isForward{
    [self pushViewController:viewController removeUUID:nil inViewDidLoad:NO isForward:isForward];
}

- (void)pushViewController:(UIViewController *)viewController removeUUID:(nullable NSString *)tabUUID{
    [self pushViewController:viewController removeUUID:tabUUID inViewDidLoad:NO isForward:NO];
}

- (void)pushViewController:(UIViewController *)viewController
                removeUUID:(nullable NSString *)tabUUID
             inViewDidLoad:(BOOL)inViewDidLoad
                 isForward:(BOOL)isForward{
    if (self.stTopViewController == viewController){
        return;
    }
    
    if ([viewController isKindOfClass:[SYSecondaryViewController class]]){
        ((SYSecondaryViewController *)viewController).stNavigationController = self.placeholderController.navigationController;
    }
    
    CGFloat top = self.placeholderController.navigationController.navigationBarHidden ?
    0 : 50 + 20;
    
    viewController.view.frame = CGRectMake(0, top, self.placeholderController.view.frame.size.width, self.placeholderController.view.frame.size.height - top);
    
    
    
    UIViewController *previousController = self.stTopViewController;
    
    [viewController viewWillAppear:NO];
    
    if ([viewController isKindOfClass:[SYSecondaryViewController class]]){
        self.placeholderController.navigationItem.rightBarButtonItems =  ((SYSecondaryViewController *)viewController).rightBarButtonItems;
    }
    
    [self.placeholderController.view addSubview:viewController.view];
    
    [viewController viewDidAppear:NO];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"app.stay.notification.NCCDidShowViewControllerNotification"
                                                        object:viewController];
    
    
    [previousController viewWillDisappear:NO];
    [previousController.view removeFromSuperview];
    [previousController viewDidDisappear:NO];
    
    [self.stViewControllers addObject:viewController];
    
    if (!isForward){
        [self.forwardViewControllers removeAllObjects];
    }
    
    [self freshBackForwadItem];
}

- (void)popViewController{
    if (self.stViewControllers.count <= 1){
        return;
    }
    UIViewController *previousController = self.stViewControllers[self.stViewControllers.count - 2];
    if ([previousController isKindOfClass:[SYSecondaryViewController class]]){
        self.placeholderController.navigationItem.rightBarButtonItems =  ((SYSecondaryViewController *)previousController).rightBarButtonItems;
    }
    [previousController viewWillAppear:NO];
    [self.placeholderController.view insertSubview:previousController.view belowSubview:self.stTopViewController.view];
    [self.stTopViewController viewWillDisappear:NO];
    [self.stTopViewController.view removeFromSuperview];
    [self.stTopViewController viewDidDisappear:NO];
    [previousController viewDidAppear:NO];
    [self popStateFresh];
}


- (void)gestureLoad{
    UIPanGestureRecognizer *panRecoginzier = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(padTrackGesture:)];
    panRecoginzier.minimumNumberOfTouches = 2;
    panRecoginzier.maximumNumberOfTouches = 2;
    panRecoginzier.allowedScrollTypesMask = UIScrollTypeMaskContinuous;
    [self.view addGestureRecognizer:panRecoginzier];
}

- (void)padTrackGesture:(UIPanGestureRecognizer *)recognizer{
    if (UIGestureRecognizerStateBegan == recognizer.state){
        if (self.panTrackDirection != PanTrackDirectionUndefined) return;
        self.panTrackStartPoint = [recognizer translationInView:self.placeholderController.view];
        self.panTrackDirection = PanTrackDirectionStart;
    }
    else if (UIGestureRecognizerStateChanged == recognizer.state){
        CGPoint changedPoint = [recognizer translationInView:self.placeholderController.view];
        if (self.panTrackDirection == PanTrackDirectionStart){
            if (changedPoint.x - self.panTrackStartPoint.x > 0 && self.stViewControllers.count > 1){
                self.panTrackDirection = PanTrackDirectionLeft;
            }
            else if (changedPoint.x - self.panTrackStartPoint.x < 0 && self.forwardViewControllers.count > 0){
                self.panTrackDirection = PanTrackDirectionRight;
            }
        }
        else{
            if (self.panTrackDirection == PanTrackDirectionLeft){
                UIViewController *previousController = self.stViewControllers[self.stViewControllers.count - 2];
                previousController.view.frame = CGRectMake(previousController.view.frame.origin.x,
                                                           previousController.view.frame.origin.y,
                                                           self.placeholderController.view.frame.size.width,
                                                           self.placeholderController.view.frame.size.height);
                [self.placeholderController.view insertSubview:previousController.view belowSubview:self.stTopViewController.view];
                if (self.shadowBorder.hidden){
                    [self.placeholderController.view bringSubviewToFront:self.shadowBorder];
                }
                self.shadowBorder.hidden = NO;
                UIView *targetView = self.stTopViewController.view;
                [targetView setFrame:CGRectMake(MAX(0, (changedPoint.x - self.panTrackStartPoint.x)),  targetView.frame.origin.y, self.placeholderController.view.frame.size.width, self.placeholderController.view.frame.size.height)];
                [self.shadowBorder setFrame:CGRectMake(MAX(-1,targetView.frame.origin.x-1),
                                                       self.shadowBorder.frame.origin.y,
                                                       self.shadowBorder.frame.size.width,
                                                       self.placeholderController.view.frame.size.height)];
            }
            else if (self.panTrackDirection == PanTrackDirectionRight){
                if (self.shadowBorder.hidden){
                    [self.placeholderController.view bringSubviewToFront:self.shadowBorder];
                }
                self.shadowBorder.hidden = NO;
                UIViewController *pushController = self.forwardViewControllers.lastObject;
                [pushController.view setFrame:CGRectMake(self.placeholderController.view.frame.size.width,
                                                         pushController.view.frame.origin.y,
                                                         self.placeholderController.view.frame.size.width,
                                                         self.placeholderController.view.frame.size.height)];
                [self.placeholderController.view addSubview:pushController.view];
                
                UIView *targetView = pushController.view;
                [targetView setFrame:CGRectMake(targetView.frame.size.width + (changedPoint.x - self.panTrackStartPoint.x), targetView.frame.origin.y, self.placeholderController.view.frame.size.width, self.placeholderController.view.frame.size.height)];
                [self.shadowBorder setFrame:CGRectMake(targetView.frame.origin.x-1,
                                                       self.shadowBorder.frame.origin.y,
                                                       self.shadowBorder.frame.size.width,
                                                       self.placeholderController.view.frame.size.height)];
            }
        }
        
    }
    else if (UIGestureRecognizerStateEnded == recognizer.state
             || UIGestureRecognizerStateCancelled == recognizer.state){
        CGPoint endPoint = [recognizer translationInView:self.placeholderController.view];
        if (self.panTrackDirection == PanTrackDirectionLeft){
            self.panTrackDirection = PanTrackDirectionLeftAnimate;
            if (endPoint.x - self.panTrackStartPoint.x <= self.placeholderController.view.frame.size.width / 5){
                //Cancel pop
                [UIView animateWithDuration:0.3 delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                    UIView *targetView = self.stTopViewController.view;
                    [targetView setFrame:CGRectMake(0, targetView.frame.origin.y, targetView.frame.size.width, targetView.frame.size.height)];
                    [self.shadowBorder setFrame:CGRectMake(-1,
                                                           self.shadowBorder.frame.origin.y,
                                                           self.shadowBorder.frame.size.width,
                                                           self.shadowBorder.frame.size.height)];
                } completion:^(BOOL finished) {
                    UIViewController *previousController = self.stViewControllers[self.stViewControllers.count - 2];
                    [previousController.view removeFromSuperview];
                    self.shadowBorder.hidden = YES;
                    self.panTrackStartPoint = CGPointZero;
                    self.panTrackDirection = PanTrackDirectionUndefined;
                }];
            }
            else{
                UIViewController *previousController = self.stViewControllers[self.stViewControllers.count - 2];
                [UIView animateWithDuration:0.3 delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                    [previousController viewWillAppear:YES];
                    [self.stTopViewController viewWillDisappear:YES];
                    UIView *targetView = self.stTopViewController.view;
                    [targetView setFrame:CGRectMake(targetView.frame.size.width, targetView.frame.origin.y, targetView.frame.size.width, targetView.frame.size.height)];
                    [self.shadowBorder setFrame:CGRectMake(targetView.frame.origin.x-1,
                                                           self.shadowBorder.frame.origin.y,
                                                           self.shadowBorder.frame.size.width,
                                                           self.shadowBorder.frame.size.height)];
                } completion:^(BOOL finished) {
                    [previousController viewDidAppear:YES];
                    
                    
                    [self.stTopViewController viewDidDisappear:YES];
                    [self.stTopViewController.view removeFromSuperview];
                    CGRect rect = self.stTopViewController.view.frame;
                    rect.origin.x = 0;
                    [self.stTopViewController.view setFrame:rect];
                    [self popStateFresh];
                    self.shadowBorder.hidden = YES;
                    self.panTrackStartPoint = CGPointZero;
                    self.panTrackDirection = PanTrackDirectionUndefined;
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"app.stay.notification.NCCDidShowViewControllerNotification"
                                                                        object:self.stTopViewController];
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
                    [self.stTopViewController viewDidDisappear:YES];
                    
                    
                    [self.stTopViewController.view removeFromSuperview];
                    
                    [self.stViewControllers addObject:pushController];
                    [self.forwardViewControllers removeLastObject];
                    [self freshBackForwadItem];
                    self.shadowBorder.hidden = YES;
                    self.panTrackStartPoint = CGPointZero;
                    self.panTrackDirection = PanTrackDirectionUndefined;
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"app.stay.notification.NCCDidShowViewControllerNotification"
                                                                        object:pushController];
                }];
            }
        }
    }
    
}

- (void)forward{
    if (self.forwardViewControllers.count > 0){
        [self pushViewController:self.forwardViewControllers.lastObject isForward:YES];
        [self.forwardViewControllers removeLastObject];
    }
    [self freshBackForwadItem];
}

- (void)popStateFresh{
    [self.forwardViewControllers addObject:self.stTopViewController];
    [self.stViewControllers removeLastObject];
    [self freshBackForwadItem];
}

- (void)freshBackForwadItem{
    if (self.stViewControllers.count > 1){
        self.backItem.enabled = YES;
        self.backItem.image = [ImageHelper sfNamed:@"chevron.left"
                                              font:FCStyle.sfNavigationBar
                                             color:FCStyle.fcMacIcon];
    }
    else{
        self.backItem.enabled = NO;
        self.backItem.image = [ImageHelper sfNamed:@"chevron.left"
                                              font:FCStyle.sfNavigationBar
                                             color:FCStyle.fcSeparator];
    }
    
    if (self.forwardViewControllers.count > 0){
        self.forwardItem.enabled = YES;
        self.forwardItem.image = [ImageHelper sfNamed:@"chevron.right"
                                              font:FCStyle.sfNavigationBar
                                             color:FCStyle.fcMacIcon];
    }
    else{
        self.forwardItem.enabled = NO;
        self.forwardItem.image = [ImageHelper sfNamed:@"chevron.right"
                                              font:FCStyle.sfNavigationBar
                                             color:FCStyle.fcSeparator];
        
    }
}

- (void)sideAction:(id)sender{
    UISplitViewController *splitController = [QuickAccess splitController];
    if (splitController.displayMode != UISplitViewControllerDisplayModeSecondaryOnly){
        splitController.preferredDisplayMode = UISplitViewControllerDisplayModeSecondaryOnly;
//        [UIView animateWithDuration:0.5 animations:^{
//
//        } completion:^(BOOL finished) {
//        }];
    }
     else if (splitController.displayMode == UISplitViewControllerDisplayModeSecondaryOnly){
         splitController.preferredDisplayMode = UISplitViewControllerDisplayModeOneBesideSecondary;
//         [UIView animateWithDuration:0.5 animations:^{
//
//         } completion:^(BOOL finished) {
//
//         }];
     }
}

- (void)backAction:(id)sender{
    [self popViewController];
    [self freshBackForwadItem];
}

- (void)forwardAction:(id)sender{
    [self forward];
}

- (NSMutableArray *)stViewControllers{
    if (nil == _stViewControllers){
        _stViewControllers = [[NSMutableArray alloc] init];
    }
    
    return _stViewControllers;
}

- (NSMutableArray *)forwardViewControllers{
    if (nil == _forwardViewControllers){
        _forwardViewControllers = [[NSMutableArray alloc] init];
    }
    
    return _forwardViewControllers;
}

- (UIViewController *)stTopViewController{
    return self.stViewControllers.lastObject;
}

- (PlaceholderController *)placeholderController{
    if (nil == _placeholderController){
        _placeholderController = [[PlaceholderController alloc] init];
    }
    
    return _placeholderController;
}

- (UIView *)shadowBorder{
    if (nil == _shadowBorder){
        _shadowBorder = [[UIView alloc] initWithFrame:CGRectMake(1, 50, 1, self.view.frame.size.height - 50)];
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

- (UIBarButtonItem *)sideItem{
    if (nil == _sideItem){
        _sideItem = [[UIBarButtonItem alloc] initWithImage:[ImageHelper sfNamed:@"sidebar.left"
                                                                           font:FCStyle.sfNavigationBar
                                                                          color:FCStyle.fcMacIcon]
                                                     style:UIBarButtonItemStylePlain
                                                    target:self
                                                    action:@selector(sideAction:)];
    }
    
    return _sideItem;
}

- (UIBarButtonItem *)backItem{
    if (nil == _backItem){
        _backItem = [[UIBarButtonItem alloc] initWithImage:[ImageHelper sfNamed:@"chevron.left"
                                                                           font:FCStyle.sfNavigationBar
                                                                          color:FCStyle.fcSeparator]
                                                     style:UIBarButtonItemStylePlain
                                                    target:self
                                                    action:@selector(backAction:)];
        _backItem.enabled = NO;
    }
    
    return _backItem;
}

- (UIBarButtonItem *)forwardItem{
    if (nil == _forwardItem){
        _forwardItem = [[UIBarButtonItem alloc] initWithImage:[ImageHelper sfNamed:@"chevron.right"
                                                                              font:FCStyle.sfNavigationBar
                                                                             color:FCStyle.fcSeparator]
                                                     style:UIBarButtonItemStylePlain
                                                    target:self
                                                    action:@selector(forwardAction:)];
        _forwardItem.enabled = NO;
    }
    
    return _forwardItem;
}

- (NSMutableDictionary<NSString *,SYDetailViewController *> *)detailViewControllerDic{
    if (nil == _detailViewControllerDic){
        _detailViewControllerDic = [[NSMutableDictionary alloc] init];
    }
    
    return _detailViewControllerDic;
}

- (nonnull SYDetailViewController *)produceDetailViewControllerWithUserScript:(UserScript *)userScript{
    @synchronized (self.detailViewControllerDic) {
        SYDetailViewController *ret = self.detailViewControllerDic[userScript.uuid];
        if (nil == ret){
            ret = [[SYDetailViewController alloc] init];
            self.detailViewControllerDic[userScript.uuid] = ret;
        }
       
        ret.script = userScript;
        return ret;
    }
}

@end
