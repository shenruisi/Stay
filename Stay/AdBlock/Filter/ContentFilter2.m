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

@interface ContentFilter()

@property (nonatomic, strong) NSString *resourcePath;
@property (nonatomic, strong) NSString *documentPath;
@property (nonatomic, strong) NSString *sharedPath;
@end

@implementation ContentFilter

- (NSString *)fetchRules{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.documentPath]){
        return [[NSString alloc] initWithContentsOfFile:self.documentPath encoding:NSUTF8StringEncoding error:nil];
    }
    
    return [[NSString alloc] initWithContentsOfFile:self.resourcePath encoding:NSUTF8StringEncoding error:nil];
}

- (NSString *)convertToJOSNRules{
    NSMutableArray *jsonRules = [[NSMutableArray alloc] init];
    NSString *rules = [self fetchRules];
    NSArray<NSString *> *lines = [rules componentsSeparatedByString:@"\n"];
    for (NSString *line in lines){
        if (line.length > 0){
            NSDictionary *jsonRule = [ContentFilterBlocker rule:line];
            if (jsonRule){
                [jsonRules addObject:jsonRule];
            }
            
        }
    }
    
    NSString *ret = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:jsonRules options:0 error:nil] encoding:NSUTF8StringEncoding];
    return ret;
}

- (void)writeContentBlockerAsync{
    NSString *content = [self convertToJOSNRules];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[ContentFilterManager shared] writeToFileName:self.rulePath content:content];
    });
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
