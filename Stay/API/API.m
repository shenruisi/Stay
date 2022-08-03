//
//  API.m
//  FastClip2
//
//  Created by ris on 2020/3/8.
//  Copyright © 2020 ris. All rights reserved.
//

#import "API.h"
#import "AppDelegate.h"
#import "FCConfig.h"

@interface API(){
    NSString *_deviceType;
    NSString *_deviceName;
    NSString *_osVersion;
    NSString *_appVersion;
}
@end

@implementation API

//static NSString *END_POINT = @"https://fastclip.shenyin.name/";
static NSString *END_POINT = @"http://localhost:8080/fc/";
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
#ifdef Mac
        _deviceType = @"mac";
#else
        _deviceType = [[UIDevice currentDevice].model lowercaseString];
#endif
        _deviceName = [UIDevice currentDevice].name;
        _osVersion = [NSString stringWithFormat:@"%ld.%ld",
                      [[NSProcessInfo processInfo] operatingSystemVersion].majorVersion,
                      [[NSProcessInfo processInfo] operatingSystemVersion].minorVersion];
        _appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    }
    return self;
}

- (void)active:(NSString *)uuid isPro:(BOOL)isPro isExtension:(BOOL)isExtension{
    NSString *reqUrl = [NSString stringWithFormat:@"%@/active",END_POINT];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:reqUrl]];
    [request setHTTPMethod:@"POST"];
    NSDictionary *event = @{
        @"uuid":uuid,
        @"device_type":_deviceType,
        @"device_name":_deviceName,
        @"os_version":_osVersion,
        @"app_version":_appVersion,
        @"pro":isPro ? @"lifetime":@"",
        @"is_extension":@(isExtension)
    };
    NSData *data = [NSJSONSerialization dataWithJSONObject:event
    options:NSJSONWritingPrettyPrinted
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

@end
