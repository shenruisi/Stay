//
//  FCTabConfig.h
//  FastClip-iOS
//
//  Created by ris on 2022/1/18.
//

#import "FCDisk.h"

NS_ASSUME_NONNULL_BEGIN

@interface FCTabConfig : FCDisk <NSSecureCoding>

// The name of the tab.
@property (nonatomic, copy) NSString *name;
// The color of the icon.
@property (nonatomic, copy) NSString *hexColor;
// Position of the tab.
@property (nonatomic, assign) NSInteger position;
@property (nonatomic, assign) double operateTimestamp;
@property (nonatomic, assign) BOOL faceIDEnabled;

- (void)operateUpdate;
@end

NS_ASSUME_NONNULL_END
