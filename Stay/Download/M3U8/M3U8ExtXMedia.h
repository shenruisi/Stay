//
//  M3U8ExtXMedia.h
//  M3U8Kit
//
//  Created by Sun Jin on 3/25/14.
//  Copyright (c) 2014 Jin Sun. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 
 /// EXT-X-MEDIA
 
 @format    #EXT-X-MEDIA:<attribute-list> ,  attibute-list: ATTR=<value>,...
 @example   #EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="600k",LANGUAGE="eng",NAME="Audio",AUTOSELECT=YES,DEFAULT=YES,URI="/talks/769/audio/600k.m3u8?sponsor=Ripple",BANDWIDTH=614400
 
#define M3U8_EXT_X_MEDIA                    @"#EXT-X-MEDIA:"
//  EXT-X-MEDIA attributes
#define M3U8_EXT_X_MEDIA_TYPE               @"TYPE" // The value is enumerated-string; valid strings are AUDIO, VIDEO, SUBTITLES and CLOSED-CAPTIONS.
#define M3U8_EXT_X_MEDIA_URI                @"URI"  // The value is a quoted-string containing a URI that identifies the Playlist file.
#define M3U8_EXT_X_MEDIA_GROUP_ID           @"GROUP-ID" // The value is a quoted-string identifying a mutually-exclusive group of renditions.
#define M3U8_EXT_X_MEDIA_LANGUAGE           @"LANGUAGE" // The value is a quoted-string containing an RFC 5646 [RFC5646] language tag that identifies the primary language used in the rendition.
#define M3U8_EXT_X_MEDIA_ASSOC_LANGUAGE     @"ASSOC-LANGUAGE"   // The value is a quoted-string containing an RFC 5646 [RFC5646](http://tools.ietf.org/html/rfc5646) language tag that identifies a language that is associated with the rendition.
#define M3U8_EXT_X_MEDIA_NAME               @"NAME" // The value is a quoted-string containing a human-readable description of the rendition.
#define M3U8_EXT_X_MEDIA_DEFAULT            @"DEFAULT" // The value is an enumerated-string; valid strings are YES and NO.
#define M3U8_EXT_X_MEDIA_AUTOSELECT         @"AUTOSELECT" // The value is an enumerated-string; valid strings are YES and NO.
#define M3U8_EXT_X_MEDIA_FORCED             @"FORCED"   // The value is an enumerated-string; valid strings are YES and NO.
#define M3U8_EXT_X_MEDIA_INSTREAM_ID        @"INSTREAM-ID" // The value is a quoted-string that specifies a rendition within the segments in the Media Playlist.
#define M3U8_EXT_X_MEDIA_CHARACTERISTICS    @"CHARACTERISTICS" // The value is a quoted-string containing one or more Uniform Type Identifiers [UTI] separated by comma (,) characters.
 
 */

@interface M3U8ExtXMedia : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (NSString *)type;
- (NSURL *)URI;
- (NSString *)groupId;
- (NSString *)language;
- (NSString *)assocLanguage;
- (NSString *)name;
- (BOOL)isDefault;
- (BOOL)autoSelect;
- (BOOL)forced;
- (NSString *)instreamId;
- (NSString *)characteristics;
- (NSInteger)bandwidth;

- (NSURL *)m3u8URL;   // the absolute url of media playlist file
- (NSString *)m3u8PlainString;

@end
