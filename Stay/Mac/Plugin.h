//
//  Plugin.h
//  Stay-Mac
//
//  Created by ris on 2022/6/20.
//

#import <Foundation/Foundation.h>
#import "FCAppKitCapability.h"
#import "FCCarbonCapability.h"

NS_ASSUME_NONNULL_BEGIN

@interface Plugin : NSObject

- (void)load;
@property (nonatomic, strong) id<FCAppKitCapability> appKit;
@property (nonatomic, strong) id<FCCarbonCapability> carbon;
@end

NS_ASSUME_NONNULL_END
