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
    FilterOptionTypeStylesheet,
    FilterOptionTypeObject,
    FilterOptionTypeXmlHttpRequest,
    FilterOptionTypeSubDocument,
    FilterOptionTypePing,
    FilterOptionTypeWebSocket,
    FilterOptionTypeWebRTC,
    FilterOptionTypeDocument,
    FilterOptionTypeElemHide,
    FilterOptionTypeGenericHide,
    FilterOptionTypeGenericBlock,
    FilterOptionTypePopup,
    FilterOptionTypeFont,
    FilterOptionTypeMedia,
    FilterOptionTypeOther,
    FilterOptionTypeMatchCase,
    FilterOptionTypeThirdParty,
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
    FilterTokenTypeTrigger,
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
    FilterTokenTypeAddress,
    FilterTokenTypeJSAPI,
    FilterTokenTypeJSAPIException,
    FilterTokenTypeElementCSSRule,
    FilterTokenTypeHtmlFilterScript,
    FilterTokenTypeHtmlFilterIframe
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
+ (instancetype)trigger:(NSString *)text;
+ (instancetype)options:(NSString *)text;
+ (instancetype)selectorElementHiding:(NSString *)selector;
+ (instancetype)selectorElementHidingEmulation:(NSString *)selector;
+ (instancetype)selectorElementHidingException:(NSString *)selector;
+ (instancetype)selectorElementSnippetFilter:(NSString *)selector;
+ (instancetype)elementCSSRule:(NSString *)cssRule;
+ (instancetype)ifDefineStart:(NSString *)condition;
+ (instancetype)ifDefineEnd;
+ (instancetype)info:(NSString *)text;
+ (instancetype)pipe;
+ (instancetype)address;
+ (instancetype)jsAPI:(NSString *)js;
+ (instancetype)jsAPIException:(NSString *)js;
+ (instancetype)htmlFilterScript:(NSString *)attributes;
+ (instancetype)htmlFilterIframe:(NSString *)attributes;

+ (NSString *)stringOfType:(FilterTokenType)type;
- (NSString *)toString;
@end

NS_ASSUME_NONNULL_END
