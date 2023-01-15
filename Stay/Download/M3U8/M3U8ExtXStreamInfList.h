//
//  M3U8ExtXStreamInfList.h
//  ILSLoader
//
//  Created by Jin Sun on 13-4-15.
//  Copyright (c) 2013年 iLegendSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M3U8ExtXStreamInf.h"

@interface M3U8ExtXStreamInfList : NSObject

@property (nonatomic, assign ,readonly) NSUInteger count;

- (void)addExtXStreamInf:(M3U8ExtXStreamInf *)extStreamInf;
- (M3U8ExtXStreamInf *)xStreamInfAtIndex:(NSUInteger)index;
- (M3U8ExtXStreamInf *)firstStreamInf;
- (M3U8ExtXStreamInf *)lastXStreamInf;

- (void)sortByBandwidthInOrder:(NSComparisonResult)order;

@end
