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
#import "TiggerBlockerAST.h"
#import "OptionsBlockerAST.h"
#import "SelectorBlockerAST.h"

@implementation ContentFilterBlocker

+ (NSMutableDictionary *)rule:(NSString *)rule{
    FilterTokenParser *parser = [[FilterTokenParser alloc] initWithChars:rule];
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setObject:[[NSMutableDictionary alloc] init] forKey:@"trigger"];
    [dictionary setObject:[[NSMutableDictionary alloc] init] forKey:@"action"];
    dictionary[@"action"][@"type"] = @"block";
    
    do{
        BlockerAST *ast;
        [parser nextToken];
        
        if ([parser isException]){
            ast = [[ExceptionBlockerAST alloc] initWithParser:parser args:@[dictionary]];
        }
        
        if ([parser isAddress]){
            ast = [[AddressBlockerAST alloc] initWithParser:parser args:@[dictionary]];
        }
        
        if ([parser isPipe]){
            ast = [[PipeBlockerAST alloc] initWithParser:parser args:@[dictionary]];
        }
        
        if ([parser isSeparator]){
            ast = [[SeparatorBlockerAST alloc] initWithParser:parser args:@[dictionary]];
        }
        
        if ([parser isTigger]){
            ast = [[TiggerBlockerAST alloc] initWithParser:parser args:@[dictionary]];
        }
        
        if ([parser isOptions]){
            ast = [[OptionsBlockerAST alloc] initWithParser:parser args:@[dictionary]];
        }
        
        if ([parser isSelector]){
            ast = [[SelectorBlockerAST alloc] initWithParser:parser args:@[dictionary]];
        }
        
    }while(!parser.isEOF);
    
    if (((NSString *)dictionary[@"trigger"][@"url-filter"]).length == 0){
        dictionary[@"trigger"][@"url-filter"] = @".*";
    }
    
    return dictionary;
}


@end
