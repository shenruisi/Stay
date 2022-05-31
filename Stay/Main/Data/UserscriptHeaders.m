//
//  UserscriptHeaders.m
//  Stay
//
//  Created by ris on 2022/5/31.
//

#import "UserscriptHeaders.h"

@interface UserscriptHeaders(){
    dispatch_queue_t _userscriptQueue;
}
@end

@implementation UserscriptHeaders

- (instancetype)initWithPath:(NSString *)path isDirectory:(BOOL)isDirectory{
    if (self = [super initWithPath:path isDirectory:isDirectory]){
        _userscriptQueue = dispatch_queue_create([[self queueName:@"userscriptHeaders"] UTF8String],
                                              DISPATCH_QUEUE_SERIAL);
    }
    
    return  self;
}

- (void)unarchiveData:(NSData *)data{
    self.content = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

- (NSData *)archiveData{
    return [NSJSONSerialization dataWithJSONObject:self.content options:0 error:nil];
}

- (dispatch_queue_t)dispatchQueue{
    return _userscriptQueue;
}

@end
