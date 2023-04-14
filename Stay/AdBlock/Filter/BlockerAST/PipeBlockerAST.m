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
    
    if (self.urlFilter.length == 0){
        self.urlFilter = @"^";
    }
    else{
        self.urlFilter =  @"$";
    }
}

@end
