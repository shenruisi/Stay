//
//  PipeBlockerAST.m
//  Stay
//
//  Created by ris on 2023/4/10.
//

#import "PipeBlockerAST.h"

@implementation PipeBlockerAST

- (void)construct:(NSArray *)args{
    [super construct:args];
    
    if (0 == self.contentBlockerRule.trigger.urlFilter.length){
        [self.contentBlockerRule.trigger appendUrlFilter:@"^"];
    }
    else{
        [self.contentBlockerRule.trigger appendUrlFilter:@"$"];
    }
}

@end
