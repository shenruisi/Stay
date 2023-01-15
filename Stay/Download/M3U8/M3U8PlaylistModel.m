//
//  M3U8Parser.m
//  M3U8Kit
//
//  Created by Oneday on 13-1-11.
//  Copyright (c) 2013年 0day. All rights reserved.
//

#import "M3U8PlaylistModel.h"
#import "NSString+m3u8.h"
#import "NSURL+m3u8.h"

#define INDEX_PLAYLIST_NAME @"index.m3u8"

#define PREFIX_MAIN_MEDIA_PLAYLIST @"main_media_"
#define PREFIX_AUDIO_PLAYLIST @"x_media_audio_"
#define PREFIX_SUBTITLES_PLAYLIST @"x_media_subtitles_"

@interface M3U8PlaylistModel()

@property (nonatomic, copy) NSURL *baseURL;
@property (nonatomic, copy) NSURL *originalURL;

@property (nonatomic, strong) M3U8MasterPlaylist *masterPlaylist;

@property (nonatomic, strong) M3U8ExtXStreamInf *currentXStreamInf;

@property (nonatomic, strong) M3U8MediaPlaylist *mainMediaPl;
@property (nonatomic, strong) M3U8MediaPlaylist *audioPl;
//@property (nonatomic, strong) M3U8MediaPlaylist *subtitlePl;

@end

@implementation M3U8PlaylistModel

- (id)initWithURL:(NSURL *)URL error:(NSError **)error {
    
    NSString *str = [[NSString alloc] initWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:error];
    if (*error) {
        return nil;
    }
    
    self.originalURL = URL;
    
    return [self initWithString:str baseURL:URL.m3u_realBaseURL error:error];
}

- (id)initWithString:(NSString *)string baseURL:(NSURL *)baseURL error:(NSError **)error {
    return [self initWithString:string originalURL:nil baseURL:baseURL error:error];
}

- (id)initWithString:(NSString *)string originalURL:(NSURL *)originalURL
             baseURL:(NSURL *)baseURL error:(NSError * *)error {

    if (!string.m3u_isExtendedM3Ufile) {
        *error = [NSError errorWithDomain:@"M3U8PlaylistModel" code:-998 userInfo:@{NSLocalizedDescriptionKey:@"The content is not a m3u8 playlist"}];
        return nil;
    }
    
    if (self = [super init]) {
        if (string.m3u_isMasterPlaylist) {
            self.originalURL = originalURL;
            self.baseURL = baseURL;
            self.masterPlaylist = [[M3U8MasterPlaylist alloc] initWithContent:string baseURL:baseURL];
            self.masterPlaylist.name = INDEX_PLAYLIST_NAME;
            self.currentXStreamInf = self.masterPlaylist.xStreamList.firstStreamInf;
            if (self.currentXStreamInf) {
                NSError *ero;
                NSURL *m3u8URL = self.currentXStreamInf.m3u8URL;
                self.mainMediaPl = [[M3U8MediaPlaylist alloc] initWithContentOfURL:m3u8URL type:M3U8MediaPlaylistTypeMedia error:&ero];
                self.mainMediaPl.name = [NSString stringWithFormat:@"%@0.m3u8", PREFIX_MAIN_MEDIA_PLAYLIST];
                if (ero) {
                    NSLog(@"Get main media playlist failed, error: %@", ero);
                }
            }
            
            // get audioPl
            M3U8ExtXStreamInfList *list = self.masterPlaylist.xStreamList;
            if (list.count > 1) {
                for (int i = 0; i < list.count; i++) {
                    M3U8ExtXStreamInf *xsinf = [list xStreamInfAtIndex:i];
                    if (xsinf.codecs.count == 1 && [xsinf.codecs.firstObject hasPrefix:@"mp4a"]) {
                        NSURL *audioURL = xsinf.m3u8URL;
                        self.audioPl = [[M3U8MediaPlaylist alloc] initWithContentOfURL:audioURL type:M3U8MediaPlaylistTypeAudio error:NULL];
                        self.audioPl.name = [NSString stringWithFormat:@"%@%d.m3u8", PREFIX_MAIN_MEDIA_PLAYLIST, i];
                        break;
                    }
                }
            }
            
        } else if (string.m3u_isMediaPlaylist) {
            self.mainMediaPl = [[M3U8MediaPlaylist alloc] initWithContent:string type:M3U8MediaPlaylistTypeMedia baseURL:baseURL];
            self.mainMediaPl.name = INDEX_PLAYLIST_NAME;
        }
    }
    return self;
}

- (NSSet *)allAlternativeURLStrings {
    NSMutableSet *allAlternativeURLStrings = [NSMutableSet set];
    M3U8ExtXStreamInfList *xsilist = self.masterPlaylist.alternativeXStreamInfList;
    for (int index = 0; index < xsilist.count; index ++) {
        M3U8ExtXStreamInf *xsinf = [xsilist xStreamInfAtIndex:index];
        [allAlternativeURLStrings addObject:xsinf.m3u8URL];
    }
    
    return allAlternativeURLStrings;
}

- (void)specifyVideoURL:(NSURL *)URL completion:(void (^)(BOOL))completion {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        BOOL success = NO;
        
        if (URL.absoluteString.length > 0
            && nil != self.masterPlaylist
            && [self.allAlternativeURLStrings containsObject:URL]) {
            
            if ([URL.absoluteString isEqualToString:self.mainMediaPl.originalURL.absoluteString]) {
                success = YES;
            } else {
                NSError *error;
                M3U8MediaPlaylist *pl = [[M3U8MediaPlaylist alloc] initWithContentOfURL:URL type:M3U8MediaPlaylistTypeMedia error:&error];
                if (pl) {
                    self.mainMediaPl = pl;
                    M3U8ExtXStreamInfList *list = self.masterPlaylist.xStreamList;
                    if (list.count > 1) {
                        for (int i = 0; i < list.count; i++) {
                            M3U8ExtXStreamInf *xsinf = [list xStreamInfAtIndex:i];
                            if ([xsinf.m3u8URL.absoluteString isEqualToString:pl.originalURL.absoluteString]) {
                                pl.name = [NSString stringWithFormat:@"%@%d.m3u8", PREFIX_MAIN_MEDIA_PLAYLIST, i];
                                break;
                            }
                        }
                    }
                    success = YES;
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(success);
            }
        });
    });
}

- (void)changeMainMediaPlWithPlaylist:(M3U8MediaPlaylist *)playlist {
    if (playlist
        && playlist.type == M3U8MediaPlaylistTypeMedia
        && [[self allAlternativeURLStrings] containsObject:playlist.baseURL]) {
        
        self.mainMediaPl = playlist;
        M3U8ExtXStreamInfList *list = self.masterPlaylist.xStreamList;
        if (list.count > 1) {
            for (int i = 0; i < list.count; i++) {
                M3U8ExtXStreamInf *xsinf = [list xStreamInfAtIndex:i];
                if ([xsinf.m3u8URL.absoluteString isEqualToString:playlist.originalURL.absoluteString]) {
                    playlist.name = [NSString stringWithFormat:@"%@%d.m3u8", PREFIX_MAIN_MEDIA_PLAYLIST, i];
                    break;
                }
            }
        }
    }
}

- (NSString *)prefixOfSegmentNameInPlaylist:(M3U8MediaPlaylist *)playlist {
    NSString *prefix = nil;
    
    switch (playlist.type) {
        case M3U8MediaPlaylistTypeMedia:
            prefix = @"media_";
            break;
        case M3U8MediaPlaylistTypeAudio:
            prefix = @"audio_";
            break;
        case M3U8MediaPlaylistTypeSubtitle:
            prefix = @"subtitle_";
            break;
        case M3U8MediaPlaylistTypeVideo:
            prefix = @"video_";
            break;
            
        default:
            return @"";
            break;
    }
    return prefix;
}

- (NSString *)sufixOfSegmentNameInPlaylist:(M3U8MediaPlaylist *)playlist {
    NSString *prefix = nil;
    
    switch (playlist.type) {
        case M3U8MediaPlaylistTypeMedia:
        case M3U8MediaPlaylistTypeVideo:
            prefix = @"ts";
            break;
        case M3U8MediaPlaylistTypeAudio:
            prefix = @"aac";
            break;
        case M3U8MediaPlaylistTypeSubtitle:
            prefix = @"vtt";
            break;
            
        default:
            return @"";
            break;
    }
    return prefix;
}

- (NSArray *)segmentNamesForPlaylist:(M3U8MediaPlaylist *)playlist {
    
    NSString *prefix = [self prefixOfSegmentNameInPlaylist:playlist];
    NSString *sufix = [self sufixOfSegmentNameInPlaylist:playlist];
    NSMutableArray *names = [NSMutableArray array];
    
    NSArray *URLs = playlist.allSegmentURLs;
    NSUInteger count = playlist.segmentList.count;
    NSUInteger index = 0;
    for (int i = 0; i < count; i ++) {
        M3U8SegmentInfo *inf = [playlist.segmentList segmentInfoAtIndex:i];
        index = [URLs indexOfObject:inf.mediaURL];
        NSString *n = [NSString stringWithFormat:@"%@%lu.%@", prefix, (unsigned long)index, sufix];
        [names addObject:n];
    }
    return names;
}

- (void)savePlaylistsToPath:(NSString *)path error:(NSError **)error {
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        if (NO == [[NSFileManager defaultManager] removeItemAtPath:path error:error]) {
            return;
        }
    }
    if (NO == [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:error]) {
        return;
    }
    
    if (self.masterPlaylist) {
        
        // master playlist
        NSString *masterContext = self.masterPlaylist.m3u8PlainString;
        for (int i = 0; i < self.masterPlaylist.xStreamList.count; i ++) {
            M3U8ExtXStreamInf *xsinf = [self.masterPlaylist.xStreamList xStreamInfAtIndex:i];
            NSString *name = [NSString stringWithFormat:@"%@%d.m3u8", PREFIX_MAIN_MEDIA_PLAYLIST, i];
            masterContext = [masterContext stringByReplacingOccurrencesOfString:xsinf.URI.absoluteString withString:name];
        }
        NSString *mPath = [path stringByAppendingPathComponent:self.indexPlaylistName];
        BOOL success = [masterContext writeToFile:mPath atomically:YES encoding:NSUTF8StringEncoding error:error];
        if (NO == success) {
            NSLog(@"M3U8Kit Error: failed to save master playlist to file. error: %@", error?*error:@"null");
            return;
        }
        
        // main media playlist
        [self saveMediaPlaylist:self.mainMediaPl toPath:path error:error];
        [self saveMediaPlaylist:self.audioPl toPath:path error:error];
        
    } else {
        [self saveMediaPlaylist:self.mainMediaPl toPath:path error:error];
    }
}

- (void)saveMediaPlaylist:(M3U8MediaPlaylist *)playlist toPath:(NSString *)path error:(NSError **)error {
    if (nil == playlist) {
        return;
    }
    NSString *mainMediaPlContext = playlist.originalText;
    if (mainMediaPlContext.length == 0) {
        return;
    }
    
    NSArray *names = [self segmentNamesForPlaylist:playlist];
    for (int i = 0; i < playlist.segmentList.count; i ++) {
        M3U8SegmentInfo *sinfo = [playlist.segmentList segmentInfoAtIndex:i];
        mainMediaPlContext = [mainMediaPlContext stringByReplacingOccurrencesOfString:sinfo.URI.absoluteString withString:names[i]];
    }
    NSString *mainMediaPlPath = [path stringByAppendingPathComponent:playlist.name];
    BOOL success = [mainMediaPlContext writeToFile:mainMediaPlPath atomically:YES encoding:NSUTF8StringEncoding error:error];
    if (NO == success) {
        if (NULL != error) {
            NSLog(@"M3U8Kit Error: failed to save mian media playlist to file. error: %@", *error);
        }
        return;
    }
}

- (NSString *)indexPlaylistName {
    return INDEX_PLAYLIST_NAME;
}

@end
