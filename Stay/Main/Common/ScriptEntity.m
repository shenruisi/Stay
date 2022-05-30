//
//  ScriptEntity.m
//  Stay
//
//  Created by zly on 2022/5/13.
//

#import "ScriptEntity.h"

@implementation ScriptEntity


- (NSDictionary *)toDictionary{
    return @{
        @"script":self.script ? self.script.toDictionary : @"",
        @"needUpdate":@(self.needUpdate),
        @"updateScript":self.updateScript ? self.updateScript.toDictionary : @""
   
    };
}

+ (instancetype)ofDictionary:(NSDictionary *)dic{
    ScriptEntity *script = [[ScriptEntity alloc] init];
    script.needUpdate = [dic[@"needUpdate"] boolValue];

    if(dic[@"updateScript"] != NULL && [dic[@"updateScript"] isKindOfClass:[NSDictionary class]]) {
        script.updateScript = [UserScript ofDictionary:dic[@"updateScript"]];
    }
    if(dic[@"script"] != NULL) {
        script.script = [UserScript ofDictionary:dic[@"script"]];
    }

    return script;
}

@end
