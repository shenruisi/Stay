//
//  ContentRecord.m
//  Stay
//
//  Created by ris on 2022/6/29.
//

#import "ContentRecord.h"

@implementation ContentRecord

- (void)fillCKRecord:(CKRecord *)ckRecord{
    [ckRecord setObject:self.uuid forKey:@"uuid"];
    [ckRecord setObject:self.asset forKey:@"asset"];
}

+ (ContentRecord *)ofRecord:(CKRecord *)record{
    ContentRecord *contentRecord = [[ContentRecord alloc] init];
    contentRecord.uuid = [record objectForKey:@"uuid"];
    contentRecord.asset = [record objectForKey:@"asset"];
    return contentRecord;
}

+ (NSString *)type{
    return @"Content";
}

@end
