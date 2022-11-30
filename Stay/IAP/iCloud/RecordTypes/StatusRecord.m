//
//  StatusRecord.m
//  Stay
//
//  Created by ris on 2022/6/29.
//

#import "StatusRecord.h"

@implementation StatusRecord


+ (StatusRecord *)ofRecord:(CKRecord *)record{
    StatusRecord *statusRecord = [[StatusRecord alloc] init];
    statusRecord.firstInitTimestamp = [[record objectForKey:@"firstInitTimestamp"] doubleValue];
    
    return statusRecord;
}

- (void)fillCKRecord:(CKRecord *)ckRecord{
    [ckRecord setObject:@(self.firstInitTimestamp) forKey:@"firstInitTimestamp"];
}

+ (NSString *)type{
    return @"Status";
}


@end
