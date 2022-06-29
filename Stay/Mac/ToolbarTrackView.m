//
//  ToolbarTrackView.m
//  Stay-Mac
//
//  Created by ris on 2022/6/22.
//

#import "ToolbarTrackView.h"
#import "FCConfig.h"
#import "FCShared.h"
#import "Plugin.h"

@interface ToolbarTrackView()

@property (nonatomic, assign) CGRect lastRect;
@end

@implementation ToolbarTrackView

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    
    if (self.lastRect.size.width != frame.size.width){
        
        for(NSToolbarItem *item in self.toolbar.items){
            if ([item.itemIdentifier isEqualToString:Toolbar_SlideTrackInPrimary]){
                [FCShared.plugin.appKit slideTrackToolbarItemChanged:item width:self.frame.size.width - 310];
            }
        }
        
        [[FCConfig shared] setIntegerValueOfKey:GroupUserDefaultsKeyMacPrimaryWidth value:self.frame.size.width];
    }
   
    self.lastRect = frame;
}
@end
