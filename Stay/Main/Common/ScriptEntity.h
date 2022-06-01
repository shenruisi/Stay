//
//  ScriptEntity.h
//  Stay
//
//  Created by zly on 2022/5/13.
//

#import <Foundation/Foundation.h>
#import "UserScript.h"
NS_ASSUME_NONNULL_BEGIN

@interface ScriptEntity : NSObject

@property (nonatomic, strong) UserScript *script;

@property (nonatomic, assign) BOOL needUpdate;

@property (nonatomic, strong) UserScript *updateScript;

- (NSDictionary *)toDictionary;

+ (instancetype)ofDictionary:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
