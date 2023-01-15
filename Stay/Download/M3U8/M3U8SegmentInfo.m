//
//  M3U8SegmentInfo.m
//  M3U8Kit
//
//  Created by Oneday on 13-1-11.
//  Copyright (c) 2013年 0day. All rights reserved.
//

#import "M3U8SegmentInfo.h"
#import "M3U8TagsAndAttributes.h"
#import "M3U8ExtXKey.h"
#import "M3U8ExtXByteRange.h"

@interface M3U8SegmentInfo()
@property (nonatomic, strong) NSDictionary *dictionary;

@end

@implementation M3U8SegmentInfo

@synthesize xKey = _xKey;

- (instancetype)init {
    return [self initWithDictionary:nil xKey:nil];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    return [self initWithDictionary:dictionary xKey:nil];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary xKey:(M3U8ExtXKey *)key {
    return [self initWithDictionary:dictionary xKey:key byteRange:nil];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary xKey:(M3U8ExtXKey *)key byteRange:(M3U8ExtXByteRange *)byteRange{
    if (self = [super init]) {
        _dictionary = dictionary;
        _xKey = key;
        _byteRange = byteRange;
    }
    return self;
}

- (NSURL *)baseURL {
    return self.dictionary[M3U8_BASE_URL];
}

- (NSURL *)URL {
    return self.dictionary[M3U8_URL];
}

- (NSString *)urlString {
    if (self.URI.scheme) {
        return self.URI.absoluteString;
    } else {
        return self.URL != nil ? [NSURL URLWithString:self.URI.absoluteString relativeToURL:[self.URL URLByDeletingLastPathComponent]].absoluteString : [NSURL URLWithString:self.URI.absoluteString relativeToURL:[self baseURL]].absoluteString;
    }
}

- (NSURL *)mediaURL {
    if (self.URI.scheme) {
        return self.URI;
    }
    
    return [NSURL URLWithString:self.URI.absoluteString relativeToURL:[self baseURL]];
}

- (NSTimeInterval)duration {
    return [self.dictionary[M3U8_EXTINF_DURATION] doubleValue];
}

- (NSString *)title {
    return self.dictionary[M3U8_EXTINF_TITLE];
}

- (NSURL *)URI {
    return [NSURL URLWithString:self.dictionary[M3U8_EXTINF_URI]];
}

- (NSDictionary<NSString *,NSString *> *)additionalParameters {
    return self.dictionary[M3U8_EXTINF_ADDITIONAL_PARAMETERS];
}

- (NSString *)description {
    NSMutableDictionary *dict = [self.dictionary mutableCopy];
    [dict addEntriesFromDictionary:[self.xKey valueForKey:@"dictionary"]];
    return dict.description;
}

@end
