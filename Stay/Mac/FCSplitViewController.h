//
//  FCSplitViewController.h
//  Stay-Mac
//
//  Created by ris on 2022/6/15.
//

#import <UIKit/UIKit.h>
#import "FCToolbar.h"
#import "SYDetailViewController.h"

NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const _Nonnull SVCDisplayModeDidChangeNotification;

@interface FCSplitViewController : UISplitViewController

@property (nonatomic, strong, nullable) FCToolbar *toolbar;
- (nonnull SYDetailViewController *)produceDetailViewControllerWithUserScript:(UserScript *)userScript;
- (void)enableToolbarItem:(NSToolbarItemIdentifier)identifier;
- (void)disableToolbarItem:(NSToolbarItemIdentifier)identifier;
@end

NS_ASSUME_NONNULL_END
