//
//  UserDefaults.h
//  Stay
//
//  Created by ris on 2022/7/21.
//

#import <Foundation/Foundation.h>
#import "FCDisk.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserDefaults : FCDisk<NSSecureCoding>

@property (nonatomic, assign) BOOL safariExtensionEnabled;
@property (nonatomic, strong) NSString *lastFolderUUID;
@end

NS_ASSUME_NONNULL_END
