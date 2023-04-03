//
//  FilterToken.m
//  Stay
//
//  Created by ris on 2023/3/27.
//

#import "FilterToken.h"

@implementation FilterOptionDomain

@end

@implementation FilterOption

- (NSString *)description{
    return [NSString stringWithFormat:@"%@",[self stringOfType:self.type]];
}

- (NSString *)stringOfType:(FilterOptionType)type{
    if (type == FilterOptionTypeScript) return @"Script";
    else if (type == FilterOptionTypeImage) return @"Image";
    else if (type == FilterOptionTypeDomain) return @"Domain";
    else if (type == FilterOptionTypeGenericHide) return @"Generic Hide";
    else if (type == FilterOptionTypeUndefined) return @"Undefined";
    return @"";
}
@end

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
        
        if (filterOption.inverse){
            optionType = [optionType substringFromIndex:1];
        }
        
        if ([optionType hasPrefix:@"domain="]){
            filterOption.type = FilterOptionTypeDomain;
            filterOption.domains = [[NSMutableArray alloc] init];
            NSString *domains = [optionType substringFromIndex:[@"domain=" length]];
            NSArray<NSString *> *domainSplits = [domains componentsSeparatedByString:@"|"];
            for (NSUInteger i = 0; i < domainSplits.count; i++){
                NSString *domain = domainSplits[i];
                FilterOptionDomain *filterOptionDomain = [[FilterOptionDomain alloc] init];
                if ([domain hasPrefix:@"~"]){
                    filterOptionDomain.inverse = YES;
                }
                
                if (filterOptionDomain.inverse){
                    domain = [domain substringFromIndex:1];
                }
                
                filterOptionDomain.value = domain;
                [filterOption.domains addObject:filterOptionDomain];
            }
        }
        else if ([optionType isEqualToString:@"script"]){
            filterOption.type = FilterOptionTypeScript;
        }
        else if ([optionType isEqualToString:@"image"]){
            filterOption.type = FilterOptionTypeImage;
        }
        else if ([optionType isEqualToString:@"generichide"]){
            filterOption.type = FilterOptionTypeGenericHide;
        }
        else {
            filterOption.type = FilterOptionTypeUndefined;
        }
        
        [filterOptions addObject:filterOption];
    }
    options.value = array;
    return options;
}

+ (instancetype)selectorElementHiding:(NSString *)selector{
    FilterToken *selectorElementHiding = [[FilterToken alloc] init];
    selectorElementHiding.type = FilterTokenTypeSelectorElementHiding;
    selectorElementHiding.value = selector;
    return selectorElementHiding;
}

+ (instancetype)selectorElementHidingEmulation:(NSString *)selector{
    FilterToken *selectorElementHidingEmulation = [[FilterToken alloc] init];
    selectorElementHidingEmulation.type = FilterTokenTypeSelectorElementHidingEmulation;
    selectorElementHidingEmulation.value = selector;
    return selectorElementHidingEmulation;
}

+ (instancetype)selectorElementHidingException:(NSString *)selector{
    FilterToken *selectorElementHidingException = [[FilterToken alloc] init];
    selectorElementHidingException.type = FilterTokenTypeSelectorElementHidingException;
    selectorElementHidingException.value = selector;
    return selectorElementHidingException;
}

+ (instancetype)selectorElementSnippetFilter:(NSString *)selector{
    FilterToken *selectorElementSnippetFilter = [[FilterToken alloc] init];
    selectorElementSnippetFilter.type = FilterTokenTypeSelectorElementSnippetFilter;
    selectorElementSnippetFilter.value = selector;
    return selectorElementSnippetFilter;
}

+ (instancetype)ifDefineStart:(NSString *)condition{
    FilterToken *ifDefineStart = [[FilterToken alloc] init];
    ifDefineStart.type = FilterTokenTypeIfDefineStart;
    ifDefineStart.value = condition;
    return ifDefineStart;
}

+ (instancetype)ifDefineEnd{
    FilterToken *ifDefineEnd = [[FilterToken alloc] init];
    ifDefineEnd.type = FilterTokenTypeIfDefineEnd;
    return ifDefineEnd;
}

+ (instancetype)info:(NSString *)text{
    FilterToken *info = [[FilterToken alloc] init];
    info.type = FilterTokenTypeInfo;
    info.value = text;
    return info;
}

+ (instancetype)pipe{
    FilterToken *pipe = [[FilterToken alloc] init];
    pipe.type = FilterTokenTypePipe;
    pipe.value = @"|";
    return pipe;
}

+ (instancetype)address{
    FilterToken *address = [[FilterToken alloc] init];
    address.type = FilterTokenTypeAddress;
    address.value = @"||";
    return address;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"%@ %@",[self stringOfType:self.type],self.value];
}

- (NSString *)stringOfType:(FilterTokenType)type{
    if (type == FilterTokenTypeEOF) return @"EOF";
    else if (type == FilterTokenTypeUndefined) return @"Undfined";
    else if (type == FilterTokenTypeComment) return @"Comment";
    else if (type == FilterTokenTypeSpecialCommentHomepage) return @"Homepage";
    else if (type == FilterTokenTypeSpecialCommentTitle) return @"Title";
    else if (type == FilterTokenTypeSpecialCommentExpires) return @"Expires";
    else if (type == FilterTokenTypeSpecialCommentRedirect) return @"Redirect";
    else if (type == FilterTokenTypeSpecialCommentVersion) return @"Version";
    else if (type == FilterTokenTypeNewLine) return @"NewLine";
    else if (type == FilterTokenTypeException) return @"Exception";
    else if (type == FilterTokenTypeSeparator) return @"Separator";
    else if (type == FilterTokenTypeTigger) return @"Tigger";
    else if (type == FilterTokenTypeOptions) return @"Options";
    else if (type == FilterTokenTypeSelectorElementHiding) return @"Element Hiding";
    else if (type == FilterTokenTypeSelectorElementHidingEmulation) return @"Element Hiding Emulation";
    else if (type == FilterTokenTypeSelectorElementHidingException) return @"Element Hiding Exception";
    else if (type == FilterTokenTypeSelectorElementSnippetFilter) return @"Snippet Filter";
    else if (type == FilterTokenTypeIfDefineStart) return @"#IF";
    else if (type == FilterTokenTypeIfDefineEnd) return @"#ENDIF";
    else if (type == FilterTokenTypeInfo) return @"Info";
    else if (type == FilterTokenTypeAddress) return @"Address";
    else if (type == FilterTokenTypePipe) return @"Pipe";
    else return @"";
}

@end
