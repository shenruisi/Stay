//
//  FilterToken.h
//  Stay
//
//  Created by ris on 2023/3/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FilterOptionDomain : NSObject
@property (nonatomic, assign) BOOL inverse;
@property (nonatomic, strong) NSString *value;
@end

typedef enum{
    FilterOptionTypeUndefined = 0,
    FilterOptionTypeScript,
    FilterOptionTypeImage,
    FilterOptionTypeDomain,
    FilterOptionTypeGenericHide
}FilterOptionType;

@interface FilterOption : NSObject

@property (nonatomic, assign) FilterOptionType type;
@property (nonatomic, assign) BOOL inverse;
@property (nonatomic, strong) NSMutableArray<FilterOptionDomain *> *domains;
@end

typedef enum{
    FilterTokenTypeEOF = -1,
    FilterTokenTypeUndefined = 0,
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
    FilterTokenTypeSelectorElementHiding,
    FilterTokenTypeSelectorElementHidingEmulation,
    FilterTokenTypeSelectorElementHidingException,
    FilterTokenTypeSelectorElementSnippetFilter,
    FilterTokenTypeIfDefineStart,
    FilterTokenTypeIfDefineEnd,
    FilterTokenTypeInfo,
    FilterTokenTypePipe,
    FilterTokenTypeAddress
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
+ (instancetype)selectorElementHiding:(NSString *)selector;
+ (instancetype)selectorElementHidingEmulation:(NSString *)selector;
+ (instancetype)selectorElementHidingException:(NSString *)selector;
+ (instancetype)selectorElementSnippetFilter:(NSString *)selector;
+ (instancetype)ifDefineStart:(NSString *)condition;
+ (instancetype)ifDefineEnd;
+ (instancetype)info:(NSString *)text;
+ (instancetype)pipe;
+ (instancetype)address;

- (NSString *)stringOfType:(FilterTokenType)type;
- (NSString *)toString;
@end

NS_ASSUME_NONNULL_END
