//
//  FCSplitViewController.m
//  Stay-Mac
//
//  Created by ris on 2022/6/15.
//

#import "FCSplitViewController.h"
#import "FCShared.h"
#import "Plugin.h"
#import "ImageHelper.h"
#import "FCStyle.h"
#import "FCConfig.h"
#import "NavigateCollectionController.h"
#import "SYEditViewController.h"
#import "QuickAccess.h"
#import "SYCodeMirrorView.h"
#import "SYHomeViewController.h"
#import "SYExpandViewController.h"
#import "SYWebScriptViewController.h"
#import "SYDetailViewController.h"
#import "FCStore.h"
#import "ICloudSyncSlideController.h"
#import "AlertHelper.h"
#import "TimeHelper.h"
#import "SYAppearanceViewController.h"

static CGFloat MIN_PRIMARY_WIDTH = 390;
static CGFloat MAX_PRIMARY_WIDTH = 540;

NSNotificationName const _Nonnull SVCDisplayModeDidChangeNotification = @"app.stay.notification.SVCDisplayModeDidChangeNotification";
NSNotificationName const _Nonnull SVCDidBecomeActiveNotification = @"app.stay.notification.SVCDidBecomeActiveNotification";

@interface FCSplitViewController ()<
 UISplitViewControllerDelegate
>

@property (nonatomic, strong) NSMutableDictionary<NSString *,SYDetailViewController *> *detailViewControllerDic;
@property (nonatomic, weak) SYEditViewController *holdEditViewController;
@property (nonatomic, weak) SYWebScriptViewController *holdWebScriptViewController;
@property (nonatomic, weak) SYDetailViewController *holdDetailViewController;
@property (nonatomic, strong) NSString *iCloudSFName;
 @property (nonatomic, strong) ICloudSyncSlideController *iCloudSyncSlideController;
@end

@implementation FCSplitViewController

//- (instancetype)init{
//    if (self = [super init]){
//        self.minimumPrimaryColumnWidth = MIN_PRIMARY_WIDTH;
//        self.maximumPrimaryColumnWidth = MAX_PRIMARY_WIDTH;
//        NSInteger preferredWidth = [[FCConfig shared] getIntegerValueOfKey:GroupUserDefaultsKeyMacPrimaryWidth];
//        if (preferredWidth > 0){
//            self.preferredPrimaryColumnWidth = preferredWidth;
//        }
//    }
//    
//    return self;
//}
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    // Do any additional setup after loading the view.
//    self.view.backgroundColor = FCStyle.fcSeparator;
//    NSLog(@"FCSplitViewController view %@",self.view);
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(navigateViewDidShow:)
//                                                 name:NCCDidShowViewControllerNotification
//                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(codeMirrorViewDidFinishContent:)
//                                                 name:CMVDidFinishContentNotification
//                                               object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(remoteSyncStart)
//                                                 name:iCloudServiceSyncStartNotification
//                                               object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(remoteSyncEnd)
//                                                 name:iCloudServiceSyncEndNotification
//                                               object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(sceneWillEnterForeground:)
//                                                 name:UISceneWillEnterForegroundNotification
//                                               object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(subscibeDidChangeHandler:)
//                                                 name:@"app.stay.notification.SYSubscibeChangeNotification"
//                                               object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(appearanceDidChangeAccentColorHandler:)
//                                                 name:AppearanceDidChangeAccentColorNotification
//                                               object:nil];
//}
//
//- (void)viewWillLayoutSubviews{
//    [super viewWillLayoutSubviews];
//    if (self.iCloudSyncSlideController.isShown){
//        [self.iCloudSyncSlideController layoutSubviews];
//    }
//}
//
//- (void)loadView{
//    [super loadView];
//  
//    self.toolbar.delegate = self;
//    self.delegate = self;
//}
//
//- (void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//}
//
//- (NSArray<NSToolbarItemIdentifier> *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar{
//    return @[Toolbar_AppIcon,Toolbar_AppName,Toolbar_SlideTrackInPrimary,Toolbar_iCloud,Toolbar_Import,Toolbar_Collapse,
//             Toolbar_Block,Toolbar_Back,Toolbar_Forward,Toolbar_TabName,NSToolbarFlexibleSpaceItemIdentifier,Toolbar_Placeholder];
//}
//
//- (NSArray<NSToolbarItemIdentifier> *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar{
//    return @[Toolbar_AppIcon,Toolbar_AppName,Toolbar_Collapse,Toolbar_Block,
//             Toolbar_Back,Toolbar_Forward,Toolbar_TabName,Toolbar_Add,Toolbar_More,Toolbar_Save,Toolbar_SlideTrackInPrimary,Toolbar_SlideTrackInSecondary,NSToolbarFlexibleSpaceItemIdentifier,Toolbar_Done,Toolbar_Placeholder,Toolbar_Import,Toolbar_iCloud,Toolbar_iCloudSync];
//}
//
//- (NSArray<NSToolbarItemIdentifier> *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar{
//    return @[];
//}
//
//- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSToolbarItemIdentifier)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
//    {
//    if ([itemIdentifier isEqualToString:Toolbar_AppIcon]){
//        NSToolbarItem *item = [FCShared.plugin.appKit appIcon:itemIdentifier imageData:
//                               [[FCStore shared] getPlan:NO] == FCPlan.None ? [ImageHelper dataNamed:@"NavIcon"] : [ImageHelper dataNamed:@"NavProIcon"]];
//        item.target = self;
//        item.action = @selector(toolbarItemDidClick:);
//        item.bordered = YES;
//        return item;
//    }
//    else if ([itemIdentifier isEqualToString:Toolbar_AppName]){
//        NSToolbarItem *item = [FCShared.plugin.appKit appName:itemIdentifier];
//        return item;
//    }
//    else if ([itemIdentifier isEqualToString:Toolbar_iCloud]){
//        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
//        item.target = self;
//        item.action = @selector(toolbarItemDidClick:);
//        item.bordered = YES;
//        self.iCloudSFName = nil;
//        item.image = nil;
//        return item;
//    }
//    else if ([itemIdentifier isEqualToString:Toolbar_iCloudSync]){
//        NSToolbarItem *item = [FCShared.plugin.appKit iCloudSync:itemIdentifier
//                                                       imageData:UIImagePNGRepresentation([ImageHelper sfNamed:@"arrow.triangle.2.circlepath" font:[UIFont systemFontOfSize:23] color:[UIColor colorWithRed:105/255.0 green:105/255.0 blue:105/255.0 alpha:1]])];
//        item.target = self;
//        item.action = @selector(toolbarItemDidClick:);
//        item.bordered = YES;
//        item.toolTip = NSLocalizedString(@"icloud.insync", @"");
//
//        return item;
//    }
//    else if ([itemIdentifier isEqualToString:Toolbar_Import]){
//        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
//        item.target = self;
//        item.action = @selector(toolbarItemDidClick:);
//        item.bordered = YES;
//        item.image = [UIImage systemImageNamed:@"plus"];
//        return item;
//    }
//    else if ([itemIdentifier isEqualToString:Toolbar_Collapse]){
//        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
//        item.target = self;
//        item.action = @selector(toolbarItemDidClick:);
//        item.bordered = YES;
//        item.image = [UIImage systemImageNamed:@"sidebar.left"];
//        item.toolTip = NSLocalizedString(@"mac.toolbar.collapse.tip", @"");
//        return item;
//    }
//    else if ([itemIdentifier isEqualToString:Toolbar_SlideTrackInPrimary]){
//        return  [FCShared.plugin.appKit slideTrackToolbarItem:itemIdentifier width:self.primaryColumnWidth - 310];
//    }
//    else if ([itemIdentifier isEqualToString:Toolbar_Block]){
//        return [FCShared.plugin.appKit blockItem:itemIdentifier width:12];
//    }
//    else if ([itemIdentifier isEqualToString:Toolbar_Back]){
//        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
//        item.target = self;
//        item.bordered = YES;
//        item.image = [UIImage systemImageNamed:@"chevron.backward"];
//        item.toolTip = NSLocalizedString(@"mac.toolbar.back.tip", @"");
//        return item;
//    }
//    else if ([itemIdentifier isEqualToString:Toolbar_Forward]){
//        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
//        item.target = self;
//        item.bordered = YES;
//        item.image = [UIImage systemImageNamed:@"chevron.forward"];
//        item.toolTip = NSLocalizedString(@"mac.toolbar.forward.tip", @"");
//        return item;
//    }
//    else if ([itemIdentifier isEqualToString:Toolbar_TabName]){
//        return [FCShared.plugin.appKit labelItem:Toolbar_TabName
//                                            text:@""
//                                        fontSize:FCStyle.headlineBold.pointSize];
//        
//        return nil;
//    }
//    else if ([itemIdentifier isEqualToString:Toolbar_Add]){
//        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
//        item.target = self;
//        item.action = @selector(toolbarItemDidClick:);
//        item.bordered = YES;
//        item.title =  NSLocalizedString(@"settings.create", @"");
//        return item;
//    }
//    else if ([itemIdentifier isEqualToString:Toolbar_More]){
//        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
//        item.target = self;
//        item.action = @selector(toolbarItemDidClick:);
//        item.bordered = YES;
//        item.image = [UIImage systemImageNamed:@"ellipsis.circle"];
//        return item;
//    }
//    else if ([itemIdentifier isEqualToString:Toolbar_Save]){
//        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
//        item.target = self;
//        item.action = @selector(toolbarItemDidClick:);
//        item.bordered = YES;
//        item.title =  NSLocalizedString(@"settings.save", @"");
//        return item;
//    }
//    else if ([itemIdentifier isEqualToString:Toolbar_Done]){
////        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
////        item.target = self;
////        item.action = @selector(toolbarItemDidClick:);
////        item.bordered = YES;
////        item.title =  NSLocalizedString(@"Done", @"");
////        return item;
//        return nil;
//    }
//    else{
//        return [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
//    }
//    return nil;
//}
//
//- (void)toolbarItemDidClick:(NSToolbarItem *)sender{
//    if ([sender.itemIdentifier isEqualToString:Toolbar_Back]){
//        if (self.holdWebScriptViewController && [self.holdWebScriptViewController canGoback]){
//            [self.holdWebScriptViewController goback];
//        }
//        else{
////            [[QuickAccess secondaryController] popViewController];
//        }
//    }
//    else if ([sender.itemIdentifier isEqualToString:Toolbar_Forward]){
////        [[QuickAccess secondaryController] forward];
//    }
//    else if ([sender.itemIdentifier isEqualToString:Toolbar_Collapse]){
//        if (self.displayMode == UISplitViewControllerDisplayModeSecondaryOnly){
//            [UIView animateWithDuration:0.5 animations:^{
//                self.preferredDisplayMode = UISplitViewControllerDisplayModeOneBesideSecondary;
//            } completion:^(BOOL finished) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:SVCDisplayModeDidChangeNotification
//                                                                                        object:nil
//                                                                                      userInfo:@{
//                                        @"operate":@"show"
//                                    }];
//            }];
//        }
//        else{
//            [UIView animateWithDuration:0.5 animations:^{
//                self.preferredDisplayMode = UISplitViewControllerDisplayModeSecondaryOnly;
//            } completion:^(BOOL finished) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:SVCDisplayModeDidChangeNotification
//                                                                                        object:nil
//                                                                                      userInfo:@{
//                                        @"operate":@"hide"
//                                    }];
//            }];
//            
//        }
//        
//    }
//    else if ([sender.itemIdentifier isEqualToString:Toolbar_Add]){
//        [self.holdEditViewController save];
//    }
//    else if ([sender.itemIdentifier isEqualToString:Toolbar_Import]){
//        [[QuickAccess homeViewController] import];
//        
//    }
//    else if ([sender.itemIdentifier isEqualToString:Toolbar_Save]){
//        [self.holdEditViewController save];
//    }
//    else if ([sender.itemIdentifier isEqualToString:Toolbar_iCloud]){
//        if ([self.iCloudSFName isEqualToString:@"checkmark.icloud"]){
//            [self remoteSyncStart];
//            [FCShared.iCloudService checkFirstInit:^(BOOL firstInit, NSError * error) {
//                [self remoteSyncEnd];
//                if (error){
//                    [FCShared.iCloudService showErrorWithMessage:NSLocalizedString(@"TryAgainLater", @"") inCer:self];
//                }
//                else{
//                    if (firstInit){
//                            dispatch_async(dispatch_get_main_queue(), ^{
//                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"iCloud"
//                                                                                           message:NSLocalizedString(@"icloud.firstInit", @"")
//                                                                                    preferredStyle:UIAlertControllerStyleAlert];
//                            UIAlertAction *conform = [UIAlertAction actionWithTitle:NSLocalizedString(@"icloud.syncNow", @"")
//                                                                              style:UIAlertActionStyleDefault
//                                                                            handler:^(UIAlertAction * _Nonnull action) {
//                                [self remoteSyncStart];
//                                [FCShared.iCloudService initUserscripts:[QuickAccess homeViewController].userscripts completionHandler:^(NSError * _Nonnull error) {
//                                    [self remoteSyncEnd];
//                                    if (error){
//                                        [FCShared.iCloudService showError:error inCer:self];
//                                    }
//                                    else{
//                                        [[FCConfig shared] setStringValueOfKey:GroupUserDefaultsKeyLastSync value:[TimeHelper current]];
//                                    }
//                                }];
//                            }];
//                            [alert addAction:conform];
//                            UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"")
//                                                                              style:UIAlertActionStyleCancel
//                                                                            handler:^(UIAlertAction * _Nonnull action) {
//                                [self.navigationController popViewControllerAnimated:YES];
//                            }];
//                            [alert addAction:cancel];
//                            [self presentViewController:alert animated:YES completion:nil];
//                        });
//                        
//                    }
//                    else{
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"iCloud"
//                                                                                           message:NSLocalizedString(@"icloud.syncNow", @"")
//                                                                                    preferredStyle:UIAlertControllerStyleAlert];
//                            UIAlertAction *conform = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"")
//                                                                              style:UIAlertActionStyleDefault
//                                                                            handler:^(UIAlertAction * _Nonnull action) {
//                                [[QuickAccess homeViewController] iCloudSyncIfNeeded];
//                            }];
//                            [alert addAction:conform];
//                            UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"")
//                                                                              style:UIAlertActionStyleCancel
//                                                                            handler:^(UIAlertAction * _Nonnull action) {
//                                [self.navigationController popViewControllerAnimated:YES];
//                            }];
//                            [alert addAction:cancel];
//                            [self presentViewController:alert animated:YES completion:nil];
//                        });
//                        
//                    }
//                }
//            }];
//        }
//        else if ([self.iCloudSFName isEqualToString:@"icloud.slash"]){
//            if (!self.iCloudSyncSlideController.isShown){
//                [self.iCloudSyncSlideController show];
//            }
//        }
//        else if ([self.iCloudSFName isEqualToString:@"person.icloud"]){
//            [AlertHelper simpleWithTitle:NSLocalizedString(@"Tips", @"")
//                                 message:NSLocalizedString(@"iCloudLogin", @"")
//                                   inCer:self];
//        }
//    }
//    else if ([sender.itemIdentifier isEqualToString:Toolbar_iCloudOn]){
//        
//        [self remoteSyncStart];
//        [FCShared.iCloudService checkFirstInit:^(BOOL firstInit, NSError * error) {
//            [self remoteSyncEnd];
//            if (error){
//                [FCShared.iCloudService showErrorWithMessage:NSLocalizedString(@"TryAgainLater", @"") inCer:self];
//            }
//            else{
//                if (firstInit){
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"iCloud"
//                                                                                       message:NSLocalizedString(@"icloud.firstInit", @"")
//                                                                                preferredStyle:UIAlertControllerStyleAlert];
//                        UIAlertAction *conform = [UIAlertAction actionWithTitle:NSLocalizedString(@"icloud.syncNow", @"")
//                                                                          style:UIAlertActionStyleDefault
//                                                                        handler:^(UIAlertAction * _Nonnull action) {
//                            [self remoteSyncStart];
//                            [FCShared.iCloudService initUserscripts:[QuickAccess homeViewController].userscripts
//                                                  completionHandler:^(NSError *error) {
//                                [self remoteSyncEnd];
//                                if (error){
//                                    [FCShared.iCloudService showError:error inCer:self];
//                                }
//                            }];
//                        }];
//                        [alert addAction:conform];
//                        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"")
//                                                                          style:UIAlertActionStyleCancel
//                                                                        handler:^(UIAlertAction * _Nonnull action) {
//                            [self.navigationController popViewControllerAnimated:YES];
//                        }];
//                        [alert addAction:cancel];
//                        [self presentViewController:alert animated:YES completion:nil];
//                    });
//                    
//                }
//                else{
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"iCloud"
//                                                                                       message:NSLocalizedString(@"icloud.syncNow", @"")
//                                                                                preferredStyle:UIAlertControllerStyleAlert];
//                        UIAlertAction *conform = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"")
//                                                                          style:UIAlertActionStyleDefault
//                                                                        handler:^(UIAlertAction * _Nonnull action) {
//                            [[NSNotificationCenter defaultCenter] postNotificationName:SVCDidBecomeActiveNotification object:nil];
//                        }];
//                        [alert addAction:conform];
//                        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"")
//                                                                          style:UIAlertActionStyleCancel
//                                                                        handler:^(UIAlertAction * _Nonnull action) {
//                            [self.navigationController popViewControllerAnimated:YES];
//                        }];
//                        [alert addAction:cancel];
//                        [self presentViewController:alert animated:YES completion:nil];
//                    });
//                    
//                }
//            }
//        }];
//    }
////    else if ([sender.itemIdentifier isEqualToString:Toolbar_More]){
////        [self showTabEdit];
////    }
//    else if ([sender.itemIdentifier isEqualToString:Toolbar_More]){
//        [self.holdDetailViewController share];
//    }
////    else if ([sender.itemIdentifier isEqualToString:Toolbar_Search]){
////        [self.toolbar removeItemAtIndex:self.toolbar.items.count - 3];
////        [self.toolbar insertItemWithItemIdentifier:Toolbar_SearchField atIndex:self.toolbar.items.count - 2];
////    }
////    else if ([sender.itemIdentifier isEqualToString:Toolbar_Save]){
////        UIViewController *viewController = [QuickAccess secondaryController].topViewController;
////        if ([viewController isKindOfClass:[DetailController class]]){
////            DetailController *detailController = (DetailController *)viewController;
////            [detailController saveContent];
////            [[QuickAccess secondaryController] popViewController];
////        }
////    }
////    else if ([sender.itemIdentifier isEqualToString:Toolbar_Done]){
////        UIViewController *viewController = [QuickAccess secondaryController].topViewController;
////        if ([viewController isKindOfClass:[BaseSnippetListController class]]){
////            BaseSnippetListController *snippetListcontroller = (BaseSnippetListController *)viewController;
////            [snippetListcontroller setSelectModeWithIsOn:NO];
////        }
////    }
////    else if ([sender.itemIdentifier isEqualToString:Toolbar_AppIcon]){
////        [self showPref];
////    }
//}
//
//- (void)appearanceDidChangeAccentColorHandler:(NSNotification *)note{
//    
//}
//
//- (void)subscibeDidChangeHandler:(NSNotification *)note{
//    NSToolbarItem *item = [self _itemOfIdentifier:Toolbar_AppIcon];
//    [FCShared.plugin.appKit changeAppIcon:item imageData:[[FCStore shared] getPlan:NO] == FCPlan.None ? [ImageHelper dataNamed:@"NavIcon"] : [ImageHelper dataNamed:@"NavProIcon"]];
//}
//
//- (void)remoteSyncStart{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.toolbar removeItemAtIndex:3];
//        [self.toolbar insertItemWithItemIdentifier:Toolbar_iCloudSync atIndex:3];
//    });
//}
//
//- (void)remoteSyncEnd{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.toolbar removeItemAtIndex:3];
//        [self.toolbar insertItemWithItemIdentifier:Toolbar_iCloud atIndex:3];
//        [self refreshICloudIcon];
//    });
//}
//
//- (void)enableToolbarItem:(NSToolbarItemIdentifier)identifier{
//    [self _itemOfIdentifier:identifier].action = @selector(toolbarItemDidClick:);
//    [[self _itemOfIdentifier:identifier] validate];
//    
//}
//
//- (void)disableToolbarItem:(NSToolbarItemIdentifier)identifier{
//    [self _itemOfIdentifier:identifier].action = nil;
//    [[self _itemOfIdentifier:identifier] validate];
//}
//
//
//- (NSToolbarItem *)_itemOfIdentifier:(NSToolbarItemIdentifier)identifier{
//    for (NSToolbarItem *item in self.toolbar.items){
//        if ([item.itemIdentifier isEqualToString:identifier]){
//            return item;
//        }
//    }
//    
//    return nil;
//}
//
//- (void)refreshICloudIcon{
//    NSToolbarItem *item = [self _itemOfIdentifier:Toolbar_iCloud];
//    FCPlan *plan = [[FCStore shared] getPlan:NO];
//    if (plan == FCPlan.None){
//        self.iCloudSFName = nil;
//        item.image = nil;
//    }
//    else{
//        BOOL iCloudEnabled = [[FCConfig shared] getBoolValueOfKey:GroupUserDefaultsKeySyncEnabled];
//        if (iCloudEnabled){
//            [FCShared.iCloudService refreshWithCompletionHandler:^(NSError *error) {
//                if (nil == error){
//                    self.iCloudSFName = FCShared.iCloudService.isLogin ?  @"checkmark.icloud" : @"person.icloud";
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        item.image = [UIImage systemImageNamed:self.iCloudSFName];
//                    });
//                }
//            }];
//            
//        }
//        else{
//            self.iCloudSFName = @"icloud.slash";
//            dispatch_async(dispatch_get_main_queue(), ^{
//                item.image = [UIImage systemImageNamed:self.iCloudSFName];
//            });
//            
//        }
//        
//    }
//}
//
//- (void)sceneWillEnterForeground:(NSNotification *)note{
//    [self refreshICloudIcon];
//    [[NSNotificationCenter defaultCenter] postNotificationName:SVCDidBecomeActiveNotification
//                                                        object:nil];
//}
//
//- (void)navigateViewDidShow:(NSNotification *)note{
//    NavigateViewController *viewController = note.object;
//    if ([viewController isKindOfClass:[SYDetailViewController class]]){
//        self.holdDetailViewController = (SYDetailViewController *)viewController;
//        SYDetailViewController *detailViewController = (SYDetailViewController *)viewController;
//        [FCShared.plugin.appKit labelItemChanged:[self _itemOfIdentifier:Toolbar_TabName]
//                                            text:detailViewController.script.name
//                                        fontSize:FCStyle.headlineBold.pointSize];
//        [self.toolbar removeItemAtIndex:self.toolbar.items.count-1];
//        [self.toolbar insertItemWithItemIdentifier:Toolbar_More atIndex:self.toolbar.items.count];
//        self.holdEditViewController = nil;
//        self.holdWebScriptViewController = nil;
//    }
//    else if ([viewController isKindOfClass:[SYEditViewController class]]){
//        self.holdEditViewController = (SYEditViewController *)viewController;
//        [self.toolbar removeItemAtIndex:self.toolbar.items.count-1];
//        NSString *text = self.holdEditViewController.isEdit ? NSLocalizedString(@"UpdateScript", @"") : NSLocalizedString(@"settings.newScript", @"");
//        if (!self.holdEditViewController.isEdit){
//            [self.toolbar insertItemWithItemIdentifier:Toolbar_Add atIndex:self.toolbar.items.count];
//        }
//        else{
//            [self.toolbar insertItemWithItemIdentifier:Toolbar_Save atIndex:self.toolbar.items.count];
//        }
//        [FCShared.plugin.appKit labelItemChanged:[self _itemOfIdentifier:Toolbar_TabName]
//                                            text:text
//                                        fontSize:FCStyle.headlineBold.pointSize];
//        self.holdWebScriptViewController = nil;
//        self.holdDetailViewController = nil;
//    }
//    else if ([viewController isKindOfClass:[SYExpandViewController class]]){
//        [FCShared.plugin.appKit labelItemChanged:[self _itemOfIdentifier:Toolbar_TabName]
//                                            text:viewController.title
//                                        fontSize:FCStyle.headlineBold.pointSize];
//        [self.toolbar removeItemAtIndex:self.toolbar.items.count-1];
//        [self.toolbar insertItemWithItemIdentifier:Toolbar_Placeholder atIndex:self.toolbar.items.count];
//        self.holdEditViewController = nil;
//        self.holdWebScriptViewController = nil;
//        self.holdDetailViewController = nil;
//    }
//    else if ([viewController isKindOfClass:[SYWebScriptViewController class]]){
//        self.holdWebScriptViewController = (SYWebScriptViewController *)viewController;
//        [FCShared.plugin.appKit labelItemChanged:[self _itemOfIdentifier:Toolbar_TabName]
//                                            text:@"Greasy Fork"
//                                        fontSize:FCStyle.headlineBold.pointSize];
//        [self.toolbar removeItemAtIndex:self.toolbar.items.count-1];
//        [self.toolbar insertItemWithItemIdentifier:Toolbar_Placeholder atIndex:self.toolbar.items.count];
//        self.holdEditViewController = nil;
//        self.holdDetailViewController = nil;
//    }
//    else{
//        [FCShared.plugin.appKit labelItemChanged:[self _itemOfIdentifier:Toolbar_TabName]
//                                            text:@""
//                                        fontSize:FCStyle.headlineBold.pointSize];
//        if (self.toolbar.items.count > 0 && ![self _itemOfIdentifier:Toolbar_Placeholder]){
//            [self.toolbar removeItemAtIndex:self.toolbar.items.count-1];
//            [self.toolbar insertItemWithItemIdentifier:Toolbar_Placeholder atIndex:self.toolbar.items.count];
//            self.holdEditViewController = nil;
//            self.holdWebScriptViewController = nil;
//            self.holdDetailViewController = nil;
//        }
//    }
//}
//
//- (void)codeMirrorViewDidFinishContent:(NSNotification *)note{
//    if (self.holdEditViewController){
//        dispatch_async(dispatch_get_main_queue(), ^{
////            [[QuickAccess secondaryController] popViewController];
//            [[NSNotificationCenter defaultCenter] postNotificationName:HomeViewShouldReloadDataNotification
//                                                                object:nil];
//        });
//    }
//}
//
//- (NSMutableDictionary<NSString *,SYDetailViewController *> *)detailViewControllerDic{
//    if (nil == _detailViewControllerDic){
//        _detailViewControllerDic = [[NSMutableDictionary alloc] init];
//    }
//    
//    return _detailViewControllerDic;
//}
//
//- (nonnull SYDetailViewController *)produceDetailViewControllerWithUserScript:(UserScript *)userScript{
//    @synchronized (self.detailViewControllerDic) {
//        SYDetailViewController *ret = self.detailViewControllerDic[userScript.uuid];
//        if (nil == ret){
//            ret = [[SYDetailViewController alloc] init];
//            self.detailViewControllerDic[userScript.uuid] = ret;
//        }
//       
//        ret.script = userScript;
//        NSLog(@"selected userscript %@",ret.script.injectInto);
//        return ret;
//    }
//}
//
//- (ICloudSyncSlideController *)iCloudSyncSlideController{
//    if (nil == _iCloudSyncSlideController){
//        _iCloudSyncSlideController = [[ICloudSyncSlideController alloc] init];
//        _iCloudSyncSlideController.cer = self;
//    }
//    return _iCloudSyncSlideController;
//}
//
//- (void)removeObserver{
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:NCCDidShowViewControllerNotification
//                                                  object:nil];
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:CMVDidFinishContentNotification
//                                                  object:nil];
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:iCloudServiceSyncStartNotification
//                                                  object:nil];
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:iCloudServiceSyncEndNotification
//                                                  object:nil];
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:UISceneWillEnterForegroundNotification
//                                                  object:nil];
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:@"app.stay.notification.SYSubscibeChangeNotification"
//                                                  object:nil];
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:AppearanceDidChangeAccentColorNotification
//                                                  object:nil];
//    
//    
//    
//}
//
//- (void)dealloc{
//    [self removeObserver];
//    
//}


@end
