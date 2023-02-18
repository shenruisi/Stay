//
//  FCShared.h
//  Stay
//
//  Created by ris on 2022/6/20.
//

#import <Foundation/Foundation.h>
#if FC_IOS || FC_MAC
#import "iCloudService.h"
#import "ToastCenter.h"
#endif
#import "FCTabManager.h"
NS_ASSUME_NONNULL_BEGIN
#ifdef FC_MAC
@class Plugin;
#endif


@interface FCShared : NSObject

#ifdef FC_MAC
@property (class, readonly, strong) Plugin *plugin;
#endif
#if FC_IOS || FC_MAC
@property (class, readonly, strong) iCloudService *iCloudService;
@property (class, readonly, strong) ToastCenter *toastCenter;
#endif
@property (class, readonly, strong) FCTabManager *tabManager;

@end

NS_ASSUME_NONNULL_END
