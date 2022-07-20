//
//  UIView+Rotate.h
//  Stay
//
//  Created by ris on 2022/7/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView(Rotate)

- (void)rotateWithDuration:(double)duration;
- (void)stopRotating;
@end

NS_ASSUME_NONNULL_END
