//
//  ContentRecord.h
//  Stay
//
//  Created by ris on 2022/6/29.
//

#import <Foundation/Foundation.h>
#import <CloudKit/CloudKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContentRecord : NSObject

@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) CKAsset *asset;

@property (class, strong, readonly) NSString *type;

- (void)fillCKRecord:(CKRecord *)ckRecord;
+ (ContentRecord *)ofRecord:(CKRecord *)record;
@end

NS_ASSUME_NONNULL_END
