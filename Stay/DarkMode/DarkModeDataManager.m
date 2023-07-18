//
//  DarkModeThemeManager.m
//  Stay
//
//  Created by ris on 2023/7/18.
//

#import "DarkModeDataManager.h"

@interface DarkModeDataManager()

@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *themesPath;
@end

@implementation DarkModeDataManager

static DarkModeDataManager *instance = nil;
+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DarkModeDataManager alloc] init];
    });
    
    return instance;
}

- (instancetype)init{
    if (self = [super init]){
        if (![[NSFileManager defaultManager] fileExistsAtPath:self.path]){
            [[NSFileManager defaultManager] createDirectoryAtPath:self.path
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:nil];
        }
    }
    
    return self;
}

- (NSMutableArray<NSDictionary *> *)themes{
    NSData *jsonData = [NSData dataWithContentsOfFile:self.themesPath];
    if (nil == jsonData) return [[NSMutableArray alloc] init];
    NSMutableArray *jsonArray = [[NSMutableArray alloc] initWithArray:[NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil]];
    return jsonArray;
}


- (void)writeThemes:(NSMutableArray *)themesArray{
    NSError *error;
    NSData *newData = [NSJSONSerialization dataWithJSONObject:themesArray options:NSJSONWritingWithoutEscapingSlashes error:&error];
    if (error) return;
    [newData writeToFile:self.themesPath atomically:YES];
}

- (void)addTheme:(NSDictionary *)theme{
    NSMutableArray *themesArray = self.themes;
    [themesArray addObject:theme];
    [self writeThemes:themesArray];
}

- (void)modifyTheme:(NSDictionary *)newTheme{
    NSMutableArray *themesArray = self.themes;
    for (int i = 0; i < themesArray.count; i++){
        NSDictionary *theme = themesArray[i];
        if ([theme[@"value"] isEqualToString:newTheme[@"value"]]){
            [themesArray replaceObjectAtIndex:i withObject:newTheme];
            break;
        }
    }
    
    [self writeThemes:themesArray];
}


- (void)deleteTheme:(NSDictionary *)targetTheme{
    NSMutableArray *themesArray = self.themes;
    for (int i = 0; i < themesArray.count; i++){
        NSDictionary *theme = themesArray[i];
        if ([theme[@"value"] isEqualToString:targetTheme[@"value"]]){
            [themesArray removeObjectAtIndex:i];
            break;
        }
    }
    
    [self writeThemes:themesArray];
}

- (NSString *)themesPath{
    return [self.path stringByAppendingPathComponent:@"themes"];
}

- (NSString *)path{
    return [[[[NSFileManager defaultManager]
              containerURLForSecurityApplicationGroupIdentifier:
                  @"group.com.dajiu.stay.pro"] path] stringByAppendingPathComponent:@".DarkMode"];
}

@end
