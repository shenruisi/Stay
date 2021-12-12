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

@implementation DataManager

+ (instancetype)shareManager {
    
    static DataManager *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[DataManager alloc] init];
        [instance copyFile2Documents:@"syScript.sqlite"];

    });
    return instance;
    
}

//- (void)moveBundleFileToSandBox{
//    NSFileManager *fm = [NSFileManager defaultManager];
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory=[paths objectAtIndex:0];
//    NSString *destpath = [documentsDirectory stringByAppendingPathComponent:@"haihuBrands/brandList.sqlite"];
//    if (![fm fileExistsAtPath:destpath]){
//        NSError *err = nil;
//        NSString *sourcePath = [[NSBundle mainBundle]pathForResource:@"brandList" ofType:@"sqlite"];
//        [fm copyItemAtPath:sourcePath toPath:destpath error:&err];
//        if (err != nil){
//            NSLog(@"error!!!!!");
//        }
//    }
//}

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
        NSArray *scriptArray = [self findScriptInLib];
        
    }
    return destPath;
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

    NSString *sql = @"SELECT * FROM user_config_script";
    
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
            scrpitDetail.mathes = [mathesStr componentsSeparatedByString:@","];
        } else {
            scrpitDetail.mathes = @[];
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
        
        [[Tampermonkey shared] conventScriptContent:scrpitDetail];
        
        [scriptList addObject:scrpitDetail];
    }

    sqlite3_finalize(stmt);
    sqlite3_close(sqliteHandle);
    
    return scriptList;
}

//根据条件查询一组用户，模糊查询 DQL
- (NSArray *)findScriptInLib{
    
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

    NSString *sql = @"SELECT * FROM script_config";
    
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
            scrpitDetail.mathes = [mathesStr componentsSeparatedByString:@","];
        } else {
            scrpitDetail.mathes = @[];
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
            scrpitDetail.mathes = [mathesStr componentsSeparatedByString:@","];
        } else {
            scrpitDetail.mathes = @[];
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
        
        [[Tampermonkey shared] conventScriptContent:scrpitDetail];
        
        [scriptList addObject:scrpitDetail];
    }

    sqlite3_finalize(stmt);
    sqlite3_close(sqliteHandle);
    
    return scriptList;
}

- (NSArray *)selectScriptByKeywordByLib:(NSString *)keyword {
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

    NSString *sql= [NSString stringWithFormat:@"SELECT * FROM script_config WHERE name like '%%%@%%';",keyword];
    
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
            scrpitDetail.mathes = [mathesStr componentsSeparatedByString:@","];
        } else {
            scrpitDetail.mathes = @[];
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
        
        [[Tampermonkey shared] conventScriptContent:scrpitDetail];
        
        [scriptList addObject:scrpitDetail];
    }

    sqlite3_finalize(stmt);
    sqlite3_close(sqliteHandle);
    
    return scriptList;
    
}

- (void)insertToUserScriptnumberId:(NSString *)uuid {
    
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
    
    NSString *sql= @"SELECT * FROM script_config WHERE uuid = ?";
    sqlite3_stmt *stmt = NULL;
    result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return;
        
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
            scrpitDetail.mathes = [mathesStr componentsSeparatedByString:@","];
        } else {
            scrpitDetail.mathes = @[];
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
        
        [[Tampermonkey shared] conventScriptContent:scrpitDetail];
    }
    sqlite3_finalize(stmt);
    sqlite3_close(sqliteHandle);
    
    [self insertUserConfigByUserScript:scrpitDetail];
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
    
    NSString *sql = @"INSERT INTO user_config_script (uuid, name, namespace, author, version, desc, homepage, icon, includes,maches,excludes,runAt,grants,noFrames,content,active,requireUrls,sourcePage) VALUES (?, ?, ?, ?, ?, ?, ?,?,?,?,?,?,?,?,?,?,?,?)";
    
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
        
        if(scrpitDetail.mathes.count > 0) {
            sqlite3_bind_text(statement, 10, [[scrpitDetail.mathes componentsJoinedByString:@","] UTF8String], -1,NULL);
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
    }
    
    NSInteger resultCode = sqlite3_step(statement);
    if (resultCode != SQLITE_DONE) {
        sqlite3_finalize(statement);
    }
    sqlite3_close(sqliteHandle);
}


- (void)updateLibScrpitStatus:(int)status numberId:(NSString *)uuid{
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

    NSString *sql = @"UPDATE script_config SET active = ? WHERE uuid = ? ";
    
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

    //执行SQL语句,代表找到一条符合条件的数据，如果有多条数据符合条件，则要循环调用
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        sqlite3_finalize(stmt);
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
    
    NSString *sql = @"UPDATE user_config_script set name = ?, namespace = ?, author = ?, version = ?, desc = ?, homepage = ?, icon = ?, includes= ?,maches= ?,excludes= ?,runAt= ?,grants= ?,noFrames= ?,content= ?,active= ?,requireUrls= ?,sourcePage= ? where uuid = ?";
    
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
        
        if(scrpitDetail.mathes.count > 0) {
            sqlite3_bind_text(statement, 9, [[scrpitDetail.mathes componentsJoinedByString:@","] UTF8String], -1,NULL);
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
        sqlite3_bind_text(statement, 18,scrpitDetail.uuid != NULL? [scrpitDetail.uuid UTF8String]:[[[NSUUID UUID] UUIDString] UTF8String], -1,NULL);
    }
    
    NSInteger resultCode = sqlite3_step(statement);
    if (resultCode != SQLITE_DONE) {
        sqlite3_finalize(statement);
    }
    sqlite3_close(sqliteHandle);
}


@end
