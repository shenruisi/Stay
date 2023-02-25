//
//  API.m
//  FastClip2
//
//  Created by ris on 2020/3/8.
//  Copyright © 2020 ris. All rights reserved.
//

#import "API.h"
#ifdef MacNative
#else
#import <UIKit/UIKit.h>
#endif


@interface API(){
    NSString *_deviceType;
    NSString *_deviceName;
    NSString *_osVersion;
    NSString *_appVersion;
}
@end

@implementation API

static NSString *END_POINT = @"https://api.shenyin.name/stay/";
//static NSString *END_POINT = @"http://127.0.0.1:10000/stay/";
static API *instance = nil;
+ (instancetype)shared{
 static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[API alloc] init];
        
    });
    
    return instance;
}

- (id)init{
    if (self = [super init]){
#ifdef MacNative
        _deviceType = @"mac";
        _deviceName = [[NSHost currentHost] localizedName];
#else
#ifdef FC_MAC
        _deviceType = @"mac";
#else
        _deviceType = [[UIDevice currentDevice].model lowercaseString];
#endif
        _deviceName = [UIDevice currentDevice].name;
#endif
        
        _osVersion = [NSString stringWithFormat:@"%ld.%ld",
                      [[NSProcessInfo processInfo] operatingSystemVersion].majorVersion,
                      [[NSProcessInfo processInfo] operatingSystemVersion].minorVersion];
        _appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    }
    return self;
}

- (NSString *)deviceInfo{
    return [NSString stringWithFormat:@"%@ %@",_deviceType,_osVersion];
}

- (void)active:(NSString *)uuid isPro:(BOOL)isPro isExtension:(BOOL)isExtension{
    NSString *reqUrl = [NSString stringWithFormat:@"%@active",END_POINT];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:reqUrl]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSLocale *locale = [NSLocale currentLocale];
    NSDictionary *event = @{
        @"uuid":uuid,
        @"device_type":_deviceType,
        @"device_name":_deviceName,
        @"os_version":_osVersion,
        @"app_version":_appVersion,
        @"pro":isPro ? @"lifetime":@"",
        @"is_extension":@(isExtension),
        @"country":locale.countryCode.length > 0 ? locale.countryCode : @"CN"
    };
    NSData *data = [NSJSONSerialization dataWithJSONObject:event
    options:0
      error:nil];
    
    [request setHTTPBody:data];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *error) {
        NSLog(@"%@",response);

        }] resume];
}

- (void)event:(NSString *)content{
//    NSString *reqUrl = [NSString stringWithFormat:@"%@api/event",END_POINT];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:reqUrl]];
//    [request setHTTPMethod:@"POST"];
//    NSDictionary *event = @{
//        @"uuid":_uuid,
//        @"content":content
//    };
//    NSData *data = [NSJSONSerialization dataWithJSONObject:event
//    options:NSJSONWritingPrettyPrinted
//      error:nil];
//    [request setHTTPBody:data];
//    
//    [[[NSURLSession sharedSession] dataTaskWithRequest:request
//                completionHandler:^(NSData *data,
//                                    NSURLResponse *response,
//                                    NSError *error) {
////                   NSLog(@"%@",response);
//
//        }] resume];
}

- (NSString *)queryDeviceType {
    
    NSString *type = @"mac";
    
#ifdef MacNative
    type = @"mac";
#else
#ifdef FC_MAC
    type = @"mac";
#else
    type = [[UIDevice currentDevice].model lowercaseString];
#endif
    
#endif
    return type;
}

@end
