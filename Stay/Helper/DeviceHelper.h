//
//  DeviceHelper.h
//  Stay
//
//  Created by ris on 2022/10/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum{
    FCDeviceTypeMac,
    FCDeviceTypeIPhone,
    FCDeviceTypeIPad
}FCDeviceType;

@interface DeviceHelper : NSObject
@property (class, nonatomic, readonly) FCDeviceType type;
@property (class, readonly) NSString *uuid;

+ (void)saveUUID:(NSString *)uuid;
+ (void)reset;
@end

NS_ASSUME_NONNULL_END
