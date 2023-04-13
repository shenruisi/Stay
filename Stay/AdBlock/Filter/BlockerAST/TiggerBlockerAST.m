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
        //Add wildcard
        if (self.urlFilter.length == 0){
            urlFilter = [NSString stringWithFormat:@"*%@*",urlFilter];
        }
        else if ([self.urlFilter hasSuffix:@"^https?://"]){
            urlFilter = [NSString stringWithFormat:@"*.%@*",urlFilter];
        }
        else if ([self.urlFilter hasSuffix:@".*[^a-zA-Z0-9_\\-.%]"]){
            urlFilter = [NSString stringWithFormat:@"%@*",urlFilter];
        }
        //Convert wildcard
        urlFilter = [urlFilter stringByReplacingOccurrencesOfString:@"*" withString:@".*"];
        urlFilter = [urlFilter stringByReplacingOccurrencesOfString:@"?" withString:@"."];
        self.urlFilter = urlFilter;
    }
}

@end
