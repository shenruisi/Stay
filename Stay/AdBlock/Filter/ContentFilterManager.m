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

- (void)writeToFileName:(NSString *)fileName content:(NSString *)content{
    NSString *filePath = [self.path stringByAppendingPathComponent:fileName];
    NSError *error;
    [content writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
}

@end
