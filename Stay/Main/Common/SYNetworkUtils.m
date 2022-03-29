//
//  SYNetworkUtils.m
//  Stay
//
//  Created by zly on 2022/1/21.
//

#import "SYNetworkUtils.h"

@implementation SYNetworkUtils


+ (instancetype)shareInstance
{
    static SYNetworkUtils *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SYNetworkUtils alloc] init];
    });
    return _sharedInstance;
}


- (void)requestHTTPMethod:(NSString *)httpMenthod relativePath:(NSString *)relativePath params:(NSDictionary *)params successBlock:(SYResponseSuccessBlock)successBlock failBlock:(SYResponseFailBlock)failBlock
{
    
    NSMutableString *paramsString = [[NSMutableString alloc] initWithCapacity:0];
    for (int i=0;i<[params allKeys].count;i++) {
        NSString *key = [[params allKeys] objectAtIndex:i];
        [paramsString appendString:[NSString stringWithFormat:@"%@=%@",key,[params objectForKey:key]]];
        if (i < [params allKeys].count-1) {
            [paramsString appendString:@"&"];
        }
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@", relativePath];
    urlString =  [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = httpMenthod;
    request.HTTPBody = [paramsString dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            if (successBlock) {
                
                NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                successBlock(result);
            }
        } else {
            if (failBlock) {
                failBlock(error);
            }
        }
    }];
    [dataTask resume];
}
- (void)requestGET:(NSString *)relativePath params:(NSDictionary *)params successBlock:(SYResponseSuccessBlock)successBlock failBlock:(SYResponseFailBlock)failBlock
{
    [self requestHTTPMethod:@"GET" relativePath:relativePath params:params successBlock:^(NSString * _Nonnull responseObject) {
        if (successBlock) {
            return successBlock(responseObject);
        }
    } failBlock:^(NSError * _Nonnull error) {
        if (failBlock) {
            return failBlock(error);
        }
    }];
}

- (void)requestPOST:(NSString *)relativePath params:(NSDictionary *)params successBlock:(SYResponseSuccessBlock)successBlock failBlock:(SYResponseFailBlock)failBlock
{
    [self requestHTTPMethod:@"POST" relativePath:relativePath params:params successBlock:^(NSString * _Nonnull responseObject) {
        if (successBlock) {
            return successBlock(responseObject);
        }
    } failBlock:^(NSError * _Nonnull error) {
        if (failBlock) {
            return failBlock(error);
        }
    }];
}


@end
