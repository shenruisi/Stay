//
//  SeparatorBlockerAST.m
//  Stay
//
//  Created by ris on 2023/4/10.
//

#import "SeparatorBlockerAST.h"

@implementation SeparatorBlockerAST

- (void)construct:(NSArray *)args{
    [super construct:args];
    
    self.urlFilter =  @"[^a-zA-Z0-9_\\-.%]";
}

@end
