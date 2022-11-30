//
//  UserscriptRecord.h
//  Stay
//
//  Created by ris on 2022/6/29.
//

#import <Foundation/Foundation.h>
#import <CloudKit/CloudKit.h>
#import "BaseRecord.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserscriptRecord : BaseRecord

@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *header;
@property (nonatomic, assign) double createTimestamp;
@property (nonatomic, assign) double updateTimestamp;
@property (class, strong, readonly) NSString *type;


- (void)fillCKRecord:(CKRecord *)ckRecord;
+ (UserscriptRecord *)ofRecord:(CKRecord *)record;
@end

NS_ASSUME_NONNULL_END
