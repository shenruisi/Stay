//
//  NewLineHighlighterAST.m
//  Stay
//
//  Created by ris on 2023/4/7.
//

#import "NewLineHighlighterAST.h"

@implementation NewLineHighlighterAST

- (void)construct:(NSArray *)args{
    [super construct:args];
    
    [self.attributedString appendAttributedString:[NSAttributedString captionText:[self.parser.curToken toString]]];
}

@end
