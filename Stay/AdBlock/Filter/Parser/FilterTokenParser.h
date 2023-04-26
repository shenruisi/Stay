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
@property (nonatomic, readonly) BOOL isComment;
@property (nonatomic, readonly) BOOL isInfo;
@property (nonatomic, readonly) BOOL isTrigger;
@property (nonatomic, readonly) BOOL isException;
@property (nonatomic, readonly) BOOL isAddress;
@property (nonatomic, readonly) BOOL isOptions;
@property (nonatomic, readonly) BOOL isSelector;
@property (nonatomic, readonly) BOOL isNewLine;
@property (nonatomic, readonly) BOOL isSeparator;
@property (nonatomic, readonly) BOOL isPipe;

- (instancetype)initWithChars:(NSString *)chars;

- (void)nextToken;
- (void)backward;
@end

NS_ASSUME_NONNULL_END
