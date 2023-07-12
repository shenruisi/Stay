//
//  ContentFilterBlocker.m
//  Stay
//
//  Created by ris on 2023/4/7.
//

#import "ContentFilterBlocker.h"
#import "FilterTokenParser.h"
#import "BlockerAST.h"
#import "ExceptionBlockerAST.h"
#import "AddressBlockerAST.h"
#import "PipeBlockerAST.h"
#import "SeparatorBlockerAST.h"
#import "TriggerBlockerAST.h"
#import "OptionsBlockerAST.h"
#import "SelectorBlockerAST.h"
#import "SpecialCommentBlockerAST.h"
#if FC_IOS
#import "Stay-Swift.h"
#else
#import "Stay-Swift.h"
#endif


@implementation ContentFilterBlocker

+ (ContentBlockerRule *)rule:(NSString *)rule isSpecialComment:(BOOL *)isSpecialComment {
    FilterTokenParser *parser = [[FilterTokenParser alloc] initWithChars:rule];
    
    ContentBlockerRule *contentBlockerRule = [[ContentBlockerRule alloc] init];
    *isSpecialComment = NO;
    do{
        BlockerAST *ast;
        [parser nextToken];
        
        if ([parser isUndefined]){
            return nil;
        }
        
        if ([parser isJSAPI]
            || [parser isJSAPIException]
            || [parser isDefineStart]
            || [parser isDefineEnd]
            || [parser isCSSRule]
            || [parser isHtmlFilterScript]
            || [parser isHtmlFilterIframe]){
            return nil;
        }
        
        if ([parser isInfo]
            || [parser isComment]){
            if ([parser isSepcialComment]){
                *isSpecialComment = YES;
                ast = [[SpecialCommentBlockerAST alloc] initWithParser:parser args:@[contentBlockerRule]];
                return contentBlockerRule;
            }
            else{
                return nil;
            }
        }
        
        if ([parser isException]){
            ast = [[ExceptionBlockerAST alloc] initWithParser:parser args:@[contentBlockerRule]];
        }
        
        if ([parser isAddress]){
            ast = [[AddressBlockerAST alloc] initWithParser:parser args:@[contentBlockerRule]];
        }
        
        if ([parser isPipe]){
            ast = [[PipeBlockerAST alloc] initWithParser:parser args:@[contentBlockerRule]];
        }
        
        if ([parser isSeparator]){
            ast = [[SeparatorBlockerAST alloc] initWithParser:parser args:@[contentBlockerRule]];
        }
        
        if ([parser isTrigger]){
            ast = [[TriggerBlockerAST alloc] initWithParser:parser args:@[contentBlockerRule]];
            if (ast.unsupported){
//                NSLog(@"Unsupport rule: %@",rule);
                return nil;
            }
        }
        
        if ([parser isOptions]){
            ast = [[OptionsBlockerAST alloc] initWithParser:parser args:@[contentBlockerRule]];
            if (ast.unsupported){
                return nil;
            }
        }
        
        if ([parser isSelector]){
            ast = [[SelectorBlockerAST alloc] initWithParser:parser args:@[contentBlockerRule]];
        }
        
    }while(!parser.isEOF);
    
    if (contentBlockerRule.trigger.urlFilter.length == 0){
        contentBlockerRule.trigger.urlFilter = @".*";
    }
    
    if ([contentBlockerRule.trigger.urlFilter isEqualToString:@".*"]){
        if (![contentBlockerRule canUrlFilterWildcard]){
            return nil;
        }
    }
    
    if ([contentBlockerRule.trigger.urlFilter isEqualToString:@"/.*/.*/.*/.*/.*"]){
        return nil;
    }
    
    if (contentBlockerRule.trigger.urlFilter.length > 80){
        return nil;
    }
    
    return contentBlockerRule;
}


@end
