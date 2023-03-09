//
//  ScriptMananger.m
//  Stay
//
//  Created by zly on 2022/5/13.
//

#import "ScriptMananger.h"
#import "DataManager.h"
#import "ScriptEntity.h"
#import "SYNetworkUtils.h"
#import "Tampermonkey.h"
#import "SYVersionUtils.h"

@implementation ScriptMananger


+ (instancetype)shareManager {
    
    static ScriptMananger *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[ScriptMananger alloc] init];
        [instance queryScript];
        [instance buildData];
    });
    
//    [instance checkScript];

    return instance;
    
}

- (void)buildData{

    NSArray *array = [[DataManager shareManager] findScript:1];
    
    if(array != NULL) {
        for(int i = 0; i < array.count; i++) {
            ScriptEntity *scriptEntity = [[ScriptEntity alloc] init];
            UserScript *scrpit = array[i];
            scriptEntity.script = scrpit;
            if(self.scriptDic[scrpit.uuid]  == nil) {
                self.scriptDic[scrpit.uuid] = scriptEntity;
            } else {
                scriptEntity = self.scriptDic[scrpit.uuid];
            }
            
            if(scrpit.updateUrl != NULL && scrpit.updateUrl.length > 0 && !scrpit.updateSwitch) {
                [[SYNetworkUtils shareInstance] requestGET:scrpit.updateUrl params:nil successBlock:^(NSString * _Nonnull responseObject) {
                    if(responseObject != nil) {
                        UserScript *userScript = [[Tampermonkey shared] parseWithScriptContent:responseObject];
                        if(userScript.version != NULL) {
                            NSInteger status =  [SYVersionUtils compareVersion:userScript.version toVersion:scrpit.version];
                            if(status == 1) {
                                if(userScript.downloadUrl == nil || userScript.downloadUrl.length <= 0){
                                    if(userScript.content != nil && userScript.content.length > 0) {
                                        userScript.uuid = scrpit.uuid;
                                        userScript.active = scrpit.active;
                                        scriptEntity.updateScript = userScript;
                                        scriptEntity.needUpdate = true;
                                        [self updateScript];
                                    } else {
                                        scriptEntity.needUpdate = false;
                                    }
                                } else {
                                    [[SYNetworkUtils shareInstance] requestGET:scrpit.downloadUrl params:nil successBlock:^(NSString * _Nonnull responseObject) {
                                        if(responseObject != nil) {
                                            UserScript *userScript = [[Tampermonkey shared] parseWithScriptContent:responseObject];
                                            userScript.uuid = scrpit.uuid;
                                            userScript.active = scrpit.active;
                                            if(userScript != nil && userScript.errorMessage != nil && userScript.errorMessage.length <= 0) {
                                                scriptEntity.updateScript = userScript;
                                                scriptEntity.needUpdate = true;
                                                [self updateScript];


                                            }else {
                                                scriptEntity.needUpdate = false;
                                            }
                                        }
                                    } failBlock:^(NSError * _Nonnull error) {
                                        
                                    }];
                                }
                            }
                        }
                        
                    }
                } failBlock:^(NSError * _Nonnull error) {
                            
                }];
            } else if(scrpit.downloadUrl != NULL && scrpit.downloadUrl.length > 0 && !scrpit.updateSwitch) {
                [[SYNetworkUtils shareInstance] requestGET:scrpit.downloadUrl params:nil successBlock:^(NSString * _Nonnull responseObject) {
                    if(responseObject != nil) {
                        UserScript *userScript = [[Tampermonkey shared] parseWithScriptContent:responseObject];
                        if(userScript.version != NULL) {
                            NSInteger status = [SYVersionUtils compareVersion:userScript.version toVersion:scrpit.version];
                            if(status == 1) {
                                userScript.uuid = scrpit.uuid;
                                userScript.active = scrpit.active;
                                if(userScript != nil && userScript.errorMessage != nil && userScript.errorMessage.length <= 0) {
                                    scriptEntity.updateScript = userScript;
                                    scriptEntity.needUpdate = true;
                                    [self updateScript];
                                }else {
                                    scriptEntity.needUpdate = false;
                                }
                            }
                        }
                    }
                } failBlock:^(NSError * _Nonnull error) {
                    
                }];
            }
        }
            
        [self checkScript];
    }
        
}


- (void)checkScript {
    
    NSArray *array = [self scriptDic].allKeys;
    
    for(int i = 0; i < array.count; i++) {
        NSString *uuid = array[i];
        UserScript *scritp = [[DataManager shareManager] selectScriptByUuid:uuid];
        if (scritp == NULL || scritp.uuid == nil) {
            [[self scriptDic] removeObjectForKey:uuid];
        } else {
            ScriptEntity *scriptEntity = self.scriptDic[uuid];
            scriptEntity.script = scritp;
            if (scriptEntity.updateScript != NULL && [scritp.version isEqualToString:scriptEntity.updateScript.version]) {
                scriptEntity.needUpdate = false;
                scriptEntity.updateScript = nil;
            } else if(scriptEntity.updateScript == nil || scriptEntity.updateScript.content == nil) {
                scriptEntity.needUpdate = false;
            }
        }
    }
    [self saveScript];
}

- (void)updateScript {
    NSNotification *notification = [NSNotification notificationWithName:@"needUpdate" object:nil];
    [[NSNotificationCenter defaultCenter]postNotification:notification];
}


- (void)refreshData{
    NSArray *array = [[DataManager shareManager] findScript:1];
    if(array != NULL) {
        for(int i = 0; i < array.count; i++) {
            ScriptEntity *scriptEntity = [[ScriptEntity alloc] init];
            UserScript *scrpit = array[i];
            scriptEntity.script = scrpit;
            if(self.scriptDic[scrpit.uuid]  == nil) {
                self.scriptDic[scrpit.uuid] = scriptEntity;
            }
        }
    }
    [self checkScript];
}


- (void)saveScript {
    NSUserDefaults *groupUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dajiu.stay.pro"];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    for(NSString *uuid in self.scriptDic.allKeys) {
        
       ScriptEntity *entity = self.scriptDic[uuid];
        
        dic[uuid] = [entity toDictionary];
    }
    
    [groupUserDefaults setObject:dic forKey:@"SCRIPT_INSTANCE"];
    [groupUserDefaults synchronize];
}

- (void)queryScript {
    NSUserDefaults *groupUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dajiu.stay.pro"];
    if([groupUserDefaults dictionaryForKey:@"SCRIPT_INSTANCE"] != NULL && [groupUserDefaults dictionaryForKey:@"SCRIPT_INSTANCE"].allValues.count > 0){
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[groupUserDefaults dictionaryForKey:@"SCRIPT_INSTANCE"]];
        
        for(NSString *uuid in dic.allKeys) {
            self.scriptDic[uuid] = [ScriptEntity ofDictionary:dic[uuid]];
        }
        
        
    }

}

- (NSMutableDictionary *)scriptDic {
    if(_scriptDic == nil) {
        _scriptDic = [NSMutableDictionary dictionary];
    }
    return _scriptDic;
}

@end
