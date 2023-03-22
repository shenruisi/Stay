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
- (NSDictionary *)downloadYoutube:(NSString *)path;
- (void)commitYoutbe:(NSString *)path code:(NSString *)code;
@end

NS_ASSUME_NONNULL_END
