//
//  TimeHelper.m
//  Stay
//
//  Created by ris on 2022/7/26.
//

#import "TimeHelper.h"

@implementation TimeHelper
static NSDateFormatter *dateFormatter= nil;
+ (NSString *)current{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!dateFormatter){
            dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        }
    });
    
    return [dateFormatter stringFromDate:[NSDate date]];
}


@end
