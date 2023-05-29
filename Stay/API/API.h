//
//  API.h
//  FastClip2
//
//  Created by ris on 2020/3/8.
//  Copyright © 2020 ris. All rights reserved.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface API : NSObject

+ (instancetype)shared;
- (void)active:(NSString *)uuid isPro:(BOOL)isPro isExtension:(BOOL)isExtension;
- (void)event:(NSString *)content;
- (NSString *)deviceInfo;
- (NSString *)queryDeviceType;
- (NSDictionary *)downloadYoutube:(NSString *)path location:(NSString *)location;
- (void)commitYoutbe:(NSString *)path code:(NSString *)code nCode:(NSString *)nCode;

- (void)queryPath:(NSString *)path
              pro:(BOOL)pro
         deviceId:(NSString *)deviceId
              biz:(nullable NSDictionary *)biz
       completion:(void(^)(NSInteger statusCode,NSError *error,NSDictionary *server,NSDictionary *biz))completion;
@end

NS_ASSUME_NONNULL_END
