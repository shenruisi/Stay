//
//  DownloadManager.m
//  Stay
//
//  Created by Jin on 2022/11/23.
//

#import <AVFoundation/AVFoundation.h>
#import "DownloadManager.h"
#import "MyAdditions.h"
#import "DMStore.h"

@implementation Request

@end

@interface Task()<NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSessionTask *sessionTask;
@property (nonatomic, strong) DMStore *store;
@property (nonatomic, strong) NSMutableDictionary<NSString *, Task *> *taskDict;
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

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
                                           didWriteData:(int64_t)bytesWritten
                                      totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    if (self.block != nil) {
        self.progress = totalBytesWritten * 1.0 / totalBytesExpectedToWrite;
        self.block(self.progress, DMStatusDownloading);
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    [NSFileManager.defaultManager moveItemAtURL:location toURL:[NSURL fileURLWithPath:self.filePath] error:nil];
    if (self.block != nil) {
        self.block(1, DMStatusComplete);
    }
    [self.store update:self.taskId withDict:@{@"progress": @(1), @"status": @(DMStatusComplete)}];
    @synchronized (self.taskDict) {
        [self.taskDict removeObjectForKey:self.taskId];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error != nil) {
        if (self.block != nil) {
            self.block(0, DMStatusFailed);
        }
        [self.store update:self.taskId withDict:@{@"progress": @(0), @"status": @(DMStatusFailed)}];
        @synchronized (self.taskDict) {
            [self.taskDict removeObjectForKey:self.taskId];
        }
    }
}

@end

@implementation Query

@end

@interface DownloadManager()<AVAssetDownloadDelegate>

@property (nonatomic, strong) NSMutableDictionary<NSString *, Task *> *taskDict;
@property (nonatomic, strong) DMStore *store;
@property (nonatomic, strong) AVAssetDownloadURLSession *assetDownloadURLSession;
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
            task.filePath = [request.fileDir stringByAppendingPathComponent:request.fileName];
            task.store = self.store;
            task.taskDict = self.taskDict;
            
            NSURLSessionTask *sessionTask;
            if ([request.url containsString:@"m3u8"]) {
                sessionTask = [self.assetDownloadURLSession assetDownloadTaskWithURLAsset:[AVURLAsset assetWithURL:[NSURL URLWithString:request.url]] assetTitle:request.fileName assetArtworkData:nil options:nil];
            } else {
                sessionTask = [NSURLSession.sharedSession downloadTaskWithURL:[NSURL URLWithString:request.url]];
                sessionTask.delegate = task;
            }
            if (sessionTask != nil) {
                task.sessionTask = sessionTask;
                [sessionTask resume];
            } else {
                
            }
            
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

- (AVAssetDownloadURLSession *)assetDownloadURLSession {
    if (nil == _assetDownloadURLSession) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"m3u8.downloader"];
        _assetDownloadURLSession = [AVAssetDownloadURLSession sessionWithConfiguration:config assetDownloadDelegate:self delegateQueue:nil];
    }
    
    return _assetDownloadURLSession;
}

- (void)URLSession:(NSURLSession *)session assetDownloadTask:(AVAssetDownloadTask *)assetDownloadTask didLoadTimeRange:(CMTimeRange)timeRange totalTimeRangesLoaded:(NSArray<NSValue *> *)loadedTimeRanges timeRangeExpectedToLoad:(CMTimeRange)timeRangeExpectedToLoad {
    Task *task = [self getTaskWithSessionTask:assetDownloadTask];
    if (task != nil) {
        float progress = 0.0;
        for (NSValue *value in loadedTimeRanges) {
            progress += CMTimeGetSeconds(value.CMTimeRangeValue.duration) / CMTimeGetSeconds(timeRangeExpectedToLoad.duration);
        }
        task.progress = progress;
        if (task.block != nil) {
            task.block(progress, DMStatusDownloading);
        }
    }
}

- (void)URLSession:(NSURLSession *)session assetDownloadTask:(AVAssetDownloadTask *)assetDownloadTask didFinishDownloadingToURL:(NSURL *)location {
    Task *task = [self getTaskWithSessionTask:assetDownloadTask];
    if (task != nil) {
        [NSFileManager.defaultManager moveItemAtURL:location toURL:[NSURL fileURLWithPath:task.filePath] error:nil];
        if (task.block != nil) {
            task.block(1, DMStatusComplete);
        }
        [self.store update:task.taskId withDict:@{@"progress": @(1), @"status": @(DMStatusComplete)}];
        @synchronized (self.taskDict) {
            [self.taskDict removeObjectForKey:task.taskId];
        }
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)sessionTask didCompleteWithError:(NSError *)error {
    Task *task = [self getTaskWithSessionTask:sessionTask];
    if (error != nil && task != nil) {
        if (task.block != nil) {
            task.block(0, DMStatusFailed);
        }
        [self.store update:task.taskId withDict:@{@"progress": @(0), @"status": @(DMStatusFailed)}];
        @synchronized (self.taskDict) {
            [self.taskDict removeObjectForKey:task.taskId];
        }
    }
}

- (nullable Task *)getTaskWithSessionTask:(NSURLSessionTask *)sessionTask {
    for (Task *task in self.taskDict.allValues) {
        if (task.sessionTask == sessionTask) {
            return task;
        }
    }
    
    return nil;
}

@end
