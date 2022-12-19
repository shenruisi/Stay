//
//  DisabledWebsites.m
//  Stay
//
//  Created by ris on 2022/12/19.
//

#import "DisabledWebsites.h"

@interface DisabledWebsites(){
    dispatch_queue_t _disabledWebsitesQueue;
}

@end

@implementation DisabledWebsites

- (instancetype)initWithPath:(NSString *)path isDirectory:(BOOL)isDirectory{
    if (self = [super initWithPath:path isDirectory:isDirectory]){
        _disabledWebsitesQueue = dispatch_queue_create([[self queueName:@"disabledWebsitesQueue"] UTF8String],
                                              DISPATCH_QUEUE_SERIAL);
    }
    
    return  self;
}

- (void)unarchiveData:(NSData *)data{
    if (data.length == 0){
        self.contentDic = [[NSMutableDictionary alloc] init];
    }
    else{
        self.contentDic = [[NSMutableDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]];
    }
    
}

- (void)initOnEmpty{
    self.contentDic = [[NSMutableDictionary alloc] init];
}

- (NSData *)archiveData{
    return [NSJSONSerialization dataWithJSONObject:self.contentDic options:0 error:nil];
}

- (dispatch_queue_t _Nonnull)dispatchQueue {
    return  _disabledWebsitesQueue;
}
@end
