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

@interface Task()

@property (nonatomic, strong) NSURLSessionTask *sessionTask;
@property (nonatomic, assign) NSTimeInterval lastTimestamp;
@end

@implementation Task

- (instancetype)init {
    if (self = [super init]) {
        self.status = DMStatusNone;
    }
    
    return self;
}

@end

@implementation Query

@end

@interface DownloadManager()<AVAssetDownloadDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSMutableDictionary<NSString *, Task *> *taskDict;
@property (nonatomic, strong) DMStore *store;
@property (nonatomic, strong) NSURLSession *downloadSession;
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
        NSArray<Task *> *tasks = [self.store query:taskId withKey:nil andStatus:-1];
        if (tasks.count == 0) {
            task = [[Task alloc] init];
            task.taskId = taskId;
            task.progress = 0;
            task.status = DMStatusPending;
            task.filePath = [request.fileDir stringByAppendingPathComponent:request.fileName];
            
            [self.store insert:@{
                @"taskId": taskId,
                @"key": request.key,
                @"url": request.url,
                @"fileDir": request.fileDir,
                @"fileName": request.fileName,
                @"fileType": request.fileType,
            }];
        } else {
            task = tasks[0];
        }
        NSURLSessionTask *sessionTask;
        if ([request.url containsString:@"m3u8"]) {
            sessionTask = [self.assetDownloadURLSession assetDownloadTaskWithURLAsset:[AVURLAsset assetWithURL:[NSURL URLWithString:request.url]] assetTitle:request.fileName assetArtworkData:nil options:nil];
        } else {
            sessionTask = [self.downloadSession downloadTaskWithURL:[NSURL URLWithString:request.url]];
        }
        if (sessionTask != nil) {
            task.sessionTask = sessionTask;
            task.lastTimestamp = [[NSDate date] timeIntervalSince1970];
            [sessionTask resume];
        } else {
            
        }
        
        @synchronized (self.taskDict) {
            self.taskDict[taskId] = task;
        }
    } else {
        if (task.status == DMStatusPaused) {
            [task.sessionTask resume];
            task.status = DMStatusDownloading;
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
    Task *task = self.taskDict[taskId];
    if (task != nil) {
        [task.sessionTask cancel];
        task.status = DMStatusPaused;
        if (task.block != nil) {
            task.block(task.progress, @"", DMStatusPaused);
        }
        
        [self.store update:taskId withDict:@{@"progress": @(task.progress), @"status": @(task.status)}];
    }
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

- (NSURLSession *)downloadSession {
    if (nil == _downloadSession) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"normal.downloader"];
        _downloadSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    }
    
    return _downloadSession;
}

- (void)URLSession:(NSURLSession *)session assetDownloadTask:(AVAssetDownloadTask *)assetDownloadTask didLoadTimeRange:(CMTimeRange)timeRange totalTimeRangesLoaded:(NSArray<NSValue *> *)loadedTimeRanges timeRangeExpectedToLoad:(CMTimeRange)timeRangeExpectedToLoad {
    NSLog(@"URLSession assetDownloadTask totalTimeRangesLoaded / timeRangeExpectedToLoad : %f / %f", CMTimeGetSeconds(loadedTimeRanges[0].CMTimeRangeValue.duration), CMTimeGetSeconds(timeRangeExpectedToLoad.duration));
    Task *task = [self getTaskWithSessionTask:assetDownloadTask];
    if (task != nil) {
        float progress = 0.0;
        for (NSValue *value in loadedTimeRanges) {
            progress += CMTimeGetSeconds(value.CMTimeRangeValue.duration) / CMTimeGetSeconds(timeRangeExpectedToLoad.duration);
        }
        task.progress = progress;
        if (task.block != nil) {
            task.block(progress, @"", DMStatusDownloading);
        }
    }
}

- (void)URLSession:(NSURLSession *)session assetDownloadTask:(AVAssetDownloadTask *)assetDownloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSLog(@"URLSession assetDownloadTask didFinishDownloadingToURL : %@", location);
    Task *task = [self getTaskWithSessionTask:assetDownloadTask];
    if (task != nil) {
        [NSFileManager.defaultManager moveItemAtURL:location toURL:[NSURL fileURLWithPath:task.filePath] error:nil];
        if (task.block != nil) {
            task.block(1, @"", DMStatusComplete);
        }
        [self.store update:task.taskId withDict:@{@"progress": @(1), @"status": @(DMStatusComplete)}];
        @synchronized (self.taskDict) {
            [self.taskDict removeObjectForKey:task.taskId];
        }
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)sessionTask didCompleteWithError:(NSError *)error {
    NSLog(@"URLSession sessionTask didCompleteWithError : %@", error);
    Task *task = [self getTaskWithSessionTask:sessionTask];
    if (error != nil && task != nil) {
        if (task.block != nil) {
            task.block(0, @"", DMStatusFailed);
        }
        [self.store update:task.taskId withDict:@{@"progress": @(0), @"status": @(DMStatusFailed)}];
        @synchronized (self.taskDict) {
            [self.taskDict removeObjectForKey:task.taskId];
        }
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
                                           didWriteData:(int64_t)bytesWritten
                                      totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    Task *task = [self getTaskWithSessionTask:downloadTask];
    if (task != nil) {
        if (task.block != nil) {
            task.progress = totalBytesWritten * 1.0 / totalBytesExpectedToWrite;
            NSString *speed = @"";
            NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
            if (task.lastTimestamp > 0) {
                long long speedBS = bytesWritten / (timestamp - task.lastTimestamp);
                speed = [[NSByteCountFormatter stringFromByteCount:speedBS countStyle:NSByteCountFormatterCountStyleFile] stringByAppendingString:@"/S"];
            }
            task.lastTimestamp = timestamp;
            NSLog(@"URLSession downloadTask didWriteData / totalBytesExpectedToWrite(speed) : %lld / %lld(%@)", bytesWritten, totalBytesExpectedToWrite, speed);
            task.block(task.progress, speed, DMStatusDownloading);
        }
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSLog(@"URLSession downloadTask didFinishDownloadingToURL : %@", location);
    Task *task = [self getTaskWithSessionTask:downloadTask];
    if (task != nil) {
        [NSFileManager.defaultManager moveItemAtURL:location toURL:[NSURL fileURLWithPath:task.filePath] error:nil];
        if (task.block != nil) {
            task.block(1, @"", DMStatusComplete);
        }
        [self.store update:task.taskId withDict:@{@"progress": @(1), @"status": @(DMStatusComplete)}];
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
