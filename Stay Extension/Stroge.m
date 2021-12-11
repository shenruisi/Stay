//
//  Stroge.m
//  Stay Extension
//
//  Created by ris on 2021/11/19.
//

#import "Stroge.h"

@implementation Stroge

+ (id)valueForKey:(NSString *)key uuid:(NSString *)uuid defaultValue:(id)defaultValue{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:uuid];
    id value = [userDefaults objectForKey:key];
    if (nil == value){
        return defaultValue;
    }
    
    return value;
}

+ (void)setValue:(NSString *)value forKey:(NSString *)key uuid:(NSString *)uuid{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:uuid];
    [userDefaults setObject:value forKey:key];
}

+ (NSDictionary *)listValues:(NSString *)uuid{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:uuid];
    return [userDefaults dictionaryRepresentation];
}

+ (void)deleteValueForKey:(NSString *)key uuid:(NSString *)uuid{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:uuid];
    [userDefaults removeObjectForKey:key];
}

+ (void)removeByUUID:(NSString *)uuid{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:uuid];
    [userDefaults removeSuiteNamed:uuid];
}

@end
