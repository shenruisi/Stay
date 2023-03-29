//
//  FilterTokenParser.m
//  Stay
//
//  Created by ris on 2023/3/27.
//

#import "FilterTokenParser.h"

static NSString *__EOF__ = @"__EOF__";
static NSString *SPECIAL_COMMENT = @"(\\s*Homepage|Title|Expires|Redirect|Version):(\\s*.*)";

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

- (void)backward{
    self.moveIndex--;
    self.opaqueCurToken = [FilterToken undefined:@""];
}

- (void)nextToken{
    self.opaqueCurToken = [self getTok];
}

- (FilterToken *)getTok{
    self.lastChars = [self getChars];
    
    if ([self isEOF:self.lastChars]){
        return [FilterToken eof];
    }
    
    if ([self isNewLine:self.lastChars]){
        return [FilterToken newLine];
    }
    
    if ([self isCommentStart:self.lastChars]){
        NSMutableString *comment = [[NSMutableString alloc] init];
        while(![self isNewLine:(self.lastChars = [self getChars])]){
            [comment appendString:self.lastChars];
        }
        
        
    }
    
    return [FilterToken undefined:self.lastChars];
}

- (NSArray<NSString *> *)specialCommentCapture:(NSString *)comment{
    NSMutableArray<NSString *> *ret = [[NSMutableArray alloc] init];
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:SPECIAL_COMMENT options:0 error:nil];
    if (regex){
        NSArray<NSTextCheckingResult *> *matches = [regex matchesInString:comment options:0 range:NSMakeRange(0, comment.length)];
        if (matches.count > 0){
            for (NSTextCheckingResult *match in matches) {
                for (NSUInteger i = 1; i < [match numberOfRanges]; i++) {
                    NSRange groupRange = [match rangeAtIndex:i];
                    [ret addObject:[comment substringWithRange:groupRange]];
                }
            }
        }
    }
    
    return ret;
}

- (BOOL)isNewLine:(NSString *)chars{
    return [chars isEqualToString:@"\n"];
}

- (BOOL)isCommentStart:(NSString *)chars{
    return [chars isEqualToString:@"!"];
}

- (BOOL)isEOF{
    return self.opaqueCurToken.type == FilterTokenTypeEOF;
}

- (BOOL)isEOF:(NSString *)chars{
    return [chars isEqualToString:__EOF__];
}

@end
