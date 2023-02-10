//
//  FCConfig.h
//  Stay
//
//  Created by ris on 2022/6/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define StringOfInt(i) [NSString stringWithFormat:@"%ld",i]

typedef enum : NSInteger {
    GroupUserDefaultsKeyMacMainWindowFrame = 1000,
    GroupUserDefaultsKeyMacPrimaryWidth,
    GroupUserDefaultsKeySyncEnabled = 10000,
    GroupUserDefaultsKeyLastSync,
    GroupUserDefaultsKeyDeviceUUID,
    GroupUserDefaultsKeyAppearanceMode = 20000,
    GroupUserDefaultsKeyM3U8Concurrency,
} GroupUserDefaultsKey;

@interface FCConfig : NSObject

+ (instancetype)shared;

#pragma mark *** get value ***
- (id)getValueOfKey:(GroupUserDefaultsKey)key;
- (NSString *)getStringValueOfKey:(GroupUserDefaultsKey)key;
- (BOOL)getBoolValueOfKey:(GroupUserDefaultsKey)key;
- (NSInteger)getIntegerValueOfKey:(GroupUserDefaultsKey)key;

#pragma mark *** set value ***
- (void)setValueOfKey:(GroupUserDefaultsKey)key value:(id)value;
- (void)setBoolValueOfKey:(GroupUserDefaultsKey)key value:(BOOL)value;
- (void)setStringValueOfKey:(GroupUserDefaultsKey)key value:(NSString *)value;
- (void)setIntegerValueOfKey:(GroupUserDefaultsKey)key value:(NSInteger)value;

- (NSUserDefaults *)groupUserDefaults;
@end

NS_ASSUME_NONNULL_END
