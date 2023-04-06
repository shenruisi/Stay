//
//  ContentFilterHighlighter.m
//  Stay
//
//  Created by ris on 2023/4/5.
//

#import "ContentFilterHighlighter.h"
#import "FilterTokenParser.h"
#import "HighlighterAST.h"
#import "CommentHighlighterAST.h"
#import "InfoHighlighterAST.h"
#import "TiggerHighlighterAST.h"
#import "ExceptionHighlighterAST.h"
#import "AddressHighlighterAST.h"
#import "OptionsHighlighterAST.h"
#import "SelectorHighlighterAST.h"

@implementation ContentFilterHighlighter

+ (NSMutableAttributedString *)rule:(NSString *)rule{
    FilterTokenParser *parser = [[FilterTokenParser alloc] initWithChars:rule];
    
    NSMutableAttributedString *ret = [[NSMutableAttributedString alloc] init];
    do{
        HighlighterAST *ast;
        [parser nextToken];
        
        if ([parser isComment]){
            ast = [[CommentHighlighterAST alloc] initWithParser:parser args:nil];
            [ret appendAttributedString:ast.attributedString];
        }
        
        if ([parser isInfo]){
            ast = [[InfoHighlighterAST alloc] initWithParser:parser args:nil];
            [ret appendAttributedString:ast.attributedString];
        }
        
        if ([parser isTigger]){
            ast = [[TiggerHighlighterAST alloc] initWithParser:parser args:nil];
            [ret appendAttributedString:ast.attributedString];
        }
        
        if ([parser isException]){
            ast = [[ExceptionHighlighterAST alloc] initWithParser:parser args:nil];
            [ret appendAttributedString:ast.attributedString];
        }
        
        if ([parser isAddress]){
            ast = [[AddressHighlighterAST alloc] initWithParser:parser args:nil];
            [ret appendAttributedString:ast.attributedString];
        }
        
        if ([parser isOptions]){
            ast = [[OptionsHighlighterAST alloc] initWithParser:parser args:nil];
            [ret appendAttributedString:ast.attributedString];
        }
        
        if ([parser isSelector]){
            ast = [[SelectorHighlighterAST alloc] initWithParser:parser args:nil];
            [ret appendAttributedString:ast.attributedString];
        }
        
        
    }while(!parser.isEOF);
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 2;
    [ret addAttributes:@{
//        NSKernAttributeName : @(0.5),
        NSParagraphStyleAttributeName : paragraphStyle
    } range:NSMakeRange(0, ret.length)];
    
    return ret;
    
}
@end
