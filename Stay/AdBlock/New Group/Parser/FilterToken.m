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

+ (instancetype)undefined{
    FilterToken *undefined = [[FilterToken alloc] init];
    undefined.type = FilterTokenTypeUndefined;
    return undefined;
}

@end
