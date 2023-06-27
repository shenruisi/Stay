//
//  DeviceHelper.m
//  Stay
//
//  Created by ris on 2022/10/18.
//

#import "DeviceHelper.h"
#import <UIKit/UIKit.h>
#import "KeychainItemWrapper.h"
#import "FCConfig.h"

NSNotificationName const _Nonnull DeviceHelperConsumePointsDidChangeNotification = @"app.stay.notification.DeviceHelperConsumePointsDidChangeNotification";

@implementation DeviceHelper

+ (FCDeviceType)type{
#ifdef FC_MAC
    return FCDeviceTypeMac;
#else
    return  [[[UIDevice currentDevice].model lowercaseString] isEqualToString:@"iphone"] ? FCDeviceTypeIPhone : FCDeviceTypeIPad;
#endif
       
}

static KeychainItemWrapper *k_keychain = nil;
+ (KeychainItemWrapper *)keychain{
    static dispatch_once_t onceTokenKeychain;
    dispatch_once(&onceTokenKeychain, ^{
        if (nil == k_keychain){
            k_keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"stay-keychain-stroge2" accessGroup:@"group.com.dajiu.stay.pro"];
        }
    });
    return k_keychain;
}

+ (void)saveUUID:(NSString *)uuid{
    [[self keychain] setObject:uuid forKey:(id)kSecAttrAccount];
}

+ (NSString *)uuid{
    return  [[self keychain] objectForKey:(id)kSecAttrAccount];
}

+ (void)reset{
//    [[self keychain] resetKeychainItem];
}

+ (void)consumePoints:(CGFloat)pointValue{
    CGFloat newPoints = [self totalConsumePoints] + pointValue;
    NSString *newPointsStr = [NSString stringWithFormat:@"%.1f",newPoints];
    [[self keychain] setObject:newPointsStr forKey:(id)kSecAttrLabel];
#if FC_IOS || FC_MAC
    [[NSNotificationCenter defaultCenter] postNotificationName:DeviceHelperConsumePointsDidChangeNotification
                                                        object:nil
                                                      userInfo:nil];
#endif
}
+ (void)rollbackPoints:(CGFloat)pointValue{
    CGFloat newPoints = [self totalConsumePoints] - pointValue;
    NSString *newPointsStr = [NSString stringWithFormat:@"%.1f",newPoints];
    [[self keychain] setObject:newPointsStr forKey:(id)kSecAttrLabel];
#if FC_IOS || FC_MAC
    [[NSNotificationCenter defaultCenter] postNotificationName:DeviceHelperConsumePointsDidChangeNotification
                                                        object:nil
                                                      userInfo:nil];
#endif
}
+ (CGFloat)totalConsumePoints{
    NSString *pointsStr =  [[self keychain] objectForKey:(id)kSecAttrLabel];
    return [pointsStr floatValue];
}

+ (NSString *)country{
    NSLocale *locale = [NSLocale currentLocale];
    return locale.countryCode.length > 0 ? locale.countryCode : @"CN";
}

@end
