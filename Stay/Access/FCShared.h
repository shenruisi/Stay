//
//  FCShared.h
//  Stay
//
//  Created by ris on 2022/6/20.
//

#import <Foundation/Foundation.h>
#if iOS || Mac
#import "iCloudService.h"
#import "ToastCenter.h"
#endif
#import "FCTabManager.h"
NS_ASSUME_NONNULL_BEGIN
#ifdef Mac
@class Plugin;
#endif


@interface FCShared : NSObject

#ifdef Mac
@property (class, readonly, strong) Plugin *plugin;
#endif
#if iOS || Mac
@property (class, readonly, strong) iCloudService *iCloudService;
@property (class, readonly, strong) ToastCenter *toastCenter;
#endif
@property (class, readonly, strong) FCTabManager *tabManager;

@end

NS_ASSUME_NONNULL_END
