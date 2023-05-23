//
//  SelectorBlockerAST.m
//  Stay
//
//  Created by ris on 2023/4/10.
//

#import "SelectorBlockerAST.h"

@implementation SelectorBlockerAST

- (void)construct:(NSArray *)args{
    [super construct:args];
    
    self.contentBlockerRule.action.type = @"css-display-none";
    self.contentBlockerRule.action.selector = [self.parser.curToken toString];
}

@end
