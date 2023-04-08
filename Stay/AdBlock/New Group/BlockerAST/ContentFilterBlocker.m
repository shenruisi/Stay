//
//  ContentFilterBlocker.m
//  Stay
//
//  Created by ris on 2023/4/7.
//

#import "ContentFilterBlocker.h"
#import "FilterTokenParser.h"
#import "BlockerAST.h"

@implementation ContentFilterBlocker

+ (NSMutableDictionary *)rule:(NSString *)rule{
    FilterTokenParser *parser = [[FilterTokenParser alloc] initWithChars:rule];
    
    do{
        BlockerAST *ast;
        
    }while(parser.isEOF);
    
    return nil;
}


@end
