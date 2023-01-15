//
//  M3U8ExtXByteRange.h
//  M3U8Kit
//
//  Created by Frank on 2020/10/1.
//  Copyright © 2020 M3U8Kit. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface M3U8ExtXByteRange : NSObject

- (instancetype)initWithAtString:(NSString *)atString;
- (instancetype)initWithLength:(NSInteger)length offset:(NSInteger)offset;

@property (nonatomic, assign, readonly) NSInteger length;
@property (nonatomic, assign, readonly) NSInteger offset;

@end

NS_ASSUME_NONNULL_END
