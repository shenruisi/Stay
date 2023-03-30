//
//  Stroge.m
//  Stay Extension
//
//  Created by ris on 2021/11/19.
//

#import "Stroge.h"

@implementation Stroge

+ (id)valueForKey:(NSString *)key uuid:(NSString *)uuid defaultValue:(id)defaultValue{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [NSDictionary dictionaryWithDictionary:[userDefaults objectForKey:uuid]];
    id value = [dict objectForKey:key];
    if (nil == value){
        return defaultValue;
    }
    
    return value;
}

+ (void)setValue:(id)value forKey:(NSString *)key uuid:(NSString *)uuid{
    if (value == nil || key.length == 0 || uuid.length == 0) return;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[userDefaults objectForKey:uuid]];
    [dict setObject:value forKey:key];
    [userDefaults setObject:dict forKey:uuid];
    [userDefaults synchronize];
}

+ (NSDictionary *)listValues:(NSString *)uuid{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *res = [userDefaults objectForKey:uuid];
    return res == nil ? @{} : res;
}

+ (void)deleteValueForKey:(NSString *)key uuid:(NSString *)uuid{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[userDefaults objectForKey:uuid]];
    [dict removeObjectForKey:key];
    [userDefaults removeObjectForKey:key];
    [userDefaults setObject:dict forKey:uuid];
    [userDefaults synchronize];
}

+ (void)removeByUUID:(NSString *)uuid{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:uuid];
    [userDefaults synchronize];
}

@end
