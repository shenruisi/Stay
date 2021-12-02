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

- (NSArray *)findScriptInLib;

- (void)updateScrpitStatus:(int)status numberId:(NSString *)uuid;

- (NSArray *)selectScriptByKeywordByAdded:(NSString *)keyword;

- (NSArray *)selectScriptByKeywordByLib:(NSString *)keyword;

- (void)insertToUserScriptnumberId:(NSString *)uuid;

- (void)updateLibScrpitStatus:(int)status numberId:(NSString *)uuid;

- (void)deleteScriptInUserScriptByNumberId:(NSString *)uuid;

@end
