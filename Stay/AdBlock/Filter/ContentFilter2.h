//
//  ContentFilter.h
//  Stay
//
//  Created by ris on 2023/3/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    ContentFilterTypeBasic = 1,
    ContentFilterTypePrivacy = 2,
    ContentFilterTypeRegion = 3,
    ContentFilterTypeCustom = 4,
    ContentFilterTypeTag = 5
}ContentFilterType;

@interface ContentFilter : NSObject

@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *downloadUrl;
@property (nonatomic, strong) NSString *expires;
@property (nonatomic, strong) NSString *homepage;
@property (nonatomic, assign) NSInteger status;
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

@property (nonatomic, readonly) BOOL active;

- (NSString *)fetchRules;
- (NSString *)convertToJOSNRules;
- (void)reloadContentBlocker;
+ (NSString *)stringOfType:(ContentFilterType)type;

@end

NS_ASSUME_NONNULL_END
