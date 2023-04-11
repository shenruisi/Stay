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
            [jsonRules addObject:jsonRule];
        }
    }
    
    NSString *ret = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:jsonRules options:0 error:nil] encoding:NSUTF8StringEncoding];
//    NSError *error;
//    [ret writeToFile:@"/Users/ris/Desktop/jsonRules.txt" atomically:YES encoding:NSUTF8StringEncoding error:&error];
    return ret;
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


+ (NSString *)stringOfTag:(ContentFilterTag)tag{
    if (ContentFilterTagAds == tag) return @"Ads";
    return @"";
}

@end
