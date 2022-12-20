//
//  DataManager.h
//  sqlite
//
//  Created by 朱凌云 on 16/3/18.
//  Copyright © 2016年 zly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserScript.h"
#import "DownloadResource.h"


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

- (void)updateUsedTimesByUuid:(NSString *)uuid count:(int)count;

- (void)updateUserScriptByIcloud:(UserScript *)scrpitDetail;

- (void)updateUserScriptTime:(NSString *)uuid;

- (void)addDownloadResource:(DownloadResource *)resource;

- (NSArray *)selectDownloadResourceByPath:(NSString *)path;

- (DownloadResource *)selectDownloadResourceByDownLoadUUid:(NSString *)uuid;

- (void)updateDownloadResourcProcess:(float)process uuid:(NSString *)uuid;

- (void)updateDownloadResourceStatus:(NSInteger)status uuid:(NSString *)uuid;

- (void)updateVideoDuration:(NSInteger)videoDuration uuid:(NSString *)uuid;

- (void)updateWatchProgress:(NSInteger)watchProgress uuid:(NSString *)uuid;

- (void)deleteVideoByuuid:(NSString *)uuid;

- (NSArray *)selectUnDownloadComplete:(NSString *)path;

- (NSArray *)selectDownloadComplete:(NSString *)path;

- (void)updateIconByuuid:(UIImage *)image uuid:(NSString *)uuid;


@end
