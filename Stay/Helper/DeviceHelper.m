//
//  DeviceHelper.m
//  Stay
//
//  Created by ris on 2022/10/18.
//

#import "DeviceHelper.h"
#import <UIKit/UIKit.h>

@implementation DeviceHelper

+ (FCDeviceType)type{
#ifdef Mac
    return FCDeviceTypeMac;
#else
    return  [[[UIDevice currentDevice].model lowercaseString] isEqualToString:@"iphone"] ? FCDeviceTypeIPhone : FCDeviceTypeIPad;
#endif
       
}

@end
