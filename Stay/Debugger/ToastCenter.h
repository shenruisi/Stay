//
//  ToastCenter.h
//  FastClip-iOS
//
//  Created by ris on 2022/3/4.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const _Nonnull FCToastShouldShowNotification;

@interface ToastCenter : NSObject

- (void)show:(nullable UIImage *)icon mainTitle:(NSString *)mainTitle secondaryTitle:(NSString *)secondaryTitle;

@end

NS_ASSUME_NONNULL_END
