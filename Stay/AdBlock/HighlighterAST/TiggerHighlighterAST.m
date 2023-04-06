//
//  TiggerHighlighterAST.m
//  Stay
//
//  Created by ris on 2023/4/5.
//

#import "TiggerHighlighterAST.h"

@implementation TiggerHighlighterAST

- (void)construct:(NSArray *)args{
    [super construct:args];
    
    [self.attributedString appendAttributedString:[NSAttributedString captionText:[self.parser.curToken toString]]];

    
    [self.attributedString addAttributes:@{
        NSForegroundColorAttributeName : FCStyle.fcBlack
    } range:NSMakeRange(0, self.attributedString.length)];
}

@end
