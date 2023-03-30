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
@property (nonatomic, strong) FilterToken *prevToken;
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
    
}

- (void)nextToken{
    self.opaqueCurToken = [self getTok];
    self.prevToken = self.opaqueCurToken;
}

- (FilterToken *)getTok{
    self.lastChars = [self getChars];
    
    if ([self isEOF:self.lastChars]){
        return [FilterToken eof];
    }
    
    if ([self isNewLine:self.lastChars]){
        return [FilterToken newLine];
    }
    
    if (self.prevToken.type == FilterTokenTypeNewLine && [self isExceptionStart:self.lastChars]){
        if ([self isExceptionStart:(self.lastChars = [self getChars])]){
            return [FilterToken exception];
        }
        else{
            [self backward];
            return [FilterToken undefined:self.lastChars];
        }
    }
    
    if ([self isSeparator:self.lastChars]){
        return [FilterToken separator];
    }
    
    if ([self isOptionsStart:self.lastChars]){
        NSMutableString *options = [[NSMutableString alloc] init];
        while(![self isEnd:(self.lastChars = [self getChars])]){
            [options appendString:self.lastChars];
        }
        
        [self backward];
        return [FilterToken options:[options componentsSeparatedByString:@","]];
    }
    
    if ([self isCommentStart:self.lastChars]){
        NSMutableString *comment = [[NSMutableString alloc] init];
        while(![self isEnd:(self.lastChars = [self getChars])]){
            [comment appendString:self.lastChars];
        }
        
        [self backward];
        
        NSArray<NSString *> *captured = [self specialCommentCapture:comment];
        if (captured.count == 2){
            if ([captured[0] isEqualToString:@"Homepage"]){
                return [FilterToken specialCommentHomePage:captured[1]];
            }
            else if ([captured[0] isEqualToString:@"Title"]){
                return [FilterToken specialCommentTitle:captured[1]];
            }
            else if ([captured[0] isEqualToString:@"Expires"]){
                return [FilterToken specialCommentExpires:captured[1]];
            }
            else if ([captured[0] isEqualToString:@"Redirect"]){
                return [FilterToken specialCommentRedirect:captured[1]];
            }
            else if ([captured[0] isEqualToString:@"Version"]){
                return [FilterToken specialCommentVersion:captured[1]];
            }
        }
        else{
            return [FilterToken comment:comment];
        }
    }
    
    NSMutableString *tigger = [[NSMutableString alloc] init];
    do{
        [tigger appendString:self.lastChars];
        self.lastChars = [self getChars];
    }while(![self isNewLine:self.lastChars]
           && ![self isSeparator:self.lastChars]
           && ![self isOptionsStart:self.lastChars]);
    
    [self backward];
    return [FilterToken tigger:tigger];
    
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

- (BOOL)isOptionsStart:(NSString *)chars{
    return [chars isEqualToString:@"$"];
}

- (BOOL)isSeparator:(NSString *)chars{
    return [chars isEqualToString:@"^"];
}

- (BOOL)isExceptionStart:(NSString *)chars{
    return [chars isEqualToString:@"@"];
}

- (BOOL)isNewLine:(NSString *)chars{
    return [chars isEqualToString:@"\n"];
}

- (BOOL)isEnd:(NSString *)chars{
    return [self isNewLine:chars] || [self isEOF:chars];
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
