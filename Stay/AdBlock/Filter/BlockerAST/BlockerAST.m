//
//  BlockerAST.m
//  Stay
//
//  Created by ris on 2023/4/7.
//

#import "BlockerAST.h"

@implementation BlockerAST

- (instancetype)initWithParser:(FilterTokenParser *)parser args:(NSArray *)args{
    if (self = [super init]){
        self.parser = parser;
        [self construct:args];
    }
    
    return self;
}


- (void)construct:(nullable NSArray *)args{
    self.contentBlockerRule = args[0];
}

@end
