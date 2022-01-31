//
//  SYNetworkUtils.h
//  Stay
//
//  Created by zly on 2022/1/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SYNetworkUtils : NSObject

+ (instancetype)shareInstance;

@property (nonatomic, copy) NSString *requestURL;


typedef void(^SYResponseSuccessBlock)(NSString *responseObject);

typedef void(^SYResponseFailBlock)(NSError *error);

- (void)requestGET:(NSString *)relativePath params:(NSDictionary *)params successBlock:(SYResponseSuccessBlock)successBlock failBlock:(SYResponseFailBlock)failBlock;

- (void)requestPOST:(NSString *)relativePath params:(NSDictionary *)params successBlock:(SYResponseSuccessBlock)successBlock failBlock:(SYResponseFailBlock)failBlock;

@end

NS_ASSUME_NONNULL_END
