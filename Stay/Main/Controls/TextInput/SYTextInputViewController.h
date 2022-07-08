//
//  SYTextInputViewController.h
//  Stay
//
//  Created by zly on 2022/7/6.
//

#import "FCSlideController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SYTextInputViewController : FCSlideController

@property(nonatomic, strong) NSString *notificationName;

- (void)updateNotificationName:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
