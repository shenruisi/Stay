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
            k_keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"stay-keychain-stroge" accessGroup:nil];
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
    [[self keychain] setObject:@(newPoints) forKey:(id)kSecAttrLabel];
}
+ (void)rollbackPoints:(CGFloat)pointValue{
    CGFloat newPoints = [self totalConsumePoints] - pointValue;
    [[self keychain] setObject:@(newPoints) forKey:(id)kSecAttrLabel];
}
+ (CGFloat)totalConsumePoints{
    NSNumber *points =  [[self keychain] objectForKey:(id)kSecAttrLabel];
    return [points floatValue];
}

+ (NSString *)country{
    NSLocale *locale = [NSLocale currentLocale];
    return locale.countryCode.length > 0 ? locale.countryCode : @"CN";
}

@end
