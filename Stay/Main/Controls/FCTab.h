//
//  FCTab.h
//  FastClip-iOS
//
//  Created by ris on 2022/1/18.
//

#import <UIKit/UIKit.h>
#import "FCDisk.h"
#import "FCTabConfig.h"
#import "SharedStorageManager.h"

static inline NSString * _Nonnull FCTabDirectory(void){
    return [FCSharedDirectory() stringByAppendingPathComponent:@".stay/data/Tabs"];
}

NS_ASSUME_NONNULL_BEGIN
@interface FCTab : FCDisk

// Treat the uuid as the folder name.
- (instancetype)initWithUUID:(NSString *)uuid;

@property (readonly) FCTabConfig *config;
@property (readonly) NSString *uuid;
@end

NS_ASSUME_NONNULL_END
