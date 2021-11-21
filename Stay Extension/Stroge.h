//
//  Stroge.h
//  Stay Extension
//
//  Created by ris on 2021/11/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Stroge : NSObject
+ (id)valueForKey:(NSString *)key uuid:(NSString *)uuid defaultValue:(id)defaultValue;
+ (void)setValue:(NSString *)value forKey:(NSString *)key uuid:(NSString *)uuid;
+ (NSDictionary *)listValues:(NSString *)uuid;
+ (void)deleteValueForKey:(NSString *)key uuid:(NSString *)uuid;
+ (void)removeByUUID:(NSString *)uuid;
@end

NS_ASSUME_NONNULL_END
