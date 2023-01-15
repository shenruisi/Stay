//
//  M3U8MediaPlaylist.m
//  M3U8Kit
//
//  Created by Sun Jin on 3/26/14.
//  Copyright (c) 2014 Jin Sun. All rights reserved.
//

#import "M3U8MediaPlaylist.h"
#import "NSString+m3u8.h"
#import "M3U8TagsAndAttributes.h"
#import "NSURL+m3u8.h"
#import "M3U8LineReader.h"
#import "M3U8ExtXKey.h"
#import "M3U8ExtXByteRange.h"
#import "NSArray+m3u8.h"

@interface M3U8MediaPlaylist()

@property (nonatomic, copy) NSString *originalText;
@property (nonatomic, copy) NSURL *baseURL;
@property (nonatomic, copy) NSURL *originalURL;

@property (nonatomic, strong) NSString *version;

@property (nonatomic, strong) M3U8SegmentInfoList *segmentList;

@property (assign, nonatomic) BOOL isLive;

@end

@implementation M3U8MediaPlaylist

- (instancetype)initWithContent:(NSString *)string type:(M3U8MediaPlaylistType)type baseURL:(NSURL *)baseURL {
    if (!string.m3u_isMediaPlaylist) {
        return nil;
    }
    
    if (self = [super init]) {
        self.originalText = string;
        self.baseURL = baseURL;
        self.type = type;
        [self parseMediaPlaylist];
    }
    return self;
}

- (instancetype)initWithContentOfURL:(NSURL *)URL type:(M3U8MediaPlaylistType)type error:(NSError **)error {
    if (nil == URL) {
        return nil;
    }
    
    self.originalURL = URL;
    
    NSString *string = [[NSString alloc] initWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:error];
    
    return [self initWithContent:string type:type baseURL:URL.m3u_realBaseURL];
}

- (NSArray *)allSegmentURLs {
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < self.segmentList.count; i ++) {
        M3U8SegmentInfo *info = [self.segmentList segmentInfoAtIndex:i];
        if (info.mediaURL.absoluteString.length > 0) {
            if (NO == [array containsObject:info.mediaURL]) {
                [array addObject:info.mediaURL];
            }
        }
    }
    return [array copy];
}

- (void)parseMediaPlaylist
{
    self.segmentList = [[M3U8SegmentInfoList alloc] init];
    BOOL isLive = [self.originalText rangeOfString:M3U8_EXT_X_ENDLIST].location == NSNotFound;
    self.isLive = isLive;
    
    M3U8LineReader* reader = [[M3U8LineReader alloc] initWithText:self.originalText];
    M3U8ExtXKey *key = nil;
    
    while (true) {
        
        NSString* line = [reader next];
        if (!line) {
            break;
        }
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        if (self.originalURL) {
            [params setObject:self.originalURL forKey:M3U8_URL];
        }
        
        if (self.baseURL) {
            [params setObject:self.baseURL forKey:M3U8_BASE_URL];
        }
        
        if ([line hasPrefix:M3U8_EXT_X_KEY]) {
            line = [line stringByReplacingOccurrencesOfString:M3U8_EXT_X_KEY withString:@""];
            key = [[M3U8ExtXKey alloc] initWithDictionary:line.m3u_attributesFromAssignmentByComma];
        }
        
        //check if it's #EXTINF:
        if ([line hasPrefix:M3U8_EXTINF]) {
            line = [line stringByReplacingOccurrencesOfString:M3U8_EXTINF withString:@""];
            
            NSArray<NSString *> *components = [line componentsSeparatedByString:@","];
            NSString *info = components.firstObject;
            if (info) {
                NSString *blankMark = @" ";
                NSArray<NSString *> *additions = [info componentsSeparatedByString:blankMark];
                // get duration
                NSString *duration = additions.firstObject;
                params[M3U8_EXTINF_DURATION] = duration;
                
                // get additional parameters from Extended M3U https://en.wikipedia.org/wiki/M3U#Extended_M3U
                if (additions.count > 1) {
                    // no need remove duration(first element). `m3u_attributesFromAssignmentByMark` function will skip first non-equation value.
                    params[M3U8_EXTINF_ADDITIONAL_PARAMETERS] = [additions m3u_attributesFromAssignmentByMark:blankMark];
                }
            }
            if (components.count > 1) {
                params[M3U8_EXTINF_TITLE] = components[1];
            }
            
            line = reader.next;
            // read ByteRange. only for version 4
            M3U8ExtXByteRange *byteRange = nil;
            if ([line hasPrefix:M3U8_EXT_X_BYTERANGE]) {
                line = [line stringByReplacingOccurrencesOfString:M3U8_EXT_X_BYTERANGE withString:@""];
                byteRange = [[M3U8ExtXByteRange alloc] initWithAtString:line];
                line = reader.next;
            }
            //ignore other # message
            while ([line hasPrefix:@"#"]) {
                line = reader.next;
            }
            //then get URI
            params[M3U8_EXTINF_URI] = line;
            
            M3U8SegmentInfo *segment = [[M3U8SegmentInfo alloc] initWithDictionary:params xKey:key byteRange:byteRange];
            if (segment) {
                [self.segmentList addSegementInfo:segment];
            }
        }
    }
}

@end

