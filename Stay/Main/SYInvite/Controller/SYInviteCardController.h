//
//  SYInviteCardController.h
//  Stay
//
//  Created by zly on 2023/6/1.
//

#import "FCSlideController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SYInviteCardController : FCSlideController
@property (nonatomic, strong) NSArray *imageList;
@property (nonatomic, strong) NSString *dateStr;
@property (nonatomic, strong) NSString *color;
@property (nonatomic, strong) NSString *defaultImage;
@property (nonatomic, strong) NSString *defaultName;

@end

NS_ASSUME_NONNULL_END
