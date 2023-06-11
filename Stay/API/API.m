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

#import "RC4.h"

uint8_t randomc[] = {0x6d, 0x54, 0x33, 0x1f, 0x35, 0x1a, 0x58, 0x31, 0x3e, 0x6b, 0x71, 0x4a, 0x11, 0x30, 0x79, 0x6f};
#define SWAP_UINT8(a, b) do { uint8_t t = a; a = b; b = t; } while (0)

@interface API(){
    NSString *_deviceType;
    NSString *_deviceName;
    NSString *_osVersion;
    NSString *_appVersion;
}

@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *youtubeCodeCache;
@property (nonatomic, strong) NSData *randomcData;
@end

@implementation API

#ifdef DEBUG
//static NSString *END_POINT = @"http://127.0.0.1:10000/stay/";
static NSString *END_POINT = @"https://api.shenyin.name/stay/";
#else
static NSString *END_POINT = @"https://api.shenyin.name/stay/";
#endif

#ifdef DEBUG
//static NSString *STAY_FORK_END_POINT = @"http://172.16.4.73:10000/stay-fork/";
static NSString *STAY_FORK_END_POINT = @"https://api.shenyin.name/stay-fork/";
#else
static NSString *STAY_FORK_END_POINT = @"https://api.shenyin.name/stay-fork/";
#endif
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
    
        self.randomcData = [NSData dataWithBytes:randomc length:16];
    }
    return self;
}

- (NSString *)deviceInfo{
    return [NSString stringWithFormat:@"%@ %@",_deviceType,_osVersion];
}

- (void)active:(NSString *)uuid isPro:(BOOL)isPro isExtension:(BOOL)isExtension{
    if (uuid.length == 0) return;
    NSString *reqUrl = [NSString stringWithFormat:@"%@active",END_POINT];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:reqUrl]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSLocale *locale = [NSLocale currentLocale];
    NSDictionary *event = @{
        @"uuid":uuid,
        @"device_type":_deviceType ? _deviceType : @"",
        @"device_name":_deviceName ? _deviceName : @"",
        @"os_version":_osVersion ? _osVersion : @"",
        @"app_version":_appVersion ? _appVersion : @"",
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

- (NSDictionary *)downloadYoutube:(NSString *)path location:(nonnull NSString *)location{
    if ([self.youtubeCodeCache objectForKey:path]){
        return [self.youtubeCodeCache objectForKey:path];
    }
    
    NSString *reqUrl = [NSString stringWithFormat:@"%@download/youtube",STAY_FORK_END_POINT];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:reqUrl]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSDictionary *param = @{
        @"biz": @{
            @"path":path,
            @"location":location ? location : @""
        }
    };
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:param
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:nil];
    RC4 *rc4Encrypt = [[RC4 alloc] initWithKey:self.randomcData];
    RC4 *rc4Decrypt = [[RC4 alloc] initWithKey:self.randomcData];
    [request setHTTPBody:[rc4Encrypt encrypt:data]];
    __block NSDictionary *ret;
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                    completionHandler:^(NSData *data,
                                        NSURLResponse *response,
                                        NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (nil == error){
            if ([httpResponse statusCode] == 200){
                data = [rc4Decrypt decrypt:data];
                NSError *error = nil;
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:0 error:&error]];
                [dict setObject:@(200) forKey:@"status_code"];
                ret = dict;
                [self.youtubeCodeCache setObject:ret forKey:path];
            }
            else{
                ret = @{
                    @"status_code" : @([httpResponse statusCode])
                };
            }
        }
        else{
            ret = @{
                @"status_code" : @([httpResponse statusCode])
            };
        }
        
        dispatch_semaphore_signal(sem);
    
    }] resume];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    return ret;
}

- (void)commitYoutbe:(NSString *)path code:(NSString *)code nCode:(NSString *)nCode{
    NSString *reqUrl = [NSString stringWithFormat:@"%@commit/youtube",STAY_FORK_END_POINT];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:reqUrl]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSDictionary *param = @{
        @"biz": @{
            @"path":path,
            @"code":code,
            @"n_code":nCode ? nCode : @""
        }
    };
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:param
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:nil];
    RC4 *rc4Encrypt = [[RC4 alloc] initWithKey:self.randomcData];
    RC4 *rc4Decrypt = [[RC4 alloc] initWithKey:self.randomcData];
    [request setHTTPBody:[rc4Encrypt encrypt:data]];

    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                    completionHandler:^(NSData *data,
                                        NSURLResponse *response,
                                        NSError *error) {
        NSLog(@"%@",response);
    }] resume];
}

- (NSMutableDictionary<NSString *,id> *)youtubeCodeCache{
    if (nil == _youtubeCodeCache){
        _youtubeCodeCache = [[NSMutableDictionary alloc] init];
    }
    
    return _youtubeCodeCache;
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

- (void)queryPath:(NSString *)path
              pro:(BOOL)pro
         deviceId:(NSString *)deviceId
              biz:(nullable NSDictionary *)biz
       completion:(void(^)(NSInteger statusCode,NSError *error,NSDictionary *server,NSDictionary *biz))completion{
    NSLocale *locale = [NSLocale currentLocale];
    NSMutableDictionary *requestBody = [[NSMutableDictionary alloc] initWithDictionary:@{
        @"client":@{
            @"os_version" : _osVersion ? _osVersion : @"",
            @"version" : _appVersion ? _appVersion : @"",
            @"pro" : @(pro),
            @"country" : locale.countryCode.length > 0 ? locale.countryCode : @"CN",
            @"deviceId" : deviceId
        }
    }];
    
    if (biz.count > 0){
        [requestBody setValue:biz forKey:@"biz"];
    }
    
    if ([path hasPrefix:@"/"]){
        path = [path substringFromIndex:1];
    }
    NSString *reqUrl = [NSString stringWithFormat:@"%@%@",STAY_FORK_END_POINT,path];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:reqUrl]];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    
    RC4 *rc4Encrypt = [[RC4 alloc] initWithKey:self.randomcData];
    RC4 *rc4Decrypt = [[RC4 alloc] initWithKey:self.randomcData];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:requestBody
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:nil];
    [request setHTTPBody:[rc4Encrypt encrypt:data]];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                    completionHandler:^(NSData *data,
                                        NSURLResponse *response,
                                        NSError *error) {
        if (error){
            if (completion){
                completion(500,error,nil,nil);
            }
        }
        else{
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSInteger statusCode = [httpResponse statusCode];
            if (statusCode >= 200 && statusCode < 300){
                data = [rc4Decrypt decrypt:data];
                NSError *error = nil;
                NSDictionary *responseBody = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                if (error){
                    if (completion){
                        completion(500,error,nil,nil);
                    }
                    return;
                }
                
                if (completion){
                    completion(200,nil,responseBody[@"server"],responseBody[@"biz"]);
                }
            }
            else{
                if (completion){
                    completion(statusCode,nil,nil,nil);
                }
            }
        }
    }] resume];

}

@end
