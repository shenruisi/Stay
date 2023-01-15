//
//  M3U8ExtXKey.m
//  M3U8Kit
//
//  Created by Pierre Perrin on 01/02/2019.
//  Copyright © 2019 M3U8Kit. All rights reserved.
//

#import "M3U8ExtXKey.h"
#import "M3U8TagsAndAttributes.h"

@interface M3U8ExtXKey()
@property (nonatomic, strong) NSDictionary *dictionary;
@end

@implementation M3U8ExtXKey

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.dictionary = dictionary;
    }
    return self;
}

- (NSString *)method {
    return self.dictionary[M3U8_EXT_X_KEY_METHOD];
}

- (NSString *)url {
    return self.dictionary[M3U8_EXT_X_KEY_URI];
}

- (NSString *)keyFormat {
    return self.dictionary[M3U8_EXT_X_KEY_KEYFORMAT];
}

- (NSString *)iV {
    return self.dictionary[M3U8_EXT_X_KEY_IV];
}

- (NSString *)description {
    return self.dictionary.description;
}

@end
