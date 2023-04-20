//
//  TiggerBlockerAST.m
//  Stay
//
//  Created by ris on 2023/4/7.
//

#import "TiggerBlockerAST.h"

@interface TiggerBlockerAST()
@end

@implementation TiggerBlockerAST

- (void)construct:(NSArray *)args{
    [super construct:args];
    
    NSString *urlFilter = [self.parser.curToken toString];
    if (urlFilter.length >= 2
        && [urlFilter characterAtIndex:0] == '/'
        && [urlFilter characterAtIndex:urlFilter.length - 1] == '/'){
        urlFilter = [urlFilter substringWithRange:NSMakeRange(1, urlFilter.length - 2)];
        urlFilter = [urlFilter stringByReplacingOccurrencesOfString:@"\\w" withString:@"."];
        NSRegularExpression *regexReplace1 = [NSRegularExpression regularExpressionWithPattern:@"\\{\\d+,\\d*\\}" options:0 error:nil];
        urlFilter = [regexReplace1 stringByReplacingMatchesInString:urlFilter options:0 range:NSMakeRange(0, urlFilter.length) withTemplate:@"+"];
        self.urlFilter = urlFilter;
    }
    else{
        //Add wildcard
        urlFilter = [urlFilter stringByReplacingOccurrencesOfString:@"?" withString:@"\?"];
        if ([urlFilter characterAtIndex:0] != '*'){
            if ([self.urlFilter hasSuffix:@"^https?://"]){
                urlFilter = [NSString stringWithFormat:@"*.?%@",urlFilter];
            }
            else{
                urlFilter = [NSString stringWithFormat:@"*%@",urlFilter];
            }
        }
        
        if ([urlFilter characterAtIndex:urlFilter.length - 1] != '*'){
            urlFilter = [NSString stringWithFormat:@"%@*",urlFilter];
        }
        else{
            self.originTriggerEndWithAsterisk = YES;
        }
        
//        if (self.urlFilter.length == 0){
//            urlFilter = [NSString stringWithFormat:@"*%@*",urlFilter];
//        }
//        else if ([self.urlFilter hasSuffix:@"^https?://"]){
//            urlFilter = [NSString stringWithFormat:@"*.?%@*",urlFilter];
//        }
//        else if ([self.urlFilter hasSuffix:@".*[^a-zA-Z0-9_\\-.%]"]){
//            urlFilter = [NSString stringWithFormat:@"%@*",urlFilter];
//        }
        //Convert wildcard
        urlFilter = [urlFilter stringByReplacingOccurrencesOfString:@"*" withString:@".*"];
//        urlFilter = [urlFilter stringByReplacingOccurrencesOfString:@"?" withString:@"."];
        self.urlFilter = urlFilter;
    }
}

@end
