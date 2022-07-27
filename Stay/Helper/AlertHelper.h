//
//  AlertHelper.h
//  Stay
//
//  Created by ris on 2022/7/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlertHelper : NSObject
+ (void)simpleWithTitle:(NSString *)title message:(NSString *)message inCer:(UIViewController *)cer;
@end

NS_ASSUME_NONNULL_END
