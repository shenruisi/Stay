//
//  JSAPIExceptionHighlighterAST.m
//  Stay
//
//  Created by ris on 2023/5/9.
//

#import "JSAPIExceptionHighlighterAST.h"

@implementation JSAPIExceptionHighlighterAST

- (void)construct:(NSArray *)args{
    [super construct:args];
    
    [self.attributedString appendAttributedString:[NSAttributedString captionText:[self.parser.curToken toString]]];

    
    [self.attributedString addAttributes:@{
        NSForegroundColorAttributeName : FCStyle.fcSeparator
    } range:NSMakeRange(0, self.attributedString.length)];
}

@end
