//
//  SharedStorageManager.m
//  Stay
//
//  Created by ris on 2022/5/31.
//

#import "SharedStorageManager.h"

@implementation SharedStorageManager

static SharedStorageManager *_instance = nil;
+ (SharedStorageManager *)shared{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (nil == _instance){
            _instance = [[SharedStorageManager alloc] init];
        }
    });
    return _instance;
}

- (UserscriptInfo *)getInfoOfUUID:(NSString *)uuid{
    UserscriptInfo *userscriptInfo = [[UserscriptInfo alloc] initWithPath:[FCDataDirectory()
                                                                           stringByAppendingPathComponent:uuid]
                                                              isDirectory:NO];
    return userscriptInfo;
}

- (UserscriptHeaders *)userscriptHeaders{
    if (nil == _userscriptHeaders){
        _userscriptHeaders = [[UserscriptHeaders alloc] initWithPath:[FCDataDirectory()
                                                                      stringByAppendingPathComponent:@"userscriptHeaders"]
                                                         isDirectory:NO];
    }
    
    return _userscriptHeaders;
}

- (ActivateChanged *)activateChanged{
    if (nil == _activateChanged){
        _activateChanged = [[ActivateChanged alloc] initWithPath:[FCDataDirectory()
                                                                    stringByAppendingPathComponent:@"activateChanged"]
                                                       isDirectory:NO];
    }
    
    return _activateChanged;
}

@end
