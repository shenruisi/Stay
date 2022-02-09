//
//  UserscriptUpdateManager.m
//  Stay
//
//  Created by zly on 2022/2/7.
//

#import "UserscriptUpdateManager.h"
#import "DataManager.h"
#import "SYNetworkUtils.h"


@implementation UserscriptUpdateManager

+ (instancetype)shareManager {
    static UserscriptUpdateManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[UserscriptUpdateManager alloc] init];
        NSString *groupPath = [[[NSFileManager defaultManager]
                     containerURLForSecurityApplicationGroupIdentifier:
                         @"group.com.dajiu.stay.pro"] path];
        
        if(![[NSFileManager defaultManager] fileExistsAtPath:groupPath]){
            [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dajiu.stay.pro"];
        }
        
    });
    return instance;
}


- (void)updateResouse {
    NSArray *array = [[DataManager shareManager] findScript:1];
    if (array == nil || array.count == 0) {
        return;
    }
    for(int i = 0; i < array.count; i++) {
        UserScript *scrpit = array[i];
        NSString *groupPath = [[[NSFileManager defaultManager]
                     containerURLForSecurityApplicationGroupIdentifier:
                         @"group.com.dajiu.stay.pro"] path];
    
        if(scrpit != nil && scrpit.requireUrls != nil){
            for(int j = 0; j < scrpit.requireUrls.count; j++) {
                NSString *requireUrl = scrpit.requireUrls[j];
                NSString *fileName = requireUrl.lastPathComponent;
                NSString *dirName = [NSString stringWithFormat:@"%@/%@/require",groupPath,scrpit.uuid];
                if(![[NSFileManager defaultManager] fileExistsAtPath:dirName]){
                    [[NSFileManager defaultManager] createDirectoryAtPath:dirName
                                              withIntermediateDirectories:YES
                                                               attributes:nil
                                                                    error:nil];
                }
                NSString *strogeUrl = [NSString stringWithFormat:@"%@/%@/require/%@",groupPath,scrpit.uuid,fileName];
                if(![[NSFileManager defaultManager] fileExistsAtPath:strogeUrl]) {
                    NSURL *url = [NSURL URLWithString:requireUrl];
                    if([url.scheme containsString:@"stay"]) {
                        continue;
                    } else {
                        [[SYNetworkUtils shareInstance] requestGET:requireUrl params:nil successBlock:^(NSString * _Nonnull responseObject) {
                            if(responseObject != nil) {
                                [[NSFileManager defaultManager] createFileAtPath:strogeUrl contents:nil attributes:nil];
                                [responseObject writeToFile:strogeUrl atomically:YES encoding:NSUTF8StringEncoding error:nil];
                            }
                        } failBlock:^(NSError * _Nonnull error) {
                        
                        }];
                    }
                }
            }
        }
        
        if(scrpit != nil && scrpit.resourceUrls != nil) {
            for(int j = 0; j < scrpit.resourceUrls.count; j++) {
                NSDictionary *resouseDic = scrpit.resourceUrls[j];
                NSArray *reouseKey = resouseDic.allKeys;
                for(int k = 0; k < reouseKey.count; k++) {
                    NSString *key = reouseKey[k];
                    NSString *strogeUrl = [NSString stringWithFormat:@"%@/%@/resource/%@-url",groupPath,scrpit.uuid,key];
                    NSString *strogeTextUrl = [NSString stringWithFormat:@"%@/%@/resource/%@-text",groupPath,scrpit.uuid,key];
                    if(![[NSFileManager defaultManager] fileExistsAtPath:strogeUrl]) {
                        [key writeToFile:strogeUrl atomically:YES encoding:NSUTF8StringEncoding error:nil];
                    }
                    
                    if(![[NSFileManager defaultManager] fileExistsAtPath:strogeTextUrl]) {
                        NSURL *url = [NSURL URLWithString:key];
                        if([url.scheme containsString:@"stay"]) {
                            continue;
                        } else {
                            [[SYNetworkUtils shareInstance] requestGET:key params:nil successBlock:^(NSString * _Nonnull responseObject) {
                                if(responseObject != nil) {
                                    BOOL isSuccess = [responseObject writeToFile:strogeTextUrl atomically:YES encoding:NSUTF8StringEncoding error:nil];
                                }
                            } failBlock:^(NSError * _Nonnull error) {
                            
                            }];
                        }
                    }
                }
            }
        }
        
    }
}

- (NSArray *)getUserScriptRequireListByUserScript:(UserScript *)scrpit {
    if(scrpit != nil && scrpit.requireUrls != nil){
        NSString *groupPath = [[[NSFileManager defaultManager]
                     containerURLForSecurityApplicationGroupIdentifier:
                         @"group.com.dajiu.stay.pro"] path];
        NSMutableArray *requireList = [[NSMutableArray alloc] init];
        for(int j = 0; j < scrpit.requireUrls.count; j++) {
            NSString *requireUrl = scrpit.requireUrls[j];
            NSString *fileName = requireUrl.lastPathComponent;
            NSString *strogeUrl = [NSString stringWithFormat:@"%@/%@/require/%@",groupPath,scrpit.uuid,fileName];
            if(![[NSFileManager defaultManager] fileExistsAtPath:strogeUrl]) {
                return nil;
            }
            NSData *data=[NSData dataWithContentsOfFile:strogeUrl];
            NSString *responData =  [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            
            [requireList addObject:responData];
        }
        return requireList;
    }
    return nil;
}




@end
