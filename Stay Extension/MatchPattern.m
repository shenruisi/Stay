//
//  MatchPattern.m
//  Stay Extension
//
//  Created by ris on 2022/5/25.
//

#import "MatchPattern.h"

@interface MatchPattern()

@property (nonatomic, assign) BOOL all;
@property (nonatomic, strong) NSString *protocol;
@property (nonatomic, assign) BOOL pass;
@property (nonatomic, strong) NSRegularExpression *hostExpr;
@property (nonatomic, strong) NSRegularExpression *pathExpr;

//Const members.
@property (nonatomic, strong) NSArray<NSString *> *validProtocols;
@property (nonatomic, strong) NSRegularExpression *REG_PARTS;
@property (nonatomic, strong) NSRegularExpression *REG_HOST;
@property (nonatomic, strong) NSRegularExpression *tldRegExp;

@end

@implementation MatchPattern

- (instancetype)initWithPattern:(NSString *)pattern{
    if (self = [super init]){
        if ([pattern isEqualToString:@"<all_urls>"]){
            self.all = YES;
            self.protocol = @"all_urls";
        }
        
        do{
            NSArray<NSTextCheckingResult *> *results =  [self.REG_PARTS matchesInString:pattern
                                                                               options:0
                                                                                 range:NSMakeRange(0, pattern.length)];
            
            if (results.count == 0){
                NSLog(@"Pattern (%@) is not vailed",pattern);
                break;
            }
            
            NSTextCheckingResult *result = results.firstObject;
            NSInteger n = result.numberOfRanges;
            
            if (n < 4){
                NSLog(@"Pattern (%@) is not vailed",pattern);
                break;
            }
            
            self.protocol = [pattern substringWithRange:[result rangeAtIndex:1]];
            NSString *host = [pattern substringWithRange:[result rangeAtIndex:2]];
            NSString *path = [pattern substringWithRange:[result rangeAtIndex:3]];
            
            if (![self.protocol isEqualToString:@"*:"] && ![self.validProtocols containsObject:self.protocol]){
                NSLog(@"@match: Invalid protocol (%@) specified.",self.protocol);
                break;
            }
            
            results = [self.REG_HOST matchesInString:host options:0 range:NSMakeRange(0, host.length)];
            if (results.count == 0){
                NSLog(@"@match: Invalid host (%@) specified.",host);
                break;
            }
            
            if (![[path substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"/"]){
                NSLog(@"@match: Invalid path (%@) specified.",path);
                break;
            }
            
            if (host.length > 0){
                NSString *expr = [[[host stringByReplacingOccurrencesOfString:@"." withString:@"\\."]
                                    stringByReplacingOccurrencesOfString:@"*" withString:@".*"]
                                   stringByReplacingOccurrencesOfString:@"*." withString:@"*\\."];
                self.hostExpr = [[NSRegularExpression alloc] initWithPattern:[NSString stringWithFormat:@"^%@$",expr]  options:0 error:nil];
                
            }
            
            //TLD missed.
            NSMutableString *builder = [[NSMutableString alloc] initWithString:@"^"];
            for (int i = 0; i < path.length; i++){
                unichar c = [path characterAtIndex:i];
                switch(c){
                    case '*' : [builder appendString:@".*"];
                        break;
                    case '.' :
                    case '?' :
                    case '^' :
                    case '$' :
                    case '+' :
                    case '{' :
                    case '}' :
                    case '[' :
                    case ']' :
                    case '|' :
                    case '(' :
                    case ')' :
                    case '\\' : [builder appendFormat:@"\\%C",c];
                        break;
                    case ' ' :
                      break;
                    default : [builder appendFormat:@"%C",c];
                      break;
                }
            }
            
            [builder appendString:@"$"];
            self.pathExpr = [[NSRegularExpression alloc] initWithPattern:builder  options:0 error:nil];
            self.pass = YES;
            
        }while(0);
    }
    
    return self;
}

- (NSArray<NSString *> *)validProtocols{
    return @[@"http:", @"https:"];
}

- (NSRegularExpression *)REG_PARTS{
    if (nil == _REG_PARTS){
        _REG_PARTS =  [[NSRegularExpression alloc] initWithPattern:@"^([a-z*]+:|\\*:)\\/\\/([^\\/]+)?(\\/.*)$" options:0 error:nil];
    }
    return _REG_PARTS;
}

- (NSRegularExpression *)REG_HOST{
    if (nil == _REG_HOST){
        _REG_HOST = [[NSRegularExpression alloc] initWithPattern:@"^(?:\\*\\.)?[^*\\/]+$|^\\*$|^$" options:0 error:nil];
    }
    return _REG_HOST;
}

- (NSRegularExpression *)tldRegExp{
    if (nil == _tldRegExp){
        _tldRegExp = [[NSRegularExpression alloc] initWithPattern:@"^([^:]+:\\/\\/[^\\/]+)\\.tld(\\/.*)?$" options:0 error:nil];
    }
    return _tldRegExp;
}

- (BOOL)doMatch:(NSString *)urlString{
    if(!self.pass) return NO;
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) return NO;
    if (self.all) return YES;
    
    return [self.hostExpr matchesInString:url.host options:0 range:NSMakeRange(0, url.host.length)].count > 0
    && [self.pathExpr matchesInString:url.path options:0 range:NSMakeRange(0, url.path.length)].count > 0;
}
@end
