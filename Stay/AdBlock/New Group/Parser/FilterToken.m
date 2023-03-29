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


@end
