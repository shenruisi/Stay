//
//  SYVersionUtils.m
//  Stay
//
//  Created by zly on 2022/1/21.
//

#import "SYVersionUtils.h"

@implementation SYVersionUtils

+ (NSInteger)compareVersion:(NSString *)newVersion toVersion:(NSString *)oldVersion
{
    NSArray *list1 = [newVersion componentsSeparatedByString:@"."];
    NSArray *list2 = [oldVersion componentsSeparatedByString:@"."];
    for (int i = 0; i < list1.count || i < list2.count; i++)
    {
        NSInteger a = 0, b = 0;
        if (i < list1.count) {
            a = [list1[i] integerValue];
        }
        if (i < list2.count) {
            b = [list2[i] integerValue];
        }
        if (a > b) {
            return 1;//newVersion大于oldVersion
        } else if (a < b) {
            return -1;//newVersion小于oldVersion
        }
    }
    return 0;//newVersion等于newVersion
}
@end
