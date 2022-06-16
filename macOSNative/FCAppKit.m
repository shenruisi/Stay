//
//  FCAppKit.m
//  Stay-Mac
//
//  Created by ris on 2022/6/15.
//

#import "FCAppKit.h"
#import <Cocoa/Cocoa.h>

@implementation FCAppKit

- (NSWindow *)_findWindow:(NSString *)targetIdentifier{
    NSArray *windows = [[NSApplication sharedApplication] windows];
    for (NSWindow *window in windows){
        NSString *windowClass = NSStringFromClass(window.class);
        if ([windowClass isEqualToString:@"UINSWindow"]){
            NSString *identifier = [[window performSelector:@selector(delegate)] persistentIdentifier];
            if (nil == identifier){
                identifier = [[window performSelector:@selector(delegate)] performSelector:@selector(sceneIdentifier)];
            }
            if ([identifier isEqualToString:targetIdentifier]){
                return window;
            }
        }
    }
    return nil;
}

- (void)openWindow:(NSString *)targetIdentifier
   sceneIdentifier:(NSString *)sceneIdentifier
  activeScreenInfo:(NSDictionary *)activeScreenInfo
            opened:(BOOL)opened{
    NSWindow *window = [self _findWindow:targetIdentifier];
    if (window){
        if (!opened){
            NSString *key = [NSString stringWithFormat:@"3%@-%@",sceneIdentifier,[activeScreenInfo[@"id"] stringValue]];
            NSDictionary *frameActive = [[NSUserDefaults standardUserDefaults] objectForKey:key];
            if (!frameActive){
                NSRect screenRect = NSMakeRect([activeScreenInfo[@"x"] floatValue],
                                         [activeScreenInfo[@"y"] floatValue],
                                         [activeScreenInfo[@"width"] floatValue],
                                         [activeScreenInfo[@"height"] floatValue]);
                [window setFrameOrigin:NSMakePoint(screenRect.origin.x + (screenRect.size.width - window.frame.size.width)/2,
                                                   (screenRect.size.height - window.frame.size.height)/2)];
                [[NSUserDefaults standardUserDefaults] setObject:@{@"x":@(window.frame.origin.x),
                                                                   @"y":@(window.frame.origin.y),
                                                                   @"width":@(window.frame.size.width),
                                                                   @"height":@(window.frame.size.height)
                                                                 }
                                                          forKey:key];
            }
            else{
                [window setFrame:NSMakeRect([frameActive[@"x"] floatValue],
                                            [frameActive[@"y"] floatValue],
                                            [frameActive[@"width"] floatValue],
                                            [frameActive[@"height"] floatValue])
                         display:YES];
            }
        }
        
        [window makeKeyAndOrderFront:nil];
    }
}

@end
