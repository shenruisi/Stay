//
//  NSString+Urlencode.m
//  Stay
//
//  Created by zly on 2021/12/12.
//

#import "NSString+Urlencode.h"

@implementation NSString (URL)

//URLEncode
-(NSString *)encodeString{
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                    (CFStringRef)self,
                     NULL,
                     (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                     kCFStringEncodingUTF8));
    
    return encodedString;
}


//URLDEcode
-(NSString *)decodeString
{
    NSString *decodedString = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                              (__bridge CFStringRef)self,CFSTR(""),
                               CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return decodedString;
}

@end
