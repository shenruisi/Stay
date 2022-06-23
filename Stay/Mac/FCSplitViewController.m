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

static CGFloat MIN_PRIMARY_WIDTH = 250;

@interface FCSplitViewController ()<
 NSToolbarDelegate,
 UISplitViewControllerDelegate
>

@end

@implementation FCSplitViewController

- (instancetype)init{
    if (self = [super init]){
        self.minimumPrimaryColumnWidth = MIN_PRIMARY_WIDTH;
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
    return @[Toolbar_AppIcon,Toolbar_AppName,Toolbar_SlideTrackInPrimary,Toolbar_Collapse,
             Toolbar_Block,Toolbar_Back,Toolbar_Forward,Toolbar_TabName,NSToolbarFlexibleSpaceItemIdentifier,Toolbar_Add,Toolbar_More];
}

- (NSArray<NSToolbarItemIdentifier> *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar{
    return @[Toolbar_AppIcon,Toolbar_AppName,Toolbar_Collapse,Toolbar_Block,
             Toolbar_Back,Toolbar_Forward,Toolbar_TabName,Toolbar_Add,Toolbar_More,Toolbar_Save,Toolbar_SlideTrackInPrimary,Toolbar_SlideTrackInSecondary,NSToolbarFlexibleSpaceItemIdentifier,Toolbar_Done];
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
        return  [FCShared.plugin.appKit slideTrackToolbarItem:itemIdentifier width:self.primaryColumnWidth - 250];
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
//        NSString *tabUUID = [[FCConfig shared] getStringValueOfKey:GroupUserDefaultsKeyMacSelectedTabUUID];
//        if (![FCShared.tabManager tabOfUUID:tabUUID]){
//
//        }
//        return [FCShared.plugin.appKit labelItem:Toolbar_TabName
//                                            text:[FCShared.tabManager tabNameWithUUID:tabUUID]
//                                        fontSize:FCStyle.headlineBold.pointSize];
        
        return nil;
    }
    else if ([itemIdentifier isEqualToString:Toolbar_Add]){
//        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
//        item.target = self;
//        item.action = @selector(toolbarItemDidClick:);
//        item.bordered = YES;
//        item.image = [UIImage systemImageNamed:@"plus"];
//        item.toolTip = NSLocalizedString(@"mac.toolbar.snippet.tip", @"");
//        [FCShared.plugin.appKit addMenuForItem:item title:NSLocalizedString(@"NewSnippet", @"") sfName:@"plus"];
//        return item;
        return nil;
    }
    else if ([itemIdentifier isEqualToString:Toolbar_More]){
//        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
//        item.target = self;
//        item.action = @selector(toolbarItemDidClick:);
//        item.bordered = YES;
//        item.image = [UIImage systemImageNamed:@"ellipsis.circle"];
//        item.toolTip = NSLocalizedString(@"More", @"");
//        [FCShared.plugin.appKit addMenuForItem:item title:NSLocalizedString(@"More", @"") sfName:@"ellipsis.circle"];
//        return item;
        return nil;
    }
    else if ([itemIdentifier isEqualToString:Toolbar_Save]){
//        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
//        item.target = self;
//        item.action = @selector(toolbarItemDidClick:);
//        item.bordered = YES;
//        item.title =  NSLocalizedString(@"Save", @"");
//        item.toolTip = NSLocalizedString(@"SaveSnippet", @"");
//        return item;
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
//        NavigateViewController *navigateViewController = [self viewControllerForColumn:UISplitViewControllerColumnSecondary];
//        [navigateViewController popViewController];
    }
    else if ([sender.itemIdentifier isEqualToString:Toolbar_Forward]){
//        NavigateViewController *navigateViewController = [self viewControllerForColumn:UISplitViewControllerColumnSecondary];
//        [navigateViewController forward];
    }
    else if ([sender.itemIdentifier isEqualToString:Toolbar_Collapse]){
        if (self.displayMode == UISplitViewControllerDisplayModeSecondaryOnly){
            [self showColumn:UISplitViewControllerColumnPrimary];
        }
        else{
            [self hideColumn:UISplitViewControllerColumnPrimary];
        }
        
    }
//    else if ([sender.itemIdentifier isEqualToString:Toolbar_Add]){
//        [self showAdd];
//    }
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


@end
