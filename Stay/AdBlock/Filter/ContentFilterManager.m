//
//  ContentFilterManager.m
//  Stay
//
//  Created by ris on 2023/4/4.
//

#import "ContentFilterManager.h"

@interface ContentFilterManager()

@property (nonatomic, strong) NSString *path;
@end

@implementation ContentFilterManager

static ContentFilterManager *instance = nil;
+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ContentFilterManager alloc] init];
    });
    
    return instance;
}

- (instancetype)init{
    if (self = [super init]){
        self.path = [[[[NSFileManager defaultManager]
                       containerURLForSecurityApplicationGroupIdentifier:
                           @"group.com.dajiu.stay.pro"] path] stringByAppendingPathComponent:@".ContentFilter"];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:self.path]){
            [[NSFileManager defaultManager] createDirectoryAtPath:self.path
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:nil];
        }
    }
    
    return self;
}

- (BOOL)existRuleJson:(NSString *)fileName{
    NSString *filePath = [self.path stringByAppendingPathComponent:fileName];
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    return exist;
}

- (void)writeToFileName:(NSString *)fileName content:(NSString *)content error:(NSError **)error{
    if ([content isEqualToString:@"[]"]){
        content = @"[{\"trigger\":{\"url-filter\":\"webkit.svg\"},\"action\":{\"type\":\"block\"}}]";
    }
    NSString *filePath = [self.path stringByAppendingPathComponent:fileName];
    [content writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:error];
    NSLog(@"writeToFileName %@",fileName);
}

- (NSURL *)contentURLOfFileName:(NSString *)fileName{
    NSString *filePath = [self.path stringByAppendingPathComponent:fileName];
    return [NSURL fileURLWithPath:filePath];
}

@end
