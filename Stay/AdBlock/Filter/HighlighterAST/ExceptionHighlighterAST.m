//
//  ExceptionHighlighterAST.m
//  Stay
//
//  Created by ris on 2023/4/6.
//

#import "ExceptionHighlighterAST.h"

@implementation ExceptionHighlighterAST

- (void)construct:(NSArray *)args{
    [super construct:args];
    
    [self.attributedString appendAttributedString:[NSAttributedString captionText:[self.parser.curToken toString]]];

    
    [self.attributedString addAttributes:@{
        NSForegroundColorAttributeName : FCStyle.filterExceptionColor
    } range:NSMakeRange(0, self.attributedString.length)];
}

@end
