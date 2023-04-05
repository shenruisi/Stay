//
//  ContentFilterHighlighter.m
//  Stay
//
//  Created by ris on 2023/4/5.
//

#import "ContentFilterHighlighter.h"
#import "FilterTokenParser.h"
#import "HighlighterAST.h"
#import "SpecialCommentHighlighterAST.h"

@implementation ContentFilterHighlighter

- (NSMutableAttributedString *)rule:(NSString *)rule{
    FilterTokenParser *parser = [[FilterTokenParser alloc] initWithChars:rule];
    
    HighlighterAST *ast;
    NSMutableAttributedString *ret = [[NSMutableAttributedString alloc] init];
    do{
        [parser nextToken];
        
        if ([parser isSepcialComment]){
            ast = [[SpecialCommentHighlighterAST alloc] init];
        }
    }while(!parser.isEOF);
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5;
    [ret addAttributes:@{
        NSKernAttributeName : @(0.5),
        NSParagraphStyleAttributeName : paragraphStyle
    } range:NSMakeRange(0, ret.length)];
    
    return ret;
    
}
@end
