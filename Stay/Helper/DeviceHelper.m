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
#ifdef Mac
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

@end
