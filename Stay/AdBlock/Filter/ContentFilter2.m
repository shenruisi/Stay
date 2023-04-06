//
//  ContentFilter.m
//  Stay
//
//  Created by ris on 2023/3/23.
//

#import "ContentFilter2.h"
#import "FilterTokenParser.h"

@interface ContentFilter()

@property (nonatomic, strong) NSString *resourcePath;
@property (nonatomic, strong) NSString *documentPath;
@end

@implementation ContentFilter

- (NSString *)fetchRules{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.documentPath]){
        return [[NSString alloc] initWithContentsOfFile:self.documentPath encoding:NSUTF8StringEncoding error:nil];
    }
    
    return [[NSString alloc] initWithContentsOfFile:self.resourcePath encoding:NSUTF8StringEncoding error:nil];
}

- (void)convertToJOSNRules{
    NSString *rules = [self fetchRules];
    NSArray<NSString *> *lines = [rules componentsSeparatedByString:@"\n"];
    for (NSString *line in lines){
        FilterTokenParser *parser = [[FilterTokenParser alloc] initWithChars:line];
        [parser nextToken];
        while(![parser isEOF]){
            NSLog(@"token: %@",parser.curToken);
            [parser nextToken];
        }
    }
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
