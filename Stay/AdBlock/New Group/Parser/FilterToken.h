//
//  FilterToken.h
//  Stay
//
//  Created by ris on 2023/3/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum{
    FilterOptionTypeScript,
    FilterOptionTypeImage,
}FilterOptionType;

@interface FilterOption : NSObject

@property (nonatomic, assign) FilterOptionType type;
@property (nonatomic, assign) BOOL inverse;

@end

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
    FilterTokenTypeNewLine,
    FilterTokenTypeException,
    FilterTokenTypeSeparator,
    FilterTokenTypeTigger,
    FilterTokenTypeOptions,
    FilterTokenTypeDomain,
} FilterTokenType;

@interface FilterToken : NSObject

@property (nonatomic, assign) FilterTokenType type;
@property (nonatomic, strong) id value;
+ (instancetype)eof;
+ (instancetype)newLine;
+ (instancetype)undefined:(NSString *)text;
+ (instancetype)comment:(NSString *)text;
+ (instancetype)specialCommentHomePage:(NSString *)text;
+ (instancetype)specialCommentTitle:(NSString *)text;
+ (instancetype)specialCommentExpires:(NSString *)text;
+ (instancetype)specialCommentRedirect:(NSString *)text;
+ (instancetype)specialCommentVersion:(NSString *)text;
+ (instancetype)exception;
+ (instancetype)separator;
+ (instancetype)tigger:(NSString *)text;
+ (instancetype)options:(NSArray<NSString *> *)array;
@end

NS_ASSUME_NONNULL_END
