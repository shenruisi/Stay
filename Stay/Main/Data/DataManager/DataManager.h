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
#import "ContentFilter2.h"

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

- (void)updateScriptConfigDisableWebsite:(NSString *)str numberId:(NSString *)uuid;


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

- (NSArray *)selectDownloadResourceByTitle:(NSString *)title;

- (void)updateVideoTitle:(NSString *)title uuid:(NSString *)uuid;

- (void)updateVideoPath:(NSString *)path uuid:(NSString *)uuid;

- (void)updateVideoAllPath:(NSString *)path uuid:(NSString *)uuid;

- (void)deleteVideoByuuidPath:(NSString *)uuid;

- (NSArray *)selectAllUnDownloadComplete;

//Content Filter
- (void)createContentFilterTable;
- (BOOL)insertContentFilter:(ContentFilter *)contentFilter error:(NSError **)error;
- (NSArray<ContentFilter *> *)selectContentFilters;
- (void)updateContentFilterStatus:(NSUInteger)status uuid:(NSString *)uuid;
- (void)updateContentFilterEnable:(NSUInteger)enable uuid:(NSString *)uuid;
- (void)updateContentFilterHomepage:(NSString *)homepage uuid:(NSString *)uuid;
- (void)updateContentFilterTitle:(NSString *)title uuid:(NSString *)uuid;
- (void)updateContentFilterRedirect:(NSString *)redirect uuid:(NSString *)uuid;
- (void)updateContentFilterExpires:(NSString *)expires uuid:(NSString *)uuid;
- (void)updateContentFilterVersion:(NSString *)version uuid:(NSString *)uuid;
- (void)updateContentFilterUpdateTime:(NSDate *)updateTime uuid:(NSString *)uuid;
- (void)updateContentFilterDownloadUrl:(NSString *)downloadUrl uuid:(NSString *)uuid;
- (void)updateContentFilterLoad:(NSUInteger)load uuid:(NSString *)uuid;
- (void)deleteContentFilterWithUUID:(NSString *)uuid;
@end
