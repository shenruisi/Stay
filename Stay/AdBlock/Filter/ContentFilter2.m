//
//  ContentFilter.m
//  Stay
//
//  Created by ris on 2023/3/23.
//

#import "ContentFilter2.h"
#import "FilterTokenParser.h"
#import "ContentFilterBlocker.h"
#import <SafariServices/SafariServices.h>
#import "ContentFilterManager.h"
#import "DataManager.h"
#import "SYVersionUtils.h"

@interface ContentFilter(){
    dispatch_queue_t _ioQueue;
}

@property (nonatomic, strong) NSString *resourcePath;
@property (nonatomic, strong) NSString *documentPath;
@property (nonatomic, strong) NSString *sharedPath;
@end

@implementation ContentFilter

- (instancetype)init{
    if (self = [super init]){
        _ioQueue = dispatch_queue_create([@"ContentFilter" UTF8String],
                                              DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}


- (NSString *)queueName:(NSString *)name{
    return [NSString stringWithFormat:@"com.stay.io.%@.%@",name,[[NSUUID UUID] UUIDString]];
}

- (NSString *)fetchRules{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.documentPath]){
        return [[NSString alloc] initWithContentsOfFile:self.documentPath encoding:NSUTF8StringEncoding error:nil];
    }
    
    return [[NSString alloc] initWithContentsOfFile:self.resourcePath encoding:NSUTF8StringEncoding error:nil];
}

- (void)checkUpdatingIfNeeded:(BOOL)focus completion:(nullable void(^)(NSError *))completion{
    if (self.type == ContentFilterTypeCustom || self.type == ContentFilterTypeTag) return;
    NSInteger days = 4;
    if (self.expires.length > 0){
        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"(\\d+) days" options:0 error:nil];
        NSArray<NSTextCheckingResult *> *results = [regex matchesInString:self.expires options:0 range:NSMakeRange(0, self.expires.length)];
        if (results.count > 0){
            NSTextCheckingResult *result = results[0];
            days = [[self.expires substringWithRange:[result rangeAtIndex:1]] integerValue];
        }
    }
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.updateTime];
    NSInteger daysBetween = (NSInteger)(timeInterval / 86400);

    if (daysBetween >= days || focus) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.downloadUrl]];
        [request setHTTPMethod:@"GET"];
        [[[NSURLSession sharedSession] dataTaskWithRequest:request
                        completionHandler:^(NSData *data,
                                            NSURLResponse *response,
                                            NSError *error) {
            if (nil == error && data.length > 0){
                NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSURL *url = [NSURL fileURLWithPath:self.documentPath];
                [content writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:&error];
                if (nil == error){
                    NSMutableArray *jsonRules = [[NSMutableArray alloc] init];
                    NSArray<NSString *> *lines = [content componentsSeparatedByString:@"\n"];
                    for (NSString *line in lines){
                        if (line.length > 0){
                            BOOL isSepcialComment;
                            NSDictionary *jsonRule = [ContentFilterBlocker rule:line isSpecialComment:&isSepcialComment];
                            if (jsonRule && !isSepcialComment){
                                [jsonRules addObject:jsonRule];
                            }
                            else if (isSepcialComment){
                                NSDictionary *specialComment = jsonRule[@"special_comment"];
                                if (specialComment[@"Homepage"]){
                                    [[DataManager shareManager]
                                     updateContentFilterHomepage:specialComment[@"Homepage"] uuid:self.uuid];
                                }
//                                else if (specialComment[@"Title"]){
//                                    [[DataManager shareManager]
//                                     updateContentFilterTitle:specialComment[@"Title"] uuid:self.uuid];
//                                }
                                else if (specialComment[@"Version"]){
                                    NSInteger compareResult = [SYVersionUtils compareVersion:specialComment[@"Version"] toVersion:self.version];
                                    if (compareResult < 1){
                                        NSError *versionError = [[NSError alloc] initWithDomain:@"" code:204 userInfo:@{
                                            NSLocalizedDescriptionKey : NSLocalizedString(@"LatestVersion", @"")
                                        }];
                                        completion(versionError);
                                        return;
                                    }
                                    [[DataManager shareManager]
                                     updateContentFilterVersion:specialComment[@"Version"] uuid:self.uuid];
                                }
                                else if (specialComment[@"Expires"]){
                                    [[DataManager shareManager]
                                     updateContentFilterExpires:specialComment[@"Expires"] uuid:self.uuid];
                                }
                                else if (specialComment[@"Redirect"]){
                                    [[DataManager shareManager]
                                     updateContentFilterRedirect:specialComment[@"Redirect"] uuid:self.uuid];
                                }
                            }
                        }
                    }
                    
                    NSString *ret = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:jsonRules options:0 error:nil] encoding:NSUTF8StringEncoding];
                    
                    if (ret.length > 0){
                        dispatch_async(self->_ioQueue, ^{
                            [[ContentFilterManager shared] writeToFileName:self.rulePath content:content];
                            [SFContentBlockerManager reloadContentBlockerWithIdentifier:self.contentBlockerIdentifier completionHandler:^(NSError * _Nullable error) {
                                NSLog(@"reloadContentBlockerWithIdentifier error %@",error);
                            }];
                        });
                    }
                }
            }
            
            if (completion){
                if (nil == error){
                    [[DataManager shareManager]
                     updateContentFilterUpdateTime:[NSDate date] uuid:self.uuid];
                }
                completion(error);
            }
            
        }] resume];
    }
    
}

- (NSString *)convertToJOSNRules{
    NSMutableArray *jsonRules = [[NSMutableArray alloc] init];
    NSString *rules = [self fetchRules];
    NSArray<NSString *> *lines = [rules componentsSeparatedByString:@"\n"];
    for (NSString *line in lines){
        if (line.length > 0){
            BOOL isSepcialComment;
            NSDictionary *jsonRule = [ContentFilterBlocker rule:line isSpecialComment:&isSepcialComment];
            if (jsonRule && !isSepcialComment){
                [jsonRules addObject:jsonRule];
            }
            
        }
    }
    
    NSString *ret = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:jsonRules options:0 error:nil] encoding:NSUTF8StringEncoding];
    return ret;
}

- (void)writeContentBlockerAsync{
    NSString *content = [self convertToJOSNRules];
    if (content.length > 0){
        dispatch_async(_ioQueue, ^{
            [[ContentFilterManager shared] writeToFileName:self.rulePath content:content];
        });
    }
}


- (void)reloadContentBlocker{
    NSString *content = [self convertToJOSNRules];
    [[ContentFilterManager shared] writeToFileName:self.rulePath content:content];
    [SFContentBlockerManager reloadContentBlockerWithIdentifier:self.contentBlockerIdentifier completionHandler:^(NSError * _Nullable error) {
        NSLog(@"error %@",error);
    }];
}

- (BOOL)active{
    return self.status == 1;
}

- (NSString *)resourcePath{
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.path];
}

- (NSString *)documentPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:self.path];
}


+ (NSString *)stringOfType:(ContentFilterType)type{
    if (ContentFilterTypeBasic == type) return @"Basic";
    if (ContentFilterTypePrivacy == type) return @"Privacy";
    if (ContentFilterTypeRegion == type) return @"Region";
    if (ContentFilterTypeCustom == type) return @"Custom";
    if (ContentFilterTypeTag == type) return @"Tag";
    return @"";
}

@end
