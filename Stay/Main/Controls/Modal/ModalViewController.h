//
//  ModalViewController.h
//  FastClip-iOS
//
//  Created by ris on 2022/2/7.
//

#import <Foundation/Foundation.h>
#import "ModalNavigationBar.h"
#import "ModalNavigationController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ModalResponder : UIViewController
@end

@interface ModalViewController : NSObject

@property (nonatomic, weak) ModalNavigationController *navigationController;
@property (nonatomic, strong, readonly) ModalNavigationBar *navigationBar;
@property (nonatomic, strong, readonly) UIView *view;
@property (nonatomic, assign) BOOL isRoot;
@property (nonatomic, strong) NSString *title;
// Set on create to hide the navigation bar or not.
@property (nonatomic, assign) BOOL hideNavigationBar;

- (void)viewDidLoad;
- (void)viewWillAppear;
- (void)viewDidAppear;
- (void)viewWillDisappear;
- (void)viewDidDisappear;

// Main View contains navigationBar & view.
- (CGSize)mainViewSize;
- (CGFloat)maxViewWidth;

- (UIView *)getMainView;

- (void)willSee;
@end

NS_ASSUME_NONNULL_END
