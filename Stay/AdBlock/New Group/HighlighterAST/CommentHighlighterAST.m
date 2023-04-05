//
//  CommentHighlighterAST.m
//  Stay
//
//  Created by ris on 2023/4/5.
//

#import "CommentHighlighterAST.h"
#import "NSAttributedString+Style.h"

@implementation CommentHighlighterAST

- (void)construct:(NSArray *)args{
    [super construct:args];
    
    [self.attributedString appendAttributedString:[NSAttributedString captionText:[self.parser.curToken toString]]];

    
    [self.attributedString addAttributes:@{
        NSForegroundColorAttributeName : FCStyle.filterCommentColor
    } range:NSMakeRange(0, self.attributedString.length)];
}

@end
