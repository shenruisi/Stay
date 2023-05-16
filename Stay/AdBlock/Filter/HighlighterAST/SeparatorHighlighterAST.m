//
//  SeparatorHighlighterAST.m
//  Stay
//
//  Created by ris on 2023/4/10.
//

#import "SeparatorHighlighterAST.h"

@implementation SeparatorHighlighterAST

- (void)construct:(NSArray *)args{
    [super construct:args];
    
    [self.attributedString appendAttributedString:[NSAttributedString captionText:[self.parser.curToken toString]]];

    
    [self.attributedString addAttributes:@{
        NSForegroundColorAttributeName : FCStyle.filterSeparatorColor
    } range:NSMakeRange(0, self.attributedString.length)];
}

@end
