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
// https://developer.apple.com/documentation/safariservices/creating_a_content_blocker?language=objc
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


- (NSString *)probGetChars:(NSUInteger)length{
    if (self.moveIndex + 1 + length >= self.opaqueChars.length){
        return nil;
    }
    
    return [self.opaqueChars substringWithRange:NSMakeRange(self.moveIndex + 1, length)];
}

- (void)forward:(NSUInteger)length{
    self.moveIndex += length;
}

- (void)backward{
    self.moveIndex--;
    
}

- (void)nextToken{
    self.opaqueCurToken = [self getTok];
    self.prevToken = self.opaqueCurToken;
}

- (FilterToken *)curToken{
    return self.opaqueCurToken;
}

- (FilterToken *)getTok{
    self.lastChars = [self getChars];
    
    if ([self isEOF:self.lastChars]){
        return [FilterToken eof];
    }
    
    if ([self isNewLine:self.lastChars]){
        return [FilterToken newLine];
    }
    
    if ([self isExceptionStart:self.lastChars]){
        if ([self isExceptionStart:(self.lastChars = [self getChars])]){
            return [FilterToken exception];
        }
        else{
            [self backward];
            return [FilterToken undefined:self.lastChars];
        }
    }
    
    if ([self isPipe:self.lastChars]){
        NSString *probChars = [self probGetChars:1];
        if ([probChars isEqualToString:@"|"]){
            [self forward:1];
            return [FilterToken address];
        }
        else{
            return [FilterToken pipe];
        }
    }
    
    if ([self isSquareBracketsStart:self.lastChars]){
        NSMutableString *info = [[NSMutableString alloc] init];
        do{
            [info appendString:self.lastChars];
            self.lastChars = [self getChars];
        }while(![self isEnd:self.lastChars] && ![self isSquareBracketsEnd:self.lastChars]);
        
        if ([self isSquareBracketsEnd:self.lastChars]){
            [info appendString:self.lastChars];
            return [FilterToken info:info];
        }
        else{
            [self backward];
            return [FilterToken undefined:info];
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
    
    if ([self isSelectorStart:self.lastChars]){
        self.lastChars = [self getChars];
        if ([self.lastChars isEqualToString:@"#"]){
            NSMutableString *selector = [[NSMutableString alloc] init];
            while([self isEnd:(self.lastChars = [self getChars])]){
                [selector appendString:self.lastChars];
            }
            [self backward];
            return [FilterToken selectorElementHiding:selector];
        }
        else if ([self.lastChars isEqualToString:@"?"]){
            self.lastChars = [self getChars];
            if ([self.lastChars isEqualToString:@"#"]){
                NSMutableString *selector = [[NSMutableString alloc] init];
                while([self isEnd:(self.lastChars = [self getChars])]){
                    [selector appendString:self.lastChars];
                }
                [self backward];
                return [FilterToken selectorElementHidingEmulation:selector];
            }
            else{
                [self backward];
                return [FilterToken undefined:@"#?"];
            }
        }
        else if ([self.lastChars isEqualToString:@"@"]){
            self.lastChars = [self getChars];
            if ([self.lastChars isEqualToString:@"#"]){
                NSMutableString *selector = [[NSMutableString alloc] init];
                while([self isEnd:(self.lastChars = [self getChars])]){
                    [selector appendString:self.lastChars];
                }
                [self backward];
                return [FilterToken selectorElementHidingException:selector];
            }
            else{
                [self backward];
                return [FilterToken undefined:@"#@"];
            }
        }
        else if ([self.lastChars isEqualToString:@"$"]){
            self.lastChars = [self getChars];
            if ([self.lastChars isEqualToString:@"#"]){
                NSMutableString *selector = [[NSMutableString alloc] init];
                while([self isEnd:(self.lastChars = [self getChars])]){
                    [selector appendString:self.lastChars];
                }
                [self backward];
                return [FilterToken selectorElementSnippetFilter:selector];
            }
            else{
                [self backward];
                return [FilterToken undefined:@"#$"];
            }
        }
        else{
            [self backward];
            return [FilterToken undefined:self.lastChars];
        }
    }
    
    if ([self isCommentStart:self.lastChars]){
        NSString *probChars1 = [self probGetChars:3];
        NSString *probChars2 = [self probGetChars:6];
        if ([probChars1 isEqualToString:@"#if"]){
            [self forward:3];
            NSMutableString *condition = [[NSMutableString alloc] init];
            while([self isEnd:(self.lastChars = [self getChars])]){
                [condition appendString:self.lastChars];
            }
            [self backward];
            return [FilterToken ifDefineStart:condition];
        }
        else if ([probChars2 isEqualToString:@"#endif"]){
            [self forward:6];
            return [FilterToken ifDefineEnd];
        }
        else{
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
    }
    
    NSMutableString *tigger = [[NSMutableString alloc] init];
    do{
        [tigger appendString:self.lastChars];
        self.lastChars = [self getChars];
    }while(![self isEnd:self.lastChars]
           && ![self isSeparator:self.lastChars]
           && ![self isOptionsStart:self.lastChars]
           && ![self isSelectorStart:self.lastChars]
           && ![self isPipe:self.lastChars]);
    
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

- (BOOL)isPipe:(NSString *)chars{
    return [chars isEqualToString:@"|"];
}

- (BOOL)isSquareBracketsStart:(NSString *)chars{
    return [chars isEqualToString:@"["];
}

- (BOOL)isSquareBracketsEnd:(NSString *)chars{
    return [chars isEqualToString:@"]"];
}

- (BOOL)isSelectorStart:(NSString *)chars{
    return [chars isEqualToString:@"#"];
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

- (BOOL)isDefineStart:(NSString *)chars{
    return [chars isEqualToString:@"#"];
}

- (BOOL)isEOF{
    return self.opaqueCurToken.type == FilterTokenTypeEOF;
}

- (BOOL)isEOF:(NSString *)chars{
    return [chars isEqualToString:__EOF__];
}

- (BOOL)isSepcialComment{
    return self.opaqueCurToken.type == FilterTokenTypeSpecialCommentTitle
    || self.opaqueCurToken.type == FilterTokenTypeSpecialCommentExpires
    || self.opaqueCurToken.type == FilterTokenTypeSpecialCommentVersion
    || self.opaqueCurToken.type == FilterTokenTypeSpecialCommentHomepage
    || self.opaqueCurToken.type == FilterTokenTypeSpecialCommentRedirect;
}

- (BOOL)isComment{
    return self.opaqueCurToken.type == FilterTokenTypeComment || self.isSepcialComment;
}

- (BOOL)isInfo{
    return self.opaqueCurToken.type == FilterTokenTypeInfo;
}

- (BOOL)isTigger{
    return self.opaqueCurToken.type == FilterTokenTypeTigger;
}

@end
