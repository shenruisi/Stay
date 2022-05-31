//
//  UserscriptInfo.m
//  Stay
//
//  Created by ris on 2022/5/31.
//

#import "UserscriptInfo.h"

@implementation UserscriptInfo

- (void)unarchiveData:(NSData *)data{
    self.content = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

- (NSData *)archiveData{
    return [NSJSONSerialization dataWithJSONObject:self.content options:0 error:nil];
}


- (dispatch_queue_t _Nonnull)dispatchQueue {
    return  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}

@end
