//
//  FCAppKitCapability.h
//  Stay-Mac
//
//  Created by ris on 2022/6/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class NSToolbarItem;
@protocol UINSApplicationDelegate;
@protocol FCAppKitCapability <NSObject>

- (instancetype)initWithAppDelegate:(id<UINSApplicationDelegate>)appDelegate;
- (void)styleWindow:(NSString *)targetIdentifier origin:(NSDictionary *)origin;
- (BOOL)titlebarAppearsTransparent:(NSString *)targetIdentifier;
- (void)topLevelWindow:(NSString *)targetIdentifier;
- (void)openWindow:(NSString *)targetIdentifier
   sceneIdentifier:(NSString *)sceneIdentifier
  activeScreenInfo:(NSDictionary *)activeScreenInfo
            opened:(BOOL)opened;

- (NSToolbarItem *)appIcon:(NSString *)identifier imageData:(NSData *)imageData;
- (void)changeAppIcon:(NSToolbarItem *)item imageData:(NSData *)imageData;
- (NSToolbarItem *)appName:(NSString *)identifier;
- (NSToolbarItem *)iCloudSync:(NSString *)identifier imageData:(NSData *)imageData;
- (NSToolbarItem *)slideTrackToolbarItem:(NSString *)identifier width:(CGFloat)width;
- (NSToolbarItem *)labelItem:(NSString *)identifier text:(NSString *)text fontSize:(CGFloat)fontSize;
- (void)labelItemChanged:(NSToolbarItem *)item text:(NSString *)text fontSize:(CGFloat)fontSize;
- (NSToolbarItem *)blockItem:(NSString *)identifier width:(CGFloat)width;
- (void)slideTrackToolbarItemChanged:(NSToolbarItem *)item width:(CGFloat)width;
- (void)appearanceChanged:(NSString *)mode;
- (void)accentColorChanged:(NSString *)colorString;
- (void)openUrl:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
