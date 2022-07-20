//
//  StatusRecord.h
//  Stay
//
//  Created by ris on 2022/6/29.
//

#import <Foundation/Foundation.h>
#import <CloudKit/CloudKit.h>
#import "BaseRecord.h"

NS_ASSUME_NONNULL_BEGIN

@interface StatusRecord : BaseRecord

@property (nonatomic, assign) double firstInitTimestamp;

@property (class, strong, readonly) NSString *type;
- (void)fillCKRecord:(CKRecord *)ckRecord;
+ (StatusRecord *)ofRecord:(CKRecord *)record;
@end

NS_ASSUME_NONNULL_END
