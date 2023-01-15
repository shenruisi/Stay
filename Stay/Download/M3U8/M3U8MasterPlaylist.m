//
//  M3U8MasterPlaylist.m
//  M3U8Kit
//
//  Created by Sun Jin on 3/25/14.
//  Copyright (c) 2014 Jin Sun. All rights reserved.
//

#import "M3U8MasterPlaylist.h"
#import "NSString+m3u8.h"
#import "M3U8TagsAndAttributes.h"
#import "NSURL+m3u8.h"
#import "M3U8LineReader.h"

// #define M3U8_EXT_X_STREAM_INF_CLOSED_CAPTIONS   @"CLOSED-CAPTIONS" // The value can be either a quoted-string or an enumerated-string with the value NONE.
//    NSArray *quotedValueAttrs = @[@"URI", @"KEYFORMAT", @"KEYFORMATVERSIONS", @"GROUP-ID", @"LANGUAGE", @"ASSOC-LANGUAGE", @"NAME", @"INSTREAM-ID", @"CHARACTERISTICS", @"CODECS", @"AUDIO", @"VIDEO", @"SUBTITLES", @"BYTERANGE"];

@interface M3U8MasterPlaylist ()

@property (nonatomic, copy) NSString *originalText;
@property (nonatomic, copy) NSURL *baseURL;
@property (nonatomic, copy) NSURL *originalURL;

@property (nonatomic, strong) NSString *version;

@property (nonatomic, strong) M3U8ExtXKey *xSessionKey;

@property (nonatomic, strong) M3U8ExtXStreamInfList *xStreamList;
@property (nonatomic, strong) M3U8ExtXMediaList *xMediaList;

@end

@implementation M3U8MasterPlaylist

- (instancetype)initWithContent:(NSString *)string baseURL:(NSURL *)baseURL {
    if (!string.m3u_isMasterPlaylist) {
        return nil;
    }
    if (self = [super init]) {
        self.originalText = string;
        self.baseURL = baseURL;
        [self parseMasterPlaylist];
    }
    return self;
}

- (instancetype)initWithContentOfURL:(NSURL *)URL error:(NSError **)error {
    if (!URL) {
        return nil;
    }
    
    self.originalURL = URL;
    
    NSString *string = [NSString stringWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:error];
    return [self initWithContent:string baseURL:URL.m3u_realBaseURL];
}

- (void)parseMasterPlaylist {
    
    self.xStreamList = [[M3U8ExtXStreamInfList alloc] init];
    self.xMediaList = [[M3U8ExtXMediaList alloc] init];
    
    M3U8LineReader* reader = [[M3U8LineReader alloc] initWithText:self.originalText];
    
    while (true) {

        NSString* line = [reader next];
        if (!line) {
            break;
        }
        
        // #EXT-X-VERSION:4
        if ([line hasPrefix:M3U8_EXT_X_VERSION]) {
            NSRange r_version = [line rangeOfString:M3U8_EXT_X_VERSION];
            self.version = [line substringFromIndex:r_version.location + r_version.length];
        }
       
        else if ([line hasPrefix:M3U8_EXT_X_SESSION_KEY]) {
            NSRange range = [line rangeOfString:M3U8_EXT_X_SESSION_KEY];
            NSString *attribute_list = [line substringFromIndex:range.location + range.length];
            NSMutableDictionary *attr = attribute_list.m3u_attributesFromAssignmentByComma;
            
            M3U8ExtXKey *sessionKey = [[M3U8ExtXKey alloc] initWithDictionary:attr];
            self.xSessionKey = sessionKey;
        }
        
        // #EXT-X-STREAM-INF:AUDIO="600k",BANDWIDTH=915685,PROGRAM-ID=1,CODECS="avc1.42c01e,mp4a.40.2",RESOLUTION=640x360,SUBTITLES="subs"
        // http://hls.ted.com/talks/769/video/600k.m3u8?sponsor=Ripple
        else if ([line hasPrefix:M3U8_EXT_X_STREAM_INF]) {
            NSRange range = [line rangeOfString:M3U8_EXT_X_STREAM_INF];
            NSString *attribute_list = [line substringFromIndex:range.location + range.length];
            NSMutableDictionary *attr = attribute_list.m3u_attributesFromAssignmentByComma;
            
            NSString *nextLine = [reader next];
            attr[@"URI"] = nextLine;
            if (self.originalURL) {
                attr[M3U8_URL] = self.originalURL;
            }
            
            if (self.baseURL) {
                attr[M3U8_BASE_URL] = self.baseURL;
            }
            
            M3U8ExtXStreamInf *xStreamInf = [[M3U8ExtXStreamInf alloc] initWithDictionary:attr];
            [self.xStreamList addExtXStreamInf:xStreamInf];
        }
        
        
        // Ignore the following tag, which is not implemented yet.
        // #EXT-X-I-FRAME-STREAM-INF:BANDWIDTH=65531,PROGRAM-ID=1,CODECS="avc1.42c00c",RESOLUTION=320x180,URI="/talks/769/video/64k_iframe.m3u8?sponsor=Ripple"
        else if ([line hasPrefix:M3U8_EXT_X_I_FRAME_STREAM_INF]) {
            
            
        }
        
        // #EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="600k",LANGUAGE="eng",NAME="Audio",AUTOSELECT=YES,DEFAULT=YES,URI="/talks/769/audio/600k.m3u8?sponsor=Ripple",BANDWIDTH=614400
        else if ([line hasPrefix:M3U8_EXT_X_MEDIA]) {
            NSRange range = [line rangeOfString:M3U8_EXT_X_MEDIA];
            NSString *attribute_list = [line substringFromIndex:range.location + range.length];
            NSMutableDictionary *attr = attribute_list.m3u_attributesFromAssignmentByComma;
            if (self.baseURL.absoluteString.length > 0) {
                attr[M3U8_BASE_URL] = self.baseURL;
            }
            
            if (self.originalURL.absoluteString.length > 0) {
                attr[M3U8_URL] = self.originalURL;
            }
            M3U8ExtXMedia *media = [[M3U8ExtXMedia alloc] initWithDictionary:attr];
            [self.xMediaList addExtXMedia:media];
        }
    }
}

- (NSArray *)allStreamURLs {
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < self.xStreamList.count; i ++) {
        M3U8ExtXStreamInf *xsinf = [self.xStreamList xStreamInfAtIndex:i];
        if (xsinf.m3u8URL.absoluteString.length > 0) {
            if (NO == [array containsObject:xsinf.m3u8URL]) {
                [array addObject:xsinf.m3u8URL];
            }
        }
    }
    return [array copy];
}

- (M3U8ExtXStreamInfList *)alternativeXStreamInfList {
    
    M3U8ExtXStreamInfList *list = [[M3U8ExtXStreamInfList alloc] init];
    
    M3U8ExtXStreamInfList *xsilist = self.xStreamList;
    for (int index = 0; index < xsilist.count; index ++) {
        M3U8ExtXStreamInf *xsinf = [xsilist xStreamInfAtIndex:index];
        BOOL flag = NO;
        for (NSString *str in xsinf.codecs) {
            if (NO == flag) {
                flag = [str hasPrefix:@"avc1"];
            }
        }
        if (flag) {
            [list addExtXStreamInf:xsinf];
        }
    }
    
    // It is only used when the resolution is selected.
    //    M3U8ExtXMediaList *xmlist = self.masterPlaylist.xMediaList.videoList;
    //    for (int i = 0; i < xmlist.count; i ++) {
    //        M3U8ExtXMedia *media = [xmlist extXMediaAtIndex:i];
    //        [allAlternativeURLStrings addObject:media.m3u8URL];
    //    }
    return list;
}

- (NSString *)m3u8PlainString {
    NSMutableString *str = [NSMutableString string];
    [str appendString:M3U8_EXTM3U];
    [str appendString:@"\n"];
    if (self.version.length > 0) {
        [str appendString:[NSString stringWithFormat:@"%@%@", M3U8_EXT_X_VERSION, self.version]];
        [str appendString:@"\n"];
    }
    for (NSInteger index = 0; index < self.xStreamList.count; index ++) {
        M3U8ExtXStreamInf *xsinf = [self.xStreamList xStreamInfAtIndex:index];
        [str appendString:xsinf.m3u8PlainString];
        [str appendString:@"\n"];
    }
    
    M3U8ExtXMediaList *audioList = self.xMediaList.audioList;
    for (NSInteger i = 0; i < audioList.count; i ++) {
        NSLog(@"ext x media %ld", (long)i);
        M3U8ExtXMedia *media = [audioList xMediaAtIndex:i];
        [str appendString:media.m3u8PlainString];
        [str appendString:@"\n"];
    }
    
    return str;
}

@end
























