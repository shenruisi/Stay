//
//  PipeHighlighterAST.m
//  Stay
//
//  Created by ris on 2023/4/10.
//

#import "PipeHighlighterAST.h"

@implementation PipeHighlighterAST

- (void)construct:(NSArray *)args{
    [super construct:args];
    
    [self.attributedString appendAttributedString:[NSAttributedString captionText:[self.parser.curToken toString]]];

    
    [self.attributedString addAttributes:@{
        NSForegroundColorAttributeName : FCStyle.filterAddressColor
    } range:NSMakeRange(0, self.attributedString.length)];
}

@end
