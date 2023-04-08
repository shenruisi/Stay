//
//  TiggerBlockerAST.m
//  Stay
//
//  Created by ris on 2023/4/7.
//

#import "TiggerBlockerAST.h"

@implementation TiggerBlockerAST

- (void)construct:(NSArray *)args{
    [super construct:args];
    
    NSString *urlFilter = [self.parser.curToken toString];
    if (urlFilter.length >= 2
        && [urlFilter characterAtIndex:0] == '/'
        && [urlFilter characterAtIndex:urlFilter.length - 1] == '/'){
        self.urlFilter = [urlFilter substringWithRange:NSMakeRange(1, urlFilter.length - 2)];
    }
    else{
        //convert wildcard to regex
        regexString = [regexString stringByReplacingOccurrencesOfString:@"\\*" withString:@".*"];
        regexString = [regexString stringByReplacingOccurrencesOfString:@"\\?" withString:@"."];
    }
}

@end
