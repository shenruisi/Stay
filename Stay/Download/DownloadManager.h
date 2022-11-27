//
//  DownloadManager.h
//  Stay
//
//  Created by Jin on 2022/11/23.
//

#import <Foundation/Foundation.h>

typedef enum {
    DMStatusPending,
    DMStatusDownloading,
    DMStatusPaused,
    DMStatusComplete,
    DMStatusFailed,
} DMStatus;

NS_ASSUME_NONNULL_BEGIN

@interface Request : NSObject

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *fileDir;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *fileType;
@property (nonatomic ,strong) NSString *key;
@end

@interface Task : NSObject

@property (nonatomic, strong) NSString *taskId;
@property (nonatomic, assign) float progress;
@property (nonatomic, assign) DMStatus status;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic ,strong) void (^block)(float progress, DMStatus status);
@end

@interface Query : NSObject

@property (nonatomic, strong) NSString *taskId;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, assign) DMStatus status;
@end

@interface DownloadManager : NSObject

+ (instancetype)shared;
- (Task *)enqueue:(Request *)request;
- (NSArray *)query:(Query *)condition;
- (void)remove:(NSString *)taskId;
- (void)removeAll:(NSString *)key;
- (void)pause:(NSString *)taskId;
@end

NS_ASSUME_NONNULL_END
