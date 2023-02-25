//
//  FCShared.m
//  Stay
//
//  Created by ris on 2022/6/20.
//

#import "FCShared.h"

#ifdef FC_MAC
#import "Plugin.h"
#endif

@implementation FCShared

#ifdef FC_MAC
static Plugin *_plugin = nil;
+ (Plugin *)plugin{
    static dispatch_once_t onceTokenPlugin;
    dispatch_once(&onceTokenPlugin, ^{
        if (nil == _plugin){
            _plugin = [[Plugin alloc] init];
        }
    });
    return _plugin;
}
#endif

#if FC_IOS || FC_MAC
static iCloudService *_iCloudService = nil;
+ (iCloudService *)iCloudService{
    static dispatch_once_t onceToken_iCloudService;
    dispatch_once(&onceToken_iCloudService, ^{
        if (nil == _iCloudService){
            _iCloudService = [[iCloudService alloc] init];
        }
    });
    return _iCloudService;
}

static ToastCenter *_toastCenter = nil;
+ (ToastCenter *)toastCenter{
    static dispatch_once_t onceTokenToastCenter;
    dispatch_once(&onceTokenToastCenter, ^{
        if (nil == _toastCenter){
            _toastCenter = [[ToastCenter alloc] init];
        }
    });
    return _toastCenter;
}
#endif

static FCTabManager *_tabManager = nil;
+ (FCTabManager *)tabManager{
    static dispatch_once_t onceTokenTabManager;
    dispatch_once(&onceTokenTabManager, ^{
        if (nil == _tabManager){
            _tabManager = [[FCTabManager alloc] init];
        }
    });
    return _tabManager;
}

@end
