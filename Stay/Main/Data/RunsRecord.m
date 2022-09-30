//
//  RunsRecord.m
//  Stay
//
//  Created by ris on 2022/9/30.
//

#import "RunsRecord.h"

@interface RunsRecord(){
    dispatch_queue_t _runsRecordQueue;
}

@end

@implementation RunsRecord

- (instancetype)initWithPath:(NSString *)path isDirectory:(BOOL)isDirectory{
    if (self = [super initWithPath:path isDirectory:isDirectory]){
        _runsRecordQueue = dispatch_queue_create([[self queueName:@"runsRecordQueue"] UTF8String],
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

- (NSData *)archiveData{
    return [NSJSONSerialization dataWithJSONObject:self.contentDic options:0 error:nil];
}

- (dispatch_queue_t _Nonnull)dispatchQueue {
    return  _runsRecordQueue;
}
@end
