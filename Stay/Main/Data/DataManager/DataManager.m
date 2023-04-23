//
//  DataManager.m
//  sqlite
//
//  Created by 朱凌云 on 16/3/18.
//  Copyright © 2016年 zly. All rights reserved.
//

#import "DataManager.h"
#import <sqlite3.h>
#import "ScriptDetailModel.h"
#import "Tampermonkey.h"
#import "SYVersionUtils.h"
#import "MyAdditions.h"

@implementation DataManager

+ (instancetype)shareManager {
    
    static DataManager *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[DataManager alloc] init];
        [instance copyFile2Documents:@"syScript.sqlite"];
        [instance recoverBadData];

    });
    return instance;
    
}


-(NSString*) copyFile2Documents:(NSString*)fileName
{
    NSFileManager*fileManager =[NSFileManager defaultManager];
    NSError*error;
    NSArray*paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];

    NSString*destPath =[documentsDirectory stringByAppendingPathComponent:fileName];

    //  如果目标目录也就是(Documents)目录没有数据库文件的时候，才会复制一份，否则不复制
    if(![fileManager fileExistsAtPath:destPath]){
        NSString* sourcePath =[[NSBundle mainBundle] pathForResource:@"scriptManager" ofType:@"sqlite"];
        if ([fileManager fileExistsAtPath:sourcePath]){
            [fileManager copyItemAtPath:sourcePath toPath:destPath error:&error];
        }
    } else {
        [self recoverBadData];
    }
    return destPath;
}

- (void)recoverBadData{
    if(![self isExitedColumn:@"switch"]){
        [self addColumn:@"user_config_script" column:@"updateUrl"];
        [self addColumn:@"user_config_script" column:@"downloadUrl"];
        [self addIntegerColumn:@"user_config_script" column:@"switch"];
        [self addColumn:@"script_config" column:@"updateUrl"];
        [self addColumn:@"script_config" column:@"downloadUrl"];
    }
    
    if(![self isExitedColumn:@"resourceUrl"]) {
        [self addColumn:@"user_config_script" column:@"resourceUrl"];
        [self addColumn:@"script_config" column:@"resourceUrl"];
    }
    
    if(![self isExitedColumn:@"notes"]) {
        [self addColumn:@"user_config_script" column:@"notes"];
        [self addColumn:@"script_config" column:@"notes"];
    }
    
    if(![self isExitedColumn:@"black_site"]) {
        [self addColumn:@"user_config_script" column:@"license"];
        [self addColumn:@"user_config_script" column:@"black_sites"];
        [self addColumn:@"user_config_script" column:@"white_sites"];
        [self addColumn:@"user_config_script" column:@"inject_info"];
    }
    
    if(![self isExitedColumn:@"iCloud_identifier"]) {
        [self addColumn:@"user_config_script" column:@"iCloud_identifier"];
    }
    
    if(![self isExitedColumn:@"status"]) {
        [self addColumn:@"user_config_script" column:@"status"];
    }
    if(![self isExitedColumn:@"used"]) {
        [self addColumn:@"user_config_script" column:@"used"];
    }
    
    if(![self isExitedColumn:@"platforms"]) {
        [self addColumn:@"user_config_script" column:@"platforms"];
        [self addColumn:@"user_config_script" column:@"stay_only"];

    }
    
    if(![self isExitedColumn:@"usedTimes"]) {
        [self addColumn:@"user_config_script" column:@"usedTimes" type:@"INTEGER"];
    }
    
    if(![self isExitedColumn:@"update_script_time"]) {
        [self addColumn:@"user_config_script" column:@"update_script_time"];

    }
    
    if(![self isExitedColumn:@"update_script_time"]) {
        [self addColumn:@"user_config_script" column:@"update_script_time"];

    }
    
    
    if(![self isExitedColumn:@"disabled_websites"]) {
        [self addColumn:@"user_config_script" column:@"disabled_websites"];
    }
    
    if(![self isExitedDownloadTable]) {
        [self createTable];
    }
    
    if(![self isExitedColumnInDownload:@"protect"]) {
        [self addColumn:@"download_resource" column:@"protect" type:@"INTEGER"];
        [self addColumn:@"download_resource" column:@"audioUrl"];
    }
    
//    [self deleteTable:@"content_filter"];
    if (![self existTable:@"content_filter" error:nil]){
        [self createContentFilterTable];
        ContentFilter *basic = [[ContentFilter alloc] init];
        basic.defaultTitle = NSLocalizedString(@"ContentFilterBasic", @"");
        basic.title = NSLocalizedString(@"ContentFilterBasic", @"");
        basic.path = @"Basic.txt";
        basic.rulePath = @"Basic.json";
        basic.defaultUrl = @"https://easylist.to/easylist/easylist.txt";
        basic.downloadUrl = @"https://easylist.to/easylist/easylist.txt";
        basic.enable = 0;
        basic.status = 1;
        basic.sort = 1;
        basic.expires = @"4 days (update frequency)";
        basic.version = @"202304190559";
        basic.homepage = @"https://easylist.to/";
        basic.uuid = [@"Basic" md5];
        basic.contentBlockerIdentifier = @"com.dajiu.stay.pro.Stay-Content-Basic";
        basic.type = ContentFilterTypeBasic;
        
        ContentFilter *privacy = [[ContentFilter alloc] init];
        privacy.defaultTitle = NSLocalizedString(@"ContentFilterPrivacy", @"");
        privacy.title = NSLocalizedString(@"ContentFilterPrivacy", @"");
        privacy.path = @"Privacy.txt";
        privacy.rulePath = @"Privacy.json";
        privacy.defaultUrl = @"https://easylist.to/easylist/easyprivacy.txt";
        privacy.downloadUrl = @"https://easylist.to/easylist/easyprivacy.txt";
        privacy.enable = 0;
        privacy.status = 1;
        privacy.sort = 2;
        privacy.expires = @"4 days (update frequency)";
        privacy.version = @"202304120535";
        privacy.homepage = @"https://easylist.to/";
        privacy.uuid = [@"Privacy" md5];
        privacy.contentBlockerIdentifier = @"com.dajiu.stay.pro.Stay-Content-Privacy";
        privacy.type = ContentFilterTypePrivacy;
        
        ContentFilter *region = [[ContentFilter alloc] init];
        region.defaultTitle = NSLocalizedString(@"ContentFilterRegion", @"");
        region.title = NSLocalizedString(@"ContentFilterRegion", @"");
        region.path = @"Region.txt";
        region.rulePath = @"Region.json";
        region.defaultUrl = @"https://easylist-downloads.adblockplus.org/easylistchina.txt";
        region.downloadUrl = @"https://easylist-downloads.adblockplus.org/easylistchina.txt";
        region.enable = 0;
        region.status = 1;
        region.sort = 3;
        region.expires = @"4 days (update frequency)";
        region.version = @"202304070640";
        region.homepage = @"https://github.com/easylist/easylistchina/";
        region.uuid = [@"Region" md5];
        region.contentBlockerIdentifier = @"com.dajiu.stay.pro.Stay-Content-Region";
        region.type = ContentFilterTypeRegion;
        
        ContentFilter *custom = [[ContentFilter alloc] init];
        custom.defaultTitle = NSLocalizedString(@"ContentFilterCustom", @"");
        custom.title = NSLocalizedString(@"ContentFilterCustom", @"");
        custom.rulePath = @"Custom.json";
        custom.defaultUrl = @"";
        custom.downloadUrl = @"";
        custom.enable = 0;
        custom.status = 1;
        custom.sort = 4;
        custom.uuid = [@"My Filters" md5];
        custom.contentBlockerIdentifier = @"com.dajiu.stay.pro.Stay-Content-Custom";
        custom.type = ContentFilterTypeCustom;
        
        ContentFilter *tag = [[ContentFilter alloc] init];
        tag.defaultTitle = NSLocalizedString(@"ContentFilterTag", @"");
        tag.title = NSLocalizedString(@"ContentFilterTag", @"");
        tag.rulePath = @"Tag.json";
        tag.defaultUrl = @"";
        tag.downloadUrl = @"";
        tag.enable = 0;
        tag.status = 1;
        tag.sort = 5;
        tag.uuid = [@"Webpage Tagging Rules" md5];
        tag.contentBlockerIdentifier = @"com.dajiu.stay.pro.Stay-Content-Tag";
        tag.type = ContentFilterTypeTag;
        
        [self insertContentFilter:basic error:nil];
        [self insertContentFilter:privacy error:nil];
        [self insertContentFilter:region error:nil];
        [self insertContentFilter:custom error:nil];
        [self insertContentFilter:tag error:nil];
        
    }
    
    return;
}

- (sqlite3 *)dbHandle{
    sqlite3 *sqliteHandle = NULL;
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];

    int result = sqlite3_open_v2([destPath UTF8String], &sqliteHandle, SQLITE_OPEN_READWRITE, NULL);
    
    if (result != SQLITE_OK) {
        return NULL;
    }
    return sqliteHandle;
}

- (BOOL)existTable:(NSString *)tableName error:(NSError **)error{
    sqlite3 *sqliteHandle = [self dbHandle];
    if (NULL == sqliteHandle){
        *error = [[NSError alloc] init];
        return NO;
    }
    NSString *sql = [NSString stringWithFormat:@"select count(*) from sqlite_master where type='table' and name = '%@'",tableName];
    sqlite3_stmt *stmt = NULL;
    int result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        sqlite3_close(sqliteHandle);
        return YES;
    }

    int activite = 0;
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        activite = sqlite3_column_int(stmt, 0);
        sqlite3_finalize(stmt);
    }
    sqlite3_close(sqliteHandle);
    return activite > 0;
}

- (void)deleteTable:(NSString *)tableName{
    sqlite3 *sqliteHandle = [self dbHandle];
    if (NULL == sqliteHandle){
        return;
    }
    
    NSString *sql = [NSString stringWithFormat:@"DROP TABLE '%@'",tableName];
    
    sqlite3_stmt *stmt = NULL;
    int result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        sqlite3_close(sqliteHandle);
        return ;
    }
    
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        sqlite3_finalize(stmt);
    }
    sqlite3_close(sqliteHandle);
    return;
}

- (void)createContentFilterTable{
    sqlite3 *sqliteHandle = [self dbHandle];
    if (NULL == sqliteHandle){
        return;
    }
    
    NSString *sql = @"CREATE TABLE 'content_filter' ('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 'title' TEXT, 'expires' TEXT, 'tags' TEXT, 'download_url' TEXT, 'homepage' TEXT,'status' INTEGER,'path' TEXT, 'version' TEXT, 'update_time' DOUBLE,'create_time' DOUBLE,'sort' INTEGER,'user_info' TEXT, 'uuid' TEXT, 'iCloud_identifier' TEXT, 'type' INTEGER,'content_blocker_identifier' TEXT, 'rule_path' TEXT,'default_title' TEXT, 'default_url' TEXT, 'enable' INTEGER, 'redirect' TEXT)";
    
    sqlite3_stmt *stmt = NULL;
    int result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        sqlite3_close(sqliteHandle);
        return ;
    }
    
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        sqlite3_finalize(stmt);
    }
    sqlite3_close(sqliteHandle);
    return;
}

- (BOOL)existContentFilter:(NSString *)uuid error:(NSError **)error{
    sqlite3 *sqliteHandle = [self dbHandle];
    if (NULL == sqliteHandle){
        *error = [[NSError alloc] init];
        return NO;
    }
    NSString *sql = [NSString stringWithFormat:@"select count(*) from content_filter where uuid='%@'",uuid];
    sqlite3_stmt *stmt = NULL;
    int result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        sqlite3_close(sqliteHandle);
        return YES;
    }
    
    int activite = 0;
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        activite = sqlite3_column_int(stmt, 0);
        sqlite3_finalize(stmt);
    }
    sqlite3_close(sqliteHandle);
    return activite > 0;
}

- (NSArray<ContentFilter *> *)selectContentFilters{
    sqlite3 *sqliteHandle = [self dbHandle];
    if (NULL == sqliteHandle){
        return nil;
    }
    
    NSString *sql = @"SELECT uuid,title,expires,tags,download_url,homepage,status,path,version,create_time,update_time,sort,user_info,iCloud_identifier,type,content_blocker_identifier,rule_path,enable,default_url,default_title,redirect FROM content_filter order by sort asc";
    
    sqlite3_stmt *stmt = NULL;
    int result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        sqlite3_close(sqliteHandle);
        return nil;
        
    }
    
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    while(sqlite3_step(stmt) == SQLITE_ROW) {
        
        ContentFilter *contentFilter = [[ContentFilter alloc] init];
        
        contentFilter.uuid = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 0)== NULL?"":(const char *)sqlite3_column_text(stmt, 0)];
        contentFilter.title = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)== NULL?"":(const char *)sqlite3_column_text(stmt, 1)];
        contentFilter.expires = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)== NULL?"":(const char *)sqlite3_column_text(stmt, 2)];
        NSString *tagsStr = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 3) == NULL?"":(const char *)sqlite3_column_text(stmt, 3)];
        NSArray<NSString *> *tagsArr = [tagsStr componentsSeparatedByString:@","];
        NSMutableArray *tags = [[NSMutableArray alloc] init];
        for (NSString *tagStr in tagsArr){
            [tags addObject:@([tagStr integerValue])];
        }
        contentFilter.tags = tags;
        contentFilter.downloadUrl = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)== NULL?"":(const char *)sqlite3_column_text(stmt, 4)];
        contentFilter.homepage =  [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 5)== NULL?"":(const char *)sqlite3_column_text(stmt, 5)];
        contentFilter.status = sqlite3_column_int(stmt, 6);
        contentFilter.path =  [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 7)== NULL?"":(const char *)sqlite3_column_text(stmt, 7)];
        contentFilter.version =  [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 8)== NULL?"":(const char *)sqlite3_column_text(stmt, 8)];
        double createTime = sqlite3_column_double(stmt, 9);
        contentFilter.createTime = [NSDate dateWithTimeIntervalSince1970:createTime/1000];
        double updateTime = sqlite3_column_double(stmt, 10);
        contentFilter.updateTime = [NSDate dateWithTimeIntervalSince1970:updateTime/1000];
        contentFilter.sort = sqlite3_column_int(stmt, 11);
        NSString *userInfoJsonStr = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 12)== NULL?"":(const char *)sqlite3_column_text(stmt, 12)];
        if (userInfoJsonStr.length > 0){
            contentFilter.userInfo = [NSJSONSerialization JSONObjectWithData:[userInfoJsonStr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        }
        contentFilter.iCloudIdentifier = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 13)== NULL?"":(const char *)sqlite3_column_text(stmt, 13)];
        contentFilter.type = sqlite3_column_int(stmt, 14);
        contentFilter.contentBlockerIdentifier = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 15)== NULL?"":(const char *)sqlite3_column_text(stmt, 15)];
        contentFilter.rulePath = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 16)== NULL?"":(const char *)sqlite3_column_text(stmt, 16)];
        contentFilter.enable = sqlite3_column_int(stmt, 17);
        contentFilter.defaultUrl = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 18)== NULL?"":(const char *)sqlite3_column_text(stmt, 18)];
        contentFilter.defaultTitle = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 19)== NULL?"":(const char *)sqlite3_column_text(stmt, 19)];
        contentFilter.redirect = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 20)== NULL?"":(const char *)sqlite3_column_text(stmt, 20)];
        
        [ret addObject:contentFilter];
    }

    sqlite3_finalize(stmt);
    sqlite3_close(sqliteHandle);
    
    return ret;
}

- (BOOL)insertContentFilter:(ContentFilter *)contentFilter error:(NSError **)error{
    sqlite3 *sqliteHandle = [self dbHandle];
    if (NULL == sqliteHandle){
        *error = [[NSError alloc] init];
        return NO;
    }
    
    NSString *sql = @"INSERT INTO content_filter (uuid, title, download_url, expires, homepage, status, path, version, sort,user_info,create_time,update_time,iCloud_identifier,tags,type,content_blocker_identifier,rule_path,enable,default_url,default_title,redirect) VALUES (?, ?, ?, ?, ?, ?, ?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(sqliteHandle, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        sqlite3_bind_text(statement, 1,[contentFilter.uuid UTF8String], -1,NULL);
        sqlite3_bind_text(statement, 2,contentFilter.title ? [contentFilter.title UTF8String]:NULL, -1,NULL);
        sqlite3_bind_text(statement, 3,contentFilter.downloadUrl ? [contentFilter.downloadUrl UTF8String]:NULL, -1,NULL);
        sqlite3_bind_text(statement, 4,contentFilter.expires ? [contentFilter.expires UTF8String]:NULL,-1,NULL);
        sqlite3_bind_text(statement, 5,contentFilter.homepage ? [contentFilter.homepage UTF8String]:NULL, -1,NULL);
        sqlite3_bind_int64(statement, 6, contentFilter.status);
        sqlite3_bind_text(statement, 7, contentFilter.path ? [contentFilter.path UTF8String] : NULL, -1,NULL);
        sqlite3_bind_text(statement, 8, contentFilter.version ? [contentFilter.version UTF8String] : NULL, -1,NULL);
        sqlite3_bind_int64(statement, 9, contentFilter.sort);
        
        NSString *json = nil;
        if (contentFilter.userInfo){
            json = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:contentFilter.userInfo options:0 error:nil] encoding:NSUTF8StringEncoding];
        }
       
        sqlite3_bind_text(statement, 10, json ? [json UTF8String] : NULL, -1,NULL);
        
        NSDate* now = [NSDate date];
        NSString *createTimeStr = [NSString stringWithFormat:@"%.0f", [now timeIntervalSince1970]*1000];
        NSString *updateTimeStr = [NSString stringWithFormat:@"%.0f", [now timeIntervalSince1970]*1000];
        if (contentFilter.createTime){
            createTimeStr = [NSString stringWithFormat:@"%.0f", [contentFilter.createTime timeIntervalSince1970]*1000];
        }
        sqlite3_bind_double(statement, 11, createTimeStr.doubleValue);
        
        if (contentFilter.updateTime){
            updateTimeStr = [NSString stringWithFormat:@"%.0f", [contentFilter.updateTime timeIntervalSince1970]*1000];
        }
        sqlite3_bind_double(statement, 12, updateTimeStr.doubleValue);
        
        sqlite3_bind_text(statement, 13, contentFilter.iCloudIdentifier ? [contentFilter.iCloudIdentifier UTF8String] : NULL, -1,NULL);
        NSMutableString *tags = [[NSMutableString alloc] init];
        for (NSUInteger i = 0; i < contentFilter.tags.count; i++){
            NSInteger tag = contentFilter.tags[i].integerValue;
            [tags appendFormat:@"%ld",tag];
            if (i != contentFilter.tags.count - 1){
                [tags appendString:@","];
            }
        }
        sqlite3_bind_text(statement, 14, [tags UTF8String], -1,NULL);
        sqlite3_bind_int64(statement, 15, contentFilter.type);
        sqlite3_bind_text(statement, 16, contentFilter.contentBlockerIdentifier ? [contentFilter.contentBlockerIdentifier UTF8String] : NULL, -1,NULL);
        sqlite3_bind_text(statement, 17, contentFilter.rulePath ? [contentFilter.rulePath UTF8String] : NULL, -1,NULL);
        sqlite3_bind_int64(statement, 18, contentFilter.enable);
        sqlite3_bind_text(statement, 19, contentFilter.defaultUrl ? [contentFilter.defaultUrl UTF8String] : NULL, -1,NULL);
        sqlite3_bind_text(statement, 20, contentFilter.defaultTitle ? [contentFilter.defaultTitle UTF8String] : NULL, -1,NULL);
        sqlite3_bind_text(statement, 21, contentFilter.redirect ? [contentFilter.redirect UTF8String] : NULL, -1,NULL);
    }
    
    NSInteger resultCode = sqlite3_step(statement);
    sqlite3_finalize(statement);
    sqlite3_close(sqliteHandle);
    return resultCode == SQLITE_DONE;
}


- (void)updateContentFilterStatus:(NSUInteger)status uuid:(NSString *)uuid{
    sqlite3 *sqliteHandle = [self dbHandle];
    if (NULL == sqliteHandle){
        return;
    }
    
    NSString *sql = @"UPDATE content_filter SET status = ? WHERE uuid = ? ";
    
    sqlite3_stmt *stmt = NULL;
    int result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return;
    }
//    绑定占位符
    sqlite3_bind_int(stmt, 1, (int)status);
    sqlite3_bind_text(stmt, 2, [uuid UTF8String], -1, NULL);
    sqlite3_step(stmt);
//    if (sqlite3_step(stmt) != SQLITE_DONE) {
//        sqlite3_finalize(stmt);
//    }
    sqlite3_finalize(stmt);
    sqlite3_close(sqliteHandle);
}

- (void)updateContentFilterEnable:(NSUInteger)enable uuid:(NSString *)uuid{
    sqlite3 *sqliteHandle = [self dbHandle];
    if (NULL == sqliteHandle){
        return;
    }
    
    NSString *sql = @"UPDATE content_filter SET enable = ? WHERE uuid = ? ";
    
    sqlite3_stmt *stmt = NULL;
    int result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return;
    }
//    绑定占位符
    sqlite3_bind_int(stmt, 1, (int)enable);
    sqlite3_bind_text(stmt, 2, [uuid UTF8String], -1, NULL);
    sqlite3_step(stmt);
//    if (sqlite3_step(stmt) != SQLITE_DONE) {
//        sqlite3_finalize(stmt);
//    }
    sqlite3_finalize(stmt);
    sqlite3_close(sqliteHandle);
}

- (void)updateContentFilterHomepage:(NSString *)homepage uuid:(NSString *)uuid{
    sqlite3 *sqliteHandle = [self dbHandle];
    if (NULL == sqliteHandle){
        return;
    }
    
    NSString *sql = @"UPDATE content_filter SET homepage = ? WHERE uuid = ? ";
    
    sqlite3_stmt *stmt = NULL;
    int result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return;
    }
//    绑定占位符
    sqlite3_bind_text(stmt, 1, [homepage UTF8String], -1, NULL);
    sqlite3_bind_text(stmt, 2, [uuid UTF8String], -1, NULL);
    sqlite3_step(stmt);
//    if (sqlite3_step(stmt) != SQLITE_DONE) {
//        sqlite3_finalize(stmt);
//    }
    sqlite3_finalize(stmt);
    sqlite3_close(sqliteHandle);
}

- (void)updateContentFilterTitle:(NSString *)title uuid:(NSString *)uuid{
    sqlite3 *sqliteHandle = [self dbHandle];
    if (NULL == sqliteHandle){
        return;
    }
    
    NSString *sql = @"UPDATE content_filter SET title = ? WHERE uuid = ? ";
    
    sqlite3_stmt *stmt = NULL;
    int result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return;
    }
//    绑定占位符
    sqlite3_bind_text(stmt, 1, [title UTF8String], -1, NULL);
    sqlite3_bind_text(stmt, 2, [uuid UTF8String], -1, NULL);
    sqlite3_step(stmt);
//    if (sqlite3_step(stmt) != SQLITE_DONE) {
//        sqlite3_finalize(stmt);
//    }
    sqlite3_finalize(stmt);
    sqlite3_close(sqliteHandle);
}

- (void)updateContentFilterRedirect:(NSString *)redirect uuid:(NSString *)uuid{
    sqlite3 *sqliteHandle = [self dbHandle];
    if (NULL == sqliteHandle){
        return;
    }
    
    NSString *sql = @"UPDATE content_filter SET redirect = ? WHERE uuid = ? ";
    
    sqlite3_stmt *stmt = NULL;
    int result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return;
    }
//    绑定占位符
    sqlite3_bind_text(stmt, 1, [redirect UTF8String], -1, NULL);
    sqlite3_bind_text(stmt, 2, [uuid UTF8String], -1, NULL);
    sqlite3_step(stmt);
//    if (sqlite3_step(stmt) != SQLITE_DONE) {
//        sqlite3_finalize(stmt);
//    }
    sqlite3_finalize(stmt);
    sqlite3_close(sqliteHandle);
}

- (void)updateContentFilterExpires:(NSString *)expires uuid:(NSString *)uuid{
    sqlite3 *sqliteHandle = [self dbHandle];
    if (NULL == sqliteHandle){
        return;
    }
    
    NSString *sql = @"UPDATE content_filter SET expires = ? WHERE uuid = ? ";
    
    sqlite3_stmt *stmt = NULL;
    int result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return;
    }
//    绑定占位符
    sqlite3_bind_text(stmt, 1, [expires UTF8String], -1, NULL);
    sqlite3_bind_text(stmt, 2, [uuid UTF8String], -1, NULL);
    sqlite3_step(stmt);
//    if (sqlite3_step(stmt) != SQLITE_DONE) {
//        sqlite3_finalize(stmt);
//    }
    sqlite3_finalize(stmt);
    sqlite3_close(sqliteHandle);
}

- (void)updateContentFilterVersion:(NSString *)version uuid:(NSString *)uuid{
    sqlite3 *sqliteHandle = [self dbHandle];
    if (NULL == sqliteHandle){
        return;
    }
    
    NSString *sql = @"UPDATE content_filter SET version = ? WHERE uuid = ? ";
    
    sqlite3_stmt *stmt = NULL;
    int result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return;
    }
//    绑定占位符
    sqlite3_bind_text(stmt, 1, [version UTF8String], -1, NULL);
    sqlite3_bind_text(stmt, 2, [uuid UTF8String], -1, NULL);
    sqlite3_step(stmt);
//    if (sqlite3_step(stmt) != SQLITE_DONE) {
//        sqlite3_finalize(stmt);
//    }
    sqlite3_finalize(stmt);
    sqlite3_close(sqliteHandle);
}

- (void)updateContentFilterUpdateTime:(NSDate *)updateTime uuid:(NSString *)uuid{
    sqlite3 *sqliteHandle = [self dbHandle];
    if (NULL == sqliteHandle){
        return;
    }
    
    NSString *sql = @"UPDATE content_filter SET update_time = ? WHERE uuid = ? ";
    
    sqlite3_stmt *stmt = NULL;
    int result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return;
    }
//    绑定占位符
    NSString *updateTimeStr = [NSString stringWithFormat:@"%.0f", [updateTime timeIntervalSince1970]*1000];
    sqlite3_bind_double(stmt, 1, updateTimeStr.doubleValue);
    sqlite3_bind_text(stmt, 2, [uuid UTF8String], -1, NULL);
    sqlite3_step(stmt);
//    if (sqlite3_step(stmt) != SQLITE_DONE) {
//        sqlite3_finalize(stmt);
//    }
    sqlite3_finalize(stmt);
    sqlite3_close(sqliteHandle);
}

- (void)updateContentFilterDownloadUrl:(NSString *)downloadUrl uuid:(NSString *)uuid{
    sqlite3 *sqliteHandle = [self dbHandle];
    if (NULL == sqliteHandle){
        return;
    }
    
    NSString *sql = @"UPDATE content_filter SET download_url = ? WHERE uuid = ? ";
    
    sqlite3_stmt *stmt = NULL;
    int result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return;
    }

    sqlite3_bind_text(stmt, 1, [downloadUrl UTF8String], -1, NULL);
    sqlite3_bind_text(stmt, 2, [uuid UTF8String], -1, NULL);
    sqlite3_step(stmt);
//    if (sqlite3_step(stmt) != SQLITE_DONE) {
//        sqlite3_finalize(stmt);
//    }
    sqlite3_finalize(stmt);
    sqlite3_close(sqliteHandle);
}

- (void)deleteScriptInUserScriptByNumberId:(NSString *)uuid{
    //打开数据库
    sqlite3 *sqliteHandle = NULL;
    int result = 0;
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];


    result = sqlite3_open([destPath
                           UTF8String], &sqliteHandle);
    
    if (result != SQLITE_OK) {
        
        NSLog(@"数据库文件打开失败");
        
        return;
    }
    
    //构造SQL语句

    NSString *sql = @"DELETE FROM user_config_script  WHERE uuid = ? ";
    
    sqlite3_stmt *stmt = NULL;
    result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return;
    }
//    绑定占位符
    sqlite3_bind_text(stmt, 1, [uuid UTF8String], -1, NULL);

    //执行SQL语句,代表找到一条符合条件的数据，如果有多条数据符合条件，则要循环调用
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        sqlite3_finalize(stmt);
    }
    sqlite3_close(sqliteHandle);
    
}

- (void)addIntegerColumn:(NSString *)tableName column:(NSString *)columnName{
    //打开数据库
    sqlite3 *sqliteHandle = NULL;
    int result = 0;
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];

    result = sqlite3_open([destPath
                           UTF8String], &sqliteHandle);
    
    if (result != SQLITE_OK) {
        NSLog(@"数据库文件打开失败");
        return;
    }
    NSString *sql = [NSString stringWithFormat:@"alter table '%@' add '%@' INTEGER DEFAULT 1",tableName,columnName];
    sqlite3_stmt *stmt = NULL;
    result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return ;
    }
    //执行SQL语句,代表找到一条符合条件的数据，如果有多条数据符合条件，则要循环调用
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        sqlite3_finalize(stmt);
    }
    sqlite3_close(sqliteHandle);
    return ;
    
}

- (void)addColumn:(NSString *)tableName column:(NSString *)columnName{
    //打开数据库
    sqlite3 *sqliteHandle = NULL;
    int result = 0;
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];

    result = sqlite3_open([destPath
                           UTF8String], &sqliteHandle);
    
    if (result != SQLITE_OK) {
        NSLog(@"数据库文件打开失败");
        return;
    }
    NSString *sql = [NSString stringWithFormat:@"alter table '%@' add '%@' text ",tableName,columnName];
    sqlite3_stmt *stmt = NULL;
    result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return ;
    }
    //执行SQL语句,代表找到一条符合条件的数据，如果有多条数据符合条件，则要循环调用
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        sqlite3_finalize(stmt);
    }
    sqlite3_close(sqliteHandle);
    return ;
    
}


- (void)addColumn:(NSString *)tableName column:(NSString *)columnName type:(NSString *)type{
    //打开数据库
    sqlite3 *sqliteHandle = NULL;
    int result = 0;
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];

    result = sqlite3_open([destPath
                           UTF8String], &sqliteHandle);
    
    if (result != SQLITE_OK) {
        NSLog(@"数据库文件打开失败");
        return;
    }
    NSString *sql = [NSString stringWithFormat:@"alter table '%@' add '%@' %@ default 0 ",tableName,columnName,type];
    sqlite3_stmt *stmt = NULL;
    result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return ;
    }
    //执行SQL语句,代表找到一条符合条件的数据，如果有多条数据符合条件，则要循环调用
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        sqlite3_finalize(stmt);
    }
    sqlite3_close(sqliteHandle);
    return ;
    
}



- (void)createTable{
    sqlite3 *sqliteHandle = NULL;
    int result = 0;
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];

    result = sqlite3_open([destPath
                           UTF8String], &sqliteHandle);
    
    if (result != SQLITE_OK) {
        NSLog(@"数据库文件打开失败");
        return ;
    }
    NSString *sql = @"CREATE TABLE 'download_resource' ('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 'title' TEXT, 'icon' TEXT, 'host' TEXT, 'download_url' TEXT, 'download_uuid' TEXT,'status' INTEGER,'download_process' DOUBLE, 'watch_process' INTEGER, 'videoDuration' INTEGER,'firstPath' TEXT,'allPath' TEXT,'type' TEXT,'update_time' DOUBLE,'create_time' DOUBLE,'sort' INTEGER,'use_info' TEXT)";

    sqlite3_stmt *stmt = NULL;
    result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return ;
    }
    //执行SQL语句,代表找到一条符合条件的数据，如果有多条数据符合条件，则要循环调用
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        sqlite3_finalize(stmt);
    }
    sqlite3_close(sqliteHandle);
    return ;
}

- (BOOL)isExitedDownloadTable{
    sqlite3 *sqliteHandle = NULL;
    int result = 0;
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];

    result = sqlite3_open([destPath
                           UTF8String], &sqliteHandle);
    
    if (result != SQLITE_OK) {
        NSLog(@"数据库文件打开失败");
        return true;
    }
    
    NSString *sql = @"select count(*) from sqlite_master where type='table' and name = 'download_resource'";
    sqlite3_stmt *stmt = NULL;
    result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return true;
    }
    //执行SQL语句,代表找到一条符合条件的数据，如果有多条数据符合条件，则要循环调用
    int activite = 0;
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        activite = sqlite3_column_int(stmt, 0);
        sqlite3_finalize(stmt);
    }
    sqlite3_close(sqliteHandle);
    return activite == 0? false:true;
}

- (BOOL)isExitedColumn:(NSString *)column {
    //打开数据库
    sqlite3 *sqliteHandle = NULL;
    int result = 0;
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];

    result = sqlite3_open([destPath
                           UTF8String], &sqliteHandle);
    
    if (result != SQLITE_OK) {
        NSLog(@"数据库文件打开失败");
        return true;
    }
    
    NSString *sql = @"select count(*) from sqlite_master where name='user_config_script' and sql like '%%%@%%'";
    sql = [NSString stringWithFormat:sql,column];
    sqlite3_stmt *stmt = NULL;
    result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return true;
    }
    //执行SQL语句,代表找到一条符合条件的数据，如果有多条数据符合条件，则要循环调用
    int activite = 0;
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        activite = sqlite3_column_int(stmt, 0);
        sqlite3_finalize(stmt);
    }
    sqlite3_close(sqliteHandle);
    return activite == 0? false:true;
}


- (BOOL)isExitedColumnInDownload:(NSString *)column {
    //打开数据库
    sqlite3 *sqliteHandle = NULL;
    int result = 0;
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];

    result = sqlite3_open([destPath
                           UTF8String], &sqliteHandle);
    
    if (result != SQLITE_OK) {
        NSLog(@"数据库文件打开失败");
        return true;
    }
    
    NSString *sql = @"select count(*) from sqlite_master where name='download_resource' and sql like '%%%@%%'";
    sql = [NSString stringWithFormat:sql,column];
    sqlite3_stmt *stmt = NULL;
    result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return true;
    }
    //执行SQL语句,代表找到一条符合条件的数据，如果有多条数据符合条件，则要循环调用
    int activite = 0;
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        activite = sqlite3_column_int(stmt, 0);
        sqlite3_finalize(stmt);
    }
    sqlite3_close(sqliteHandle);
    return activite == 0? false:true;
}


//根据条件查询一组用户，模糊查询 DQL
- (NSArray *)findScript:(int)condition {
    
    NSMutableArray *scriptList = [NSMutableArray array];
    
    //打开数据库
    sqlite3 *sqliteHandle = NULL;
    int result = 0;
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];


    result = sqlite3_open([destPath
                           UTF8String], &sqliteHandle);
    
    if (result != SQLITE_OK) {
        
        NSLog(@"数据库文件打开失败");
        
        return scriptList;
    }
    
    //构造SQL语句

    NSString *sql = @"SELECT * FROM user_config_script order by update_time desc";
    
    sqlite3_stmt *stmt = NULL;
    result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return scriptList;
        
    }
    
//    绑定占位符
//    NSString *queryCondition = [NSString stringWithFormat:@"%d", condition];
    sqlite3_bind_int(stmt, 1, condition);
    //执行SQL语句,代表找到一条符合条件的数据，如果有多条数据符合条件，则要循环调用
    while(sqlite3_step(stmt) == SQLITE_ROW) {
        
        UserScript *scrpitDetail = [[UserScript alloc] init];
        
        //第几列字段是从0开始
        scrpitDetail.uuid = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)== NULL?"":(const char *)sqlite3_column_text(stmt, 1)];
        scrpitDetail.name = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)== NULL?"":(const char *)sqlite3_column_text(stmt, 2)];
        scrpitDetail.namespace = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 3) == NULL?"":(const char *)sqlite3_column_text(stmt, 3)];
        scrpitDetail.author = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)== NULL?"":(const char *)sqlite3_column_text(stmt, 4)];
        scrpitDetail.version =  [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 5)== NULL?"":(const char *)sqlite3_column_text(stmt, 5)];
        scrpitDetail.desc = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 6)== NULL?"":(const char *)sqlite3_column_text(stmt, 6)];
        scrpitDetail.homepage = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 7)== NULL?"":(const char *)sqlite3_column_text(stmt, 7)];
        scrpitDetail.icon = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 8)== NULL?"":(const char *)sqlite3_column_text(stmt, 8)];
        
        NSString * includesStr = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 9)== NULL?"":(const char *)sqlite3_column_text(stmt, 9)];
        if (includesStr != NULL && includesStr.length > 0) {
            scrpitDetail.includes = [includesStr componentsSeparatedByString:@","];
        } else {
            scrpitDetail.includes = @[];
        }
        NSString * mathesStr = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 10)== NULL?"":(const char *)sqlite3_column_text(stmt, 10)];
        if (mathesStr != NULL && mathesStr.length > 0) {
            scrpitDetail.matches = [mathesStr componentsSeparatedByString:@","];
        } else {
            scrpitDetail.matches = @[];
        }
        NSString * excludesStr = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 11)== NULL?"":(const char *)sqlite3_column_text(stmt, 11)];
        if (excludesStr != NULL && excludesStr.length > 0) {
            scrpitDetail.excludes = [excludesStr componentsSeparatedByString:@","];
        } else {
            scrpitDetail.excludes = @[];
        }
        
        scrpitDetail.runAt = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 12)== NULL?"":(const char *)sqlite3_column_text(stmt, 12)];
        
        NSString * grantsStr = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 13)== NULL?"":(const char *)sqlite3_column_text(stmt, 13)];
        if (grantsStr != NULL && grantsStr.length > 0) {
            scrpitDetail.grants = [grantsStr componentsSeparatedByString:@","];
        } else {
            scrpitDetail.grants = @[];
        }
        
        
        int noframes = sqlite3_column_int(stmt, 14);
        scrpitDetail.noFrames = noframes == 0? false:true;
    
        scrpitDetail.content = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 15)== NULL?"":(const char *)sqlite3_column_text(stmt, 15)];
        
        int activite = sqlite3_column_int(stmt, 16);
        scrpitDetail.active = activite == 0? false:true;
        
        NSString * requiresUrlStr = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 17)== NULL?"":(const char *)sqlite3_column_text(stmt, 17)];
        if (requiresUrlStr != NULL && requiresUrlStr.length > 0) {
            scrpitDetail.requireUrls = [requiresUrlStr componentsSeparatedByString:@","];
        } else {
            scrpitDetail.requireUrls = @[];
        }
        
        
        NSString *sourcePage = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 18)== NULL?"":(const char *)sqlite3_column_text(stmt, 18)];
        
        scrpitDetail.sourcePage = sourcePage;

        double updateTime = sqlite3_column_double(stmt, 19);
        scrpitDetail.updateTime = [NSString stringWithFormat:@"%f", updateTime];
        
        NSString *updateUrl = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 20)== NULL?"":(const char *)sqlite3_column_text(stmt, 20)];
        scrpitDetail.updateUrl = updateUrl;
        NSString *downloadUrl = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 21)== NULL?"":(const char *)sqlite3_column_text(stmt, 21)];
        scrpitDetail.downloadUrl = downloadUrl;
        
        int updateSwitch = sqlite3_column_int(stmt, 22);
        scrpitDetail.updateSwitch = updateSwitch == 1? true:false;

        NSString * resourceUrl = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 23)== NULL?"":(const char *)sqlite3_column_text(stmt, 23)];
        if (resourceUrl != NULL && resourceUrl.length > 0) {
            NSData *jsonData = [resourceUrl dataUsingEncoding:NSUTF8StringEncoding];
            scrpitDetail.resourceUrls =  [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
        } else {
            scrpitDetail.resourceUrls = @{};
        }
        
        
        NSString * notesStr = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 24)== NULL?"":(const char *)sqlite3_column_text(stmt, 24)];
        if (notesStr != NULL && notesStr.length > 0) {
            scrpitDetail.notes = [notesStr componentsSeparatedByString:@","];
        } else {
            scrpitDetail.notes = @[];
        }
        
        NSString * license = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 25)== NULL?"":(const char *)sqlite3_column_text(stmt, 25)];

        scrpitDetail.license = license;
        
        NSString * blackListStr = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 26)== NULL?"":(const char *)sqlite3_column_text(stmt, 26)];
        
        if (blackListStr != NULL && blackListStr.length > 0) {
            scrpitDetail.blacklist = [blackListStr componentsSeparatedByString:@","];
        } else {
            scrpitDetail.blacklist = @[];
        }
        
        NSString * whiteListStr = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 27)== NULL?"":(const char *)sqlite3_column_text(stmt, 27)];
        
        if (whiteListStr != NULL && whiteListStr.length > 0) {
            scrpitDetail.whitelist = [whiteListStr componentsSeparatedByString:@","];
        } else {
            scrpitDetail.whitelist = @[];
        }
        
        NSString * inject = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 28)== NULL?"":(const char *)sqlite3_column_text(stmt, 28)];

        scrpitDetail.injectInto = inject;
        
        NSString * iCloudIdentifier = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 29)== NULL?"":(const char *)sqlite3_column_text(stmt, 29)];
        scrpitDetail.iCloudIdentifier = iCloudIdentifier;
        
        int status = sqlite3_column_int(stmt, 30);
        scrpitDetail.status = status;

        
        NSString * platforms = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 32)== NULL?"":(const char *)sqlite3_column_text(stmt, 32)];
        if (platforms != NULL && platforms.length > 0) {
            scrpitDetail.plafroms = [platforms componentsSeparatedByString:@","];
        } else {
            scrpitDetail.plafroms = @[];
        }
        
        int stayOnly = sqlite3_column_int(stmt, 33);
        scrpitDetail.stayOnly = stayOnly == 1? true:false;
        
        
        int usedTimes = sqlite3_column_int(stmt, 34);
        scrpitDetail.usedTimes = usedTimes;
        
        
        NSString *updateScriptTime = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 35)== NULL?"":(const char *)sqlite3_column_text(stmt, 35)];
        scrpitDetail.updateScriptTime = updateScriptTime;
    
        
        NSString *disabledWebsites = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 36)== NULL?"":(const char *)sqlite3_column_text(stmt, 36)];
        
        if (disabledWebsites != NULL && disabledWebsites.length > 0) {
            scrpitDetail.disabledWebsites = [disabledWebsites componentsSeparatedByString:@","];
        } else {
            scrpitDetail.disabledWebsites = @[];
        }
        
        [[Tampermonkey shared] conventScriptContent:scrpitDetail];
        
        [scriptList addObject:scrpitDetail];
    }

    sqlite3_finalize(stmt);
    sqlite3_close(sqliteHandle);
    
    return scriptList;
}

- (void)updateScrpitStatus:(int)status numberId:(NSString *)uuid {
    //打开数据库
    sqlite3 *sqliteHandle = NULL;
    int result = 0;
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];


    result = sqlite3_open([destPath
                           UTF8String], &sqliteHandle);
    
    if (result != SQLITE_OK) {
        
        NSLog(@"数据库文件打开失败");
        
        return;
    }
    
    //构造SQL语句

    NSString *sql = @"UPDATE user_config_script SET active = ? WHERE uuid = ? ";
    
    sqlite3_stmt *stmt = NULL;
    result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return;
    }
//    绑定占位符
    sqlite3_bind_int(stmt, 1, status);
    sqlite3_bind_text(stmt, 2, [uuid UTF8String], -1, NULL);
//    if (sqlite3_prepare_v2(sqliteHandle, [sql UTF8String], -1, &stmt, nil) == SQLITE_OK)
//    {
//    }
    //执行SQL语句,代表找到一条符合条件的数据，如果有多条数据符合条件，则要循环调用
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        sqlite3_finalize(stmt);
    }
    sqlite3_close(sqliteHandle);
    
}

- (NSArray *)selectScriptByKeywordByAdded:(NSString *)keyword {
    NSMutableArray *scriptList = [NSMutableArray array];
    
    //打开数据库
    sqlite3 *sqliteHandle = NULL;
    int result = 0;
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];


    result = sqlite3_open([destPath
                           UTF8String], &sqliteHandle);
    
    if (result != SQLITE_OK) {
        
        NSLog(@"数据库文件打开失败");
        
        return scriptList;
    }
    
    //构造SQL语句

    NSString *sql= [NSString stringWithFormat:@"SELECT * FROM user_config_script WHERE name like '%%%@%%';",keyword];


    
    sqlite3_stmt *stmt = NULL;
    

    result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return scriptList;
        
    }
    
//    sqlite3_bind_text(stmt, 1, [keyword UTF8String], -1, NULL);
//    sqlite3_bind_text(stmt, 2, [keyword UTF8String], -1, NULL);
//    sqlite3_bind_text(stmt, 3, [keyword UTF8String], -1, NULL);

//    绑定占位符
//    NSString *queryCondition = [NSString stringWithFormat:@"%d", condition];
    //执行SQL语句,代表找到一条符合条件的数据，如果有多条数据符合条件，则要循环调用
    while(sqlite3_step(stmt) == SQLITE_ROW) {
        
        UserScript *scrpitDetail = [[UserScript alloc] init];
        
        //第几列字段是从0开始
        scrpitDetail.uuid = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)== NULL?"":(const char *)sqlite3_column_text(stmt, 1)];
        scrpitDetail.name = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)== NULL?"":(const char *)sqlite3_column_text(stmt, 2)];
        scrpitDetail.namespace = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 3) == NULL?"":(const char *)sqlite3_column_text(stmt, 3)];
        scrpitDetail.author = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)== NULL?"":(const char *)sqlite3_column_text(stmt, 4)];
        scrpitDetail.version =  [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 5)== NULL?"":(const char *)sqlite3_column_text(stmt, 5)];
        scrpitDetail.desc = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 6)== NULL?"":(const char *)sqlite3_column_text(stmt, 6)];
        scrpitDetail.homepage = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 7)== NULL?"":(const char *)sqlite3_column_text(stmt, 7)];
        scrpitDetail.icon = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 8)== NULL?"":(const char *)sqlite3_column_text(stmt, 8)];
        
        NSString * includesStr = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 9)== NULL?"":(const char *)sqlite3_column_text(stmt, 9)];
        if (includesStr != NULL && includesStr.length > 0) {
            scrpitDetail.includes = [includesStr componentsSeparatedByString:@","];
        } else {
            scrpitDetail.includes = @[];
        }
        NSString * mathesStr = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 10)== NULL?"":(const char *)sqlite3_column_text(stmt, 10)];
        if (mathesStr != NULL && mathesStr.length > 0) {
            scrpitDetail.matches = [mathesStr componentsSeparatedByString:@","];
        } else {
            scrpitDetail.matches = @[];
        }
        NSString * excludesStr = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 11)== NULL?"":(const char *)sqlite3_column_text(stmt, 11)];
        if (excludesStr != NULL && excludesStr.length > 0) {
            scrpitDetail.excludes = [excludesStr componentsSeparatedByString:@","];
        } else {
            scrpitDetail.excludes = @[];
        }
        
        scrpitDetail.runAt = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 12)== NULL?"":(const char *)sqlite3_column_text(stmt, 12)];
        
        NSString * grantsStr = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 13)== NULL?"":(const char *)sqlite3_column_text(stmt, 13)];
        if (grantsStr != NULL && grantsStr.length > 0) {
            scrpitDetail.grants = [grantsStr componentsSeparatedByString:@","];
        } else {
            scrpitDetail.grants = @[];
        }
        
        
        int noframes = sqlite3_column_int(stmt, 14);
        scrpitDetail.noFrames = noframes == 0? false:true;
    
        scrpitDetail.content = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 15)== NULL?"":(const char *)sqlite3_column_text(stmt, 15)];
        
        int activite = sqlite3_column_int(stmt, 16);
        scrpitDetail.active = activite == 0? false:true;
        
        NSString * requiresUrlStr = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 17)== NULL?"":(const char *)sqlite3_column_text(stmt, 17)];
        if (requiresUrlStr != NULL && requiresUrlStr.length > 0) {
            scrpitDetail.requireUrls = [requiresUrlStr componentsSeparatedByString:@","];
        } else {
            scrpitDetail.requireUrls = @[];
        }
        
        
        NSString *sourcePage = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 18)== NULL?"":(const char *)sqlite3_column_text(stmt, 18)];
        
        scrpitDetail.sourcePage = sourcePage;

        NSString *updateUrl = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 20)== NULL?"":(const char *)sqlite3_column_text(stmt, 20)];
        scrpitDetail.updateUrl = updateUrl;
        NSString *downloadUrl = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 21)== NULL?"":(const char *)sqlite3_column_text(stmt, 21)];
        scrpitDetail.downloadUrl = downloadUrl;
        int updateSwitch = sqlite3_column_int(stmt, 22);
        scrpitDetail.updateSwitch = updateSwitch == 1? true:false;
        
        NSString * license = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 25)== NULL?"":(const char *)sqlite3_column_text(stmt, 25)];

        scrpitDetail.license = license;
        
        NSString * blackListStr = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 26)== NULL?"":(const char *)sqlite3_column_text(stmt, 26)];
        
        if (blackListStr != NULL && blackListStr.length > 0) {
            scrpitDetail.blacklist = [blackListStr componentsSeparatedByString:@","];
        } else {
            scrpitDetail.blacklist = @[];
        }
        
        NSString * whiteListStr = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 27)== NULL?"":(const char *)sqlite3_column_text(stmt, 27)];
        
        if (whiteListStr != NULL && whiteListStr.length > 0) {
            scrpitDetail.whitelist = [whiteListStr componentsSeparatedByString:@","];
        } else {
            scrpitDetail.whitelist = @[];
        }
        
        NSString * inject = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 28)== NULL?"":(const char *)sqlite3_column_text(stmt, 28)];

        scrpitDetail.injectInto = inject;
        
        NSString * iCloudIdentifier = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 29)== NULL?"":(const char *)sqlite3_column_text(stmt, 29)];
        
        scrpitDetail.iCloudIdentifier = iCloudIdentifier;
        
        
        int status = sqlite3_column_int(stmt, 30);
        scrpitDetail.status = status;
        
        NSString * platforms = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 32)== NULL?"":(const char *)sqlite3_column_text(stmt, 32)];
        if (platforms != NULL && platforms.length > 0) {
            scrpitDetail.plafroms = [platforms componentsSeparatedByString:@","];
        } else {
            scrpitDetail.plafroms = @[];
        }
        
        int stayOnly = sqlite3_column_int(stmt, 33);
        scrpitDetail.stayOnly = stayOnly == 1? true:false;
        
        int usedTimes = sqlite3_column_int(stmt, 34);
        scrpitDetail.usedTimes = usedTimes;
        
        [[Tampermonkey shared] conventScriptContent:scrpitDetail];
        
        [scriptList addObject:scrpitDetail];
    }

    sqlite3_finalize(stmt);
    sqlite3_close(sqliteHandle);
    
    return scriptList;
}

- (void)insertUserConfigByUserScript:(UserScript *)scrpitDetail {
    //打开数据库
    sqlite3 *sqliteHandle = NULL;
    int result = 0;
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];


    result = sqlite3_open_v2([destPath UTF8String], &sqliteHandle, SQLITE_OPEN_READWRITE, NULL);
    
    if (result != SQLITE_OK) {
        
        NSLog(@"数据库文件打开失败");
        return;
    }
    
    NSString *sql = @"INSERT INTO user_config_script (uuid, name, namespace, author, version, desc, homepage, icon, includes,maches,excludes,runAt,grants,noFrames,content,active,requireUrls,sourcePage,updateUrl,downloadUrl,notes,resourceUrl,update_time,switch,license,iCloud_identifier,status,platforms,stay_only,inject_info) VALUES (?, ?, ?, ?, ?, ?, ?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(sqliteHandle, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        sqlite3_bind_text(statement, 1,scrpitDetail.uuid != NULL? [scrpitDetail.uuid UTF8String]:[[[NSUUID UUID] UUIDString] UTF8String], -1,NULL);
        sqlite3_bind_text(statement, 2,scrpitDetail.name != NULL? [scrpitDetail.name UTF8String]:NULL, -1,NULL);
        sqlite3_bind_text(statement, 3,scrpitDetail.namespace !=NULL? [scrpitDetail.namespace UTF8String]:NULL, -1,NULL);
        sqlite3_bind_text(statement, 4,scrpitDetail.author != NULL? [scrpitDetail.author UTF8String]:NULL, -1,NULL);
        sqlite3_bind_text(statement, 5,scrpitDetail.version != NULL? [scrpitDetail.version UTF8String]:NULL, -1,NULL);
        sqlite3_bind_text(statement, 6, [scrpitDetail.desc UTF8String], -1,NULL);
        sqlite3_bind_text(statement, 7, [scrpitDetail.homepage UTF8String], -1,NULL);
        sqlite3_bind_text(statement, 8, [scrpitDetail.icon UTF8String], -1,NULL);
        if(scrpitDetail.includes.count > 0) {
        sqlite3_bind_text(statement, 9, [[scrpitDetail.includes componentsJoinedByString:@","] UTF8String], -1,NULL);
        } else {
            sqlite3_bind_text(statement, 9, NULL, -1,NULL);
        }
        
        if(scrpitDetail.matches.count > 0) {
            sqlite3_bind_text(statement, 10, [[scrpitDetail.matches componentsJoinedByString:@","] UTF8String], -1,NULL);
        } else {
            sqlite3_bind_text(statement, 10, NULL, -1,NULL);
        }
        if(scrpitDetail.excludes.count > 0) {
            sqlite3_bind_text(statement, 11, [[scrpitDetail.excludes componentsJoinedByString:@","] UTF8String], -1,NULL);
        } else {
            sqlite3_bind_text(statement, 11,  NULL, -1,NULL);
        }
  
        sqlite3_bind_text(statement, 12, [scrpitDetail.runAt UTF8String], -1,NULL);
        
        if(scrpitDetail.grants.count > 0) {
            sqlite3_bind_text(statement, 13, [[scrpitDetail.grants componentsJoinedByString:@","] UTF8String], -1,NULL);
        } else {
            sqlite3_bind_text(statement, 13, NULL, -1,NULL);
        }
        sqlite3_bind_int(statement, 14, scrpitDetail.noFrames?1:0);
        sqlite3_bind_text(statement, 15, [scrpitDetail.content UTF8String], -1,NULL);
        sqlite3_bind_int(statement, 16, 1);
        if(scrpitDetail.requireUrls.count > 0) {
            sqlite3_bind_text(statement, 17, [[scrpitDetail.requireUrls componentsJoinedByString:@","] UTF8String], -1,NULL);
        } else {
            sqlite3_bind_text(statement, 17, NULL, -1,NULL);
        }
        sqlite3_bind_text(statement, 18, [scrpitDetail.sourcePage UTF8String], -1,NULL);
        
        sqlite3_bind_text(statement, 19, [scrpitDetail.updateUrl UTF8String], -1,NULL);
        
        sqlite3_bind_text(statement, 20, [scrpitDetail.downloadUrl UTF8String], -1,NULL);
        
        if(scrpitDetail.notes.count > 0) {
            sqlite3_bind_text(statement, 21, [[scrpitDetail.notes componentsJoinedByString:@","] UTF8String], -1,NULL);
        } else {
            sqlite3_bind_text(statement, 21,  NULL, -1,NULL);
        }
        
        if(scrpitDetail.resourceUrls != NULL && scrpitDetail.resourceUrls.count > 0) {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:scrpitDetail.resourceUrls options:NSJSONWritingPrettyPrinted error:nil];
            sqlite3_bind_text(statement, 22, [[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding] UTF8String], -1,NULL);
        } else {
            sqlite3_bind_text(statement, 22,  NULL, -1,NULL);
        }
        
        NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval a=[date timeIntervalSince1970]*1000; // *1000 是精确到毫秒，不乘就是精确到秒
        NSString *timeString = [NSString stringWithFormat:@"%.0f", a];
        sqlite3_bind_double(statement, 23, timeString.doubleValue);
        int updateSwitch= scrpitDetail.updateSwitch?1:0;
        sqlite3_bind_int(statement, 24, updateSwitch);
        sqlite3_bind_text(statement, 25, [scrpitDetail.license UTF8String], -1,NULL);
        sqlite3_bind_text(statement, 26, [scrpitDetail.iCloudIdentifier UTF8String], -1,NULL);
        sqlite3_bind_int(statement, 27, 0);
        if(scrpitDetail.plafroms.count > 0) {
            sqlite3_bind_text(statement, 28, [[scrpitDetail.plafroms componentsJoinedByString:@","] UTF8String], -1,NULL);
        } else {
            sqlite3_bind_text(statement, 28,  NULL, -1,NULL);
        }
        int stayOnly= scrpitDetail.stayOnly?1:0;
        //        sqlite3_bind_text(statement, 29, [scrpitDetail.plafroms UTF8String], -1,NULL);
        sqlite3_bind_int(statement, 29, stayOnly);
//        sqlite3_bind_text(statement, 29, [scrpitDetail.plafroms UTF8String], -1,NULL);
        
        NSString *injectInto = @"Auto";
        if (scrpitDetail.injectInto.length > 0){
            injectInto = [NSString stringWithFormat:@"%@%@",
                                    [scrpitDetail.injectInto substringToIndex:1].uppercaseString,
                                    [scrpitDetail.injectInto substringFromIndex:1]
            ];
        }
        sqlite3_bind_text(statement, 30, [injectInto UTF8String], -1,NULL);
    }
    
    NSInteger resultCode = sqlite3_step(statement);
    if (resultCode != SQLITE_DONE) {
        sqlite3_finalize(statement);
    }
    sqlite3_close(sqliteHandle);
}


//- (void)deleteScriptInUserScriptByNumberId:(NSString *)uuid{
//    //打开数据库
//    sqlite3 *sqliteHandle = NULL;
//    int result = 0;
//
//    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
//    NSString*documentsDirectory =[paths objectAtIndex:0];
//
//    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];
//
//
//    result = sqlite3_open([destPath
//                           UTF8String], &sqliteHandle);
//
//    if (result != SQLITE_OK) {
//
//        NSLog(@"数据库文件打开失败");
//
//        return;
//    }
//
//    //构造SQL语句
//
//    NSString *sql = @"DELETE FROM user_config_script  WHERE uuid = ? ";
//
//    sqlite3_stmt *stmt = NULL;
//    result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
//    if (result != SQLITE_OK) {
//        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
//        NSLog(@"编译sql失败");
//        sqlite3_close(sqliteHandle);
//        return;
//    }
////    绑定占位符
//    sqlite3_bind_text(stmt, 1, [uuid UTF8String], -1, NULL);
//
//    //执行SQL语句,代表找到一条符合条件的数据，如果有多条数据符合条件，则要循环调用
//    if (sqlite3_step(stmt) != SQLITE_DONE) {
//        sqlite3_finalize(stmt);
//    }
//    sqlite3_close(sqliteHandle);
//}

- (void)updateUserScript:(UserScript *)scrpitDetail {
    
    //打开数据库
    sqlite3 *sqliteHandle = NULL;
    int result = 0;
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];


    result = sqlite3_open_v2([destPath UTF8String], &sqliteHandle, SQLITE_OPEN_READWRITE, NULL);
    
    if (result != SQLITE_OK) {
        
        NSLog(@"数据库文件打开失败");
        return;
    }
    
    NSString *sql = @"UPDATE user_config_script set name = ?, namespace = ?, author = ?, version = ?, desc = ?, homepage = ?, icon = ?, includes= ?,maches= ?,excludes= ?,runAt= ?,grants= ?,noFrames= ?,content= ?,active= ?,requireUrls= ?,sourcePage= ?,updateUrl = ?,downloadUrl = ?,notes = ?,resourceUrl = ?, update_time = ?, license = ?,iCloud_identifier = ?,switch = ?,inject_info = ?   where uuid = ?";
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(sqliteHandle, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        sqlite3_bind_text(statement, 1,scrpitDetail.name != NULL? [scrpitDetail.name UTF8String]:NULL, -1,NULL);
        sqlite3_bind_text(statement, 2,scrpitDetail.namespace !=NULL? [scrpitDetail.namespace UTF8String]:NULL, -1,NULL);
        sqlite3_bind_text(statement, 3,scrpitDetail.author != NULL? [scrpitDetail.author UTF8String]:NULL, -1,NULL);
        sqlite3_bind_text(statement, 4,scrpitDetail.version != NULL? [scrpitDetail.version UTF8String]:NULL, -1,NULL);
        sqlite3_bind_text(statement, 5, [scrpitDetail.desc UTF8String], -1,NULL);
        sqlite3_bind_text(statement, 6, [scrpitDetail.homepage UTF8String], -1,NULL);
        sqlite3_bind_text(statement, 7, [scrpitDetail.icon UTF8String], -1,NULL);
        if(scrpitDetail.includes.count > 0) {
        sqlite3_bind_text(statement, 8, [[scrpitDetail.includes componentsJoinedByString:@","] UTF8String], -1,NULL);
        } else {
            sqlite3_bind_text(statement, 8, NULL, -1,NULL);
        }
        
        if(scrpitDetail.matches.count > 0) {
            sqlite3_bind_text(statement, 9, [[scrpitDetail.matches componentsJoinedByString:@","] UTF8String], -1,NULL);
        } else {
            sqlite3_bind_text(statement, 9, NULL, -1,NULL);
        }
        if(scrpitDetail.excludes.count > 0) {
            sqlite3_bind_text(statement, 10, [[scrpitDetail.excludes componentsJoinedByString:@","] UTF8String], -1,NULL);
        } else {
            sqlite3_bind_text(statement, 10,  NULL, -1,NULL);
        }
  
        sqlite3_bind_text(statement, 11, [scrpitDetail.runAt UTF8String], -1,NULL);
        
        if(scrpitDetail.grants.count > 0) {
            sqlite3_bind_text(statement, 12, [[scrpitDetail.grants componentsJoinedByString:@","] UTF8String], -1,NULL);
        } else {
            sqlite3_bind_text(statement, 12, NULL, -1,NULL);
        }
        sqlite3_bind_int(statement, 13, scrpitDetail.noFrames?1:0);
        sqlite3_bind_text(statement, 14, [scrpitDetail.content UTF8String], -1,NULL);
        sqlite3_bind_int(statement, 15, scrpitDetail.active?1:0);
        if(scrpitDetail.requireUrls.count > 0) {
            sqlite3_bind_text(statement, 16, [[scrpitDetail.requireUrls componentsJoinedByString:@","] UTF8String], -1,NULL);
        } else {
            sqlite3_bind_text(statement, 16, NULL, -1,NULL);
        }
        sqlite3_bind_text(statement, 17, [scrpitDetail.sourcePage UTF8String], -1,NULL);
        sqlite3_bind_text(statement, 21,scrpitDetail.uuid != NULL? [scrpitDetail.uuid UTF8String]:[[[NSUUID UUID] UUIDString] UTF8String], -1,NULL);
        sqlite3_bind_text(statement, 18, [scrpitDetail.updateUrl UTF8String], -1,NULL);
        
        sqlite3_bind_text(statement, 19, [scrpitDetail.downloadUrl UTF8String], -1,NULL);
        if(scrpitDetail.notes.count > 0) {
            sqlite3_bind_text(statement, 20, [[scrpitDetail.notes componentsJoinedByString:@","] UTF8String], -1,NULL);
        } else {
            sqlite3_bind_text(statement, 20, NULL, -1,NULL);
        }
        
        if(scrpitDetail.resourceUrls != nil && scrpitDetail.resourceUrls.count > 0) {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:scrpitDetail.resourceUrls options:NSJSONWritingPrettyPrinted error:nil];
            sqlite3_bind_text(statement, 21, [ [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding] UTF8String], -1,NULL);
        } else {
            sqlite3_bind_text(statement, 21, NULL, -1,NULL);
        }
        NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
                        NSTimeInterval a=[date timeIntervalSince1970]*1000; // *1000 是精确到毫秒，不乘就是精确到秒
                        NSString *timeString = [NSString stringWithFormat:@"%.0f", a];
        sqlite3_bind_double(statement, 22, timeString.doubleValue);
        
        sqlite3_bind_text(statement, 23,[scrpitDetail.license UTF8String], -1,NULL);
        sqlite3_bind_text(statement, 24,[scrpitDetail.iCloudIdentifier UTF8String], -1,NULL);
        int updateSwitch = scrpitDetail.updateSwitch ?1:0;
        sqlite3_bind_int(statement, 25, updateSwitch);
        
        NSString *injectInto = @"Auto";
        if (scrpitDetail.injectInto.length > 0){
            injectInto = [NSString stringWithFormat:@"%@%@",
                                    [scrpitDetail.injectInto substringToIndex:1].uppercaseString,
                                    [scrpitDetail.injectInto substringFromIndex:1]
            ];
        }
       
        sqlite3_bind_text(statement, 26,[injectInto UTF8String], -1,NULL);
        
        sqlite3_bind_text(statement, 27,scrpitDetail.uuid != NULL? [scrpitDetail.uuid UTF8String]:[[[NSUUID UUID] UUIDString] UTF8String], -1,NULL);
        

    }
    
    NSInteger resultCode = sqlite3_step(statement);
    if (resultCode != SQLITE_DONE) {
        sqlite3_finalize(statement);
    }
    sqlite3_close(sqliteHandle);
}


- (UserScript *)selectScriptByUuid:(NSString *)uuid {
    //打开数据库
    sqlite3 *sqliteHandle = NULL;
    int result = 0;
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];

    result = sqlite3_open([destPath
                           UTF8String], &sqliteHandle);
    
    if (result != SQLITE_OK) {
        
        NSLog(@"数据库文件打开失败");
        return nil;
    }
    
    NSString *sql= @"SELECT * FROM user_config_script WHERE uuid = ?";
    sqlite3_stmt *stmt = NULL;
    result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return nil;
        
    }
    sqlite3_bind_text(stmt, 1, [uuid UTF8String], -1, NULL);

    UserScript *scrpitDetail = [[UserScript alloc] init];
    
    while(sqlite3_step(stmt) == SQLITE_ROW) {
        
        //第几列字段是从0开始
        scrpitDetail.uuid = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)== NULL?"":(const char *)sqlite3_column_text(stmt, 1)];
        scrpitDetail.name = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)== NULL?"":(const char *)sqlite3_column_text(stmt, 2)];
        scrpitDetail.namespace = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 3) == NULL?"":(const char *)sqlite3_column_text(stmt, 3)];
        scrpitDetail.author = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)== NULL?"":(const char *)sqlite3_column_text(stmt, 4)];
        scrpitDetail.version =  [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 5)== NULL?"":(const char *)sqlite3_column_text(stmt, 5)];
        scrpitDetail.desc = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 6)== NULL?"":(const char *)sqlite3_column_text(stmt, 6)];
        scrpitDetail.homepage = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 7)== NULL?"":(const char *)sqlite3_column_text(stmt, 7)];
        scrpitDetail.icon = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 8)== NULL?"":(const char *)sqlite3_column_text(stmt, 8)];
        
        NSString * includesStr = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 9)== NULL?"":(const char *)sqlite3_column_text(stmt, 9)];
        if (includesStr != NULL && includesStr.length > 0) {
            scrpitDetail.includes = [includesStr componentsSeparatedByString:@","];
        } else {
            scrpitDetail.includes = @[];
        }
        NSString * mathesStr = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 10)== NULL?"":(const char *)sqlite3_column_text(stmt, 10)];
        if (mathesStr != NULL && mathesStr.length > 0) {
            scrpitDetail.matches = [mathesStr componentsSeparatedByString:@","];
        } else {
            scrpitDetail.matches = @[];
        }
        NSString * excludesStr = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 11)== NULL?"":(const char *)sqlite3_column_text(stmt, 11)];
        if (excludesStr != NULL && excludesStr.length > 0) {
            scrpitDetail.excludes = [excludesStr componentsSeparatedByString:@","];
        } else {
            scrpitDetail.excludes = @[];
        }
        
        scrpitDetail.runAt = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 12)== NULL?"":(const char *)sqlite3_column_text(stmt, 12)];
        
        NSString * grantsStr = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 13)== NULL?"":(const char *)sqlite3_column_text(stmt, 13)];
        if (grantsStr != NULL && grantsStr.length > 0) {
            scrpitDetail.grants = [grantsStr componentsSeparatedByString:@","];
        } else {
            scrpitDetail.grants = @[];
        }
        
        
        int noframes = sqlite3_column_int(stmt, 14);
        scrpitDetail.noFrames = noframes == 0? false:true;
    
        scrpitDetail.content = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 15)== NULL?"":(const char *)sqlite3_column_text(stmt, 15)];
        
        int activite = sqlite3_column_int(stmt, 16);
        scrpitDetail.active = activite == 0? false:true;
        
        NSString * requiresUrlStr = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 17)== NULL?"":(const char *)sqlite3_column_text(stmt, 17)];
        if (requiresUrlStr != NULL && requiresUrlStr.length > 0) {
            scrpitDetail.requireUrls = [requiresUrlStr componentsSeparatedByString:@","];
        } else {
            scrpitDetail.requireUrls = @[];
        }
        
        
        NSString *sourcePage = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 18)== NULL?"":(const char *)sqlite3_column_text(stmt, 18)];
        
        scrpitDetail.sourcePage = sourcePage;
        double updateTime = sqlite3_column_double(stmt, 19);
        scrpitDetail.updateTime = [NSString stringWithFormat:@"%f", updateTime];
        
        NSString *updateUrl = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 20)== NULL?"":(const char *)sqlite3_column_text(stmt, 20)];
        scrpitDetail.updateUrl = updateUrl;
        NSString *downloadUrl = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 21)== NULL?"":(const char *)sqlite3_column_text(stmt, 21)];
        scrpitDetail.downloadUrl = downloadUrl;
    
        int updateSwitch = sqlite3_column_int(stmt, 22);
        scrpitDetail.updateSwitch = updateSwitch == 1? true:false;

        NSString * resourceUrl = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 23)== NULL?"":(const char *)sqlite3_column_text(stmt, 23)];
        if (resourceUrl != NULL && resourceUrl.length > 0) {
            NSData *jsonData = [resourceUrl dataUsingEncoding:NSUTF8StringEncoding];
            scrpitDetail.resourceUrls =  [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
        } else {
            scrpitDetail.resourceUrls = @{};
        }
        
        
        NSString * notesStr = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 24)== NULL?"":(const char *)sqlite3_column_text(stmt, 24)];
        if (notesStr != NULL && notesStr.length > 0) {
            scrpitDetail.notes = [notesStr componentsSeparatedByString:@","];
        } else {
            scrpitDetail.notes = @[];
        }
        
        NSString * license = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 25)== NULL?"":(const char *)sqlite3_column_text(stmt, 25)];

        scrpitDetail.license = license;
        
        NSString * blackListStr = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 26)== NULL?"":(const char *)sqlite3_column_text(stmt, 26)];
        
        if (blackListStr != NULL && blackListStr.length > 0) {
            scrpitDetail.blacklist = [blackListStr componentsSeparatedByString:@","];
        } else {
            scrpitDetail.blacklist = @[];
        }
        
        NSString * whiteListStr = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 27)== NULL?"":(const char *)sqlite3_column_text(stmt, 27)];
        
        if (whiteListStr != NULL && whiteListStr.length > 0) {
            scrpitDetail.whitelist = [whiteListStr componentsSeparatedByString:@","];
        } else {
            scrpitDetail.whitelist = @[];
        }
        
        NSString * inject = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 28)== NULL?"":(const char *)sqlite3_column_text(stmt, 28)];

        scrpitDetail.injectInto = inject;
        
        NSString * iCloudIdentifier = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 29)== NULL?"":(const char *)sqlite3_column_text(stmt, 29)];
        scrpitDetail.iCloudIdentifier = iCloudIdentifier;
        
        int status = sqlite3_column_int(stmt, 30);
        scrpitDetail.status = status;
        
        NSString * platforms = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 32)== NULL?"":(const char *)sqlite3_column_text(stmt, 32)];
        if (platforms != NULL && platforms.length > 0) {
            scrpitDetail.plafroms = [platforms componentsSeparatedByString:@","];
        } else {
            scrpitDetail.plafroms = @[];
        }
        
        int stayOnly = sqlite3_column_int(stmt, 33);
        scrpitDetail.stayOnly = stayOnly == 1? true:false;
        
        int usedTimes = sqlite3_column_int(stmt, 34);
        scrpitDetail.usedTimes = usedTimes;
        
        NSString *updateScriptTime = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 35)== NULL?"":(const char *)sqlite3_column_text(stmt, 35)];
        scrpitDetail.updateScriptTime = updateScriptTime;
        
        NSString *disabledWebsites = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 36)== NULL?"":(const char *)sqlite3_column_text(stmt, 36)];
        
        if (disabledWebsites != NULL && disabledWebsites.length > 0) {
            scrpitDetail.disabledWebsites = [disabledWebsites componentsSeparatedByString:@","];
        } else {
            scrpitDetail.disabledWebsites = @[];
        }
        
        
        [[Tampermonkey shared] conventScriptContent:scrpitDetail];
    }
    sqlite3_finalize(stmt);
    sqlite3_close(sqliteHandle);
    
    return scrpitDetail;
}

- (void)insertScriptConfigByUserScript:(UserScript *)scrpitDetail {
    //打开数据库
    sqlite3 *sqliteHandle = NULL;
    int result = 0;
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];


    result = sqlite3_open_v2([destPath UTF8String], &sqliteHandle, SQLITE_OPEN_READWRITE, NULL);
    
    if (result != SQLITE_OK) {
        
        NSLog(@"数据库文件打开失败");
        return;
    }
    
    NSString *sql = @"INSERT INTO script_config (uuid, name, namespace, author, version, desc, homepage, icon, includes,maches,excludes,runAt,grants,noFrames,content,active,requireUrls,sourcePage,updateUrl,downloadUrl) VALUES (?, ?, ?, ?, ?, ?, ?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(sqliteHandle, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        sqlite3_bind_text(statement, 1,scrpitDetail.uuid != NULL? [scrpitDetail.uuid UTF8String]:[[[NSUUID UUID] UUIDString] UTF8String], -1,NULL);
        sqlite3_bind_text(statement, 2,scrpitDetail.name != NULL? [scrpitDetail.name UTF8String]:NULL, -1,NULL);
        sqlite3_bind_text(statement, 3,scrpitDetail.namespace !=NULL? [scrpitDetail.namespace UTF8String]:NULL, -1,NULL);
        sqlite3_bind_text(statement, 4,scrpitDetail.author != NULL? [scrpitDetail.author UTF8String]:NULL, -1,NULL);
        sqlite3_bind_text(statement, 5,scrpitDetail.version != NULL? [scrpitDetail.version UTF8String]:NULL, -1,NULL);
        sqlite3_bind_text(statement, 6, [scrpitDetail.desc UTF8String], -1,NULL);
        sqlite3_bind_text(statement, 7, [scrpitDetail.homepage UTF8String], -1,NULL);
        sqlite3_bind_text(statement, 8, [scrpitDetail.icon UTF8String], -1,NULL);
        if(scrpitDetail.includes.count > 0) {
        sqlite3_bind_text(statement, 9, [[scrpitDetail.includes componentsJoinedByString:@","] UTF8String], -1,NULL);
        } else {
            sqlite3_bind_text(statement, 9, NULL, -1,NULL);
        }
        
        if(scrpitDetail.matches.count > 0) {
            sqlite3_bind_text(statement, 10, [[scrpitDetail.matches componentsJoinedByString:@","] UTF8String], -1,NULL);
        } else {
            sqlite3_bind_text(statement, 10, NULL, -1,NULL);
        }
        if(scrpitDetail.excludes.count > 0) {
            sqlite3_bind_text(statement, 11, [[scrpitDetail.excludes componentsJoinedByString:@","] UTF8String], -1,NULL);
        } else {
            sqlite3_bind_text(statement, 11,  NULL, -1,NULL);
        }
  
        sqlite3_bind_text(statement, 12, [scrpitDetail.runAt UTF8String], -1,NULL);
        
        if(scrpitDetail.grants.count > 0) {
            sqlite3_bind_text(statement, 13, [[scrpitDetail.grants componentsJoinedByString:@","] UTF8String], -1,NULL);
        } else {
            sqlite3_bind_text(statement, 13, NULL, -1,NULL);
        }
        sqlite3_bind_int(statement, 14, scrpitDetail.noFrames?1:0);
        sqlite3_bind_text(statement, 15, [scrpitDetail.content UTF8String], -1,NULL);
        sqlite3_bind_int(statement, 16, scrpitDetail.active?1:0);
        if(scrpitDetail.requireUrls.count > 0) {
            sqlite3_bind_text(statement, 17, [[scrpitDetail.requireUrls componentsJoinedByString:@","] UTF8String], -1,NULL);
        } else {
            sqlite3_bind_text(statement, 17, NULL, -1,NULL);
        }
        sqlite3_bind_text(statement, 18, [scrpitDetail.sourcePage UTF8String], -1,NULL);
        
        sqlite3_bind_text(statement, 19, [scrpitDetail.updateUrl UTF8String], -1,NULL);
                
        sqlite3_bind_text(statement, 20, [scrpitDetail.downloadUrl UTF8String], -1,NULL);
    }
    
    NSInteger resultCode = sqlite3_step(statement);
    if (resultCode != SQLITE_DONE) {
        sqlite3_finalize(statement);
    }
    sqlite3_close(sqliteHandle);
}

- (void)updateScriptConfigAutoupdate:(int)status numberId:(NSString *)uuid {
    //打开数据库
    sqlite3 *sqliteHandle = NULL;
    int result = 0;
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];


    result = sqlite3_open([destPath
                           UTF8String], &sqliteHandle);
    
    if (result != SQLITE_OK) {
        
        NSLog(@"数据库文件打开失败");
        
        return;
    }
    
    //构造SQL语句

    NSString *sql = @"UPDATE user_config_script SET switch = ? WHERE uuid = ? ";
    
    sqlite3_stmt *stmt = NULL;
    result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return;
    }
    sqlite3_bind_int(stmt, 1, status);
    sqlite3_bind_text(stmt, 2, [uuid UTF8String], -1, NULL);

    if (sqlite3_step(stmt) != SQLITE_DONE) {
        sqlite3_finalize(stmt);
    }
    sqlite3_close(sqliteHandle);
}



- (void)updateScriptConfigBlackList:(NSString *)str numberId:(NSString *)uuid {
    //打开数据库
    sqlite3 *sqliteHandle = NULL;
    int result = 0;
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];


    result = sqlite3_open([destPath
                           UTF8String], &sqliteHandle);
    
    if (result != SQLITE_OK) {
        
        NSLog(@"数据库文件打开失败");
        
        return;
    }
    
    //构造SQL语句

    NSString *sql = @"UPDATE user_config_script SET black_sites = ? WHERE uuid = ? ";
    
    sqlite3_stmt *stmt = NULL;
    result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return;
    }
    sqlite3_bind_text(stmt, 1, [str UTF8String], -1, NULL);
    sqlite3_bind_text(stmt, 2, [uuid UTF8String], -1, NULL);

    if (sqlite3_step(stmt) != SQLITE_DONE) {
        sqlite3_finalize(stmt);
    }
    sqlite3_close(sqliteHandle);
}

- (void)updateScriptConfigWhiteList:(NSString *)str numberId:(NSString *)uuid {
    //打开数据库
    sqlite3 *sqliteHandle = NULL;
    int result = 0;
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];


    result = sqlite3_open([destPath
                           UTF8String], &sqliteHandle);
    
    if (result != SQLITE_OK) {
        
        NSLog(@"数据库文件打开失败");
        
        return;
    }
    
    //构造SQL语句

    NSString *sql = @"UPDATE user_config_script SET white_sites = ? WHERE uuid = ? ";
    
    sqlite3_stmt *stmt = NULL;
    result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return;
    }
    sqlite3_bind_text(stmt, 1, [str UTF8String], -1, NULL);
    sqlite3_bind_text(stmt, 2, [uuid UTF8String], -1, NULL);

    if (sqlite3_step(stmt) != SQLITE_DONE) {
        sqlite3_finalize(stmt);
    }
    sqlite3_close(sqliteHandle);
}

- (void)updateScriptConfigInjectInfo:(NSString *)str numberId:(NSString *)uuid{
    //打开数据库
    sqlite3 *sqliteHandle = NULL;
    int result = 0;
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];


    result = sqlite3_open([destPath
                           UTF8String], &sqliteHandle);
    
    if (result != SQLITE_OK) {
        
        NSLog(@"数据库文件打开失败");
        
        return;
    }
    
    //构造SQL语句

    NSString *sql = @"UPDATE user_config_script SET inject_info = ? WHERE uuid = ? ";
    
    sqlite3_stmt *stmt = NULL;
    result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return;
    }
    sqlite3_bind_text(stmt, 1, [str UTF8String], -1, NULL);
    sqlite3_bind_text(stmt, 2, [uuid UTF8String], -1, NULL);

    if (sqlite3_step(stmt) != SQLITE_DONE) {
        sqlite3_finalize(stmt);
    }
    sqlite3_close(sqliteHandle);
}


- (void)updateScriptConfigStatus:(int)status numberId:(NSString *)uuid {
    //打开数据库
    sqlite3 *sqliteHandle = NULL;
    int result = 0;
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];


    result = sqlite3_open([destPath
                           UTF8String], &sqliteHandle);
    
    if (result != SQLITE_OK) {
        
        NSLog(@"数据库文件打开失败");
        
        return;
    }
    
    //构造SQL语句

    NSString *sql = @"UPDATE user_config_script SET status = ? WHERE uuid = ? ";
    
    sqlite3_stmt *stmt = NULL;
    result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return;
    }
    sqlite3_bind_int(stmt, 1, status);
    sqlite3_bind_text(stmt, 2, [uuid UTF8String], -1, NULL);

    if (sqlite3_step(stmt) != SQLITE_DONE) {
        sqlite3_finalize(stmt);
    }
    sqlite3_close(sqliteHandle);
}

- (void)updateUsedTimesByUuid:(NSString *)uuid count:(int)count {
    
    //打开数据库
    sqlite3 *sqliteHandle = NULL;
    int result = 0;
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];


    result = sqlite3_open([destPath
                           UTF8String], &sqliteHandle);
    
    if (result != SQLITE_OK) {
        
        NSLog(@"数据库文件打开失败");
        
        return;
    }
    
    //构造SQL语句

    NSString *sql = @"UPDATE user_config_script SET usedTimes = usedTimes + ? WHERE uuid = ? ";
    
    sqlite3_stmt *stmt = NULL;
    result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return;
    }
    sqlite3_bind_int(stmt, 1, count);

    sqlite3_bind_text(stmt, 2, [uuid UTF8String], -1, NULL);

    if (sqlite3_step(stmt) != SQLITE_DONE) {
        sqlite3_finalize(stmt);
    }
    sqlite3_close(sqliteHandle);
}


- (void)updateUserScriptByIcloud:(UserScript *)scrpitDetail {
    //打开数据库
    sqlite3 *sqliteHandle = NULL;
    int result = 0;
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];


    result = sqlite3_open_v2([destPath UTF8String], &sqliteHandle, SQLITE_OPEN_READWRITE, NULL);
    
    if (result != SQLITE_OK) {
        
        NSLog(@"数据库文件打开失败");
        return;
    }
    
    NSString *sql = @"UPDATE user_config_script set name = ?, namespace = ?, author = ?, version = ?, desc = ?, homepage = ?, icon = ?, includes= ?,maches= ?,excludes= ?,runAt= ?,grants= ?,noFrames= ?,content= ?,active= ?,requireUrls= ?,sourcePage= ?,updateUrl = ?,downloadUrl = ?,notes = ?,resourceUrl = ?, update_time = ?, license = ?,iCloud_identifier = ?,switch = ?,inject_info = ?,black_sites = ?,white_sites = ? where uuid = ?";
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(sqliteHandle, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        sqlite3_bind_text(statement, 1,scrpitDetail.name != NULL? [scrpitDetail.name UTF8String]:NULL, -1,NULL);
        sqlite3_bind_text(statement, 2,scrpitDetail.namespace !=NULL? [scrpitDetail.namespace UTF8String]:NULL, -1,NULL);
        sqlite3_bind_text(statement, 3,scrpitDetail.author != NULL? [scrpitDetail.author UTF8String]:NULL, -1,NULL);
        sqlite3_bind_text(statement, 4,scrpitDetail.version != NULL? [scrpitDetail.version UTF8String]:NULL, -1,NULL);
        sqlite3_bind_text(statement, 5, [scrpitDetail.desc UTF8String], -1,NULL);
        sqlite3_bind_text(statement, 6, [scrpitDetail.homepage UTF8String], -1,NULL);
        sqlite3_bind_text(statement, 7, [scrpitDetail.icon UTF8String], -1,NULL);
        if(scrpitDetail.includes.count > 0) {
        sqlite3_bind_text(statement, 8, [[scrpitDetail.includes componentsJoinedByString:@","] UTF8String], -1,NULL);
        } else {
            sqlite3_bind_text(statement, 8, NULL, -1,NULL);
        }
        
        if(scrpitDetail.matches.count > 0) {
            sqlite3_bind_text(statement, 9, [[scrpitDetail.matches componentsJoinedByString:@","] UTF8String], -1,NULL);
        } else {
            sqlite3_bind_text(statement, 9, NULL, -1,NULL);
        }
        if(scrpitDetail.excludes.count > 0) {
            sqlite3_bind_text(statement, 10, [[scrpitDetail.excludes componentsJoinedByString:@","] UTF8String], -1,NULL);
        } else {
            sqlite3_bind_text(statement, 10,  NULL, -1,NULL);
        }
  
        sqlite3_bind_text(statement, 11, [scrpitDetail.runAt UTF8String], -1,NULL);
        
        if(scrpitDetail.grants.count > 0) {
            sqlite3_bind_text(statement, 12, [[scrpitDetail.grants componentsJoinedByString:@","] UTF8String], -1,NULL);
        } else {
            sqlite3_bind_text(statement, 12, NULL, -1,NULL);
        }
        sqlite3_bind_int(statement, 13, scrpitDetail.noFrames?1:0);
        sqlite3_bind_text(statement, 14, [scrpitDetail.content UTF8String], -1,NULL);
        sqlite3_bind_int(statement, 15, scrpitDetail.active?1:0);
        if(scrpitDetail.requireUrls.count > 0) {
            sqlite3_bind_text(statement, 16, [[scrpitDetail.requireUrls componentsJoinedByString:@","] UTF8String], -1,NULL);
        } else {
            sqlite3_bind_text(statement, 16, NULL, -1,NULL);
        }
        sqlite3_bind_text(statement, 17, [scrpitDetail.sourcePage UTF8String], -1,NULL);
        sqlite3_bind_text(statement, 21,scrpitDetail.uuid != NULL? [scrpitDetail.uuid UTF8String]:[[[NSUUID UUID] UUIDString] UTF8String], -1,NULL);
        sqlite3_bind_text(statement, 18, [scrpitDetail.updateUrl UTF8String], -1,NULL);
        
        sqlite3_bind_text(statement, 19, [scrpitDetail.downloadUrl UTF8String], -1,NULL);
        if(scrpitDetail.notes.count > 0) {
            sqlite3_bind_text(statement, 20, [[scrpitDetail.notes componentsJoinedByString:@","] UTF8String], -1,NULL);
        } else {
            sqlite3_bind_text(statement, 20, NULL, -1,NULL);
        }
        
        if(scrpitDetail.resourceUrls != nil && scrpitDetail.resourceUrls.count > 0) {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:scrpitDetail.resourceUrls options:NSJSONWritingPrettyPrinted error:nil];
            sqlite3_bind_text(statement, 21, [ [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding] UTF8String], -1,NULL);
        } else {
            sqlite3_bind_text(statement, 21, NULL, -1,NULL);
        }
        NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
                        NSTimeInterval a=[date timeIntervalSince1970]*1000; // *1000 是精确到毫秒，不乘就是精确到秒
                        NSString *timeString = [NSString stringWithFormat:@"%.0f", a];
        sqlite3_bind_double(statement, 22, timeString.doubleValue);
        
        sqlite3_bind_text(statement, 23,[scrpitDetail.license UTF8String], -1,NULL);
        sqlite3_bind_text(statement, 24,[scrpitDetail.iCloudIdentifier UTF8String], -1,NULL);
        int updateSwitch = scrpitDetail.updateSwitch ?1:0;
        sqlite3_bind_int(statement, 25, updateSwitch);
        
        sqlite3_bind_text(statement, 26,[scrpitDetail.injectInto UTF8String], -1,NULL);

        
        if(scrpitDetail.blacklist.count > 0) {
            sqlite3_bind_text(statement, 27, [[scrpitDetail.blacklist componentsJoinedByString:@","] UTF8String], -1,NULL);
        } else {
            sqlite3_bind_text(statement, 27, NULL, -1,NULL);
        }
        
        if(scrpitDetail.whitelist.count > 0) {
            sqlite3_bind_text(statement, 28, [[scrpitDetail.whitelist componentsJoinedByString:@","] UTF8String], -1,NULL);
        } else {
            sqlite3_bind_text(statement, 28, NULL, -1,NULL);
        }
        
        sqlite3_bind_text(statement, 29,scrpitDetail.uuid != NULL? [scrpitDetail.uuid UTF8String]:[[[NSUUID UUID] UUIDString] UTF8String], -1,NULL);

        
        
    }
    
    NSInteger resultCode = sqlite3_step(statement);
    if (resultCode != SQLITE_DONE) {
        sqlite3_finalize(statement);
    }
    sqlite3_close(sqliteHandle);
    
}


- (void)updateUserScriptTime:(NSString *)uuid{
    //打开数据库
    sqlite3 *sqliteHandle = NULL;
    int result = 0;
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];


    result = sqlite3_open([destPath
                           UTF8String], &sqliteHandle);
    
    if (result != SQLITE_OK) {
        
        NSLog(@"数据库文件打开失败");
        
        return;
    }
    
    //构造SQL语句

    NSString *sql = @"UPDATE user_config_script SET update_script_time = ? WHERE uuid = ? ";
    
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[date timeIntervalSince1970]*1000; // *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeString = [NSString stringWithFormat:@"%.0f", a];
    
    sqlite3_stmt *stmt = NULL;
    result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return;
    }
    sqlite3_bind_text(stmt, 1, [timeString UTF8String], -1, NULL);
    sqlite3_bind_text(stmt, 2, [uuid UTF8String], -1, NULL);

    if (sqlite3_step(stmt) != SQLITE_DONE) {
        sqlite3_finalize(stmt);
    }
    sqlite3_close(sqliteHandle);
}


- (void)addDownloadResource:(DownloadResource *)resource {
    
    //打开数据库
    sqlite3 *sqliteHandle = NULL;
    int result = 0;
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];


    result = sqlite3_open([destPath
                           UTF8String], &sqliteHandle);
    
    if (result != SQLITE_OK) {
        
        NSLog(@"数据库文件打开失败");
        
        return;
    }
    
    NSString *sql = @"INSERT INTO download_resource (title,icon,host,download_url,download_uuid,status,download_process,watch_process,firstPath,allPath,type,update_time,create_time,use_info,protect,audioUrl) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(sqliteHandle, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        sqlite3_bind_text(statement, 1,resource.title != NULL? [resource.title UTF8String]:NULL, -1,NULL);
        sqlite3_bind_text(statement, 2,resource.icon != NULL? [resource.icon  UTF8String]:NULL, -1,NULL);
        sqlite3_bind_text(statement, 3,resource.host !=NULL? [resource.host UTF8String]:NULL, -1,NULL);
        sqlite3_bind_text(statement, 4,resource.downloadUrl != NULL? [resource.downloadUrl UTF8String]:NULL, -1,NULL);
        sqlite3_bind_text(statement, 5,resource.downloadUuid != NULL? [resource.downloadUuid UTF8String]:NULL, -1,NULL);
        sqlite3_bind_int(statement, 6, 0);
        sqlite3_bind_double(statement, 7, resource.downloadProcess);
        sqlite3_bind_double(statement, 8, 0);
        sqlite3_bind_text(statement, 9, resource.firstPath !=NULL? [resource.firstPath UTF8String]:NULL,-1,NULL);
        sqlite3_bind_text(statement, 10, resource.allPath !=NULL? [resource.allPath UTF8String]:NULL,-1,NULL);
        sqlite3_bind_text(statement, 11, resource.type !=NULL? [resource.type UTF8String]:NULL,-1,NULL);
        NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval a=[date timeIntervalSince1970]*1000; // *1000 是精确到毫秒，不乘就是精确到秒
        NSString *timeString = [NSString stringWithFormat:@"%.0f", a];
        sqlite3_bind_double(statement, 12, timeString.doubleValue);
        sqlite3_bind_double(statement, 13, timeString.doubleValue);
        if(resource.useInfo != NULL) {
            NSError * err;
            NSData * jsonData = [NSJSONSerialization dataWithJSONObject:resource.useInfo options:0 error:&err];
            NSString * useInfo = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            sqlite3_bind_text(statement, 14,[useInfo UTF8String], -1,NULL);
        } else {
            sqlite3_bind_text(statement, 14,NULL, -1,NULL);

        }
        
        int protect = resource.protect ?1:0;
        sqlite3_bind_int(statement, 15, protect);
        sqlite3_bind_text(statement, 16, resource.audioUrl !=NULL? [resource.audioUrl UTF8String]:NULL,-1,NULL);
    }
    
    NSInteger resultCode = sqlite3_step(statement);
    if (resultCode != SQLITE_DONE) {
        sqlite3_finalize(statement);
    }
    sqlite3_close(sqliteHandle);
}


- (NSArray *)selectDownloadResourceByPath:(NSString *)path{
    NSMutableArray *scriptList = [NSMutableArray array];
    
    //打开数据库
    sqlite3 *sqliteHandle = NULL;
    int result = 0;
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];


    result = sqlite3_open([destPath
                           UTF8String], &sqliteHandle);
    
    if (result != SQLITE_OK) {
        
        NSLog(@"数据库文件打开失败");
        
        return scriptList;
    }
    
    //构造SQL语句

    NSString *sql = @"SELECT * FROM download_resource where firstPath = ? order by create_time desc";
    
    sqlite3_stmt *stmt = NULL;
    result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return scriptList;
        
    }
    
//    绑定占位符
//    NSString *queryCondition = [NSString stringWithFormat:@"%d", condition];
    sqlite3_bind_text(stmt, 1, [path UTF8String], -1, NULL);
    //执行SQL语句,代表找到一条符合条件的数据，如果有多条数据符合条件，则要循环调用
    while(sqlite3_step(stmt) == SQLITE_ROW) {
        
        DownloadResource *resource = [[DownloadResource alloc] init];
        
        
        //第几列字段是从0开始
        resource.title = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)== NULL?"":(const char *)sqlite3_column_text(stmt, 1)];
        resource.icon = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)== NULL?"":(const char *)sqlite3_column_text(stmt, 2)];
        resource.host = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 3) == NULL?"":(const char *)sqlite3_column_text(stmt, 3)];
        resource.downloadUrl = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)== NULL?"":(const char *)sqlite3_column_text(stmt, 4)];
        resource.downloadUuid =  [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 5)== NULL?"":(const char *)sqlite3_column_text(stmt, 5)];
        resource.status = sqlite3_column_int(stmt, 6);;
        resource.downloadProcess = sqlite3_column_double(stmt, 7);;
        resource.watchProcess = sqlite3_column_int(stmt, 8);
        resource.videoDuration = sqlite3_column_int(stmt, 9);
        resource.firstPath =  [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 10)== NULL?"":(const char *)sqlite3_column_text(stmt, 10)];
        resource.allPath =  [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 11)== NULL?"":(const char *)sqlite3_column_text(stmt, 11)];
        resource.type =  [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 12)== NULL?"":(const char *)sqlite3_column_text(stmt, 12)];
        resource.updateTime = [NSString stringWithFormat:@"%f", sqlite3_column_double(stmt, 13)];
        resource.createTime = [NSString stringWithFormat:@"%f", sqlite3_column_double(stmt, 14)];
        resource.sort = sqlite3_column_int(stmt, 15);
        int protect = sqlite3_column_int(stmt, 17);
        resource.protect = protect == 1? true:false;
        resource.audioUrl =  [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 18)== NULL?"":(const char *)sqlite3_column_text(stmt, 18)];
        [scriptList addObject:resource];
    }
    sqlite3_finalize(stmt);
    sqlite3_close(sqliteHandle);
    
    return scriptList;
}

- (DownloadResource *)selectDownloadResourceByDownLoadUUid:(NSString *)uuid {
    
    
    
    //打开数据库
    sqlite3 *sqliteHandle = NULL;
    int result = 0;
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];


    result = sqlite3_open([destPath
                           UTF8String], &sqliteHandle);
    
    if (result != SQLITE_OK) {
        
        NSLog(@"数据库文件打开失败");
        
        return nil;
    }
    
    //构造SQL语句

    NSString *sql = @"SELECT * FROM download_resource where download_uuid = ? ";
    
    sqlite3_stmt *stmt = NULL;
    result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return nil;
        
    }
    
//    绑定占位符
//    NSString *queryCondition = [NSString stringWithFormat:@"%d", condition];
    sqlite3_bind_text(stmt, 1, [uuid UTF8String], -1, NULL);
    //执行SQL语句,代表找到一条符合条件的数据，如果有多条数据符合条件，则要循环调用
    DownloadResource *resource = [[DownloadResource alloc] init];

    while(sqlite3_step(stmt) == SQLITE_ROW) {
        //第几列字段是从0开始
        resource.title = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)== NULL?"":(const char *)sqlite3_column_text(stmt, 1)];
        resource.icon = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)== NULL?"":(const char *)sqlite3_column_text(stmt, 2)];
        resource.host = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 3) == NULL?"":(const char *)sqlite3_column_text(stmt, 3)];
        resource.downloadUrl = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)== NULL?"":(const char *)sqlite3_column_text(stmt, 4)];
        resource.downloadUuid =  [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 5)== NULL?"":(const char *)sqlite3_column_text(stmt, 5)];
        resource.status = sqlite3_column_int(stmt, 6);;
        resource.downloadProcess = sqlite3_column_double(stmt, 7);;
        resource.watchProcess = sqlite3_column_int(stmt, 8);
        resource.videoDuration = sqlite3_column_int(stmt, 9);
        resource.firstPath =  [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 10)== NULL?"":(const char *)sqlite3_column_text(stmt, 10)];
        resource.allPath =  [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 11)== NULL?"":(const char *)sqlite3_column_text(stmt, 11)];
        resource.type =  [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 12)== NULL?"":(const char *)sqlite3_column_text(stmt, 12)];
        resource.updateTime = [NSString stringWithFormat:@"%f", sqlite3_column_double(stmt, 13)];
        resource.createTime = [NSString stringWithFormat:@"%f", sqlite3_column_double(stmt, 14)];
        resource.sort = sqlite3_column_int(stmt, 15);
        int protect = sqlite3_column_int(stmt, 17);
        resource.protect = protect == 1? true:false;
        resource.audioUrl =  [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 18)== NULL?"":(const char *)sqlite3_column_text(stmt, 18)];
    }
    sqlite3_finalize(stmt);
    sqlite3_close(sqliteHandle);
    
    return resource;
}

- (void)updateDownloadResourcProcess:(float)process uuid:(NSString *)uuid {
    sqlite3 *sqliteHandle = NULL;
    int result = 0;
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];


    result = sqlite3_open([destPath
                           UTF8String], &sqliteHandle);
    
    if (result != SQLITE_OK) {
        
        NSLog(@"数据库文件打开失败");
        
        return;
    }
    
    //构造SQL语句

    NSString *sql = @"UPDATE download_resource SET download_process = ? WHERE download_uuid = ? ";
    
    sqlite3_stmt *stmt = NULL;
    result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return;
    }
    sqlite3_bind_double(stmt, 1, process);
    sqlite3_bind_text(stmt, 2, [uuid UTF8String], -1, NULL);

    if (sqlite3_step(stmt) != SQLITE_DONE) {
        sqlite3_finalize(stmt);
    }
    sqlite3_close(sqliteHandle);
}


- (void)updateDownloadResourceStatus:(NSInteger)status uuid:(NSString *)uuid{
    sqlite3 *sqliteHandle = NULL;
    int result = 0;
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];


    result = sqlite3_open([destPath
                           UTF8String], &sqliteHandle);
    
    if (result != SQLITE_OK) {
        
        NSLog(@"数据库文件打开失败");
        
        return;
    }
    
    //构造SQL语句

    NSString *sql = @"UPDATE download_resource SET status = ? WHERE download_uuid = ? ";
    
    sqlite3_stmt *stmt = NULL;
    result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return;
    }
    sqlite3_bind_int(stmt, 1, status);
    sqlite3_bind_text(stmt, 2, [uuid UTF8String], -1, NULL);

    if (sqlite3_step(stmt) != SQLITE_DONE) {
        sqlite3_finalize(stmt);
    }
    sqlite3_close(sqliteHandle);
}


- (void)updateVideoDuration:(NSInteger)videoDuration uuid:(NSString *)uuid{
    sqlite3 *sqliteHandle = NULL;
    int result = 0;
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];


    result = sqlite3_open([destPath
                           UTF8String], &sqliteHandle);
    
    if (result != SQLITE_OK) {
        
        NSLog(@"数据库文件打开失败");
        
        return;
    }
    
    //构造SQL语句

    NSString *sql = @"UPDATE download_resource SET videoDuration = ? WHERE download_uuid = ? ";
    
    sqlite3_stmt *stmt = NULL;
    result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return;
    }
    sqlite3_bind_int(stmt, 1, videoDuration);
    sqlite3_bind_text(stmt, 2, [uuid UTF8String], -1, NULL);

    if (sqlite3_step(stmt) != SQLITE_DONE) {
        sqlite3_finalize(stmt);
    }
    sqlite3_close(sqliteHandle);
}


- (void)updateWatchProgress:(NSInteger)watchProgress uuid:(NSString *)uuid{
    sqlite3 *sqliteHandle = NULL;
    int result = 0;
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];


    result = sqlite3_open([destPath
                           UTF8String], &sqliteHandle);
    
    if (result != SQLITE_OK) {
        
        NSLog(@"数据库文件打开失败");
        
        return;
    }
    
    //构造SQL语句

    NSString *sql = @"UPDATE download_resource SET watch_process = ? WHERE download_uuid = ? ";
    
    sqlite3_stmt *stmt = NULL;
    result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return;
    }
    sqlite3_bind_int(stmt, 1, watchProgress);
    sqlite3_bind_text(stmt, 2, [uuid UTF8String], -1, NULL);

    if (sqlite3_step(stmt) != SQLITE_DONE) {
        sqlite3_finalize(stmt);
    }
    sqlite3_close(sqliteHandle);
}


- (void)deleteVideoByuuid:(NSString *)uuid{
    //打开数据库
    sqlite3 *sqliteHandle = NULL;
    int result = 0;
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];


    result = sqlite3_open([destPath
                           UTF8String], &sqliteHandle);
    
    if (result != SQLITE_OK) {
        
        NSLog(@"数据库文件打开失败");
        
        return;
    }
    
    //构造SQL语句

    NSString *sql = @"DELETE FROM download_resource  WHERE download_uuid = ? ";
    
    sqlite3_stmt *stmt = NULL;
    result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return;
    }
//    绑定占位符
    sqlite3_bind_text(stmt, 1, [uuid UTF8String], -1, NULL);

    //执行SQL语句,代表找到一条符合条件的数据，如果有多条数据符合条件，则要循环调用
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        sqlite3_finalize(stmt);
    }
    sqlite3_close(sqliteHandle);
}


- (NSArray *)selectUnDownloadComplete:(NSString *)path {
    NSMutableArray *scriptList = [NSMutableArray array];
    
    //打开数据库
    sqlite3 *sqliteHandle = NULL;
    int result = 0;
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];


    result = sqlite3_open([destPath
                           UTF8String], &sqliteHandle);
    
    if (result != SQLITE_OK) {
        
        NSLog(@"数据库文件打开失败");
        return scriptList;
    }
    
    //构造SQL语句

    NSString *sql = @"SELECT * FROM download_resource where firstPath = ? and status != 2 order by create_time desc";
    
    sqlite3_stmt *stmt = NULL;
    result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return scriptList;
        
    }
    
//    绑定占位符
//    NSString *queryCondition = [NSString stringWithFormat:@"%d", condition];
    sqlite3_bind_text(stmt, 1, [path UTF8String], -1, NULL);
    //执行SQL语句,代表找到一条符合条件的数据，如果有多条数据符合条件，则要循环调用
    while(sqlite3_step(stmt) == SQLITE_ROW) {
        
        DownloadResource *resource = [[DownloadResource alloc] init];
        
        
        //第几列字段是从0开始
        resource.title = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)== NULL?"":(const char *)sqlite3_column_text(stmt, 1)];
        resource.icon = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)== NULL?"":(const char *)sqlite3_column_text(stmt, 2)];
        resource.host = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 3) == NULL?"":(const char *)sqlite3_column_text(stmt, 3)];
        resource.downloadUrl = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)== NULL?"":(const char *)sqlite3_column_text(stmt, 4)];
        resource.downloadUuid =  [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 5)== NULL?"":(const char *)sqlite3_column_text(stmt, 5)];
        resource.status = sqlite3_column_int(stmt, 6);;
        resource.downloadProcess = sqlite3_column_double(stmt, 7);;
        resource.watchProcess = sqlite3_column_int(stmt, 8);
        resource.videoDuration = sqlite3_column_int(stmt, 9);
        resource.firstPath =  [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 10)== NULL?"":(const char *)sqlite3_column_text(stmt, 10)];
        resource.allPath =  [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 11)== NULL?"":(const char *)sqlite3_column_text(stmt, 11)];
        resource.type =  [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 12)== NULL?"":(const char *)sqlite3_column_text(stmt, 12)];
        resource.updateTime = [NSString stringWithFormat:@"%f", sqlite3_column_double(stmt, 13)];
        resource.createTime = [NSString stringWithFormat:@"%f", sqlite3_column_double(stmt, 14)];
        resource.sort = sqlite3_column_int(stmt, 15);
        
        int protect = sqlite3_column_int(stmt, 17);
        resource.protect = protect == 1? true:false;
        resource.audioUrl =  [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 18)== NULL?"":(const char *)sqlite3_column_text(stmt, 18)];

        [scriptList addObject:resource];
    }
    sqlite3_finalize(stmt);
    sqlite3_close(sqliteHandle);
    
    return scriptList;
}

- (NSArray *)selectDownloadComplete:(NSString *)path {
    NSMutableArray *scriptList = [NSMutableArray array];
    
    //打开数据库
    sqlite3 *sqliteHandle = NULL;
    int result = 0;
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];


    result = sqlite3_open([destPath
                           UTF8String], &sqliteHandle);
    
    if (result != SQLITE_OK) {
        
        NSLog(@"数据库文件打开失败");
        return scriptList;
    }
    
    //构造SQL语句

    NSString *sql = @"SELECT * FROM download_resource where firstPath = ? and status = 2 order by create_time desc";
    
    sqlite3_stmt *stmt = NULL;
    result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return scriptList;
        
    }
    
//    绑定占位符
//    NSString *queryCondition = [NSString stringWithFormat:@"%d", condition];
    sqlite3_bind_text(stmt, 1, [path UTF8String], -1, NULL);
    //执行SQL语句,代表找到一条符合条件的数据，如果有多条数据符合条件，则要循环调用
    while(sqlite3_step(stmt) == SQLITE_ROW) {
        
        DownloadResource *resource = [[DownloadResource alloc] init];
        
        
        //第几列字段是从0开始
        resource.title = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)== NULL?"":(const char *)sqlite3_column_text(stmt, 1)];
        resource.icon = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)== NULL?"":(const char *)sqlite3_column_text(stmt, 2)];
        resource.host = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 3) == NULL?"":(const char *)sqlite3_column_text(stmt, 3)];
        resource.downloadUrl = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)== NULL?"":(const char *)sqlite3_column_text(stmt, 4)];
        resource.downloadUuid =  [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 5)== NULL?"":(const char *)sqlite3_column_text(stmt, 5)];
        resource.status = sqlite3_column_int(stmt, 6);;
        resource.downloadProcess = sqlite3_column_double(stmt, 7);;
        resource.watchProcess = sqlite3_column_int(stmt, 8);
        resource.videoDuration = sqlite3_column_int(stmt, 9);
        resource.firstPath =  [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 10)== NULL?"":(const char *)sqlite3_column_text(stmt, 10)];
        resource.allPath =  [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 11)== NULL?"":(const char *)sqlite3_column_text(stmt, 11)];
        resource.type =  [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 12)== NULL?"":(const char *)sqlite3_column_text(stmt, 12)];
        resource.updateTime = [NSString stringWithFormat:@"%f", sqlite3_column_double(stmt, 13)];
        resource.createTime = [NSString stringWithFormat:@"%f", sqlite3_column_double(stmt, 14)];
        resource.sort = sqlite3_column_int(stmt, 15);
        int protect = sqlite3_column_int(stmt, 17);
        resource.protect = protect == 1? true:false;
        resource.audioUrl =  [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 18)== NULL?"":(const char *)sqlite3_column_text(stmt, 18)];

        [scriptList addObject:resource];
    }
    sqlite3_finalize(stmt);
    sqlite3_close(sqliteHandle);
    
    return scriptList;
}


- (void)updateIconByuuid:(UIImage *)image uuid:(NSString *)uuid{
    
    NSString *path_document = NSHomeDirectory();
    //设置一个图片的存储路径
    NSString *imageDocPath = [NSString stringWithFormat:@"/Documents/%@.jpg",[NSUUID UUID].UUIDString];
    
    NSString *imagePath = [path_document stringByAppendingString:imageDocPath];
    [UIImageJPEGRepresentation(image, 100) writeToFile:imagePath options:0 error:nil];

    sqlite3 *sqliteHandle = NULL;
    int result = 0;
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];


    result = sqlite3_open([destPath
                           UTF8String], &sqliteHandle);
    
    if (result != SQLITE_OK) {
        
        NSLog(@"数据库文件打开失败");
        
        return;
    }
    //构造SQL语句

    NSString *sql = @"UPDATE download_resource SET icon = ? WHERE download_uuid = ? ";
    
    sqlite3_stmt *stmt = NULL;
    result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return;
    }
    sqlite3_bind_text(stmt, 1, [imageDocPath UTF8String], -1, NULL);
    sqlite3_bind_text(stmt, 2, [uuid UTF8String], -1, NULL);
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        sqlite3_finalize(stmt);
    }
    sqlite3_close(sqliteHandle);
    
    
}

- (NSArray *)selectDownloadResourceByTitle:(NSString *)title {
    NSMutableArray *scriptList = [NSMutableArray array];
    
    //打开数据库
    sqlite3 *sqliteHandle = NULL;
    int result = 0;
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];


    result = sqlite3_open([destPath
                           UTF8String], &sqliteHandle);
    
    if (result != SQLITE_OK) {
        
        NSLog(@"数据库文件打开失败");
        return scriptList;
    }
    
    //构造SQL语句

    NSString *sql = @"SELECT * FROM download_resource where title like '%%%@%%' and status = 2 order by create_time desc";
    sql = [NSString stringWithFormat:sql,title];
    sqlite3_stmt *stmt = NULL;
    result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return scriptList;
        
    }
    
//    绑定占位符
//    NSString *queryCondition = [NSString stringWithFormat:@"%d", condition];
    //执行SQL语句,代表找到一条符合条件的数据，如果有多条数据符合条件，则要循环调用
    while(sqlite3_step(stmt) == SQLITE_ROW) {
        
        DownloadResource *resource = [[DownloadResource alloc] init];
        
        
        //第几列字段是从0开始
        resource.title = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)== NULL?"":(const char *)sqlite3_column_text(stmt, 1)];
        resource.icon = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)== NULL?"":(const char *)sqlite3_column_text(stmt, 2)];
        resource.host = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 3) == NULL?"":(const char *)sqlite3_column_text(stmt, 3)];
        resource.downloadUrl = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)== NULL?"":(const char *)sqlite3_column_text(stmt, 4)];
        resource.downloadUuid =  [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 5)== NULL?"":(const char *)sqlite3_column_text(stmt, 5)];
        resource.status = sqlite3_column_int(stmt, 6);;
        resource.downloadProcess = sqlite3_column_double(stmt, 7);;
        resource.watchProcess = sqlite3_column_int(stmt, 8);
        resource.videoDuration = sqlite3_column_int(stmt, 9);
        resource.firstPath =  [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 10)== NULL?"":(const char *)sqlite3_column_text(stmt, 10)];
        resource.allPath =  [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 11)== NULL?"":(const char *)sqlite3_column_text(stmt, 11)];
        resource.type =  [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 12)== NULL?"":(const char *)sqlite3_column_text(stmt, 12)];
        resource.updateTime = [NSString stringWithFormat:@"%f", sqlite3_column_double(stmt, 13)];
        resource.createTime = [NSString stringWithFormat:@"%f", sqlite3_column_double(stmt, 14)];
        resource.sort = sqlite3_column_int(stmt, 15);
        int protect = sqlite3_column_int(stmt, 17);
        resource.protect = protect == 1? true:false;
        resource.audioUrl =  [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 18)== NULL?"":(const char *)sqlite3_column_text(stmt, 18)];
        [scriptList addObject:resource];
    }
    sqlite3_finalize(stmt);
    sqlite3_close(sqliteHandle);
    
    return scriptList;
}

- (void)updateScriptConfigDisableWebsite:(NSString *)str numberId:(NSString *)uuid {
    //打开数据库
    sqlite3 *sqliteHandle = NULL;
    int result = 0;
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];


    result = sqlite3_open([destPath
                           UTF8String], &sqliteHandle);
    
    if (result != SQLITE_OK) {
        
        NSLog(@"数据库文件打开失败");
        
        return;
    }
    
    //构造SQL语句

    NSString *sql = @"UPDATE user_config_script SET disabled_websites = ? WHERE uuid = ? ";
    
    sqlite3_stmt *stmt = NULL;
    result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return;
    }
    sqlite3_bind_text(stmt, 1, [str UTF8String], -1, NULL);
    sqlite3_bind_text(stmt, 2, [uuid UTF8String], -1, NULL);

    if (sqlite3_step(stmt) != SQLITE_DONE) {
        sqlite3_finalize(stmt);
    }
    sqlite3_close(sqliteHandle);
}

- (void)updateVideoTitle:(NSString *)title uuid:(NSString *)uuid {
    sqlite3 *sqliteHandle = NULL;
    int result = 0;
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];


    result = sqlite3_open([destPath
                           UTF8String], &sqliteHandle);
    
    if (result != SQLITE_OK) {
        
        NSLog(@"数据库文件打开失败");
        
        return;
    }
    
    //构造SQL语句

    NSString *sql = @"UPDATE download_resource SET title = ? WHERE download_uuid = ? ";
    
    sqlite3_stmt *stmt = NULL;
    result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return;
    }
    sqlite3_bind_text(stmt, 1, [title UTF8String], -1, NULL);
    sqlite3_bind_text(stmt, 2, [uuid UTF8String], -1, NULL);

    if (sqlite3_step(stmt) != SQLITE_DONE) {
        sqlite3_finalize(stmt);
    }
    sqlite3_close(sqliteHandle);
}

- (void)updateVideoPath:(NSString *)path uuid:(NSString *)uuid {
    sqlite3 *sqliteHandle = NULL;
    int result = 0;
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];


    result = sqlite3_open([destPath
                           UTF8String], &sqliteHandle);
    
    if (result != SQLITE_OK) {
        
        NSLog(@"数据库文件打开失败");
        
        return;
    }
    
    //构造SQL语句

    NSString *sql = @"UPDATE download_resource SET firstPath = ? WHERE download_uuid = ? ";
    
    sqlite3_stmt *stmt = NULL;
    result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return;
    }
    sqlite3_bind_text(stmt, 1, [path UTF8String], -1, NULL);
    sqlite3_bind_text(stmt, 2, [uuid UTF8String], -1, NULL);

    if (sqlite3_step(stmt) != SQLITE_DONE) {
        sqlite3_finalize(stmt);
    }
    sqlite3_close(sqliteHandle);
}


- (void)updateVideoAllPath:(NSString *)path uuid:(NSString *)uuid {
    sqlite3 *sqliteHandle = NULL;
    int result = 0;
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];


    result = sqlite3_open([destPath
                           UTF8String], &sqliteHandle);
    
    if (result != SQLITE_OK) {
        
        NSLog(@"数据库文件打开失败");
        
        return;
    }
    
    //构造SQL语句

    NSString *sql = @"UPDATE download_resource SET allPath = ? WHERE download_uuid = ? ";
    
    sqlite3_stmt *stmt = NULL;
    result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return;
    }
    sqlite3_bind_text(stmt, 1, [path UTF8String], -1, NULL);
    sqlite3_bind_text(stmt, 2, [uuid UTF8String], -1, NULL);

    if (sqlite3_step(stmt) != SQLITE_DONE) {
        sqlite3_finalize(stmt);
    }
    sqlite3_close(sqliteHandle);
}


- (void)deleteVideoByuuidPath:(NSString *)uuid{
    //打开数据库
    sqlite3 *sqliteHandle = NULL;
    int result = 0;
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];


    result = sqlite3_open([destPath
                           UTF8String], &sqliteHandle);
    
    if (result != SQLITE_OK) {
        
        NSLog(@"数据库文件打开失败");
        
        return;
    }
    
    //构造SQL语句

    NSString *sql = @"DELETE FROM download_resource  WHERE firstPath = ? ";
    
    sqlite3_stmt *stmt = NULL;
    result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return;
    }
//    绑定占位符
    sqlite3_bind_text(stmt, 1, [uuid UTF8String], -1, NULL);

    //执行SQL语句,代表找到一条符合条件的数据，如果有多条数据符合条件，则要循环调用
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        sqlite3_finalize(stmt);
    }
    sqlite3_close(sqliteHandle);
}

- (NSArray *)selectAllUnDownloadComplete {
    NSMutableArray *scriptList = [NSMutableArray array];
    
    //打开数据库
    sqlite3 *sqliteHandle = NULL;
    int result = 0;
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*documentsDirectory =[paths objectAtIndex:0];
    
    NSString *destPath =[documentsDirectory stringByAppendingPathComponent:@"syScript.sqlite"];


    result = sqlite3_open([destPath
                           UTF8String], &sqliteHandle);
    
    if (result != SQLITE_OK) {
        
        NSLog(@"数据库文件打开失败");
        return scriptList;
    }
    
    //构造SQL语句

    NSString *sql = @"SELECT * FROM download_resource where status != 2 order by create_time desc";
    
    sqlite3_stmt *stmt = NULL;
    result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return scriptList;
        
    }
    
    //执行SQL语句,代表找到一条符合条件的数据，如果有多条数据符合条件，则要循环调用
    while(sqlite3_step(stmt) == SQLITE_ROW) {
        
        DownloadResource *resource = [[DownloadResource alloc] init];
        
        
        //第几列字段是从0开始
        resource.title = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)== NULL?"":(const char *)sqlite3_column_text(stmt, 1)];
        resource.icon = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)== NULL?"":(const char *)sqlite3_column_text(stmt, 2)];
        resource.host = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 3) == NULL?"":(const char *)sqlite3_column_text(stmt, 3)];
        resource.downloadUrl = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)== NULL?"":(const char *)sqlite3_column_text(stmt, 4)];
        resource.downloadUuid =  [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 5)== NULL?"":(const char *)sqlite3_column_text(stmt, 5)];
        resource.status = sqlite3_column_int(stmt, 6);;
        resource.downloadProcess = sqlite3_column_double(stmt, 7);;
        resource.watchProcess = sqlite3_column_int(stmt, 8);
        resource.videoDuration = sqlite3_column_int(stmt, 9);
        resource.firstPath =  [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 10)== NULL?"":(const char *)sqlite3_column_text(stmt, 10)];
        resource.allPath =  [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 11)== NULL?"":(const char *)sqlite3_column_text(stmt, 11)];
        resource.type =  [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 12)== NULL?"":(const char *)sqlite3_column_text(stmt, 12)];
        resource.updateTime = [NSString stringWithFormat:@"%f", sqlite3_column_double(stmt, 13)];
        resource.createTime = [NSString stringWithFormat:@"%f", sqlite3_column_double(stmt, 14)];
        resource.sort = sqlite3_column_int(stmt, 15);
        int protect = sqlite3_column_int(stmt, 17);
        resource.protect = protect == 1? true:false;
        resource.audioUrl =  [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 18)== NULL?"":(const char *)sqlite3_column_text(stmt, 18)];
        [scriptList addObject:resource];
    }
    sqlite3_finalize(stmt);
    sqlite3_close(sqliteHandle);
    
    return scriptList;
}


@end
