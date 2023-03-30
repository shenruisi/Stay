//
//  FilterToken.m
//  Stay
//
//  Created by ris on 2023/3/27.
//

#import "FilterToken.h"

@implementation FilterToken

+ (instancetype)eof{
    FilterToken *eof = [[FilterToken alloc] init];
    eof.type = FilterTokenTypeEOF;
    return eof;
}

+ (instancetype)newLine{
    FilterToken *newLine = [[FilterToken alloc] init];
    newLine.type = FilterTokenTypeNewLine;
    return newLine;
}

+ (instancetype)undefined:(NSString *)text{
    FilterToken *undefined = [[FilterToken alloc] init];
    undefined.type = FilterTokenTypeUndefined;
    undefined.value = text;
    return undefined;
}

+ (instancetype)comment:(NSString *)text{
    FilterToken *comment = [[FilterToken alloc] init];
    comment.type = FilterTokenTypeComment;
    comment.value = text;
    return comment;
}

+ (instancetype)specialCommentHomePage:(NSString *)text{
    FilterToken *homePage = [[FilterToken alloc] init];
    homePage.type = FilterTokenTypeSpecialCommentHomepage;
    homePage.value = text;
    return homePage;
}

+ (instancetype)specialCommentTitle:(NSString *)text{
    FilterToken *title = [[FilterToken alloc] init];
    title.type = FilterTokenTypeSpecialCommentTitle;
    title.value = text;
    return title;
}

+ (instancetype)specialCommentExpires:(NSString *)text{
    FilterToken *expires = [[FilterToken alloc] init];
    expires.type = FilterTokenTypeSpecialCommentExpires;
    expires.value = text;
    return expires;
}

+ (instancetype)specialCommentRedirect:(NSString *)text{
    FilterToken *redirect = [[FilterToken alloc] init];
    redirect.type = FilterTokenTypeSpecialCommentRedirect;
    redirect.value = text;
    return redirect;
}

+ (instancetype)specialCommentVersion:(NSString *)text{
    FilterToken *version = [[FilterToken alloc] init];
    version.type = FilterTokenTypeSpecialCommentVersion;
    version.value = text;
    return version;
}

+ (instancetype)exception{
    FilterToken *exception = [[FilterToken alloc] init];
    exception.type = FilterTokenTypeException;
    exception.value = @"@@";
    return exception;
}

+ (instancetype)separator{
    FilterToken *separator = [[FilterToken alloc] init];
    separator.type = FilterTokenTypeSeparator;
    separator.value = @"^";
    return separator;
}

+ (instancetype)tigger:(NSString *)text{
    FilterToken *tigger = [[FilterToken alloc] init];
    tigger.type = FilterTokenTypeTigger;
    tigger.value = text;
    return tigger;
}

+ (instancetype)options:(NSArray<NSString *> *)array{
    FilterToken *options = [[FilterToken alloc] init];
    options.type = FilterTokenTypeOptions;
    NSMutableArray<FilterOption *> *filterOptions = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < array.count; i++){
        NSString *optionType = array[i];
        FilterOption *filterOption = [[FilterOption alloc] init];
        if ([optionType hasPrefix:@"~"]){
            filterOption.inverse = YES;
        }
        
        optionType = [optionType substringFromIndex:1];
        if ([optionType hasPrefix:@"domain="]){
//            filterOption.type = 
        }
        else if ([optionType isEqualToString:@"script"]){
            
        }
        else if ([optionType isEqualToString:@"image"]){
            
        }
    }
    options.value = array;
    return options;
}

@end
