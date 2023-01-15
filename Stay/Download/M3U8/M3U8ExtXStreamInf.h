//
//  M3U8ExtXStreamInf.h
//  ILSLoader
//
//  Created by Jin Sun on 13-4-15.
//  Copyright (c) 2013年 iLegendSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

struct MediaResoulution{
    float width;
    float height;
};
typedef struct MediaResoulution MediaResoulution;

extern MediaResoulution MediaResolutionMake(float width, float height);

extern const MediaResoulution MediaResoulutionZero;
NSString * NSStringFromMediaResolution(MediaResoulution resolution);

/*!
 @class M3U8SegmentInfo
 @abstract This is the class indicates #EXT-X-STREAM-INF:<attribute-list> + <URI> in master playlist file.
 
 /// EXT-X-STREAM-INF

 @format    #EXT-X-STREAM-INF:<attribute-list>
 <URI>
 @example   #EXT-X-STREAM-INF:AUDIO="600k",BANDWIDTH=915685,PROGRAM-ID=1,CODECS="avc1.42c01e,mp4a.40.2",RESOLUTION=640x360,SUBTITLES="subs"
 /talks/769/video/600k.m3u8?sponsor=Ripple
 
 @note      The EXT-X-STREAM-INF tag MUST NOT appear in a Media Playlist.

#define M3U8_EXT_X_STREAM_INF               @"#EXT-X-STREAM-INF:"
// EXT-X-STREAM-INF Attributes
#define M3U8_EXT_X_STREAM_INF_BANDWIDTH     @"BANDWIDTH" // The value is a decimal-integer of bits per second.
#define M3U8_EXT_X_STREAM_INF_PROGRAM_ID    @"PROGRAM-ID"   // The value is a decimal-integer that uniquely identifies a particular presentation within the scope of the Playlist file.
#define M3U8_EXT_X_STREAM_INF_CODECS        @"CODECS" // The value is a quoted-string containing a comma-separated list of formats.
#define M3U8_EXT_X_STREAM_INF_RESOLUTION    @"RESOLUTION" // The value is a decimal-resolution describing the approximate encoded horizontal and vertical resolution of video within the presentation.
#define M3U8_EXT_X_STREAM_INF_AUDIO         @"AUDIO" // The value is a quoted-string.
#define M3U8_EXT_X_STREAM_INF_VIDEO         @"VIDEO" // The value is a quoted-string.
#define M3U8_EXT_X_STREAM_INF_SUBTITLES     @"SUBTITLES" // The value is a quoted-string.
#define M3U8_EXT_X_STREAM_INF_CLOSED_CAPTIONS   @"CLOSED-CAPTIONS" // The value can be either a quoted-string or an enumerated-string with the value NONE.
#define M3U8_EXT_X_STREAM_INF_URI           @"URI"  // The value is a enumerated-string containing a URI that identifies the Playlist file.

 */
@interface M3U8ExtXStreamInf : NSObject

@property (nonatomic, readonly, assign) NSInteger bandwidth;
@property (nonatomic, readonly, assign) NSInteger averageBandwidth;
@property (nonatomic, readonly, assign) NSInteger programId;        // removed by draft 12
@property (nonatomic, readonly, copy) NSArray *codecs;
@property (nonatomic, readonly) MediaResoulution resolution;
@property (nonatomic, readonly, copy) NSString *audio;
@property (nonatomic, readonly, copy) NSString *video;
@property (nonatomic, readonly, copy) NSString *subtitles;
@property (nonatomic, readonly, copy) NSString *closedCaptions;
@property (nonatomic, readonly, copy) NSURL   *URI;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (NSURL *)m3u8URL; // the absolute url

- (NSString *)m3u8PlainString;

@end
