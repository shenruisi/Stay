//
//  InfoHighlighterAST.m
//  Stay
//
//  Created by ris on 2023/4/5.
//

#import "InfoHighlighterAST.h"

@implementation InfoHighlighterAST

- (void)construct:(NSArray *)args{
    [super construct:args];
    
    [self.attributedString appendAttributedString:[NSAttributedString captionText:[self.parser.curToken toString]]];

    
    [self.attributedString addAttributes:@{
        NSForegroundColorAttributeName : FCStyle.accent
    } range:NSMakeRange(0, self.attributedString.length)];
}

@end
