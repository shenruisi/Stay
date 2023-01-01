//
//  DMStore.m
//  Stay
//
//  Created by Jin on 2022/11/28.
//

#import "DMStore.h"
#import "DownloadManager.h"
#import <sqlite3.h>

@interface DMStore()

@property(nonatomic) sqlite3 *sqliteHandle;
@end

@implementation DMStore

- (instancetype)init {
    if (self = [super init]){
        int err = sqlite3_open([self sqlitePath], (sqlite3**)&_sqliteHandle);
        if(err != SQLITE_OK) {
            NSLog(@"error opening!: %d", err);
        } else {
            NSString *sql = @"CREATE TABLE IF NOT EXISTS Task (task_id Text Primary key, key Text, url Text, file_dir Text, file_name Text, file_type Text, progress Float, status Int, create_time DATETIME)";
            sqlite3_stmt *stmt = NULL;
            int result = sqlite3_prepare(_sqliteHandle, [sql UTF8String], -1, &stmt, NULL);
            if (result == SQLITE_OK) {
                sqlite3_step(stmt);
            }
            sqlite3_finalize(stmt);
        }
    }
    
    return self;
}

- (void)dealloc {
    if (_sqliteHandle != nil) {
        sqlite3_close(_sqliteHandle);
        _sqliteHandle = nil;
    }
}

- (const char*)sqlitePath {
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/.dm/dm.sqlite"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [NSFileManager.defaultManager createDirectoryAtPath:[path stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return [path fileSystemRepresentation];
}

- (void)insert:(NSDictionary *)task {
    if (_sqliteHandle == nil) {
        return;
    }
    
    NSString *sql = @"INSERT INTO Task VALUES (?, ?, ?, ?, ?, ?, 0, 0, datetime())";
    sqlite3_stmt *stmt = NULL;
    if (sqlite3_prepare_v2(_sqliteHandle, [sql UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, [task[@"taskId"] UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 2, [task[@"key"] UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 3, [task[@"url"] UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 4, [task[@"fileDir"] UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 5, [task[@"fileName"] UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 6, [task[@"fileType"] UTF8String], -1, NULL);
    }
    sqlite3_step(stmt);
    sqlite3_finalize(stmt);
}

- (void)remove:(NSString *)taskId {
    NSString *sql = @"DELETE FROM Task WHERE task_id=?";
    sqlite3_stmt *stmt = NULL;
    if (sqlite3_prepare_v2(_sqliteHandle, [sql UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, [taskId UTF8String], -1, NULL);
    }
    sqlite3_step(stmt);
    sqlite3_finalize(stmt);
}

- (void)removeAll:(NSString *)key {
    NSString *sql = @"DELETE FROM Task WHERE key=?";
    sqlite3_stmt *stmt = NULL;
    if (sqlite3_prepare_v2(_sqliteHandle, [sql UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, [key UTF8String], -1, NULL);
    }
    sqlite3_step(stmt);
    sqlite3_finalize(stmt);
}

- (void)update:(NSString *)taskId withDict:(NSDictionary *)info {
    NSString *sql = @"UPDATE Task SET progress=?, status=? WHERE task_id=?";
    sqlite3_stmt *stmt = NULL;
    if (sqlite3_prepare_v2(_sqliteHandle, [sql UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
        sqlite3_bind_double(stmt, 1, [info[@"progress"] floatValue]);
        sqlite3_bind_int(stmt, 2, [info[@"status"] intValue]);
        sqlite3_bind_text(stmt, 3, [taskId UTF8String], -1, NULL);
    }
    sqlite3_step(stmt);
    sqlite3_finalize(stmt);
}

- (NSArray *)query:(nullable NSString *)taskId withKey:(nullable NSString *)key andStatus:(NSInteger)status {
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    
    int count = 0;
    NSString *sql = @"SELECT * FROM Task WHERE ";
    if (taskId != nil) {
        sql = [sql stringByAppendingString:@"task_id=? AND "];
        count++;
    }
    if (key != nil) {
        sql = [sql stringByAppendingString:@"key=? AND "];
        count++;
    }
    if (status != -1) {
        sql = [sql stringByAppendingString:@"status=?"];
        count++;
    } else if (count > 0) {
        sql = [sql substringToIndex:sql.length - 4];
    }
    sqlite3_stmt *stmt = NULL;
    if (sqlite3_prepare_v2(_sqliteHandle, [sql UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
        if (taskId != nil) {
            sqlite3_bind_text(stmt, 1, [taskId UTF8String], -1, NULL);
            if (key != nil) {
                sqlite3_bind_text(stmt, 2, [key UTF8String], -1, NULL);
                if (status != -1) {
                    sqlite3_bind_int(stmt, 3, (int)status);
                }
            } else if (status != -1) {
                sqlite3_bind_int(stmt, 2, (int)status);
            }
        } else {
            if (key != nil) {
                sqlite3_bind_text(stmt, 1, [key UTF8String], -1, NULL);
                if (status != -1) {
                    sqlite3_bind_int(stmt, 2, (int)status);
                }
            } else {
                sqlite3_bind_int(stmt, 1, (int)status);
            }
        }
    }
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        Task *task = [[Task alloc] init];
        task.taskId = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 0)];
        task.progress = sqlite3_column_double(stmt, 6);
        task.status = sqlite3_column_int(stmt, 7);
        NSString *url = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)];
        task.filePath = [NSString stringWithFormat:@"%@/%@.%@", [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 3)], task.taskId, [url containsString:@"m3u8"] ? @"m3u8" : @"mp4"];
        [ret addObject:task];
    }
    sqlite3_finalize(stmt);
    
    return ret;
}

@end
