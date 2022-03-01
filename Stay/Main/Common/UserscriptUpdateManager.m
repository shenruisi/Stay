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
    
//        if(scrpit != nil && scrpit.requireUrls != nil){
//            for(int j = 0; j < scrpit.requireUrls.count; j++) {
//                NSString *requireUrl = scrpit.requireUrls[j];
//                NSString *fileName = requireUrl.lastPathComponent;
//                NSString *dirName = [NSString stringWithFormat:@"%@/%@/require",groupPath,scrpit.uuid];
//                if(![[NSFileManager defaultManager] fileExistsAtPath:dirName]){
//                    [[NSFileManager defaultManager] createDirectoryAtPath:dirName
//                                              withIntermediateDirectories:YES
//                                                               attributes:nil
//                                                                    error:nil];
//                }
//                NSString *strogeUrl = [NSString stringWithFormat:@"%@/%@/require/%@",groupPath,scrpit.uuid,fileName];
//                if(![[NSFileManager defaultManager] fileExistsAtPath:strogeUrl]) {
//                    NSURL *url = [NSURL URLWithString:requireUrl];
//                    if([url.scheme containsString:@"stay"]) {
//                        continue;
//                    } else {
//                        [[SYNetworkUtils shareInstance] requestGET:requireUrl params:nil successBlock:^(NSString * _Nonnull responseObject) {
//                            if(responseObject != nil) {
//                                [[NSFileManager defaultManager] createFileAtPath:strogeUrl contents:nil attributes:nil];
//                                [responseObject writeToFile:strogeUrl atomically:YES encoding:NSUTF8StringEncoding error:nil];
//                            }
//                        } failBlock:^(NSError * _Nonnull error) {
//
//                        }];
//                    }
//                }
//            }
//        }
        
        if(scrpit != nil && scrpit.resourceUrls != nil) {
            for(int j = 0; j < scrpit.resourceUrls.count; j++) {
                NSDictionary *resouseDic = scrpit.resourceUrls[j];
                NSArray *reouseKey = resouseDic.allKeys;
                for(int k = 0; k < reouseKey.count; k++) {
                    NSString *key = reouseKey[k];
                    NSString *dirName = [NSString stringWithFormat:@"%@/%@/resource",groupPath,scrpit.uuid];
                    if(![[NSFileManager defaultManager] fileExistsAtPath:dirName]){
                        [[NSFileManager defaultManager] createDirectoryAtPath:dirName
                                                  withIntermediateDirectories:YES
                                                                   attributes:nil
                                                                        error:nil];
                    }
                    NSString *strogeUrl = [NSString stringWithFormat:@"%@/%@/resource/%@",groupPath,scrpit.uuid,key];
                    if(![[NSFileManager defaultManager] fileExistsAtPath:strogeUrl]) {
                        NSURL *url = [NSURL URLWithString:resouseDic[key]];
                        if([url.scheme containsString:@"stay"]) {
                            continue;
                        } else {
                            [[SYNetworkUtils shareInstance] requestGET:key params:nil successBlock:^(NSString * _Nonnull responseObject) {
                                if(responseObject != nil) {
                                    [[NSFileManager defaultManager] createFileAtPath:strogeUrl contents:nil attributes:nil];
                                    BOOL isSuccess = [responseObject writeToFile:strogeUrl atomically:YES encoding:NSUTF8StringEncoding error:nil];
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


- (BOOL)saveRequireUrl:(UserScript *)scrpit {
    
    BOOL downloadSuccess = true;
    
    if(scrpit != nil && scrpit.requireUrls != nil){
        NSString *groupPath = [[[NSFileManager defaultManager]
                     containerURLForSecurityApplicationGroupIdentifier:
                         @"group.com.dajiu.stay.pro"] path];
        for(int j = 0; j < scrpit.requireUrls.count; j++) {
            NSString *requireUrl = scrpit.requireUrls[j];
            NSURLRequest *request = [[NSURLRequest alloc]initWithURL:requireUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
            NSError *error;
            NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
            NSString *fileName = requireUrl.lastPathComponent;
            if(error == nil && received != nil) {
                NSString *str = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
                NSString *strogeUrl = [NSString stringWithFormat:@"%@/%@/require/%@",groupPath,scrpit.uuid,fileName];
                if(![[NSFileManager defaultManager] fileExistsAtPath:strogeUrl]) {
                    [[NSFileManager defaultManager] createFileAtPath:strogeUrl contents:nil attributes:nil];
                    [str writeToFile:strogeUrl atomically:YES encoding:NSUTF8StringEncoding error:nil];
                }
            }
        }
    }
    
    return downloadSuccess;
}

- (BOOL)saveResourceUrl:(UserScript *)scrpit {
    
    BOOL downloadSuccess = true;
    NSString *groupPath = [[[NSFileManager defaultManager]
                 containerURLForSecurityApplicationGroupIdentifier:
                     @"group.com.dajiu.stay.pro"] path];
    if(scrpit != nil && scrpit.resourceUrls != nil) {
        for(int j = 0; j < scrpit.resourceUrls.count; j++) {
            NSDictionary *resouseDic = scrpit.resourceUrls[j];
            NSArray *reouseKey = resouseDic.allKeys;
            for(int k = 0; k < reouseKey.count; k++) {
                NSString *key = reouseKey[k];
                NSString *dirName = [NSString stringWithFormat:@"%@/%@/resource",groupPath,scrpit.uuid];
                if(![[NSFileManager defaultManager] fileExistsAtPath:dirName]){
                    [[NSFileManager defaultManager] createDirectoryAtPath:dirName
                                              withIntermediateDirectories:YES
                                                               attributes:nil
                                                                    error:nil];
                }
                NSString *strogeUrl = [NSString stringWithFormat:@"%@/%@/resource/%@",groupPath,scrpit.uuid,key];
                if(![[NSFileManager defaultManager] fileExistsAtPath:strogeUrl]) {
                    NSURL *url = [NSURL URLWithString:resouseDic[key]];
                    if([url.scheme containsString:@"stay"]) {
                        continue;
                    } else {
                        [[SYNetworkUtils shareInstance] requestGET:key params:nil successBlock:^(NSString * _Nonnull responseObject) {
                            if(responseObject != nil) {
                                [[NSFileManager defaultManager] createFileAtPath:strogeUrl contents:nil attributes:nil];
                                BOOL isSuccess = [responseObject writeToFile:strogeUrl atomically:YES encoding:NSUTF8StringEncoding error:nil];
                            }
                        } failBlock:^(NSError * _Nonnull error) {
                        
                        }];
                    }
                }
            }
        }
    }
    
    return downloadSuccess;
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
