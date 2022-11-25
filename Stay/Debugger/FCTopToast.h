//
//  FCTopToast.h
//  Stay
//
//  Created by ris on 2022/11/25.
//

#import "FCSlideController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FCTopToast : FCSlideController

- (instancetype)initWithPermanent:(BOOL)permanent;

- (void)showWithIcon:(nullable UIImage *)icon
           mainTitle:(nullable NSString *)mainTitle
      secondaryTitle:(nullable NSString *)secondaryTitle;
@end

NS_ASSUME_NONNULL_END
