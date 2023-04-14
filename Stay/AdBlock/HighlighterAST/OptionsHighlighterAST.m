//
//  OptionsHighlighterAST.m
//  Stay
//
//  Created by ris on 2023/4/6.
//

#import "OptionsHighlighterAST.h"

@implementation OptionsHighlighterAST

- (void)construct:(NSArray *)args{
    [super construct:args];
    
    [self.attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"$" attributes:@{
        NSFontAttributeName : FCStyle.caption,
        NSForegroundColorAttributeName : FCStyle.filterModifierColor
    }]];
    
    [self.attributedString appendAttributedString:[NSAttributedString captionText:[self.parser.curToken toString]]];
    [self.attributedString addAttributes:@{
        NSForegroundColorAttributeName : FCStyle.filterOptionColor
    } range:NSMakeRange(1, self.attributedString.length - 1)];
    
}

@end
