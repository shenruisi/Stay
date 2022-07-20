//
//  ContentRecord.h
//  Stay
//
//  Created by ris on 2022/6/29.
//

#import <Foundation/Foundation.h>
#import <CloudKit/CloudKit.h>
#import "BaseRecord.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContentRecord : BaseRecord

@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *raw;
@property (nonatomic, assign) double createTimestamp;
@property (nonatomic, assign) double updateTimestamp;
@property (class, strong, readonly) NSString *type;

- (void)fillCKRecord:(CKRecord *)ckRecord;
+ (ContentRecord *)ofRecord:(CKRecord *)record;
@end

NS_ASSUME_NONNULL_END
