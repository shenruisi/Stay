//
//  UserscriptRecord.m
//  Stay
//
//  Created by ris on 2022/6/29.
//

#import "UserscriptRecord.h"

@implementation UserscriptRecord

+ (UserscriptRecord *)ofRecord:(CKRecord *)record{
    UserscriptRecord *userscriptRecord = [[UserscriptRecord alloc] init];
    userscriptRecord.uuid = [record objectForKey:@"uuid"];
    userscriptRecord.header = [record objectForKey:@"header"];
    userscriptRecord.createTimestamp = [[record objectForKey:@"createTimestamp"] doubleValue];
    userscriptRecord.updateTimestamp = [[record objectForKey:@"updateTimestamp"] doubleValue];
    return userscriptRecord;
}

- (void)fillCKRecord:(CKRecord *)ckRecord{
    [ckRecord setObject:self.uuid forKey:@"uuid"];
    [ckRecord setObject:self.header forKey:@"header"];
    [ckRecord setObject:@(self.createTimestamp) forKey:@"createTimestamp"];
    [ckRecord setObject:@(self.updateTimestamp) forKey:@"updateTimestamp"];
}

+ (NSString *)type{
    return @"Userscript";
}

@end
