//
//  M3U8ExtXStreamInf.m
//  ILSLoader
//
//  Created by Jin Sun on 13-4-15.
//  Copyright (c) 2013年 iLegendSoft. All rights reserved.
//

#import "M3U8ExtXStreamInf.h"
#import "M3U8TagsAndAttributes.h"

const MediaResoulution MediaResoulutionZero = {0.f, 0.f};

NSString * NSStringFromMediaResolution(MediaResoulution resolution) {
    return [NSString stringWithFormat:@"%gx%g", resolution.width, resolution.height];
}

MediaResoulution MediaResolutionFromString(NSString *string) {
    NSArray *comps = [string componentsSeparatedByString:@"x"];
    if (comps.count == 2) {
        float width = [comps[0] floatValue];
        float height = [comps[1] floatValue];
        return MediaResolutionMake(width, height);
    } else {
        return MediaResoulutionZero;
    }
}

MediaResoulution MediaResolutionMake(float width, float height) {
    MediaResoulution resolution = {width, height};
    return resolution;
}


@interface M3U8ExtXStreamInf()
@property (nonatomic, strong) NSDictionary *dictionary;
@property (nonatomic) MediaResoulution resolution;
@end

@implementation M3U8ExtXStreamInf

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.dictionary = dictionary;
        self.resolution = MediaResoulutionZero;
    }
    return self;
}

- (NSURL *)baseURL {
    return self.dictionary[M3U8_BASE_URL];
}

- (NSURL *)URL {
    return self.dictionary[M3U8_URL];
}

- (NSURL *)m3u8URL {
    if (self.URI.scheme) {
        return self.URI;
    }
    
    return [NSURL URLWithString:self.URI.absoluteString relativeToURL:[self baseURL]];
}

- (NSInteger)bandwidth {
    return [self.dictionary[M3U8_EXT_X_STREAM_INF_BANDWIDTH] integerValue];
}

- (NSInteger)averageBandwidth {
    return [self.dictionary[M3U8_EXT_X_STREAM_INF_AVERAGE_BANDWIDTH] integerValue];
}

- (NSInteger)programId {
    return [self.dictionary[M3U8_EXT_X_STREAM_INF_PROGRAM_ID] integerValue];
}

- (NSArray *)codecs {
    NSString *codecsString = self.dictionary[M3U8_EXT_X_STREAM_INF_CODECS];
    return [codecsString componentsSeparatedByString:@","];
}

- (MediaResoulution)resolution {
    NSString *rStr = self.dictionary[M3U8_EXT_X_STREAM_INF_RESOLUTION];
    MediaResoulution resolution = MediaResolutionFromString(rStr);
    return resolution;
}

- (NSString *)audio {
    return self.dictionary[M3U8_EXT_X_STREAM_INF_AUDIO];
}

- (NSString *)video {
    return self.dictionary[M3U8_EXT_X_STREAM_INF_VIDEO];
}

- (NSString *)subtitles {
    return self.dictionary[M3U8_EXT_X_STREAM_INF_SUBTITLES];
}

- (NSString *)closedCaptions {
    return self.dictionary[M3U8_EXT_X_STREAM_INF_CLOSED_CAPTIONS];
}

- (NSURL *)URI {
    return [NSURL URLWithString:self.dictionary[M3U8_EXT_X_STREAM_INF_URI]];
}

- (NSString *)description {
    return [NSString stringWithString:self.dictionary.description];
}

/*
 #EXT-X-STREAM-INF:AUDIO="600k",BANDWIDTH=1049794,AVERAGE-BANDWIDTH=1000000,PROGRAM-ID=1,CODECS="avc1.42c01e,mp4a.40.2",RESOLUTION=640x360,SUBTITLES="subs"
 main_media_0.m3u8
 */
- (NSString *)m3u8PlainString {
    NSMutableString *str = [NSMutableString string];
    [str appendString:M3U8_EXT_X_STREAM_INF];
    if (self.audio.length > 0) {
        [str appendString:[NSString stringWithFormat:@"AUDIO=\"%@\"", self.audio]];
        [str appendString:[NSString stringWithFormat:@",BANDWIDTH=%ld", (long)self.bandwidth]];
    } else {
        [str appendString:[NSString stringWithFormat:@"BANDWIDTH=%ld", (long)self.bandwidth]];
    }
    
    if (self.averageBandwidth > 0) {
        [str appendString:[NSString stringWithFormat:@",AVERAGE-BANDWIDTH=%ld", (long)self.averageBandwidth]];
    }
    
    [str appendString:[NSString stringWithFormat:@",PROGRAM-ID=%ld", (long)self.programId]];
    NSString *codecsString = self.dictionary[M3U8_EXT_X_STREAM_INF_CODECS];
    [str appendString:[NSString stringWithFormat:@",CODECS=\"%@\"", codecsString]];
    NSString *rStr = self.dictionary[M3U8_EXT_X_STREAM_INF_RESOLUTION];
    if (rStr.length > 0) {
        [str appendString:[NSString stringWithFormat:@",RESOLUTION=%@", rStr]];
    }
    [str appendString:[NSString stringWithFormat:@"\n%@", self.URI.absoluteString]];
    return str;
}

@end





