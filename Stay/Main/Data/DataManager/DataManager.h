//
//  DataManager.h
//  sqlite
//
//  Created by 朱凌云 on 16/3/18.
//  Copyright © 2016年 zly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserScript.h"


@interface DataManager : NSObject

+ (instancetype)shareManager;

- (NSArray *)findScript:(int)condition;

- (void)updateScrpitStatus:(int)status numberId:(NSString *)uuid;

- (UserScript *)selectScriptByUuid:(NSString *)uuid;

- (NSArray *)selectScriptByKeywordByAdded:(NSString *)keyword;

- (void)deleteScriptInUserScriptByNumberId:(NSString *)uuid;

- (void)insertUserConfigByUserScript:(UserScript *)scrpitDetail;

- (void)updateUserScript:(UserScript *)scrpitDetail;

- (void)updateScriptConfigAutoupdate:(int)status numberId:(NSString *)uuid;


- (void)updateScriptConfigBlackList:(NSString *)str numberId:(NSString *)uuid;

- (void)updateScriptConfigWhiteList:(NSString *)str numberId:(NSString *)uuid;

- (void)updateScriptConfigInjectInfo:(NSString *)str numberId:(NSString *)uuid;

- (void)updateScriptConfigStatus:(int)status numberId:(NSString *)uuid;

- (void)updateUsedTimesByUuid:(NSString *)uuid;


@end
