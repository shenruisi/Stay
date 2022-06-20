//
//  FCShared.m
//  Stay
//
//  Created by ris on 2022/6/20.
//

#import "FCShared.h"

#ifdef Mac
#import "Plugin.h"
#endif

@implementation FCShared

#ifdef Mac
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

@end
