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
    
}

@end
