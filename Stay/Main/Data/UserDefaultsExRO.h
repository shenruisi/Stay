//
//  UserDefaultsExRO.h
//  Stay
//
//  Created by ris on 2022/7/28.
//

#import <Foundation/Foundation.h>
#import "FCDisk.h"

NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const _Nonnull UserDefaultsExROAvailablePointsDidChangeNotification;
extern NSNotificationName const _Nonnull UserDefaultsExROAvailableGiftPointsDidChangeNotification;

@interface UserDefaultsExRO : FCDisk<NSSecureCoding>

@property (nonatomic, strong) NSString *deviceID;
@property (nonatomic, assign) BOOL pro;
@property (nonatomic, assign) CGFloat availablePoints;
@property (nonatomic, assign) CGFloat availableGiftPoints;
@property (nonatomic, assign) CGFloat downloadConsumePoints;
@property (nonatomic, assign) CGFloat tagConsumePoints;
@end

NS_ASSUME_NONNULL_END
