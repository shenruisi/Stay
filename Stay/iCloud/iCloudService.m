//
//  iCloudService.m
//  Stay
//
//  Created by ris on 2022/6/28.
//

#import "iCloudService.h"
#import <CloudKit/CloudKit.h>

#import "StatusRecord.h"
#import "UserscriptRecord.h"
#import "ContentRecord.h"

@interface iCloudService()

@property (nonatomic, strong) CKContainer *container;
@property (nonatomic, strong) CKDatabase *database;
@property (nonatomic, strong) NSMutableDictionary<NSString *, CKRecordZone *> *zoneDic;


@end


@implementation iCloudService

- (BOOL)logged{
    __block BOOL status;
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    [self.container accountStatusWithCompletionHandler:^(CKAccountStatus accountStatus, NSError * _Nullable error) {
        status = accountStatus == CKAccountStatusAvailable;
        dispatch_semaphore_signal(sem);
    }];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    return status;
}

- (NSString *)serviceIdentifier{
    __block NSString *identifier;
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    [self.container fetchUserRecordIDWithCompletionHandler:^(CKRecordID * _Nullable recordID, NSError * _Nullable error) {
        if (error == nil){
            identifier = [recordID.recordName copy];
        }
        dispatch_semaphore_signal(sem);
    }];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    return identifier;
}

- (BOOL)firstInit:(NSError **)outError{
    __block BOOL ret = NO;
    CKRecordZone *zone = [self _getZone:@"Userscripts" recordTypes:@[StatusRecord.type]];
    if (nil == zone){
        *outError = [[NSError alloc] init];
        return ret;
    }
    
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:StatusRecord.type predicate:predicate];
    [self.database performQuery:query inZoneWithID:zone.zoneID completionHandler:^(NSArray<CKRecord *> * _Nullable results, NSError * _Nullable error) {
        if (error){
//            *outError = error;
        }
        else{
            ret = results.count > 0;
        }
        dispatch_semaphore_signal(sem);
    }];
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    return ret;
}

- (CKRecordZone *)_getZone:(NSString *)zoneName recordTypes:(NSArray<CKRecordType> *)recordTypes{
    __block CKRecordZone *zone = self.zoneDic[zoneName];
    if (zone) return zone;
    
    zone = [[CKRecordZone alloc] initWithZoneName:zoneName];
    //Save zone first
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    [self.database saveRecordZone:zone completionHandler:^(CKRecordZone * _Nullable zone, NSError * _Nullable error) {
        if (nil == error){
            //Create zone record subscription
            NSMutableArray *subs = [[NSMutableArray alloc] init];
            for (CKRecordType recordType in recordTypes){
                CKQuerySubscription *subscription = [self _subOfType:recordType zoneName:zoneName];
                [subs addObject:subscription];
            }
            
            CKModifySubscriptionsOperation *operation =
                   [[CKModifySubscriptionsOperation alloc]
                    initWithSubscriptionsToSave:subs
                    subscriptionIDsToDelete:NULL];
            
            operation.modifySubscriptionsCompletionBlock =
                    ^(NSArray *subscriptions, NSArray *deleted, NSError *error) {
                    if (error) {
                        // Handle the error.
                        NSLog(@"subscriptions error");
                    } else {
                        self.zoneDic[zoneName] = zone;
                    }
                    dispatch_semaphore_signal(sem);
                };
                    
            // Set an appropriate QoS and add the operation to the private
            // database's operation queue to execute it.
            operation.qualityOfService = NSQualityOfServiceUtility;
            [self.database addOperation:operation];
        }
        else{
            NSLog(@"_getZone error %@",error);
            dispatch_semaphore_signal(sem);
        }
    }];
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    return zone;
}

- (void)_getZoneOnAsync:(void(^)(CKRecordZone *zone, NSError *error))action zoneName:(NSString *)zoneName recordTypes:(NSArray<CKRecordType> *)recordTypes{
    
    CKRecordZone *zone = self.zoneDic[zoneName];
    if (zone){
        action(zone,nil);
        return;
    }
    
    zone = [[CKRecordZone alloc] initWithZoneName:zoneName];
    //Save zone first
    [self.database saveRecordZone:zone completionHandler:^(CKRecordZone * _Nullable zone, NSError * _Nullable error) {
        if (nil == error){
            //Create zone record subscription
            NSMutableArray *subs = [[NSMutableArray alloc] init];
            for (CKRecordType recordType in recordTypes){
                CKQuerySubscription *subscription = [self _subOfType:recordType zoneName:zoneName];
                [subs addObject:subscription];
            }
        
            CKModifySubscriptionsOperation *operation =
                   [[CKModifySubscriptionsOperation alloc]
                    initWithSubscriptionsToSave:subs
                    subscriptionIDsToDelete:NULL];
            
            operation.modifySubscriptionsCompletionBlock =
                    ^(NSArray *subscriptions, NSArray *deleted, NSError *error) {
                    if (error) {
                        // Handle the error.
                        NSLog(@"subscriptions error");
                    } else {
                        self.zoneDic[zoneName] = zone;
                        action(zone,nil);
                    }
                };
                    
            // Set an appropriate QoS and add the operation to the private
            // database's operation queue to execute it.
            operation.qualityOfService = NSQualityOfServiceUtility;
            [self.database addOperation:operation];
        }
        else{
            action(zone,error);
        }
    }];
}

- (void)freshZone:(NSString *)zoneName recordTypes:(NSArray<CKRecordType> *)recordTypes{
    [self clearZone:zoneName recordTypes:recordTypes];
    [self _getZoneOnAsync:^(CKRecordZone *zone,NSError *error) {
        
    } zoneName:zoneName recordTypes:recordTypes];
}

- (void)clearZone:(NSString *)zoneName recordTypes:(NSArray<CKRecordType> *)recordTypes{
    if ([zoneName isEqualToString:@"Tabs"]) return;
    
    for (CKRecordType recordType in recordTypes){
        [self.database deleteSubscriptionWithID:[NSString stringWithFormat:@"%@-%@-changes",zoneName,recordType] completionHandler:^(CKSubscriptionID  _Nullable subscriptionID, NSError * _Nullable error) {
            
        }];
    }
    
    @synchronized (self.zoneDic) {
        [self.zoneDic removeObjectForKey:zoneName];
    }
}


- (CKQuerySubscription *)_subOfType:(CKRecordType)recordType zoneName:(NSString *)zoneName{
    CKQuerySubscription *sub;
    sub = [[CKQuerySubscription alloc] initWithRecordType:recordType
                                                predicate:[NSPredicate predicateWithValue:YES]
                                           subscriptionID:[NSString stringWithFormat:@"%@.%@.changes",zoneName,recordType]
                                                  options:CKQuerySubscriptionOptionsFiresOnRecordCreation | CKQuerySubscriptionOptionsFiresOnRecordUpdate | CKQuerySubscriptionOptionsFiresOnRecordDeletion];
   
    sub.notificationInfo = [CKNotificationInfo new];
    sub.notificationInfo.alertBody = nil;
    sub.notificationInfo.shouldSendContentAvailable = YES;
    return sub;
}


- (CKContainer *)container{
    if (nil == _container){
        _container = [CKContainer containerWithIdentifier:@"iCloud.app.stay.icloud.library"];
    }
    
    return _container;
}

- (CKDatabase *)database{
    if (nil == _database){
        _database = self.container.privateCloudDatabase;
    }
    
    return _database;
}

- (NSMutableDictionary<NSString *,CKRecordZone *> *)zoneDic{
    if (nil == _zoneDic){
        _zoneDic = [[NSMutableDictionary alloc] init];
    }
    
    return _zoneDic;
}


@end
