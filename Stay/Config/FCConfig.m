//
//  FCConfig.m
//  Stay
//
//  Created by ris on 2022/6/20.
//

#import "FCConfig.h"
#import "SharedStorageManager.h"
#import "DeviceHelper.h"

@interface FCConfig(){
    NSUserDefaults *_groupUserDefaults;
}

@end

@implementation FCConfig

static FCConfig *k_config = nil;
+ (instancetype)shared{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
         if (nil == k_config){
               k_config = [[FCConfig alloc] init];
           }
    });
   
    
    return k_config;
}


- (id)init{
    if (self = [super init]){
        [self setValueOfKey:GroupUserDefaultsKeyMacMainWindowFrame value:@{@"x":@(-1),@"y":@(-1),@"width":@(850),@"height":@(550)} setWhenNil:YES];
        [self setBoolValueOfKey:GroupUserDefaultsKeySyncEnabled value:NO setWhenNil:YES];
        [self setStringValueOfKey:GroupUserDefaultsKeyLastSync value:@"" setWhenNil:YES];
        NSString *deviceID = [self getStringValueOfKey:GroupUserDefaultsKeyDeviceUUID];
        if (deviceID.length > 0){
            [DeviceHelper saveUUID:deviceID];
        }
        else{
            deviceID = [DeviceHelper uuid];
            if (deviceID.length == 0){
                deviceID = [UIDevice currentDevice].identifierForVendor.UUIDString;
                [DeviceHelper saveUUID:deviceID];
            }
        }
        [self setStringValueOfKey:GroupUserDefaultsKeyDeviceUUID value:deviceID setWhenNil:YES];
        [SharedStorageManager shared].userDefaultsExRO.deviceID = deviceID;
        [self setStringValueOfKey:GroupUserDefaultsKeyAppearanceMode value:@"System" setWhenNil:YES];
        [self setIntegerValueOfKey:GroupUserDefaultsKeyM3U8Concurrency value:10 setWhenNil:YES];
    }
    
    return self;
}

- (NSUserDefaults *)groupUserDefaults{
    if (nil == _groupUserDefaults){
        _groupUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dajiu.stay"];
    }
    
    return _groupUserDefaults;
}

- (id)getValueOfKey:(GroupUserDefaultsKey)key{
    return [[self groupUserDefaults] objectForKey:StringOfInt(key)];
}

- (BOOL)getBoolValueOfKey:(GroupUserDefaultsKey)key{
     return [[[self groupUserDefaults] objectForKey:StringOfInt(key)] boolValue];
}

- (NSInteger)getIntegerValueOfKey:(GroupUserDefaultsKey)key{
     return [[[self groupUserDefaults] objectForKey:StringOfInt(key)] intValue];
}

- (NSString *)getStringValueOfKey:(GroupUserDefaultsKey)key{
     return [[self groupUserDefaults] objectForKey:StringOfInt(key)];
}

- (void)setValueOfKey:(GroupUserDefaultsKey)key value:(id)value setWhenNil:(BOOL)setWhenNil{
    if (setWhenNil && nil != [self getValueOfKey:key]){
        return;
    }
    
    [[self groupUserDefaults] setValue:value forKey:StringOfInt(key)];
}

- (void)setBoolValueOfKey:(GroupUserDefaultsKey)key value:(BOOL)value setWhenNil:(BOOL)setWhenNil{
    if (setWhenNil && nil != [self getValueOfKey:key]){
        return;
    }
    
    [[self groupUserDefaults] setValue:@(value) forKey:StringOfInt(key)];
}

- (void)setIntegerValueOfKey:(GroupUserDefaultsKey)key value:(NSInteger)value setWhenNil:(BOOL)setWhenNil{
    if (setWhenNil && nil != [self getValueOfKey:key]){
           return;
    }
       
    [[self groupUserDefaults] setValue:@(value) forKey:StringOfInt(key)];
}

- (void)setStringValueOfKey:(GroupUserDefaultsKey)key value:(NSString *)value setWhenNil:(BOOL)setWhenNil{
    if (setWhenNil && nil != [self getValueOfKey:key]){
           return;
    }
       
    [[self groupUserDefaults] setValue:value forKey:StringOfInt(key)];
}


- (void)setValueOfKey:(GroupUserDefaultsKey)key value:(id)value{
    [self setValueOfKey:key value:value setWhenNil:NO];
}

- (void)setBoolValueOfKey:(GroupUserDefaultsKey)key value:(BOOL)value{
    [self setBoolValueOfKey:key value:value setWhenNil:NO];
}

- (void)setIntegerValueOfKey:(GroupUserDefaultsKey)key value:(NSInteger)value{
    [self setIntegerValueOfKey:key value:value setWhenNil:NO];
}

- (void)setStringValueOfKey:(GroupUserDefaultsKey)key value:(NSString *)value{
    [self setStringValueOfKey:key value:value setWhenNil:NO];
}

@end
