//
//  FCAppKitCapability.h
//  Stay-Mac
//
//  Created by ris on 2022/6/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
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
@end

NS_ASSUME_NONNULL_END
