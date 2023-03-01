//
//  NSString+Urlencode.h
//  Stay
//
//  Created by zly on 2021/12/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString(URL)
-(NSString *)encodeString;
-(NSString *)decodeString;
-(NSString *)safeEncode;
@end

NS_ASSUME_NONNULL_END
