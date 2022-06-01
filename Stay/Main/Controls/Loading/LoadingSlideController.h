//
//  LoadingSlideController.h
//  Stay
//
//  Created by ris on 2022/5/23.
//

#import "FCSlideController.h"

NS_ASSUME_NONNULL_BEGIN

@interface LoadingSlideController : FCSlideController

@property (nonatomic, strong) NSString *originMainText;
@property (nonatomic, strong) NSString *originSubText;
- (void)updateMainText:(NSString *)text;
- (void)updateSubText:(NSString *)text;
@end

NS_ASSUME_NONNULL_END
