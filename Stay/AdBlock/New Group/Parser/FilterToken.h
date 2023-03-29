//
//  FilterToken.h
//  Stay
//
//  Created by ris on 2023/3/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum{
    FilterTokenTypeEOF = -1,
    FilterTokenTypeUndefined = 0,
    FilterTokenTypeUrl = 1,
    FilterTokenTypeComment,
    FilterTokenTypeSpecialCommentHomepage,
    FilterTokenTypeSpecialCommentTitle,
    FilterTokenTypeSpecialCommentExpires,
    FilterTokenTypeSpecialCommentRedirect,
    FilterTokenTypeSpecialCommentVersion,
    FilterTokenTypeNewLine
} FilterTokenType;

@interface FilterToken : NSObject

@property (nonatomic, assign) FilterTokenType type;
@property (nonatomic, strong) id value;
+ (instancetype)eof;
+ (instancetype)newLine;
+ (instancetype)undefined:(NSString *)text;
@end

NS_ASSUME_NONNULL_END
