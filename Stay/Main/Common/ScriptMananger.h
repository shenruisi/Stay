//
//  ScriptMananger.h
//  Stay
//
//  Created by zly on 2022/5/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScriptMananger : NSObject


// 数据源数组
@property (nonatomic, strong) NSMutableDictionary *scriptDic;

+ (instancetype)shareManager;

- (void)buildData;

- (void)refreshData;

@end

NS_ASSUME_NONNULL_END
