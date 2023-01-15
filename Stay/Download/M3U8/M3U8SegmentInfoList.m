//
//  M3U8SegmentInfoList.m
//  M3U8Kit
//
//  Created by Oneday on 13-1-11.
//  Copyright (c) 2013年 0day. All rights reserved.
//

#import "M3U8SegmentInfoList.h"

@interface M3U8SegmentInfoList ()

@property (nonatomic, strong) NSMutableArray *segmentInfoList;

@end

@implementation M3U8SegmentInfoList

- (id)init {
    if (self = [super init]) {
        self.segmentInfoList = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Getter && Setter
- (NSUInteger)count {
    return [self.segmentInfoList count];
}

#pragma mark - Public
- (void)addSegementInfo:(M3U8SegmentInfo *)segment {
    if (segment) {
        [self.segmentInfoList addObject:segment];
    }
}

- (M3U8SegmentInfo *)segmentInfoAtIndex:(NSUInteger)index {
    return [self.segmentInfoList objectAtIndex:index];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@", self.segmentInfoList];
}

@end
