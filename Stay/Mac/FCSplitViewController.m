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

static CGFloat MIN_PRIMARY_WIDTH = 270;
static CGFloat MAX_PRIMARY_WIDTH = 540;

NSNotificationName const _Nonnull SVCDisplayModeDidChangeNotification = @"app.stay.notification.SVCDisplayModeDidChangeNotification";

@interface FCSplitViewController ()<
 NSToolbarDelegate,
 UISplitViewControllerDelegate
>

@property (nonatomic, strong) NSMutableDictionary<NSString *,SYDetailViewController *> *detailViewControllerDic;
@property (nonatomic, weak) SYEditViewController *holdEditViewController;
@end

@implementation FCSplitViewController

- (instancetype)init{
    if (self = [super init]){
        self.minimumPrimaryColumnWidth = MIN_PRIMARY_WIDTH;
        self.maximumPrimaryColumnWidth = MAX_PRIMARY_WIDTH;
        NSInteger preferredWidth = [[FCConfig shared] getIntegerValueOfKey:GroupUserDefaultsKeyMacPrimaryWidth];
        if (preferredWidth > 0){
            self.preferredPrimaryColumnWidth = preferredWidth;
        }
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = FCStyle.fcSeparator;
    NSLog(@"FCSplitViewController view %@",self.view);
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(navigateViewDidShow:)
                                                 name:NCCDidShowViewControllerNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(codeMirrorViewDidFinishContent:)
                                                 name:CMVDidFinishContentNotification
                                               object:nil];
}

- (void)loadView{
    [super loadView];
  
    self.toolbar.delegate = self;
    self.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (NSArray<NSToolbarItemIdentifier> *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar{
    return @[Toolbar_AppIcon,Toolbar_AppName,Toolbar_SlideTrackInPrimary,Toolbar_Import,Toolbar_Collapse,
             Toolbar_Block,Toolbar_Back,Toolbar_Forward,Toolbar_TabName,NSToolbarFlexibleSpaceItemIdentifier,Toolbar_Placeholder];
}

- (NSArray<NSToolbarItemIdentifier> *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar{
    return @[Toolbar_AppIcon,Toolbar_AppName,Toolbar_Collapse,Toolbar_Block,
             Toolbar_Back,Toolbar_Forward,Toolbar_TabName,Toolbar_Add,Toolbar_More,Toolbar_Save,Toolbar_SlideTrackInPrimary,Toolbar_SlideTrackInSecondary,NSToolbarFlexibleSpaceItemIdentifier,Toolbar_Done,Toolbar_Placeholder,Toolbar_Import];
}

- (NSArray<NSToolbarItemIdentifier> *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar{
    return @[];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSToolbarItemIdentifier)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
    {
    if ([itemIdentifier isEqualToString:Toolbar_AppIcon]){
        NSToolbarItem *item = [FCShared.plugin.appKit appIcon:itemIdentifier imageData:[ImageHelper dataNamed:@"NavIcon"]];
        item.target = self;
        item.action = @selector(toolbarItemDidClick:);
        item.bordered = YES;
        item.toolTip = NSLocalizedString(@"mac.toolbar.preferences.tip", @"");
        return item;
    }
    else if ([itemIdentifier isEqualToString:Toolbar_AppName]){
        NSToolbarItem *item = [FCShared.plugin.appKit appName:itemIdentifier];
        return item;
    }
    else if ([itemIdentifier isEqualToString:Toolbar_Import]){
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        item.target = self;
        item.action = @selector(toolbarItemDidClick:);
        item.bordered = YES;
        item.image = [UIImage systemImageNamed:@"plus"];
        return item;
    }
    else if ([itemIdentifier isEqualToString:Toolbar_Collapse]){
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        item.target = self;
        item.action = @selector(toolbarItemDidClick:);
        item.bordered = YES;
        item.image = [UIImage systemImageNamed:@"sidebar.left"];
        item.toolTip = NSLocalizedString(@"mac.toolbar.collapse.tip", @"");
        return item;
    }
    else if ([itemIdentifier isEqualToString:Toolbar_SlideTrackInPrimary]){
        return  [FCShared.plugin.appKit slideTrackToolbarItem:itemIdentifier width:self.primaryColumnWidth - 270];
    }
    else if ([itemIdentifier isEqualToString:Toolbar_Block]){
        return [FCShared.plugin.appKit blockItem:itemIdentifier width:12];
    }
    else if ([itemIdentifier isEqualToString:Toolbar_Back]){
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        item.target = self;
        item.bordered = YES;
        item.image = [UIImage systemImageNamed:@"chevron.backward"];
        item.toolTip = NSLocalizedString(@"mac.toolbar.back.tip", @"");
        return item;
    }
    else if ([itemIdentifier isEqualToString:Toolbar_Forward]){
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        item.target = self;
        item.bordered = YES;
        item.image = [UIImage systemImageNamed:@"chevron.forward"];
        item.toolTip = NSLocalizedString(@"mac.toolbar.forward.tip", @"");
        return item;
    }
    else if ([itemIdentifier isEqualToString:Toolbar_TabName]){
        return [FCShared.plugin.appKit labelItem:Toolbar_TabName
                                            text:@""
                                        fontSize:FCStyle.headlineBold.pointSize];
        
        return nil;
    }
    else if ([itemIdentifier isEqualToString:Toolbar_Add]){
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        item.target = self;
        item.action = @selector(toolbarItemDidClick:);
        item.bordered = YES;
        item.title =  NSLocalizedString(@"settings.create", @"");
        return item;
    }
    else if ([itemIdentifier isEqualToString:Toolbar_More]){
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        item.target = self;
        item.action = @selector(toolbarItemDidClick:);
        item.bordered = YES;
        item.image = [UIImage systemImageNamed:@"ellipsis.circle"];
        return item;
    }
    else if ([itemIdentifier isEqualToString:Toolbar_Save]){
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        item.target = self;
        item.action = @selector(toolbarItemDidClick:);
        item.bordered = YES;
        item.title =  NSLocalizedString(@"settings.save", @"");
        return nil;
    }
    else if ([itemIdentifier isEqualToString:Toolbar_Done]){
//        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
//        item.target = self;
//        item.action = @selector(toolbarItemDidClick:);
//        item.bordered = YES;
//        item.title =  NSLocalizedString(@"Done", @"");
//        return item;
        return nil;
    }
    else{
        return [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
    }
    return nil;
}

- (void)toolbarItemDidClick:(NSToolbarItem *)sender{
    if ([sender.itemIdentifier isEqualToString:Toolbar_Back]){
        [[QuickAccess secondaryController] popViewController];
    }
    else if ([sender.itemIdentifier isEqualToString:Toolbar_Forward]){
        [[QuickAccess secondaryController] forward];
    }
    else if ([sender.itemIdentifier isEqualToString:Toolbar_Collapse]){
        if (self.displayMode == UISplitViewControllerDisplayModeSecondaryOnly){
            [UIView animateWithDuration:0.5 animations:^{
                self.preferredDisplayMode = UISplitViewControllerDisplayModeOneBesideSecondary;
            } completion:^(BOOL finished) {
                [[NSNotificationCenter defaultCenter] postNotificationName:SVCDisplayModeDidChangeNotification
                                                                                        object:nil
                                                                                      userInfo:@{
                                        @"operate":@"show"
                                    }];
            }];
        }
        else{
            [UIView animateWithDuration:0.5 animations:^{
                self.preferredDisplayMode = UISplitViewControllerDisplayModeSecondaryOnly;
            } completion:^(BOOL finished) {
                [[NSNotificationCenter defaultCenter] postNotificationName:SVCDisplayModeDidChangeNotification
                                                                                        object:nil
                                                                                      userInfo:@{
                                        @"operate":@"hide"
                                    }];
            }];
            
        }
        
    }
    else if ([sender.itemIdentifier isEqualToString:Toolbar_Add]){
        [self.holdEditViewController save];
    }
    else if ([sender.itemIdentifier isEqualToString:Toolbar_Import]){
        [[QuickAccess homeViewController] import];
        
    }
//    else if ([sender.itemIdentifier isEqualToString:Toolbar_More]){
//        [self showTabEdit];
//    }
//    else if ([sender.itemIdentifier isEqualToString:Toolbar_Search]){
//        [self.toolbar removeItemAtIndex:self.toolbar.items.count - 3];
//        [self.toolbar insertItemWithItemIdentifier:Toolbar_SearchField atIndex:self.toolbar.items.count - 2];
//    }
//    else if ([sender.itemIdentifier isEqualToString:Toolbar_Save]){
//        UIViewController *viewController = [QuickAccess secondaryController].topViewController;
//        if ([viewController isKindOfClass:[DetailController class]]){
//            DetailController *detailController = (DetailController *)viewController;
//            [detailController saveContent];
//            [[QuickAccess secondaryController] popViewController];
//        }
//    }
//    else if ([sender.itemIdentifier isEqualToString:Toolbar_Done]){
//        UIViewController *viewController = [QuickAccess secondaryController].topViewController;
//        if ([viewController isKindOfClass:[BaseSnippetListController class]]){
//            BaseSnippetListController *snippetListcontroller = (BaseSnippetListController *)viewController;
//            [snippetListcontroller setSelectModeWithIsOn:NO];
//        }
//    }
//    else if ([sender.itemIdentifier isEqualToString:Toolbar_AppIcon]){
//        [self showPref];
//    }
}

- (void)enableToolbarItem:(NSToolbarItemIdentifier)identifier{
    [self _itemOfIdentifier:identifier].action = @selector(toolbarItemDidClick:);
    [[self _itemOfIdentifier:identifier] validate];
    
}

- (void)disableToolbarItem:(NSToolbarItemIdentifier)identifier{
    [self _itemOfIdentifier:identifier].action = nil;
    [[self _itemOfIdentifier:identifier] validate];
}


- (NSToolbarItem *)_itemOfIdentifier:(NSToolbarItemIdentifier)identifier{
    for (NSToolbarItem *item in self.toolbar.items){
        if ([item.itemIdentifier isEqualToString:identifier]){
            return item;
        }
    }
    
    return nil;
}

- (void)navigateViewDidShow:(NSNotification *)note{
    NavigateViewController *viewController = note.object;
    if ([viewController isKindOfClass:[SYDetailViewController class]]){
        SYDetailViewController *detailViewController = (SYDetailViewController *)viewController;
        [FCShared.plugin.appKit labelItemChanged:[self _itemOfIdentifier:Toolbar_TabName]
                                            text:detailViewController.script.name
                                        fontSize:FCStyle.headlineBold.pointSize];
        [self.toolbar removeItemAtIndex:self.toolbar.items.count-1];
        [self.toolbar insertItemWithItemIdentifier:Toolbar_More atIndex:self.toolbar.items.count];
    }
    else if ([viewController isKindOfClass:[SYEditViewController class]]){
        self.holdEditViewController = (SYEditViewController *)viewController;
        [FCShared.plugin.appKit labelItemChanged:[self _itemOfIdentifier:Toolbar_TabName]
                                            text:NSLocalizedString(@"settings.newScript", @"")
                                        fontSize:FCStyle.headlineBold.pointSize];
        [self.toolbar removeItemAtIndex:self.toolbar.items.count-1];
        if (self.holdEditViewController.isNew){
            [self.toolbar insertItemWithItemIdentifier:Toolbar_Add atIndex:self.toolbar.items.count];
        }
        else{
            [self.toolbar insertItemWithItemIdentifier:Toolbar_Save atIndex:self.toolbar.items.count];
        }
    }
    else if ([viewController isKindOfClass:[SYExpandViewController class]]){
        [FCShared.plugin.appKit labelItemChanged:[self _itemOfIdentifier:Toolbar_TabName]
                                            text:viewController.title
                                        fontSize:FCStyle.headlineBold.pointSize];
    }
    else{
        [FCShared.plugin.appKit labelItemChanged:[self _itemOfIdentifier:Toolbar_TabName]
                                            text:@""
                                        fontSize:FCStyle.headlineBold.pointSize];
    }
}

- (void)codeMirrorViewDidFinishContent:(NSNotification *)note{
    if (self.holdEditViewController){
        dispatch_async(dispatch_get_main_queue(), ^{
            [[QuickAccess secondaryController] popViewController];
        });
    }
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
            ret.script = userScript;
            self.detailViewControllerDic[userScript.uuid] = ret;
        }
        return ret;
    }
}

- (void)removeObserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NCCDidShowViewControllerNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:CMVDidFinishContentNotification
                                                  object:nil];
}

- (void)dealloc{
    [self removeObserver];
    
}


@end
