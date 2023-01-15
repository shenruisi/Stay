//
//  M3U8ExtXByteRange.m
//  M3U8Kit
//
//  Created by Frank on 2020/10/1.
//  Copyright © 2020 M3U8Kit. All rights reserved.
//

#import "M3U8ExtXByteRange.h"

@implementation M3U8ExtXByteRange

- (instancetype)initWithAtString:(NSString *)atString {
    NSArray<NSString *> *params = [atString componentsSeparatedByString:@"@"];
    NSInteger length = params.firstObject.integerValue;
    NSInteger offset = 0;
    if (params.count > 1) {
        offset = MAX(0, params[1].integerValue);
    }
    
    return [self initWithLength:length offset:offset];
}

- (instancetype)initWithLength:(NSInteger)length offset:(NSInteger)offset {
    self = [super init];
    if (self) {
        _length = length;
        _offset = offset;
    }
    return self;
}

@end
