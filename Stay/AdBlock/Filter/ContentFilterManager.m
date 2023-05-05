//
//  ContentFilterManager.m
//  Stay
//
//  Created by ris on 2023/4/4.
//

#import "ContentFilterManager.h"

@interface ContentFilterManager()

@property (nonatomic, strong) NSString *ruleJSONPath;
@property (nonatomic, strong) NSString *ruleTextPath;
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
        self.ruleJSONPath = [[[[NSFileManager defaultManager]
                       containerURLForSecurityApplicationGroupIdentifier:
                           @"group.com.dajiu.stay.pro"] path] stringByAppendingPathComponent:@".ContentFilterJSON"];
        
        self.ruleTextPath = [[[[NSFileManager defaultManager]
                       containerURLForSecurityApplicationGroupIdentifier:
                           @"group.com.dajiu.stay.pro"] path] stringByAppendingPathComponent:@".ContentFilterText"];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:self.ruleJSONPath]){
            [[NSFileManager defaultManager] createDirectoryAtPath:self.ruleJSONPath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:nil];
        }
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:self.ruleTextPath]){
            [[NSFileManager defaultManager] createDirectoryAtPath:self.ruleTextPath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:nil];
        }
    }
    
    return self;
}

- (BOOL)existRuleJSON:(NSString *)fileName{
    NSString *filePath = [self.ruleJSONPath stringByAppendingPathComponent:fileName];
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    return exist;
}

- (void)writeJSONToFileName:(NSString *)fileName content:(NSString *)content error:(NSError **)error{
    if ([content isEqualToString:@"[]"]){
        content = @"[{\"trigger\":{\"url-filter\":\"webkit.svg\"},\"action\":{\"type\":\"block\"}}]";
    }
    NSString *filePath = [self.ruleJSONPath stringByAppendingPathComponent:fileName];
    [content writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:error];
    NSLog(@"writeToFileName %@ %@",fileName,*error);
}

- (void)appendJSONToFileName:(NSString *)fileName dictionary:(NSDictionary *)dictionary error:(NSError **)error{
    NSString *filePath = [self.ruleJSONPath stringByAppendingPathComponent:fileName];
    NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
    if (nil == jsonData){
        jsonData = [NSData data];
    }
    NSMutableArray *existJsonArray = [NSMutableArray arrayWithArray:[NSJSONSerialization JSONObjectWithData:jsonData options:0 error:error]];
    if (error) return;
    [existJsonArray addObject:dictionary];
    NSData *newData = [NSJSONSerialization dataWithJSONObject:existJsonArray options:NSJSONWritingWithoutEscapingSlashes error:error];
    if (error) return;
    [newData writeToFile:filePath atomically:YES];
}

- (void)writeTextToFileName:(NSString *)fileName content:(NSString *)content error:(NSError **)error{
    NSString *filePath = [self.ruleTextPath stringByAppendingPathComponent:fileName];
    [content writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:error];
}

- (void)appendTextToFileName:(NSString *)fileName content:(NSString *)content error:(NSError **)error{
    NSString *filePath = [self.ruleTextPath stringByAppendingPathComponent:fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        BOOL success = [[NSFileManager defaultManager]  createFileAtPath:filePath contents:nil attributes:nil];
        if (!success) {
            return;
        }
    }
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    [fileHandle seekToEndOfFile];
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    [fileHandle writeData:data];
    [fileHandle closeFile];
}

- (NSArray *)ruleJSONArray:(NSString *)fileName error:(NSError **)error{
    NSString *filePath = [self.ruleJSONPath stringByAppendingPathComponent:fileName];
    NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
    if (nil == jsonData) return @[];
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:error];
    return jsonArray;
}


- (NSURL *)ruleJSONURLOfFileName:(NSString *)fileName{
    NSString *filePath = [self.ruleJSONPath stringByAppendingPathComponent:fileName];
    return [NSURL fileURLWithPath:filePath];
}

@end
 
