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
    return;
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
    
    NSString *sql = @"INSERT INTO user_config_script (uuid, name, namespace, author, version, desc, homepage, icon, includes,maches,excludes,runAt,grants,noFrames,content,active,requireUrls,sourcePage,updateUrl,downloadUrl,notes,resourceUrl,update_time,switch,license,iCloud_identifier,status) VALUES (?, ?, ?, ?, ?, ?, ?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    
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
        sqlite3_bind_int(statement, 24, 0);
        sqlite3_bind_text(statement, 25, [scrpitDetail.license UTF8String], -1,NULL);
        sqlite3_bind_text(statement, 26, [scrpitDetail.iCloudIdentifier UTF8String], -1,NULL);
        sqlite3_bind_int(statement, 27, 1);
    }
    
    NSInteger resultCode = sqlite3_step(statement);
    if (resultCode != SQLITE_DONE) {
        sqlite3_finalize(statement);
    }
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
    
    NSString *sql = @"UPDATE user_config_script set name = ?, namespace = ?, author = ?, version = ?, desc = ?, homepage = ?, icon = ?, includes= ?,maches= ?,excludes= ?,runAt= ?,grants= ?,noFrames= ?,content= ?,active= ?,requireUrls= ?,sourcePage= ?,updateUrl = ?,downloadUrl = ?,notes = ?,resourceUrl = ?, update_time = ?, license = ?,iCloud_identifier = ?   where uuid = ?";
    
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
        sqlite3_bind_text(statement, 25,scrpitDetail.uuid != NULL? [scrpitDetail.uuid UTF8String]:[[[NSUUID UUID] UUIDString] UTF8String], -1,NULL);

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


@end
