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
#import "UserScript.h"

NSNotificationName const _Nonnull iCloudServiceUserscriptSavedNotification = @"app.stay.notification.iCloudServiceUserscriptSavedNotification";

@interface iCloudService(){
    dispatch_queue_t _iCloudServiceQueue;
}

@property (nonatomic, strong) CKContainer *container;
@property (nonatomic, strong) CKDatabase *database;
@property (nonatomic, strong) NSMutableDictionary<NSString *, CKRecordZone *> *zoneDic;
@end


@implementation iCloudService

- (instancetype)init{
    if (self = [super init]){
        _iCloudServiceQueue = dispatch_queue_create([@"app.stay.queue.iCloudService" UTF8String],
                                              DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

- (dispatch_queue_t)queue{
    return _iCloudServiceQueue;
}

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

- (void)checkFirstInit:(void (^)(BOOL firstInit, NSError *error))completionHandler{
    NSNumber *n = [[NSUserDefaults standardUserDefaults] objectForKey:@"iCloudService.firstInit"];
    if (n && ![n boolValue]){
        completionHandler(NO,nil);
        return;
    }
    
    [self _getZoneOnAsync:^(CKRecordZone *zone, NSError *error) {
        if (error){
            completionHandler(YES,error);
        }
        else{
            NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
            CKQuery *query = [[CKQuery alloc] initWithRecordType:StatusRecord.type predicate:predicate];
            [self.database performQuery:query inZoneWithID:zone.zoneID completionHandler:^(NSArray<CKRecord *> * _Nullable results, NSError * _Nullable error) {
                if (error){
                    completionHandler(YES,error);
                }
                else{
                    if (results.count == 0){
                        completionHandler(YES,nil);
                    }
                    else{
                        StatusRecord *statusRecord = [StatusRecord ofRecord:results.firstObject];
                        [[NSUserDefaults standardUserDefaults] setObject:@(statusRecord.firstInitTimestamp == 0) forKey:@"iCloudService.firstInit"];
                        completionHandler(statusRecord.firstInitTimestamp == 0,nil);
                    }
                }
            }];
        }
    } zoneName:@"Userscripts" recordTypes:@[StatusRecord.type]];
}

- (BOOL)firstInit:(NSError * __strong *)outError{
    __block BOOL ret = NO;
    NSError *zoneError = nil;
    CKRecordZone *zone = [self _getZone:@"Userscripts" recordTypes:@[StatusRecord.type] error:&zoneError];
    if (nil != zoneError){
        *outError = zoneError;
        return ret;
    }
    
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:StatusRecord.type predicate:predicate];
    [self.database performQuery:query inZoneWithID:zone.zoneID completionHandler:^(NSArray<CKRecord *> * _Nullable results, NSError * _Nullable error) {
        if (error){
            *outError = error;
        }
        else{
            if (results.count == 0){
                ret = YES;
            }
            else{
                StatusRecord *statusRecord = [StatusRecord ofRecord:results.firstObject];
                ret = statusRecord.firstInitTimestamp == 0;
            }
        }
        dispatch_semaphore_signal(sem);
    }];

    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    return ret;
}

- (void)pushUserscripts:(NSArray<UserScript *> *)userscripts
      completionHandler:(void (^)(NSError *))completionHandler{
    dispatch_async(_iCloudServiceQueue, ^{
        for (UserScript *userscript in userscripts){
            [self addUserscript:userscript];
        }
        NSError *zoneError = nil;
        CKRecordZone *zone = [self _getZone:@"Userscripts" recordTypes:@[StatusRecord.type] error:&zoneError];
        if (nil == zoneError){
            NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
            CKQuery *query = [[CKQuery alloc] initWithRecordType:StatusRecord.type predicate:predicate];
            [self.database performQuery:query inZoneWithID:zone.zoneID completionHandler:^(NSArray<CKRecord *> * _Nullable results, NSError * _Nullable error) {
                if (error){
                    completionHandler(error);
                }
                else{
                    CKRecord *ckStatusRecord = results.count == 0 ? [[CKRecord alloc] initWithRecordType:StatusRecord.type zoneID:zone.zoneID] : results.firstObject;
                    StatusRecord *statusRecord = [[StatusRecord alloc] init];
                    statusRecord.firstInitTimestamp = [[NSDate date] timeIntervalSince1970];
                    [statusRecord fillCKRecord:ckStatusRecord];
                    [self.database saveRecord:ckStatusRecord completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
                        if (nil == error){
                            [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"iCloudService.firstInit"];
                        }
                        completionHandler(error);
                    }];
                }
            }];
        }
        completionHandler(zoneError);
    });
}

- (void)pullUserscriptWithCompletionHandler:(void (^)(NSArray<UserScript *> * userscripts, NSError * error))completionHandler{
    dispatch_async(_iCloudServiceQueue, ^{
        
    });
}

- (void)removeUserscript:(UserScript *)userscript{
    NSError *zoneError = nil;
    CKRecordZone *zone = [self _getZone:@"Userscripts" recordTypes:@[UserscriptRecord.type,ContentRecord.type] error:&zoneError];
    if (zoneError != nil) return;
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    NSPredicate *userscriptPredicate = [NSPredicate predicateWithFormat:@"uuid == %@", userscript.uuid];
    CKQuery *userscriptQuery = [[CKQuery alloc] initWithRecordType:UserscriptRecord.type predicate:userscriptPredicate];
    [self.database performQuery:userscriptQuery inZoneWithID:zone.zoneID completionHandler:^(NSArray<CKRecord *> * _Nullable results, NSError * _Nullable error) {
        if (error || results.count == 0){
            dispatch_semaphore_signal(sem);
        }
        else{
            [self.database deleteRecordWithID:results.firstObject.recordID completionHandler:^(CKRecordID * _Nullable recordID, NSError * _Nullable error) {
                if (error){
                    dispatch_semaphore_signal(sem);
                }
                else{
                    NSPredicate *contentPredicate = [NSPredicate predicateWithFormat:@"uuid == %@", userscript.uuid];
                    CKQuery *contentQuery = [[CKQuery alloc] initWithRecordType:ContentRecord.type predicate:contentPredicate];
                    [self.database performQuery:contentQuery inZoneWithID:zone.zoneID completionHandler:^(NSArray<CKRecord *> * _Nullable results, NSError * _Nullable error) {
                        if (error || results.count == 0){
                            dispatch_semaphore_signal(sem);
                        }
                        else{
                            [self.database deleteRecordWithID:results.firstObject.recordID completionHandler:^(CKRecordID * _Nullable recordID, NSError * _Nullable error) {
                                dispatch_semaphore_signal(sem);
                            }];
                        }
                    }];
                }
            }];
        }
    }];

    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
}

- (void)addUserscript:(UserScript *)userscript{
    NSError *zoneError = nil;
    CKRecordZone *zone = [self _getZone:@"Userscripts" recordTypes:@[UserscriptRecord.type,ContentRecord.type] error:&zoneError];
    if (zoneError != nil) return;
    
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    NSPredicate *userscriptPredicate = [NSPredicate predicateWithFormat:@"uuid == %@", userscript.uuid];
    CKQuery *userscriptQuery = [[CKQuery alloc] initWithRecordType:UserscriptRecord.type predicate:userscriptPredicate];
    [self.database performQuery:userscriptQuery inZoneWithID:zone.zoneID completionHandler:^(NSArray<CKRecord *> * _Nullable results, NSError * _Nullable error) {
        if (error){ //error jump this adding
            dispatch_semaphore_signal(sem);
        }
        else{
            CKRecord *ckUserscriptRecord = results.count == 0 ? [[CKRecord alloc] initWithRecordType:UserscriptRecord.type zoneID:zone.zoneID] : results.firstObject;
            UserscriptRecord *userscriptRecord = [[UserscriptRecord alloc] init];
            userscriptRecord.uuid = userscript.uuid;
            userscriptRecord.header = [[NSString alloc] initWithData:
                                       [NSJSONSerialization dataWithJSONObject:
                                        [userscript toDictionaryWithoutContent] options:0 error:nil]
                                                            encoding:NSUTF8StringEncoding];
            double now = [[NSDate date] timeIntervalSince1970];
            userscriptRecord.createTimestamp = now;
            userscriptRecord.updateTimestamp = now;
            [userscriptRecord fillCKRecord:ckUserscriptRecord];
            [self.database saveRecord:ckUserscriptRecord completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
                if (error){
                    dispatch_semaphore_signal(sem);
                }
                else{
                    NSPredicate *contentPredicate = [NSPredicate predicateWithFormat:@"uuid == %@", userscript.uuid];
                    CKQuery *contentQuery = [[CKQuery alloc] initWithRecordType:ContentRecord.type predicate:contentPredicate];
                    [self.database performQuery:contentQuery inZoneWithID:zone.zoneID completionHandler:^(NSArray<CKRecord *> * _Nullable results, NSError * _Nullable error) {
                        if (nil == error){
                            CKRecord *ckCotentRecord = results.count == 0 ? [[CKRecord alloc] initWithRecordType:ContentRecord.type zoneID:zone.zoneID] : results.firstObject;
                            ContentRecord *contentRecord = [[ContentRecord alloc] init];
                            contentRecord.uuid = userscript.uuid;
                            contentRecord.raw = [userscript.content copy];
                            [contentRecord fillCKRecord:ckCotentRecord];
                            [self.database saveRecord:ckCotentRecord completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
                                if (nil == error){
                                    [[NSNotificationCenter defaultCenter]
                                     postNotificationName:iCloudServiceUserscriptSavedNotification
                                     object:nil
                                     userInfo:@{@"uuid":userscript.uuid}];
                                }
                            }];
                        }
                        dispatch_semaphore_signal(sem);
                    }];
                    
                }
            }];
        }
    }];

    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
}

- (void)_initStatusRecordType{
    CKRecordZone *zone = [[CKRecordZone alloc] initWithZoneName:@"Userscripts"];
    [self.database saveRecordZone:zone completionHandler:^(CKRecordZone * _Nullable zone, NSError * _Nullable error) {
        if (nil == error){
            StatusRecord *statusRecord = [[StatusRecord alloc] init];
            statusRecord.firstInitTimestamp = 0;
            CKRecord *ckRecord = [[CKRecord alloc] initWithRecordType:StatusRecord.type zoneID:zone.zoneID];
            [statusRecord fillCKRecord:ckRecord];
            [self.database saveRecord:ckRecord completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
                NSLog(@"error %@",error);
            }];
        }
    }];
}


- (CKRecordZone *)_getZone:(NSString *)zoneName recordTypes:(NSArray<CKRecordType> *)recordTypes error:(NSError * __strong *)outError{
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
            
            if (subs.count > 0){
                CKModifySubscriptionsOperation *operation =
                       [[CKModifySubscriptionsOperation alloc]
                        initWithSubscriptionsToSave:subs
                        subscriptionIDsToDelete:NULL];
        
                operation.modifySubscriptionsCompletionBlock =
                        ^(NSArray *subscriptions, NSArray *deleted, NSError *error) {
                        if (error) {
                            // Handle the error.
                            *outError = error;
                            NSLog(@"subscriptions error");
                        } else {
                            self.zoneDic[zoneName] = zone;
                        }
                        dispatch_semaphore_signal(sem);
                    };

                operation.qualityOfService = NSQualityOfServiceUserInitiated;
                [self.database addOperation:operation];
            }
            else{
                self.zoneDic[zoneName] = zone;
                dispatch_semaphore_signal(sem);
            }
            
        }
        else{
            NSLog(@"_getZone error %@",error);
            *outError = error;
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
            
            if (subs.count > 0){
                operation.modifySubscriptionsCompletionBlock =
                        ^(NSArray *subscriptions, NSArray *deleted, NSError *error) {
                        if (error) {
                            // Handle the error.
                            action(zone,error);
                            NSLog(@"subscriptions error");
                        } else {
                            self.zoneDic[zoneName] = zone;
                            action(zone,nil);
                        }
                    };
                operation.qualityOfService = NSQualityOfServiceUserInitiated;
                [self.database addOperation:operation];
            }
            else{
                self.zoneDic[zoneName] = zone;
                action(zone,nil);
            }
            
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
    if ([zoneName isEqualToString:@"Userscripts"]) return;
    
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
