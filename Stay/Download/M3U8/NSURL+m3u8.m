//
//  NSURL+m3u8.m
//  M3U8Kit
//
//  Created by Frank on 16/06/2017.
//

#import "NSURL+m3u8.h"
#import "NSString+m3u8.h"
#import "M3U8PlaylistModel.h"

@implementation NSURL (m3u8)

- (NSURL *)m3u_realBaseURL {
    NSURL *baseURL = self.baseURL;
    if (!baseURL) {
        NSString *string = [self.absoluteString stringByReplacingOccurrencesOfString:self.lastPathComponent withString:@""];
        
        baseURL = [NSURL URLWithString:string];
    }
    
    return baseURL;
}

- (void)m3u_loadAsyncCompletion:(void (^)(M3U8PlaylistModel *model, NSError *error))completion {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
        NSError *err = nil;
        NSString *str = [[NSString alloc] initWithContentsOfURL:self headers:[self getHeaders]
                                                       encoding:NSUTF8StringEncoding error:&err];
        
        if (err) {
            completion(nil, err);
            return;
        }
        
        M3U8PlaylistModel *listModel = [[M3U8PlaylistModel alloc] initWithString:str
                                                                     originalURL:self baseURL:self.m3u_realBaseURL error:&err];
        if (err) {
            completion(nil, err);
            return;
        }
        
        completion(listModel, nil);
    });
}

- (NSDictionary *)getHeaders {
    NSString *host = self.host;
    if ([host containsString:@"akamai-cdn-content.com"]) {
        return @{
                 @"User-Agent": @"Mozilla/5.0 (iPhone; CPU iPhone OS 15_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.5 Mobile/15E148 Safari/604.1",
        };
    }
    return nil;
}

- (NSURLRequest *)getRequest {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self];
    NSDictionary *headers = [self getHeaders];
    for (NSString *key in headers.allKeys) {
        [request addValue:headers[key] forHTTPHeaderField:key];
    }
    return request;
}

@end
