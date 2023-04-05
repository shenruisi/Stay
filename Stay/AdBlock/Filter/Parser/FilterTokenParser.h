//
//  FilterTokenParser.h
//  Stay
//
//  Created by ris on 2023/3/27.
//

#import <Foundation/Foundation.h>
#import "FilterToken.h"

NS_ASSUME_NONNULL_BEGIN

@interface FilterTokenParser : NSObject

@property (nonatomic, readonly) FilterToken *curToken;
@property (nonatomic, readonly) BOOL isEOF;
@property (nonatomic, readonly) BOOL isSepcialComment;

- (instancetype)initWithChars:(NSString *)chars;

- (void)nextToken;
- (void)backward;
@end

NS_ASSUME_NONNULL_END
