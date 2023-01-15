//
//  NSArray+m3u8.m
//  M3U8Kit
//
//  Created by Frank on 2022/7/12.
//  Copyright © 2022 M3U8Kit. All rights reserved.
//

#import "NSArray+m3u8.h"
#import "NSString+m3u8.h"

@implementation NSArray (m3u8)

- (NSMutableDictionary *)m3u_attributesFromAssignment {
    return [self m3u_attributesFromAssignmentByMark:nil];
}

- (NSMutableDictionary *)m3u_attributesFromAssignmentByMark:(NSString *)mark {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    NSString *lastkey = nil;
    for (NSString *keyValue in self) {
        NSRange equalMarkRange = [keyValue rangeOfString:@"="];
        // if equal mark is not found, it means this value is previous value left. eg: CODECS=\"avc1.42c01e,mp4a.40.2\"
        if (equalMarkRange.location == NSNotFound) {
            if (!mark) continue;
            if (!lastkey) continue;
            NSString *lastValue = dict[lastkey];
            NSString *supplement = [lastValue stringByAppendingFormat:@"%@%@", mark, keyValue.m3u_stringByTrimmingQuoteMark];
            dict[lastkey] = supplement;
            continue;
        }
        NSString *key = [keyValue substringToIndex:equalMarkRange.location].m3u_stringByTrimmingQuoteMark;
        NSString *value = [keyValue substringFromIndex:equalMarkRange.location + 1].m3u_stringByTrimmingQuoteMark;
        
        dict[key] = value;
        lastkey = key;
    }
    
    return dict;
}

@end
