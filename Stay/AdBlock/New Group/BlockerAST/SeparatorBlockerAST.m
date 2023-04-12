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
    
    if (self.urlFilter.length == 0){
        self.urlFilter =  @".*[^a-zA-Z0-9_\\-.%]";
    }
    else{
        if ([self.urlFilter hasSuffix:@".*"]){
            [self resetUrlFilter:[self.urlFilter substringWithRange:NSMakeRange(0, self.urlFilter.length - 2)]];
        }
        self.urlFilter =  @"[^a-zA-Z0-9_\\-.%].*";
    }
    
}

@end
