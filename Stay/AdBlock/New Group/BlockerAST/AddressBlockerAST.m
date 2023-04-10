//
//  AddressBlockerAST.m
//  Stay
//
//  Created by ris on 2023/4/10.
//

#import "AddressBlockerAST.h"

@implementation AddressBlockerAST

- (void)construct:(NSArray *)args{
    [super construct:args];
    
    self.urlFilter = @"^https?://";
}

@end
