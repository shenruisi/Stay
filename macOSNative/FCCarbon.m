//
//  FCCarbon.m
//  macOSNative
//
//  Created by ris on 2022/6/20.
//

#import "FCCarbon.h"

#import <Cocoa/Cocoa.h>
#import <SafariServices/SafariServices.h>

@interface FCCarbon()

@property (nonatomic, strong) NSScreen *activeScreen;
@end

@implementation FCCarbon

- (instancetype)init{
    if (self = [super init]){
        self.activeScreen = [NSScreen mainScreen];
        [NSEvent addGlobalMonitorForEventsMatchingMask:NSEventMaskFlagsChanged | NSEventMaskLeftMouseDown | NSEventTypeRightMouseDown
                                               handler:^(NSEvent *incomingEvent){
            [self updateByMousePoint:[incomingEvent locationInWindow]];
        }
        ];
    }
    
    return self;
}

- (void)updateByMousePoint:(NSPoint)point{
    for (NSScreen *screen in [NSScreen screens]){
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[screen.deviceDescription[@"NSScreenNumber"] stringValue]];
        if (NSPointInRect(point, screen.frame)){
            self.activeScreen = screen;
            break;
        }
    }
}

- (NSDictionary *)activeScreenInfo{
    return @{
        @"x":@(self.activeScreen.frame.origin.x),
        @"y":@(self.activeScreen.frame.origin.y),
        @"width":@(self.activeScreen.frame.size.width),
        @"height":@(self.activeScreen.frame.size.height),
        @"id":self.activeScreen.deviceDescription[@"NSScreenNumber"]
    };
}

- (void)enableExtension{
//    [SFSafariApplication showPreferencesForExtensionWithIdentifier:@"com.dajiu.stay.pro.Mac-Extension" completionHandler:^(NSError * _Nullable error) {
//
//    }];
    NSWorkspaceOpenConfiguration *conf = [NSWorkspaceOpenConfiguration configuration];
    [[NSWorkspace sharedWorkspace] openApplicationAtURL:[NSURL fileURLWithPath:@"/Applications/Safari.app"] configuration:conf completionHandler:^(NSRunningApplication * _Nullable app, NSError * _Nullable error) {

    }];

}

@end
