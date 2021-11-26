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

    NSString *sql = @"SELECT * FROM script_config WHERE status = ? ";
    
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
        
        ScriptDetailModel *scrpitDetail = [[ScriptDetailModel alloc] init];
        
        //第几列字段是从0开始
        scrpitDetail.id_number = sqlite3_column_int(stmt, 0);
        scrpitDetail.title = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)== NULL?"1":(const char *)sqlite3_column_text(stmt, 1)];
        scrpitDetail.script_desc = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2) == NULL?"1":(const char *)sqlite3_column_text(stmt, 2)];
        scrpitDetail.author = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 3)== NULL?"1":(const char *)sqlite3_column_text(stmt, 3)];
        scrpitDetail.status =  sqlite3_column_int(stmt, 4);
        scrpitDetail.script = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 5)== NULL?"1":(const char *)sqlite3_column_text(stmt, 5)];
        
        [scriptList addObject:scrpitDetail];
    }

    sqlite3_finalize(stmt);
    sqlite3_close(sqliteHandle);
    
    return scriptList;
}


- (void)updateScrpitStatus:(int)status numberId:(int)numberId {
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

    NSString *sql = @"UPDATE script_config SET status = ? WHERE id = ? ";
    
    sqlite3_stmt *stmt = NULL;
    result = sqlite3_prepare(sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(sqliteHandle));
        NSLog(@"编译sql失败");
        sqlite3_close(sqliteHandle);
        return;
    }
    
//    绑定占位符
//    NSString *queryCondition = [NSString stringWithFormat:@"%d", condition];
    sqlite3_bind_int(stmt, 1, status);
    sqlite3_bind_int(stmt, 2, numberId);
//    if (sqlite3_prepare_v2(sqliteHandle, [sql UTF8String], -1, &stmt, nil) == SQLITE_OK)
//    {
//    }
    //执行SQL语句,代表找到一条符合条件的数据，如果有多条数据符合条件，则要循环调用
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        sqlite3_finalize(stmt);
    }
    sqlite3_close(sqliteHandle);
    
}

@end
