//
//  DownloadManager.m
//  Stay
//
//  Created by Jin on 2022/11/23.
//

#import "DownloadManager.h"
#import "MyAdditions.h"
#import "DMStore.h"

@implementation Request

@end

@interface Task()<NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSURLSessionTask *sessionTask;
@end

@implementation Task

- (instancetype)init {
    if (self = [super init]) {
        self.status = DMStatusNone;
    }
    
    return self;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    if (self.block != nil) {
        self.progress = totalBytesSent * 1.0 / totalBytesExpectedToSend;
        self.block(self.progress, DMStatusDownloading);
    }
}

@end

@implementation Query

@end

@interface DownloadManager()

@property (nonatomic, strong) NSMutableDictionary<NSString *, Task *> *taskDict;
@property (nonatomic, strong) DMStore *store;
@end

@implementation DownloadManager

static DownloadManager *instance = nil;
+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DownloadManager alloc] init];
    });
    
    return instance;
}

- (Task *)enqueue:(Request *)request {
    NSString *taskId = [request.url md5];
    Task *task = self.taskDict[taskId];
    if (task == nil) {
        if ([self.store query:taskId withKey:nil andStatus:-1].count == 0) {
            task = [[Task alloc] init];
            task.taskId = taskId;
            task.progress = 0;
            task.status = DMStatusPending;
            NSURLSessionDownloadTask *sessionTask = [NSURLSession.sharedSession downloadTaskWithURL:[NSURL URLWithString:request.url] completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (error != nil) {
                    if (task.block != nil) {
                        task.block(0, DMStatusFailed);
                    }
                    [self.store update:taskId withDict:@{@"progress": @(0), @"status": @(DMStatusFailed)}];
                } else {
                    if (task.block != nil) {
                        task.block(100, DMStatusComplete);
                    }
                    [self.store update:taskId withDict:@{@"progress": @(100), @"status": @(DMStatusComplete)}];
                }
                @synchronized (self.taskDict) {
                    [self.taskDict removeObjectForKey:taskId];
                }
            }];
            sessionTask.delegate = task;
            task.sessionTask = sessionTask;
            [sessionTask resume];
            
            @synchronized (self.taskDict) {
                self.taskDict[taskId] = task;
            }
        }
    } else {
        if (task.status == DMStatusPaused) {
            [task.sessionTask resume];
        }
    }
    
    return task;
}

- (NSArray *)query:(Query *)condition {
    return [self.store query:condition.taskId withKey:condition.key andStatus:condition.status];
}

- (void)remove:(NSString *)taskId {
    @synchronized (self.taskDict) {
        [self.taskDict removeObjectForKey:taskId];
    }
    [self.store remove:taskId];
}

- (void)removeAll:(NSString *)key {
    @synchronized (self.taskDict) {
        Query *condition = [[Query alloc] init];
        condition.key = key;
        NSArray *tasks = [self.store query:condition.taskId withKey:condition.key andStatus:condition.status];
        for (Task *t in tasks) {
            [self.taskDict removeObjectForKey:t.taskId];
        }
    }
    [self.store removeAll:key];
}

- (void)pause:(NSString *)taskId {
    @synchronized (self.taskDict) {
        Task *task = self.taskDict[taskId];
        if (task != nil) {
            [task.sessionTask suspend];
            task.status = DMStatusPaused;
            if (task.block != nil) {
                task.block(task.progress, DMStatusPaused);
            }
        }
    }
    [self.store update:taskId withDict:@{@"progress": self.taskDict[taskId], @"status": @(self.taskDict[taskId].status)}];
}

- (NSMutableDictionary<NSString *, Task *> *)taskDict{
    if (nil == _taskDict){
        _taskDict = [[NSMutableDictionary alloc] init];
    }
    
    return _taskDict;
}

- (DMStore *)store {
    if (nil == _store){
        _store = [[DMStore alloc] init];
    }
    
    return _store;
}

@end
