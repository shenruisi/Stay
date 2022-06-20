//
//  FCShared.h
//  Stay
//
//  Created by ris on 2022/6/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
#ifdef Mac
@class Plugin;
#endif
@interface FCShared : NSObject

#ifdef Mac
@property (class, readonly, strong) Plugin *plugin;
#endif
@end

NS_ASSUME_NONNULL_END
