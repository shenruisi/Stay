//
//  DMStore.h
//  Stay
//
//  Created by Jin on 2022/11/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DMStore : NSObject

- (instancetype)init;
- (void)insert:(NSDictionary *)task;
- (void)remove:(NSString *)taskId;
- (void)removeAll:(NSString *)key;
- (void)update:(NSString *)taskId withDict:(NSDictionary *)info;
- (NSArray *)query:(nullable NSString *)taskId withKey:(nullable NSString *)key andStatus:(NSInteger)status;
@end

NS_ASSUME_NONNULL_END
