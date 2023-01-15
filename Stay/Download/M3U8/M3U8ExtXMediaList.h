//
//  M3U8ExtXMediaList.h
//  M3U8Kit
//
//  Created by Sun Jin on 3/25/14.
//  Copyright (c) 2014 Jin Sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M3U8ExtXMedia.h"

@interface M3U8ExtXMediaList : NSObject

@property (nonatomic, assign ,readonly) NSUInteger count;

- (void)addExtXMedia:(M3U8ExtXMedia *)extXMedia;
- (M3U8ExtXMedia *)xMediaAtIndex:(NSUInteger)index;
- (M3U8ExtXMedia *)firstExtXMedia;
- (M3U8ExtXMedia *)lastExtXMedia;

- (M3U8ExtXMediaList *)audioList;
- (M3U8ExtXMedia *)suitableAudio;

- (M3U8ExtXMediaList *)videoList;
- (M3U8ExtXMedia *)suitableVideo;

- (M3U8ExtXMediaList *)subtitleList;
- (M3U8ExtXMedia *)suitableSubtitle;

@end
