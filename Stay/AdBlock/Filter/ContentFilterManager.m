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
@property (nonatomic, strong) NSString *truestSitesPath;
@property (nonatomic, strong) NSString *ruleJSONStoppedPath;
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
        
        self.truestSitesPath = [[[[NSFileManager defaultManager]
                       containerURLForSecurityApplicationGroupIdentifier:
                           @"group.com.dajiu.stay.pro"] path] stringByAppendingPathComponent:@".TruestSites"];
        
        self.ruleJSONStoppedPath = [[[[NSFileManager defaultManager]
                       containerURLForSecurityApplicationGroupIdentifier:
                           @"group.com.dajiu.stay.pro"] path] stringByAppendingPathComponent:@".ContentFilterJSONStopped"];
        
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
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:self.truestSitesPath]){
            [[NSFileManager defaultManager] createDirectoryAtPath:self.truestSitesPath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:nil];
        }
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:self.ruleJSONStoppedPath]){
            [[NSFileManager defaultManager] createDirectoryAtPath:self.ruleJSONStoppedPath
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

- (void)writeJSONToFileName:(NSString *)fileName data:(NSData *)data error:(NSError **)error{
    NSString *filePath = [self.ruleJSONPath stringByAppendingPathComponent:fileName];
    [data writeToFile:filePath atomically:YES];
    NSLog(@"writeToFileName %@ %@",fileName,*error);
}

- (void)writeJSONToFileName:(NSString *)fileName content:(NSString *)content error:(NSError **)error{
    if (content.length == 0 || [content isEqualToString:@"[]"]){
        content = @"[{\"trigger\":{\"url-filter\":\"webkit.svg\"},\"action\":{\"type\":\"block\"}}]";
    }
    NSString *filePath = [self.ruleJSONPath stringByAppendingPathComponent:fileName];
    [content writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:error];
    NSLog(@"writeToFileName %@ %@",fileName,*error);
}

- (void)writeJSONToFileName:(NSString *)fileName array:(NSArray *)array error:(NSError **)error{
    if (array.count == 0){
        array = @[
            @{
                @"trigger" : @{
                    @"url-filter" : @"webkit.svg"
                },
                @"action" : @{
                    @"type" : @"block"
                }
            }
        ];
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingWithoutEscapingSlashes error:error];
    NSString *filePath = [self.ruleJSONPath stringByAppendingPathComponent:fileName];
    if (error) return;
    [data writeToFile:filePath atomically:YES];;
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

- (NSArray<TruestedSite *> *)truestSites{
    NSString *filePath = [self.truestSitesPath stringByAppendingPathComponent:@"domianRule"];
    NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
    if (nil == jsonData) return @[];
    NSError *error;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if (error) return @[];
    
    NSArray *domains = jsonDictionary[@"trigger"][@"if-domain"];
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    for (NSString *domain in domains){
        TruestedSite *truestedSite = [[TruestedSite alloc] init];
        truestedSite.domain = domain;
        [ret addObject:truestedSite];
    }
    return ret;
}

- (void)addTruestSiteWithDomain:(NSString *)domain error:(NSError **)error{
    NSString *filePath = [self.truestSitesPath stringByAppendingPathComponent:@"domianRule"];
    NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
    NSMutableDictionary *dic;
    if (nil == jsonData){
        dic = [NSMutableDictionary dictionaryWithDictionary:@{
            @"trigger" : @{
                @"url-filter" : @".*",
                @"if-domain" : @[domain]
            },
            @"action" : @{
                @"type" : @"ignore-previous-rules"
            }
        }];
    }
    else{
        dic = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:0 error:error]];
        if (error) return;
        NSMutableArray *existDomains = [[NSMutableArray alloc] initWithArray:dic[@"trigger"][@"if-domian"]];
        [existDomains addObject:domain];
        dic[@"trigger"][@"if-domian"] = existDomains;
    }
    
    NSData *newData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingWithoutEscapingSlashes error:error];
    if (error) return;
    [newData writeToFile:filePath atomically:YES];
}

- (BOOL)existTruestSiteWithDomain:(NSString *)domain{
    NSArray<TruestedSite *> *truestSites = [self truestSites];
    for (TruestedSite *truestSite in truestSites){
        if ([truestSite.domain isEqualToString:domain]){
            return YES;
        }
    }
    
    return NO;
}

- (void)deleteTruestSiteWithDomain:(NSString *)domain{
    NSMutableArray<TruestedSite *> *truestSites = [[NSMutableArray alloc] initWithArray:[self truestSites]];
    NSMutableArray *domains = [[NSMutableArray alloc] init];
    for (int i = 0; i < truestSites.count; i++){
        TruestedSite *truestSite = truestSites[i];
        if (![truestSite.domain isEqualToString:domain]){
            [domains addObject:truestSite.domain];
        }
    }
    
    NSDictionary *dic = @{
        @"trigger" : @{
            @"url-filter" : @".*",
            @"if-domain" : domains
        },
        @"action" : @{
            @"type" : @"ignore-previous-rules"
        }
    };
    
    NSString *filePath = [self.truestSitesPath stringByAppendingPathComponent:@"domianRule"];
    NSData *newData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingWithoutEscapingSlashes error:nil];
    [newData writeToFile:filePath atomically:YES];
}

- (BOOL)ruleJSONStopped:(NSString *)fileName{
    NSString *filePath = [self.ruleJSONStoppedPath stringByAppendingPathComponent:fileName];
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

- (void)updateRuleJSON:(NSString *)fileName status:(NSUInteger)status{
    NSString *filePath = [self.ruleJSONStoppedPath stringByAppendingPathComponent:fileName];
    if (0 == status){
        [@"0" writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    else{
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
}

@end
 
