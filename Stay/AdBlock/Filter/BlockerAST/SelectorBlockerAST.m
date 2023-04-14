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
    
    self.type = @"css-display-none";
    self.selector = [self.parser.curToken toString];
}

@end
