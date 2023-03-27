//
//  FilterTokenParser.m
//  Stay
//
//  Created by ris on 2023/3/27.
//

#import "FilterTokenParser.h"

static NSString *__EOF__ = @"__EOF__";

// https://help.adblockplus.org/hc/en-us/articles/360062733293
// https://adguard.com/kb/general/ad-filtering/create-own-filters/
@interface FilterTokenParser()

@property (nonatomic, strong) NSMutableString *opaqueChars;
@property (nonatomic, assign) NSInteger moveIndex;
@property (nonatomic, copy) NSString *lastChars;
@property (nonatomic, strong) FilterToken *opaqueCurToken;
@end

@implementation FilterTokenParser

- (instancetype)initWithChars:(NSString *)chars{
    if (self = [super init]){
        self.opaqueChars = [[NSMutableString alloc] initWithString:chars];
        self.moveIndex = -1;
    }
    
    return self;
}

- (NSString *)getChars{
    self.moveIndex++;
    if (self.moveIndex >= self.opaqueChars.length){
        return __EOF__;
    }
    
    return  [self.opaqueChars substringWithRange:NSMakeRange(self.moveIndex, 1)];
}

- (void)nextToken{
    self.opaqueCurToken = [self getTok];
}


- (FilterToken *)getTok{
    self.lastChars = [self getChars];
    
    if ([self isEOF:self.lastChars]){
        
    }
    
    return [FilterToken ]
}

- (BOOL)isEOF:(NSString *)chars{
    return [chars isEqualToString:__EOF__];
}

@end
