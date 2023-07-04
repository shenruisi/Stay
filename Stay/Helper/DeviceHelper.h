//
//  DeviceHelper.h
//  Stay
//
//  Created by ris on 2022/10/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const _Nonnull DeviceHelperConsumePointsDidChangeNotification;

typedef enum{
    FCDeviceTypeMac,
    FCDeviceTypeIPhone,
    FCDeviceTypeIPad
}FCDeviceType;

@interface DeviceHelper : NSObject
@property (class, nonatomic, readonly) FCDeviceType type;
@property (class, readonly) NSString *uuid;
@property (class, readonly) NSString *country;

+ (void)saveUUID:(NSString *)uuid;
+ (void)reset;
+ (void)consumePoints:(CGFloat)pointValue;
+ (void)rollbackPoints:(CGFloat)pointValue;
+ (CGFloat)totalConsumePoints;
@end

NS_ASSUME_NONNULL_END
