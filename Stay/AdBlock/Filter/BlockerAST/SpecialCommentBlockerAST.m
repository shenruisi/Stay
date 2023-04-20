//
//  SpecialCommentBlockerAST.m
//  Stay
//
//  Created by ris on 2023/4/17.
//

#import "SpecialCommentBlockerAST.h"

@implementation SpecialCommentBlockerAST

- (void)construct:(NSArray *)args{
    [super construct:args];
    
    NSMutableDictionary *specialComment = [[NSMutableDictionary alloc] init];
    if (FilterTokenTypeSpecialCommentTitle == self.parser.curToken.type
        || FilterTokenTypeSpecialCommentHomepage == self.parser.curToken.type
        || FilterTokenTypeSpecialCommentExpires == self.parser.curToken.type
        || FilterTokenTypeSpecialCommentVersion == self.parser.curToken.type
        || FilterTokenTypeSpecialCommentRedirect == self.parser.curToken.type){
        specialComment[[FilterToken stringOfType:self.parser.curToken.type]] = self.parser.curToken.value;
    }
    
    self.dictionary[@"special_comment"] = specialComment;
}

@end
