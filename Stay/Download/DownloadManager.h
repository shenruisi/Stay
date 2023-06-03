//
//  DownloadManager.h
//  Stay
//
//  Created by Jin on 2022/11/23.
//

#import <Foundation/Foundation.h>

extern NSNotificationName const _Nonnull DMTaskDidStartNotification;
extern NSNotificationName const _Nonnull DMTaskSpeedNotification;
extern NSNotificationName const _Nonnull DMTaskDidFinishNotification;

typedef enum {
    DMStatusNone = -1,
    DMStatusPending,
    DMStatusDownloading,
    DMStatusPaused,
    DMStatusComplete,
    DMStatusFailed,
    DMStatusTranscoding,
    DMStatusFailedNoSpace,
    DMStatusFailedTranscode,
} DMStatus;

NS_ASSUME_NONNULL_BEGIN

@interface Request : NSObject

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *fileDir;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *fileType;
@property (nonatomic ,strong) NSString *key;
@property (nonatomic ,strong) NSString *m3u8Content;
@property (nonatomic ,strong) NSString *audioUrl;
@end

@interface Task : NSObject

@property (nonatomic, strong) NSString *taskId;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, assign) float progress;
@property (nonatomic, assign) DMStatus status;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic ,strong) void (^block)(float progress, NSString *speed, DMStatus status);
@end

@interface DownloadManager : NSObject

+ (instancetype)shared;
- (Task *)enqueue:(Request *)request;
- (void)remove:(NSString *)taskId;
- (void)pause:(NSString *)taskId;
- (Task *)queryByTaskId:(NSString *)taskId;

- (void)setM3U8Concurrency:(int)concurrency;
@end

NS_ASSUME_NONNULL_END
