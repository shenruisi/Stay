//
//  FCCarbonCapability.h
//  FastClip-iOS
//
//  Created by ris on 2022/3/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FCCarbonCapability <NSObject>
- (NSDictionary *)activeScreenInfo;
- (void)enableExtension;
@end

NS_ASSUME_NONNULL_END
