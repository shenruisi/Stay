//
//  FCToolbar.h
//  FastClip-Mac
//
//  Created by ris on 2022/3/8.
//
#import <Cocoa/Cocoa.h>


NS_ASSUME_NONNULL_BEGIN

static const NSToolbarItemIdentifier Toolbar_Collapse = @"toolbar.collapse";
static const NSToolbarItemIdentifier Toolbar_AppIcon = @"toolbar.appIcon";
static const NSToolbarItemIdentifier Toolbar_AppName = @"toolbar.appName";
static const NSToolbarItemIdentifier Toolbar_SlideTrackInPrimary = @"toolbar.slideTrackInPrimary";
static const NSToolbarItemIdentifier Toolbar_Block = @"toolbar.block";
static const NSToolbarItemIdentifier Toolbar_Back = @"toolbar.back";
static const NSToolbarItemIdentifier Toolbar_Forward = @"toolbar.forward";
static const NSToolbarItemIdentifier Toolbar_TabName = @"toolbar.tabName";
static const NSToolbarItemIdentifier Toolbar_SlideTrackInSecondary = @"toolbar.slideTrackInSecondary";
static const NSToolbarItemIdentifier Toolbar_Add = @"toolbar.add";
static const NSToolbarItemIdentifier Toolbar_More = @"toolbar.more";
static const NSToolbarItemIdentifier Toolbar_Save = @"toolbar.save";
static const NSToolbarItemIdentifier Toolbar_Done = @"toolbar.done";

@protocol FCToolbarDelegate <NSObject>

- (NSArray<NSToolbarItemIdentifier> *)itemIdentifiers;
@end

@interface FCToolbar : NSToolbar

@property (nonatomic, assign) CGFloat height;
@end



NS_ASSUME_NONNULL_END

