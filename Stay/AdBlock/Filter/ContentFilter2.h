//
//  ContentFilter.h
//  Stay
//
//  Created by ris on 2023/3/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const _Nonnull ContentFilterDidUpdateNotification;

typedef enum {
    ContentFilterTypeBasic = 1,
    ContentFilterTypePrivacy = 2,
    ContentFilterTypeRegion = 3,
    ContentFilterTypeCustom = 4,
    ContentFilterTypeTag = 5
}ContentFilterType;

@interface ContentFilter : NSObject

@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *defaultTitle;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *defaultUrl;
@property (nonatomic, strong) NSString *downloadUrl;
@property (nonatomic, strong) NSString *expires;
@property (nonatomic, strong) NSString *homepage;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, assign) NSInteger enable;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *rulePath;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, assign) NSInteger sort;
@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, strong) NSDate *createTime;
@property (nonatomic, strong) NSDate *updateTime;
@property (nonatomic, strong) NSString *iCloudIdentifier;
@property (nonatomic, strong) NSArray<NSNumber *> *tags;
@property (nonatomic, assign) ContentFilterType type;
@property (nonatomic, strong) NSString *contentBlockerIdentifier;
@property (nonatomic, strong) NSString *redirect;

@property (nonatomic, readonly) BOOL active;

- (void)restoreRulesWithCompletion:(void(^)(NSError *error))completion;
- (void)reloadContentBlockerWithCompletion:(void(^)(NSError *error))completion;
- (NSString *)fetchRules:(NSError **)error;
- (void)checkUpdatingIfNeeded:(BOOL)focus completion:(nullable void(^)(NSError *error))completion;
+ (NSString *)stringOfType:(ContentFilterType)type;

@end

NS_ASSUME_NONNULL_END
