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
#import "M3U8Parser.h"
#import <ffmpegkit/FFmpegKit.h>
#import "FWEncryptorAES.h"

@implementation Request

@end

@interface TaskSessionState : NSObject

@property (nonatomic, strong) NSURLSessionTask *sessionTask;
@property (nonatomic, strong) NSData *data;
@end

@implementation TaskSessionState

@end

@interface M3U8State : NSObject

@property (nonatomic, assign) NSUInteger totalCount;
@property (nonatomic, assign) NSUInteger currCount;
@property (nonatomic, assign) int status; // 0:start 1: all ts downloaded 2: all ts combined 3: convert to mp4 success
@property (nonatomic, strong) NSMutableArray<NSString *> *tsURLs;
@property (nonatomic, strong) NSString *keyURL;
@property (nonatomic, strong) NSData *keyData;
@property (nonatomic, strong) NSString *keyIV;
@end

@implementation M3U8State

- (nullable instancetype)initWithTaskPath:(NSString *)taskPath {
    NSString *content = [NSString stringWithContentsOfFile:[taskPath stringByAppendingPathComponent:@"M3U8State"] encoding:NSUTF8StringEncoding error:nil];
    if (content.length == 0) {
        content = [NSString stringWithContentsOfFile:[taskPath stringByAppendingPathComponent:@"M3U8State_bak"] encoding:NSUTF8StringEncoding error:nil];
    }
    if (content.length > 0) {
        if (self = [super init]){
            NSArray<NSString *> *lines = [content componentsSeparatedByString:@"\n"];
            self.totalCount = lines[0].intValue;
            self.currCount = lines[1].intValue;
            self.status = lines[2].intValue;
            self.keyURL = lines[3];
            self.keyIV = lines[4];
            self.tsURLs = [NSMutableArray array];
            for (int i = 5; i < lines.count; i++) {
                [self.tsURLs addObject:lines[i]];
            }
            return self;
        }
    }
    
    return nil;
}

- (void)saveToPath:(NSString *)taskPath {
    NSString *content = [NSString stringWithFormat:@"%lu\n%lu\n%d\n%@\n%@",
                         (unsigned long)_totalCount, (unsigned long)_currCount, _status,
                         _keyURL == nil ? @"" : _keyURL, _keyIV == nil ? @"" : _keyIV];
    @synchronized (_tsURLs) {
        for (NSString *tsURL in _tsURLs) {
            content = [content stringByAppendingFormat:@"\n%@", tsURL];
        }
    }
    NSString *filePath = [taskPath stringByAppendingPathComponent:@"M3U8State"];
    [NSFileManager.defaultManager moveItemAtPath:filePath toPath:[filePath stringByAppendingString:@"_bak"] error:nil];
    [content writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

@end


@interface Task()

@property (nonatomic, assign) BOOL isM3U8;
@property (nonatomic, strong) M3U8State *m3u8State;
@property (nonatomic, strong) NSMutableArray<TaskSessionState *> *sessionStates;
@property (nonatomic, assign) NSTimeInterval lastTimestamp;
@property (nonatomic, assign) int64_t bytesWritten;
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

@interface DownloadManager()<AVAssetDownloadDelegate, NSURLSessionDownloadDelegate> {
    dispatch_queue_t _dataQueue;
    dispatch_queue_t _m3u8StateQueue;
    dispatch_queue_t _m3u8TranscodeQueue;
}

@property (nonatomic, strong) NSString *dataPath;
@property (nonatomic, strong) NSMutableDictionary<NSString *, Task *> *taskDict;
@property (nonatomic, strong) NSMutableDictionary<NSURLSessionTask *, Task *> *sessionDict;
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

- (instancetype)init {
    if (self = [super init]){
        _dataQueue = dispatch_queue_create([@"downloader.session.data.queue" UTF8String], DISPATCH_QUEUE_SERIAL);
        _m3u8StateQueue = dispatch_queue_create([@"downloader.m3u8.state.queue" UTF8String], DISPATCH_QUEUE_SERIAL);
        _m3u8TranscodeQueue = dispatch_queue_create([@"downloader.m3u8.transcode.queue" UTF8String], DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
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
            task.filePath = [NSString stringWithFormat:@"%@/%@.%@", request.fileDir, taskId, @"mp4"];
            
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
        task.isM3U8 = [request.url containsString:@"m3u8"];
        NSURLSessionTask *sessionTask;
        if (task.isM3U8) {
//            sessionTask = [self.assetDownloadURLSession assetDownloadTaskWithURLAsset:[AVURLAsset assetWithURL:[NSURL URLWithString:request.url]] assetTitle:request.fileName assetArtworkData:nil options:nil];
            NSString *taskPath = [self.dataPath stringByAppendingPathComponent:taskId];
            if (![[NSFileManager defaultManager] fileExistsAtPath:taskPath]) {
                [NSFileManager.defaultManager createDirectoryAtPath:taskPath withIntermediateDirectories:YES attributes:nil error:nil];
                [self startM3U8Task:task withURL:[NSURL URLWithString:request.url]];
            } else {
                M3U8State *m3u8State = [[M3U8State alloc] initWithTaskPath:taskPath];
                if (m3u8State == nil) {
                    [self startM3U8Task:task withURL:[NSURL URLWithString:request.url]];
                } else {
                    task.m3u8State = m3u8State;
                    task.lastTimestamp = [[NSDate date] timeIntervalSince1970];
                    task.bytesWritten = 0;
                    [self resumeM3U8Task:task];
                }
            }
        } else {
            NSString *dataFilePath = [self.dataPath stringByAppendingPathComponent:[[request.url md5] stringByAppendingString:@"_data"]];
            NSData *data = [NSData dataWithContentsOfFile:dataFilePath];
            sessionTask = data == nil ? [self.downloadSession downloadTaskWithURL:[NSURL URLWithString:request.url]] : [self.downloadSession downloadTaskWithResumeData:data];
            [NSFileManager.defaultManager removeItemAtPath:dataFilePath error:nil];
        }
        if (sessionTask != nil) {
            @synchronized (self.sessionDict) {
                self.sessionDict[sessionTask] = task;
            }
            TaskSessionState *sessionState = [[TaskSessionState alloc] init];
            sessionState.sessionTask = sessionTask;
            task.sessionStates = [NSMutableArray arrayWithObject:sessionState];
            task.lastTimestamp = [[NSDate date] timeIntervalSince1970];
            task.bytesWritten = 0;
            [sessionTask resume];
            task.status = DMStatusDownloading;
        } else {
            
        }
        
        @synchronized (self.taskDict) {
            self.taskDict[taskId] = task;
        }
    } else {
        if (task.status == DMStatusPaused) {
            for (TaskSessionState *sessionState in task.sessionStates) {
                if (sessionState.data != nil) {
                    if (sessionState.sessionTask != nil) {
                        @synchronized (self.sessionDict) {
                            [self.sessionDict removeObjectForKey:sessionState.sessionTask];
                        }
                    }
                    NSURLSessionTask *sessionTask = [self.downloadSession downloadTaskWithResumeData:sessionState.data];
                    sessionState.data = nil;
                    [NSFileManager.defaultManager removeItemAtPath:[self.dataPath stringByAppendingPathComponent:[[sessionState.sessionTask.originalRequest.URL.absoluteString md5] stringByAppendingString:@"_data"]] error:nil];
                    if (sessionTask != nil) {
                        sessionState.sessionTask = sessionTask;
                    }
                    if (sessionState.sessionTask != nil) {
                        @synchronized (self.sessionDict) {
                            self.sessionDict[sessionState.sessionTask] = task;
                        }
                    }
                }
                [sessionState.sessionTask resume];
            }
            task.lastTimestamp = [[NSDate date] timeIntervalSince1970];
            task.bytesWritten = 0;
            if (task.isM3U8) {
                [self resumeM3U8Task:task];
            }
            task.status = DMStatusDownloading;
        }
    }
    
    return task;
}

- (NSArray *)query:(Query *)condition {
    return [self.store query:condition.taskId withKey:condition.key andStatus:condition.status];
}

- (Task *)queryByTaskId:(NSString *)taskId {
    return self.taskDict[taskId];
}

- (void)remove:(NSString *)taskId {
    @synchronized (self.taskDict) {
        Task *task = self.taskDict[taskId];
        if (task != nil) {
            for (TaskSessionState *sessionState in task.sessionStates) {
                @synchronized (self.sessionDict) {
                    [self.sessionDict removeObjectForKey:sessionState.sessionTask];
                }
                [sessionState.sessionTask cancel];
            }
        }
        [self.taskDict removeObjectForKey:taskId];
    }
    [NSFileManager.defaultManager removeItemAtPath:[self.dataPath stringByAppendingPathComponent:taskId] error:nil];
    [self.store remove:taskId];
}

- (void)removeAll:(NSString *)key {
    @synchronized (self.taskDict) {
        Query *condition = [[Query alloc] init];
        condition.key = key;
        NSArray *tasks = [self.store query:condition.taskId withKey:condition.key andStatus:condition.status];
        for (Task *t in tasks) {
            Task *task = self.taskDict[t.taskId];
            if (task != nil) {
                for (TaskSessionState *sessionState in task.sessionStates) {
                    @synchronized (self.sessionDict) {
                        [self.sessionDict removeObjectForKey:sessionState.sessionTask];
                    }
                    [sessionState.sessionTask cancel];
                }
            }
            [self.taskDict removeObjectForKey:t.taskId];
        }
    }
    [self.store removeAll:key];
}

- (void)pause:(NSString *)taskId {
    Task *task = self.taskDict[taskId];
    if (task != nil) {
        @synchronized (task.sessionStates) {
            for (TaskSessionState *sessionState in task.sessionStates) {
                [((NSURLSessionDownloadTask *)sessionState.sessionTask) cancelByProducingResumeData:^(NSData *data) {
                    sessionState.data = data;
                    dispatch_async(self->_dataQueue, ^{
                        NSString *dataFilePath = [self.dataPath stringByAppendingPathComponent:[[sessionState.sessionTask.originalRequest.URL.absoluteString md5] stringByAppendingString:@"_data"]];
                        [NSFileManager.defaultManager removeItemAtPath:dataFilePath error:nil];
                        [data writeToFile:dataFilePath options:NSDataWritingAtomic error:nil];
                    });
                }];
            }
        }
        task.lastTimestamp = 0;
        task.bytesWritten = 0;
        task.status = DMStatusPaused;
        if (task.block != nil) {
            task.block(task.progress, @"", DMStatusPaused);
        }
        
        [self.store update:taskId withDict:@{@"progress": @(task.progress), @"status": @(task.status)}];
    }
}

- (void)pauseAll {
    for (NSString *taskId in self.taskDict.allKeys) {
        [self pause:taskId];
    }
}

- (NSString *)dataPath{
    if (nil == _dataPath){
        _dataPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/.dm/"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:_dataPath]) {
            [NSFileManager.defaultManager createDirectoryAtPath:_dataPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    
    return _dataPath;
}

- (NSMutableDictionary<NSString *, Task *> *)taskDict{
    if (nil == _taskDict){
        _taskDict = [[NSMutableDictionary alloc] init];
    }
    
    return _taskDict;
}

- (NSMutableDictionary<NSURLSessionTask *, Task *> *)sessionDict{
    if (nil == _sessionDict){
        _sessionDict = [[NSMutableDictionary alloc] init];
    }
    
    return _sessionDict;
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
        config.shouldUseExtendedBackgroundIdleMode = YES;
        [config setHTTPAdditionalHeaders:@{@"User-Agent" : @"Mozilla/5.0 (iPhone; CPU iPhone OS 16_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.1 Mobile/15E148 Safari/604.1"}];
        _downloadSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    }
    
    return _downloadSession;
}

- (void)startM3U8Task:(Task *)task withURL:(NSURL *)url {
    [url m3u_loadAsyncCompletion:^(M3U8PlaylistModel *model, NSError *error) {
        if (model != nil) {
            M3U8State *m3u8State = [[M3U8State alloc] init];
            NSUInteger segmentCount = model.mainMediaPl.segmentList.count;
            m3u8State.totalCount = segmentCount;
            m3u8State.tsURLs = [NSMutableArray array];
            for (int i = 0; i < segmentCount; i++) {
                M3U8SegmentInfo *segInfo = [model.mainMediaPl.segmentList segmentInfoAtIndex:i];
                [m3u8State.tsURLs addObject:segInfo.urlString];
                if (i == 0 && segInfo.xKey != nil) {
                    m3u8State.keyURL = segInfo.xKey.url;
                    if (![m3u8State.keyURL hasPrefix:@"http"]) {
                        m3u8State.keyURL = [NSURL URLWithString:m3u8State.keyURL relativeToURL:[[NSURL URLWithString:segInfo.urlString] URLByDeletingLastPathComponent]].absoluteString;
                    }
                    m3u8State.keyIV = segInfo.xKey.iV;
                }
            }
            task.m3u8State = m3u8State;
            task.lastTimestamp = [[NSDate date] timeIntervalSince1970];
            task.bytesWritten = 0;
            [self resumeM3U8Task:task];
        } else {
            if (task.block != nil) {
                task.block(0, @"", DMStatusFailed);
            }
            [self.store update:task.taskId withDict:@{@"progress": @(0), @"status": @(DMStatusFailed)}];
            @synchronized (self.taskDict) {
                [self.taskDict removeObjectForKey:task.taskId];
            }
        }
    }];
}

- (void)resumeM3U8Task:(Task *)task {
    if (task.sessionStates == nil) {
        task.sessionStates = [NSMutableArray array];
    }
    int status = task.m3u8State.status;
    if (status == 1 || status == 2) {
        [self transcodeM3U8:task];
    } else {
        @synchronized (task.sessionStates) {
            NSUInteger count = task.sessionStates.count;
            NSMutableSet<NSString *> *currURLs = [NSMutableSet set];
            for (TaskSessionState *sessionState in task.sessionStates) {
                NSString *url = sessionState.sessionTask.originalRequest.URL.absoluteString;
                if (url.length > 0) {
                    [currURLs addObject:url];
                }
            }
            NSString *taskPath = [self.dataPath stringByAppendingPathComponent:task.taskId];
            NSString *keyURL = task.m3u8State.keyURL;
            if (keyURL != nil && [keyURL hasPrefix:@"http"] && ![currURLs containsObject:keyURL]) {
                [self addTsSession:keyURL withTaskPath:taskPath andTask:task];
            } else {
                for (NSString *tsURL in task.m3u8State.tsURLs) {
                    if ([tsURL hasPrefix:@"http"] && ![currURLs containsObject:tsURL]) {
                        [self addTsSession:tsURL withTaskPath:taskPath andTask:task];
                        count++;
                        if (count > 3) {
                            break;
                        }
                    }
                }
                if (count == 0) {
                    task.m3u8State.status = 1;
                    [self transcodeM3U8:task];
                }
            }
        }
    }
    [task.m3u8State saveToPath:[self.dataPath stringByAppendingPathComponent:task.taskId]];
}

- (void)addTsSession:(NSString *)tsURL withTaskPath:(NSString *)taskPath andTask:(Task *)task {
    NSURLSessionTask *sessionTask;
    NSString *dataFilePath = [taskPath stringByAppendingPathComponent:[[tsURL md5] stringByAppendingString:@"_data"]];
    NSData *data = [NSData dataWithContentsOfFile:dataFilePath];
    sessionTask = data == nil ? [self.downloadSession downloadTaskWithURL:[NSURL URLWithString:tsURL]] : [self.downloadSession downloadTaskWithResumeData:data];
    [NSFileManager.defaultManager removeItemAtPath:dataFilePath error:nil];
    if (sessionTask != nil) {
        @synchronized (self.sessionDict) {
            self.sessionDict[sessionTask] = task;
        }
        TaskSessionState *sessionState = [[TaskSessionState alloc] init];
        sessionState.sessionTask = sessionTask;
        [task.sessionStates addObject:sessionState];
        [sessionTask resume];
    } else {
        
    }
}

- (void)transcodeM3U8:(Task *)task {
    if (task.block != nil) {
        task.block(0, @"", DMStatusTranscoding);
    }
    dispatch_async(self->_m3u8TranscodeQueue, ^{
        [self combineM3U8Ts:task];
        [self convertM3U8ToMP4:task];
    });
}

- (void)combineM3U8Ts:(Task *)task {
    if (task.m3u8State.status != 1) {
        return;
    }
    
//    NSString *taskPath = [self.dataPath stringByAppendingPathComponent:task.taskId];
//    NSString *content = @"";
//    for (NSString *tsURL in task.m3u8State.tsURLs) {
//        content = [content stringByAppendingFormat:@"file '%@'\n", [taskPath stringByAppendingPathComponent:tsURL]];
//    }
//    NSString *filePath = [taskPath stringByAppendingPathComponent:@"allts.txt"];
//    NSError *err;
//    [content writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&err];
//    if (err != nil) {
//        if (task.block != nil) {
//            task.block(0, @"", DMStatusFailedNoSpace);
//        }
//        [self.store update:task.taskId withDict:@{@"progress": @(0), @"status": @(DMStatusFailed)}];
////        @synchronized (self.taskDict) {
////            [self.taskDict removeObjectForKey:task.taskId];
////        }
//        return;
//    }
//    task.m3u8State.status = 2;
//    [task.m3u8State saveToPath:taskPath];
    
    NSLog(@"FFmpeg : start");
    NSString *taskPath = [self.dataPath stringByAppendingPathComponent:task.taskId];
    NSString *filePath = [taskPath stringByAppendingPathComponent:@"combined.ts"];
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
    for (NSString *tsURL in task.m3u8State.tsURLs) {
        NSError *err;
        [fileHandle writeData:[NSData dataWithContentsOfFile:[taskPath stringByAppendingPathComponent:tsURL]] error:&err];
        if (err != nil) {
            if (task.block != nil) {
                task.block(0, @"", DMStatusFailedNoSpace);
            }
            [self.store update:task.taskId withDict:@{@"progress": @(0), @"status": @(DMStatusFailed)}];
//                @synchronized (self.taskDict) {
//                    [self.taskDict removeObjectForKey:task.taskId];
//                }
            [fileHandle closeAndReturnError:&err];
            return;
        }
    }
    [fileHandle closeAndReturnError:nil];
    task.m3u8State.status = 2;
    [task.m3u8State saveToPath:taskPath];
    for (NSString *tsURL in task.m3u8State.tsURLs) {
        [NSFileManager.defaultManager removeItemAtPath:[taskPath stringByAppendingPathComponent:tsURL] error:nil];
    }
}

- (void)convertM3U8ToMP4:(Task *)task {
    if (task.m3u8State.status != 2) {
        return;
    }
    
    NSString *taskPath = [self.dataPath stringByAppendingPathComponent:task.taskId];
    [NSFileManager.defaultManager removeItemAtPath:task.filePath error:nil];
    FFmpegSession* session = [FFmpegKit execute:[NSString stringWithFormat:@"-i '%@' -c copy '%@'", [taskPath stringByAppendingPathComponent:@"combined.ts"], task.filePath]];
//    FFmpegSession* session = [FFmpegKit execute:[NSString stringWithFormat:@"-f concat -safe 0 -i '%@' -c copy '%@'", [taskPath stringByAppendingPathComponent:@"allts.txt"], task.filePath]];
    
    NSLog(@"FFmpeg : cost %ldms", [session getDuration]);
    NSArray *logs = [session getLogs];
    for (Log *log in logs) {
        NSLog(@"FFmpeg : %@", [log getMessage]);
    }
    
    ReturnCode *returnCode = [session getReturnCode];
    NSLog(@"FFmpeg process exited with state %@ and rc %@.%@", [FFmpegKitConfig sessionStateToString:[session getState]], returnCode, [session getFailStackTrace]);
    if ([ReturnCode isSuccess:returnCode]) {
        [[NSFileManager defaultManager] removeItemAtPath:taskPath error:nil];
        if (task.block != nil) {
            task.block(1, @"", DMStatusComplete);
        }
        [self.store update:task.taskId withDict:@{@"progress": @(1), @"status": @(DMStatusComplete)}];
        @synchronized (self.taskDict) {
            [self.taskDict removeObjectForKey:task.taskId];
        }
    } else if ([ReturnCode isCancel:returnCode]) {
        // CANCEL

    } else {
        // FAILURE
        NSLog(@"Command failed with state %@ and rc %@.%@", [FFmpegKitConfig sessionStateToString:[session getState]], returnCode, [session getFailStackTrace]);
        if (task.block != nil) {
            task.block(0, @"", DMStatusFailedTranscode);
        }
        [self.store update:task.taskId withDict:@{@"progress": @(0), @"status": @(DMStatusFailed)}];
//            @synchronized (self.taskDict) {
//                [self.taskDict removeObjectForKey:task.taskId];
//            }
    }
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
    if (task != nil && assetDownloadTask.error == nil) {
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
    if (task != nil && task.status != DMStatusPaused) {
        @synchronized (self.sessionDict) {
            [self.sessionDict removeObjectForKey:sessionTask];
        }
        @synchronized (task.sessionStates) {
            for (int i = task.sessionStates.count - 1; i >= 0; i--) {
                if (task.sessionStates[i].sessionTask == sessionTask) {
                    [task.sessionStates removeObjectAtIndex:i];
                    break;
                }
            }
        }
    }
    if (error != nil && task != nil && task.status != DMStatusPaused) {
        if (task.isM3U8) {
            [self resumeM3U8Task:task];
        } else {
            if (task.block != nil) {
                task.block(0, @"", DMStatusFailed);
            }
            [self.store update:task.taskId withDict:@{@"progress": @(0), @"status": @(DMStatusFailed)}];
            @synchronized (self.taskDict) {
                [self.taskDict removeObjectForKey:task.taskId];
            }
        }
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
                                           didWriteData:(int64_t)bytesWritten
                                      totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    Task *task = [self getTaskWithSessionTask:downloadTask];
    if (task != nil) {
        task.bytesWritten += bytesWritten;
        if (task.block != nil) {
            task.progress = task.isM3U8 ? task.m3u8State.currCount * 1.0 / task.m3u8State.totalCount : totalBytesWritten * 1.0 / totalBytesExpectedToWrite;
            NSString *speed = @"";
            NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
            if (task.lastTimestamp > 0 && timestamp - task.lastTimestamp > 1) {
                long long speedBS = task.bytesWritten / (timestamp - task.lastTimestamp);
                NSLog([NSString stringWithFormat:@"speedBS : %ld, bytesWritten : %ld, time : %f", speedBS, task.bytesWritten, timestamp - task.lastTimestamp]);
                speed = [[NSByteCountFormatter stringFromByteCount:speedBS countStyle:NSByteCountFormatterCountStyleFile] stringByAppendingString:@"/S"];
                task.lastTimestamp = timestamp;
                task.bytesWritten = 0;
                task.block(task.progress, speed, DMStatusDownloading);
            }
        }
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSLog(@"URLSession downloadTask didFinishDownloadingToURL : %@", location);
    Task *task = [self getTaskWithSessionTask:downloadTask];
    if (task != nil && downloadTask.error == nil) {
        if (task.isM3U8) {
            @synchronized (task.sessionStates) {
                for (int i = task.sessionStates.count - 1; i >= 0; i--) {
                    if (task.sessionStates[i].sessionTask == downloadTask) {
                        [task.sessionStates removeObjectAtIndex:i];
                        break;
                    }
                }
            }
            NSString *requestURL = downloadTask.originalRequest.URL.absoluteString;
            NSString *taskPath = [self.dataPath stringByAppendingPathComponent:task.taskId];
            NSString *filePath = [taskPath stringByAppendingPathComponent:[[requestURL md5] stringByAppendingString:@".ts"]];
            BOOL isKeyURL = NO;
            if (task.m3u8State.keyURL.length == 0) {
                [NSFileManager.defaultManager moveItemAtURL:location toURL:[NSURL fileURLWithPath:filePath] error:nil];
            } else {
                if ([task.m3u8State.keyURL isEqualToString:requestURL]) {
                    isKeyURL = YES;
                    [NSFileManager.defaultManager moveItemAtURL:location toURL:[NSURL fileURLWithPath:filePath] error:nil];
                    task.m3u8State.keyURL = filePath.lastPathComponent;
                    task.m3u8State.keyData = [NSData dataWithContentsOfFile:filePath];
                } else {
                    if (task.m3u8State.keyData == nil) {
                        task.m3u8State.keyData = [NSData dataWithContentsOfFile:[taskPath stringByAppendingPathComponent:task.m3u8State.keyURL]];
                    }
                    NSData *decrypted = [FWEncryptorAES decrypt:[NSData dataWithContentsOfURL:location] Key:task.m3u8State.keyData IV:task.m3u8State.keyIV];
                    if (decrypted != nil) {
                        [decrypted writeToFile:filePath atomically:YES];
                    } else {
                        [NSFileManager.defaultManager moveItemAtURL:location toURL:[NSURL fileURLWithPath:filePath] error:nil];
                    }
                }
            }
            if (!isKeyURL) {
                NSMutableArray<NSString *> *tsURLs = task.m3u8State.tsURLs;
                for (int i = 0; i < tsURLs.count; i++) {
                    NSString *tsURL = tsURLs[i];
                    if ([tsURL hasPrefix:@"http"] && [tsURL isEqualToString:requestURL]) {
                        task.m3u8State.currCount++;
                        tsURLs[i] = filePath.lastPathComponent;
                        break;
                    }
                }
            }
            [self resumeM3U8Task:task];
        } else {
            [NSFileManager.defaultManager moveItemAtURL:location toURL:[NSURL fileURLWithPath:task.filePath] error:nil];
            [NSFileManager.defaultManager removeItemAtPath:[self.dataPath stringByAppendingPathComponent:[[downloadTask.originalRequest.URL.absoluteString md5] stringByAppendingString:@"_data"]] error:nil];
            if (task.block != nil) {
                task.block(1, @"", DMStatusComplete);
            }
            [self.store update:task.taskId withDict:@{@"progress": @(1), @"status": @(DMStatusComplete)}];
            @synchronized (self.taskDict) {
                [self.taskDict removeObjectForKey:task.taskId];
            }
        }
    }
}

- (nullable Task *)getTaskWithSessionTask:(NSURLSessionTask *)sessionTask {
    return self.sessionDict[sessionTask];
}

@end
