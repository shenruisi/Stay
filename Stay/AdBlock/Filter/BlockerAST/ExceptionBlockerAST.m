//
//  ExceptionBlockerAST.m
//  Stay
//
//  Created by ris on 2023/4/10.
//

#import "ExceptionBlockerAST.h"

@implementation ExceptionBlockerAST

- (void)construct:(NSArray *)args{
    [super construct:args];
    
    self.contentBlockerRule.action.type = @"ignore-previous-rules";
}

@end
