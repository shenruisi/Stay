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
#import "NSString+m3u8.h"
#import "NSURL+m3u8.h"
#import "FCConfig.h"

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
@property (nonatomic, strong) NSString *mapURL;
@property (nonatomic, assign) int mediaType; // 0:ts 1:fmp4
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
            self.mediaType = lines[3].intValue;
            self.keyURL = lines[4];
            self.keyIV = lines[5];
            self.mapURL = lines[6];
            self.tsURLs = [NSMutableArray array];
            for (int i = 7; i < lines.count; i++) {
                [self.tsURLs addObject:lines[i]];
            }
            return self;
        }
    }
    
    return nil;
}

- (void)saveToPath:(NSString *)taskPath {
    NSString *content = [NSString stringWithFormat:@"%lu\n%lu\n%d\n%d\n%@\n%@\n%@",
                         (unsigned long)_totalCount, (unsigned long)_currCount, _status, _mediaType,
                         _keyURL == nil ? @"" : _keyURL, _keyIV == nil ? @"" : _keyIV, _mapURL == nil ? @"" : _mapURL];
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

@interface NormalState : NSObject

@property (nonatomic, assign) int mode; // 0:no range
@property (nonatomic, assign) int status; // 0:start 1: video downloaded 2: audio downloaded 3: convert to mp4 success
@property (nonatomic, strong) NSString *videoUrl;
@property (nonatomic, strong) NSString *videoType;
@property (nonatomic, strong) NSString *audioUrl;
@property (nonatomic, strong) NSString *audioType;
@end

@implementation NormalState

- (nullable instancetype)initWithTaskPath:(NSString *)taskPath {
    NSString *content = [NSString stringWithContentsOfFile:[taskPath stringByAppendingPathComponent:@"NormalState"] encoding:NSUTF8StringEncoding error:nil];
    if (content.length == 0) {
        content = [NSString stringWithContentsOfFile:[taskPath stringByAppendingPathComponent:@"NormalState_bak"] encoding:NSUTF8StringEncoding error:nil];
    }
    if (content.length > 0) {
        if (self = [super init]){
            NSArray<NSString *> *lines = [content componentsSeparatedByString:@"\n"];
            self.mode = lines[0].intValue;
            self.status = lines[1].intValue;
            self.videoUrl = lines[2];
            self.videoType = lines[3];
            self.audioUrl = lines[4];
            self.audioType = lines[5];
            return self;
        }
    }
    
    return nil;
}

- (void)saveToPath:(NSString *)taskPath {
    NSString *content = [NSString stringWithFormat:@"%d\n%d\n%@\n%@\n%@\n%@",
                         _mode, _status, _videoUrl, _videoType == nil ? @"mp4" : _videoType, _audioUrl == nil ? @"" : _audioUrl, _audioType == nil ? @"m4a" : _audioType];
    NSString *filePath = [taskPath stringByAppendingPathComponent:@"NormalState"];
    [NSFileManager.defaultManager moveItemAtPath:filePath toPath:[filePath stringByAppendingString:@"_bak"] error:nil];
    [content writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

@end


@interface Task()

@property (nonatomic, assign) BOOL isM3U8;
@property (nonatomic, strong) M3U8State *m3u8State;
@property (nonatomic, assign) BOOL isNormal;
@property (nonatomic, strong) NormalState *normalState;
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
    dispatch_queue_t _stateQueue;
    dispatch_queue_t _transcodeQueue;
    NSInteger _m3u8Concurrency;
}

@property (nonatomic, strong) NSString *dataPath;
@property (nonatomic, strong) NSMutableDictionary<NSString *, Task *> *taskDict;
@property (nonatomic, strong) NSMutableDictionary<NSURLSessionTask *, Task *> *sessionDict;
@property (nonatomic, strong) DMStore *store;
@property (nonatomic, strong) NSURLSession *downloadSession;
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
        _stateQueue = dispatch_queue_create([@"downloader.task.state.queue" UTF8String], DISPATCH_QUEUE_SERIAL);
        _transcodeQueue = dispatch_queue_create([@"downloader.task.transcode.queue" UTF8String], DISPATCH_QUEUE_SERIAL);
        _m3u8Concurrency = [[FCConfig shared] getIntegerValueOfKey:GroupUserDefaultsKeyM3U8Concurrency];
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
            task.key = request.key;
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
        task.isM3U8 = [request.url containsString:@"m3u8"] || request.m3u8Content.length > 0;
        NSURLSessionTask *sessionTask;
        if (task.isM3U8) {
            NSString *taskPath = [self.dataPath stringByAppendingPathComponent:taskId];
            if (![[NSFileManager defaultManager] fileExistsAtPath:taskPath]) {
                [NSFileManager.defaultManager createDirectoryAtPath:taskPath withIntermediateDirectories:YES attributes:nil error:nil];
                [self startM3U8Task:task withURL:[NSURL URLWithString:request.url] withContent:request.m3u8Content];
            } else {
                M3U8State *m3u8State = [[M3U8State alloc] initWithTaskPath:taskPath];
                if (m3u8State == nil) {
                    [self startM3U8Task:task withURL:[NSURL URLWithString:request.url] withContent:request.m3u8Content];
                } else {
                    task.progress = m3u8State.currCount * 1.0 / m3u8State.totalCount;
                    task.m3u8State = m3u8State;
                    task.lastTimestamp = [[NSDate date] timeIntervalSince1970];
                    task.bytesWritten = 0;
                    [self resumeM3U8Task:task];
                }
            }
        } else {
            NSString *dataFilePath = [self.dataPath stringByAppendingPathComponent:[[request.url md5] stringByAppendingString:@"_data"]];
            NSData *data = [NSData dataWithContentsOfFile:dataFilePath];
            if (data != nil) {
                sessionTask = [self.downloadSession downloadTaskWithResumeData:data];
            }
            if (sessionTask != nil) {
                sessionTask.priority = 1.0;
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
                task.isNormal = YES;
                NSString *taskPath = [self.dataPath stringByAppendingPathComponent:taskId];
                if (![[NSFileManager defaultManager] fileExistsAtPath:taskPath]) {
                    [NSFileManager.defaultManager createDirectoryAtPath:taskPath withIntermediateDirectories:YES attributes:nil error:nil];
                    [self startNormalTask:task withRequest:request];
                } else {
                    NormalState *normalState = [[NormalState alloc] initWithTaskPath:taskPath];
                    if (normalState == nil) {
                        [self startNormalTask:task withRequest:request];
                    } else {
                        task.normalState = normalState;
                        task.lastTimestamp = [[NSDate date] timeIntervalSince1970];
                        task.bytesWritten = 0;
                        [self resumNormalTask:task];
                    }
                }
            }
            [NSFileManager.defaultManager removeItemAtPath:dataFilePath error:nil];
        }
        
        @synchronized (self.taskDict) {
            self.taskDict[taskId] = task;
        }
    } else {
        if (task.status == DMStatusPaused) {
            NSString *dirPath = (task.isM3U8 || task.isNormal) ? [self.dataPath stringByAppendingPathComponent:task.taskId] : self.dataPath;
            for (TaskSessionState *sessionState in task.sessionStates) {
                if (sessionState.sessionTask != nil) {
                    @synchronized (self.sessionDict) {
                        [self.sessionDict removeObjectForKey:sessionState.sessionTask];
                    }
                }
                NSURLSessionTask *sessionTask;
                if (sessionState.data != nil) {
                    sessionTask = [self.downloadSession downloadTaskWithResumeData:sessionState.data];
                    sessionState.data = nil;
                    [NSFileManager.defaultManager removeItemAtPath:[dirPath stringByAppendingPathComponent:[[sessionState.sessionTask.originalRequest.URL.absoluteString md5] stringByAppendingString:@"_data"]] error:nil];
                }
                if (sessionTask == nil) {
                    sessionTask = [self.downloadSession downloadTaskWithRequest:[sessionState.sessionTask.originalRequest.URL getRequest]];
                }
                sessionState.sessionTask = sessionTask;
                if (sessionState.sessionTask != nil) {
                    sessionState.sessionTask.priority = 1.0;
                    @synchronized (self.sessionDict) {
                        self.sessionDict[sessionState.sessionTask] = task;
                    }
                    [sessionState.sessionTask resume];
                }
            }
            task.lastTimestamp = [[NSDate date] timeIntervalSince1970];
            task.bytesWritten = 0;
            if (task.isM3U8) {
                [self resumeM3U8Task:task];
            } else if (task.isNormal) {
                [self resumNormalTask:task];
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
            [NSFileManager.defaultManager removeItemAtPath:[self.dataPath stringByAppendingPathComponent:t.taskId] error:nil];
        }
    }
    [self.store removeAll:key];
}

- (void)pause:(NSString *)taskId {
    Task *task = self.taskDict[taskId];
    if (task != nil) {
        @synchronized (task.sessionStates) {
            for (TaskSessionState *sessionState in task.sessionStates) {
                sessionState.data = nil;
                [NSFileManager.defaultManager removeItemAtPath:[self.dataPath stringByAppendingPathComponent:[[sessionState.sessionTask.originalRequest.URL.absoluteString md5] stringByAppendingString:@"_data"]] error:nil];
                [((NSURLSessionDownloadTask *)sessionState.sessionTask) cancelByProducingResumeData:^(NSData *data) {
                    sessionState.data = data;
                    if (data != nil) {
                        dispatch_async(self->_dataQueue, ^{
                            NSString *dataFilePath = [self.dataPath stringByAppendingPathComponent:[[sessionState.sessionTask.originalRequest.URL.absoluteString md5] stringByAppendingString:@"_data"]];
                            [NSFileManager.defaultManager removeItemAtPath:dataFilePath error:nil];
                            [data writeToFile:dataFilePath options:NSDataWritingAtomic error:nil];
                        });
                    }
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

- (NSURLSession *)downloadSession {
    if (nil == _downloadSession) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"normal.downloader"];
        config.HTTPMaximumConnectionsPerHost = 65535;
        config.shouldUseExtendedBackgroundIdleMode = YES;
        [config setHTTPAdditionalHeaders:@{@"User-Agent" : @"Mozilla/5.0 (iPhone; CPU iPhone OS 16_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.1 Mobile/15E148 Safari/604.1"}];
        _downloadSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    }
    
    return _downloadSession;
}

- (void)setM3U8Concurrency:(int)concurrency {
    _m3u8Concurrency = concurrency;
}

- (void)startM3U8Task:(Task *)task withURL:(NSURL *)url withContent:(NSString *)content {
    [url m3u_loadAsyncCompletion:^(M3U8PlaylistModel *model, NSError *error) {
        if (model != nil) {
            M3U8State *m3u8State = [[M3U8State alloc] init];
            NSUInteger segmentCount = model.mainMediaPl.segmentList.count;
            m3u8State.totalCount = segmentCount;
            m3u8State.tsURLs = [NSMutableArray array];
            if (model.mainMediaPl.mapURL.length > 0) {
                m3u8State.mapURL = model.mainMediaPl.mapURL;
                m3u8State.mediaType = 1;
                [m3u8State.tsURLs addObject:model.mainMediaPl.mapURL];
            } else {
                m3u8State.mediaType = 0;
            }
            for (int i = 0; i < segmentCount; i++) {
                M3U8SegmentInfo *segInfo = [model.mainMediaPl.segmentList segmentInfoAtIndex:i];
                [m3u8State.tsURLs addObject:segInfo.urlString];
                if (i == 0 && segInfo.xKey != nil) {
                    m3u8State.keyURL = segInfo.xKey.url;
                    if (![m3u8State.keyURL hasPrefix:@"http"]) {
                        m3u8State.keyURL = [NSURL URLWithString:m3u8State.keyURL relativeToURL:[[NSURL URLWithString:segInfo.urlString] URLByDeletingLastPathComponent]].absoluteString;
                    }
                    m3u8State.keyIV = segInfo.xKey.iV;
                    if (m3u8State.keyIV == nil) {
                        m3u8State.keyIV = @"";
                    }
                }
            }
            task.m3u8State = m3u8State;
            task.lastTimestamp = [[NSDate date] timeIntervalSince1970];
            task.bytesWritten = 0;
            [self resumeM3U8Task:task];
        } else {
            [self taskFailed:task];
        }
    } withContent:content];
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
                        if (count >= _m3u8Concurrency) {
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
    dispatch_async(self->_stateQueue, ^{
        [task.m3u8State saveToPath:[self.dataPath stringByAppendingPathComponent:task.taskId]];
    });
}

- (void)addTsSession:(NSString *)tsURL withTaskPath:(NSString *)taskPath andTask:(Task *)task {
    NSURLSessionTask *sessionTask;
    NSString *dataFilePath = [taskPath stringByAppendingPathComponent:[[tsURL md5] stringByAppendingString:@"_data"]];
    NSData *data = [NSData dataWithContentsOfFile:dataFilePath];
    if (data != nil) {
        sessionTask = [self.downloadSession downloadTaskWithResumeData:data];
    }
    if (sessionTask == nil) {
        sessionTask = [self.downloadSession downloadTaskWithRequest:[tsURL getRequest]];
    };
    [NSFileManager.defaultManager removeItemAtPath:dataFilePath error:nil];
    if (sessionTask != nil) {
        sessionTask.priority = 1.0;
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
    dispatch_async(self->_transcodeQueue, ^{
        [self combineM3U8Ts:task];
        [self convertM3U8ToMP4:task];
    });
}

- (void)combineM3U8Ts:(Task *)task {
    if (task.m3u8State.status != 1) {
        return;
    }
    
    NSString *taskPath = [self.dataPath stringByAppendingPathComponent:task.taskId];
    NSString *filePath = [taskPath stringByAppendingPathComponent:task.m3u8State.mediaType == 1 ? @"combined.mp4" : @"combined.ts"];
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
    [self ffmpegExecute:[NSString stringWithFormat:@"-i '%@' -c copy '%@'", [taskPath stringByAppendingPathComponent:task.m3u8State.mediaType == 1 ? @"combined.mp4" : @"combined.ts"], task.filePath] forTask:task];
}

- (void)startNormalTask:(Task *)task withRequest:(Request *)request {
    NormalState *normalState = [[NormalState alloc] init];
    normalState.videoUrl = request.url;
    normalState.videoType = [request.url containsString:@"webm"] ? @"webm" : @"mp4";
    normalState.audioUrl = request.audioUrl;
    if (request.audioUrl.length > 0) {
        normalState.audioType = [request.audioUrl containsString:@"webm"] ? @"webm" : @"mp4";
    }
    task.normalState = normalState;
    task.lastTimestamp = [[NSDate date] timeIntervalSince1970];
    task.bytesWritten = 0;
    [self resumNormalTask:task];
}

- (void)resumNormalTask:(Task *)task {
    if (task.sessionStates == nil) {
        task.sessionStates = [NSMutableArray array];
    }
    NSString *taskPath = [self.dataPath stringByAppendingPathComponent:task.taskId];
    int status = task.normalState.status;
    if (status == 2) {
        [self transcodeNormal:task];
    } else if (status == 1) {
        if (task.normalState.audioUrl.length > 0) {
            NSString *filePath = [taskPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", [task.normalState.audioUrl md5], task.normalState.audioType]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                task.normalState.status = 2;
                [self transcodeNormal:task];
            } else {
                if (task.block != nil) {
                    task.block(0, @"", DMStatusTranscoding);
                }
                if (task.sessionStates.count == 0) {
                    [self addTsSession:task.normalState.audioUrl withTaskPath:taskPath andTask:task];
                }
            }
        } else {
            if ([task.normalState.videoType isEqualToString:@"mp4"]) {
                NSString *filePath = [taskPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", task.taskId, task.normalState.videoType]];
                if ([task.key isEqualToString:FILEUUID]) {
                    NSUserDefaults *groupUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dajiu.stay.pro"];
                    NSData *loadPath = [groupUserDefaults objectForKey:@"bookmark"];
                    NSURL *loadUrl = [NSURL URLByResolvingBookmarkData:loadPath options:0 relativeToURL:nil bookmarkDataIsStale:nil error:nil];
                    BOOL fileUrlAuthozied = [loadUrl startAccessingSecurityScopedResource];
                    if (fileUrlAuthozied) {
                        NSError *err;
                        [NSFileManager.defaultManager moveItemAtPath:filePath toPath:task.filePath error:&err];
                        if (err) {
                            [self taskFailed:task];
                        } else {
                            task.normalState.status = 3;
                            [self taskComplete:task];
                        }
                    } else {
                        [self taskFailed:task];
                    }
                    [loadUrl stopAccessingSecurityScopedResource];
                } else {
                    [NSFileManager.defaultManager moveItemAtPath:filePath toPath:task.filePath error:nil];
                    task.normalState.status = 3;
                    [self taskComplete:task];
                }
                return;
            } else {
                task.normalState.status = 2;
                [self transcodeNormal:task];
            }
        }
    } else {
        if (task.sessionStates.count > 0) {
            return;
        }
        @synchronized (task.sessionStates) {
            [self addTsSession:task.normalState.videoUrl withTaskPath:taskPath andTask:task];
            if (task.normalState.audioUrl.length > 0) {
                [self addTsSession:task.normalState.audioUrl withTaskPath:taskPath andTask:task];
            }
        }
    }
    dispatch_async(self->_stateQueue, ^{
        [task.normalState saveToPath:[self.dataPath stringByAppendingPathComponent:task.taskId]];
    });
}

- (void)transcodeNormal:(Task *)task {
    if (task.block != nil) {
        task.block(0, @"", DMStatusTranscoding);
    }
    dispatch_async(self->_transcodeQueue, ^{
        [self convertNormalToMP4:task];
    });
}

- (void)convertNormalToMP4:(Task *)task {
    if (task.normalState.status != 2) {
        return;
    }
    
    NSString *taskPath = [self.dataPath stringByAppendingPathComponent:task.taskId];
    [NSFileManager.defaultManager removeItemAtPath:task.filePath error:nil];
    NSString *command = [NSString stringWithFormat:@"-i '%@.%@' -c:v mpeg4 -c:a aac '%@'", [taskPath stringByAppendingPathComponent:task.taskId], task.normalState.videoType, task.filePath];
    if (task.normalState.audioUrl.length > 0) {
        command = [NSString stringWithFormat:@"-i '%@.%@' -i '%@.%@' -c:v %@ -c:a %@ '%@'",
                   [taskPath stringByAppendingPathComponent:task.taskId], task.normalState.videoType,
                   [taskPath stringByAppendingPathComponent:[task.normalState.audioUrl md5]], task.normalState.audioType,
                   [task.normalState.videoType isEqualToString:@"mp4"] ? @"copy" : @"mpeg4",
                   [task.normalState.audioType isEqualToString:@"mp4"] ? @"copy" : @"aac",
                   task.filePath];
    }
    [self ffmpegExecute:command forTask:task];
}

- (void)ffmpegExecute:(NSString *)command forTask:(Task *)task {
    __block double duration = 0;
    [FFmpegKitConfig enableLogCallback:^(Log *log) {
        if (duration == 0) {
            if ([log.getMessage rangeOfString:@"^\\d{2,}:\\d\\d:\\d\\d" options:NSRegularExpressionSearch].length > 0) {
                NSArray<NSString *> *times = [log.getMessage componentsSeparatedByString:@":"];
                duration = times[0].doubleValue * 3600 + times[1].doubleValue * 60 + times[2].doubleValue;
            }
        }
//        NSLog(@"ffmpeg log: %@", log.getMessage);
    }];
    [FFmpegKitConfig enableStatisticsCallback:^(Statistics *statistics) {
        if (duration > 0) {
            if (task.block != nil && statistics.getTime > 0) {
                int remain = (duration - statistics.getTime / 1000.0) / statistics.getSpeed;
//                NSLog(@"ffmpeg remain: %d", remain);
                if (remain > 0) {
                    task.block(0, [self timeFormatted:remain], DMStatusTranscoding);
                }
            }
        }
//        NSLog(@"ffmpeg stat: %d", statistics.getTime);
    }];
    NSURL *loadUrl;
    if ([task.key isEqualToString:FILEUUID]) {
        NSUserDefaults *groupUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dajiu.stay.pro"];
        NSData *loadPath = [groupUserDefaults objectForKey:@"bookmark"];
        loadUrl = [NSURL URLByResolvingBookmarkData:loadPath options:0 relativeToURL:nil bookmarkDataIsStale:nil error:nil];
        BOOL fileUrlAuthozied = [loadUrl startAccessingSecurityScopedResource];
        if (!fileUrlAuthozied) {
            
        }
    }
    FFmpegSession* session = [FFmpegKit execute:command];
    if ([task.key isEqualToString:FILEUUID]) {
        [loadUrl stopAccessingSecurityScopedResource];
    }
    ReturnCode *returnCode = [session getReturnCode];
//    NSLog(@"FFmpeg process exited with state %@ and rc %@.%@", [FFmpegKitConfig sessionStateToString:[session getState]], returnCode, [session getFailStackTrace]);
    if ([ReturnCode isSuccess:returnCode]) {
        if (task.isM3U8) {
            task.m3u8State.status = 3;
        } else {
            task.normalState.status = 3;
        }
        [self taskComplete:task];
    } else if ([ReturnCode isCancel:returnCode]) {
        // CANCEL

    } else {
        // FAILURE
//        NSLog(@"Command failed with state %@ and rc %@.%@", [FFmpegKitConfig sessionStateToString:[session getState]], returnCode, [session getFailStackTrace]);
        if (task.block != nil) {
            task.block(0, @"", DMStatusFailedTranscode);
        }
        [self.store update:task.taskId withDict:@{@"progress": @(0), @"status": @(DMStatusFailed)}];
    }
}

- (NSString *)timeFormatted:(int)totalSeconds {
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;

    if(hours == 0) {
        return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    } else {
        return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)sessionTask didCompleteWithError:(NSError *)error {
//    NSLog(@"URLSession sessionTask didCompleteWithError : %@", error);
    Task *task = [self getTaskWithSessionTask:sessionTask];
    if (task != nil && task.status != DMStatusPaused) {
        @synchronized (self.sessionDict) {
            [self.sessionDict removeObjectForKey:sessionTask];
        }
        [self removeSessionTask:sessionTask fromTask:task];
    }
    if (error != nil && task != nil && task.status != DMStatusPaused) {
        if (task.isM3U8) {
            [self resumeM3U8Task:task];
        } else if (task.isNormal) {
            if ([task.normalState.videoUrl isEqualToString:sessionTask.originalRequest.URL.absoluteString]) {
                for (TaskSessionState *sessionState in task.sessionStates) {
                    @synchronized (self.sessionDict) {
                        [self.sessionDict removeObjectForKey:sessionState.sessionTask];
                    }
                    [sessionState.sessionTask cancel];
                }
                [self taskFailed:task];
            } else {
                if (task.normalState.status == 1) {
                    if (task.block != nil) {
                        task.block(0, @"", DMStatusFailedTranscode);
                    }
                    [self.store update:task.taskId withDict:@{@"progress": @(0), @"status": @(DMStatusFailed)}];
                }
            }
        } else {
            [self taskFailed:task];
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
        if (task.isNormal && task.normalState.audioUrl.length > 0 && [task.normalState.audioUrl isEqualToString:downloadTask.originalRequest.URL.absoluteString]) {
            return;
        }
        if (task.block != nil) {
            task.progress = task.isM3U8 ? task.m3u8State.currCount * 1.0 / task.m3u8State.totalCount : totalBytesWritten * 1.0 / totalBytesExpectedToWrite;
            NSString *speed = @"";
            NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
            if (task.lastTimestamp > 0 && timestamp - task.lastTimestamp > 1) {
                long long speedBS = task.bytesWritten / (timestamp - task.lastTimestamp);
//                NSLog([NSString stringWithFormat:@"speedBS : %ld, bytesWritten : %ld, time : %f", speedBS, task.bytesWritten, timestamp - task.lastTimestamp]);
                speed = [[NSByteCountFormatter stringFromByteCount:speedBS countStyle:NSByteCountFormatterCountStyleFile] stringByAppendingString:@"/S"];
                task.lastTimestamp = timestamp;
                task.bytesWritten = 0;
                task.block(task.progress, speed, DMStatusDownloading);
            }
        }
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
//    NSLog(@"URLSession downloadTask didFinishDownloadingToURL : %@", location);
    Task *task = [self getTaskWithSessionTask:downloadTask];
    if (task != nil && downloadTask.error == nil) {
        if (task.isM3U8) {
            [self removeSessionTask:downloadTask fromTask:task];
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
                if (![task.m3u8State.mapURL isEqualToString:requestURL]) {
                    unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] fileSize];
                    if (fileSize < 2000) {
                        for (TaskSessionState *sessionState in task.sessionStates) {
                            @synchronized (self.sessionDict) {
                                [self.sessionDict removeObjectForKey:sessionState.sessionTask];
                            }
                            [sessionState.sessionTask cancel];
                        }
                        [self taskFailed:task];
                        return;
                    }
                }
                NSMutableArray<NSString *> *tsURLs = task.m3u8State.tsURLs;
                @synchronized (tsURLs) {
                    for (int i = 0; i < tsURLs.count; i++) {
                        NSString *tsURL = tsURLs[i];
                        if ([tsURL hasPrefix:@"http"] && [tsURL isEqualToString:requestURL]) {
                            task.m3u8State.currCount++;
                            tsURLs[i] = filePath.lastPathComponent;
                            break;
                        }
                    }
                }
            }
            [self resumeM3U8Task:task];
        } else if (task.isNormal) {
            [self removeSessionTask:downloadTask fromTask:task];
            if ([task.normalState.videoUrl isEqualToString:downloadTask.originalRequest.URL.absoluteString]) {
                NSString *taskPath = [self.dataPath stringByAppendingPathComponent:task.taskId];
                NSString *filePath = [taskPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", task.taskId, task.normalState.videoType]];
                [NSFileManager.defaultManager moveItemAtURL:location toURL:[NSURL fileURLWithPath:filePath] error:nil];
                unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] fileSize];
                if (fileSize < 2000) {
                    for (TaskSessionState *sessionState in task.sessionStates) {
                        @synchronized (self.sessionDict) {
                            [self.sessionDict removeObjectForKey:sessionState.sessionTask];
                        }
                        [sessionState.sessionTask cancel];
                    }
                    [self taskFailed:task];
                    return;
                }
                task.normalState.status = 1;
                [self resumNormalTask:task];
            } else {
                NSString *taskPath = [self.dataPath stringByAppendingPathComponent:task.taskId];
                NSString *filePath = [taskPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", [downloadTask.originalRequest.URL.absoluteString md5], task.normalState.audioType]];
                [NSFileManager.defaultManager moveItemAtURL:location toURL:[NSURL fileURLWithPath:filePath] error:nil];
                unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] fileSize];
                if (fileSize < 2000) {
                    if (task.normalState.status == 1) {
                        if (task.block != nil) {
                            task.block(0, @"", DMStatusFailedTranscode);
                        }
                        [self.store update:task.taskId withDict:@{@"progress": @(0), @"status": @(DMStatusFailed)}];
                    }
                    return;
                }
                if (task.normalState.status == 1) {
                    task.normalState.status = 2;
                    [self resumNormalTask:task];
                }
            }
        } else {
            [NSFileManager.defaultManager moveItemAtURL:location toURL:[NSURL fileURLWithPath:task.filePath] error:nil];
            [NSFileManager.defaultManager removeItemAtPath:[self.dataPath stringByAppendingPathComponent:[[downloadTask.originalRequest.URL.absoluteString md5] stringByAppendingString:@"_data"]] error:nil];
            unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:task.filePath error:nil] fileSize];
            if (fileSize < 2000) {
                [self taskFailed:task];
                return;
            }
            [self taskComplete:task];
        }
    }
}

- (nullable Task *)getTaskWithSessionTask:(NSURLSessionTask *)sessionTask {
    return self.sessionDict[sessionTask];
}

- (void)removeSessionTask:(NSURLSessionTask *)sessionTask fromTask:(Task *)task {
    @synchronized (task.sessionStates) {
        for (int i = (int)task.sessionStates.count - 1; i >= 0; i--) {
            if (task.sessionStates[i].sessionTask == sessionTask) {
                [task.sessionStates removeObjectAtIndex:i];
                break;
            }
        }
    }
}

- (void)taskFailed:(Task *)task {
    if (task.block != nil) {
        task.block(0, @"", DMStatusFailed);
    }
    [self.store update:task.taskId withDict:@{@"progress": @(0), @"status": @(DMStatusFailed)}];
    @synchronized (self.taskDict) {
        [self.taskDict removeObjectForKey:task.taskId];
    }
}

- (void)taskComplete:(Task *)task {
    if (task.block != nil) {
        task.block(1, @"", DMStatusComplete);
    }
    [self.store update:task.taskId withDict:@{@"progress": @(1), @"status": @(DMStatusComplete)}];
    @synchronized (self.taskDict) {
        [self.taskDict removeObjectForKey:task.taskId];
    }
    NSString *taskPath = [self.dataPath stringByAppendingPathComponent:task.taskId];
    [[NSFileManager defaultManager] removeItemAtPath:taskPath error:nil];
}

@end
