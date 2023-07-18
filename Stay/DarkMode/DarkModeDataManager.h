//
//  DarkModeDataManager.h
//  Stay
//
//  Created by ris on 2023/7/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DarkModeDataManager : NSObject

+ (instancetype)shared;
- (NSMutableArray<NSDictionary *> *)themes;
- (void)addTheme:(NSDictionary *)theme;
- (void)modifyTheme:(NSDictionary *)newTheme;
- (void)deleteTheme:(NSDictionary *)targetTheme;
@end

NS_ASSUME_NONNULL_END
