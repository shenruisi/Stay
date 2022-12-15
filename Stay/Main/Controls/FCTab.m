//
//  FCTab.m
//  FastClip-iOS
//
//  Created by ris on 2022/1/18.
//

#import "FCTab.h"


@interface FCTab(){
    NSString *_uuid;
}

@property (nonatomic, strong) FCTabConfig *config;
@end

@implementation FCTab

- (instancetype)initWithUUID:(NSString *)uuid{
    NSString *path = [FCTabDirectory() stringByAppendingPathComponent:uuid];
    if (self = [super initWithPath:path isDirectory:YES]){
        _uuid = uuid;
        [self config];
    }
    
    return self;
}

- (void)flush{
    [self.config flush];
}

- (FCTabConfig *)config{
    if (nil == _config){
        _config = [[FCTabConfig alloc] initUnder:self
                                    relativePath:@"_Config"
                                     isDirectory:NO];
    }
    
    return _config;
}

@end
