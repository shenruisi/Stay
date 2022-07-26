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

NSNotificationName const _Nonnull iCloudServiceSyncStartNotification = @"app.stay.notification.iCloudServiceSyncStartNotification";
NSNotificationName const _Nonnull iCloudServiceSyncEndNotification = @"app.stay.notification.iCloudServiceSyncEndNotification";

@interface iCloudService(){
    dispatch_queue_t _iCloudServiceQueue;
    BOOL _isLogin;
}

@property (nonatomic, strong) CKContainer *container;
@property (nonatomic, strong) CKDatabase *database;
@property (nonatomic, strong) NSMutableDictionary<NSString *, CKRecordZone *> *zoneDic;
@property (nonatomic, strong) CKServerChangeToken *changeToken;
@property (nonatomic, strong) NSString *identifier;
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

- (void)refresh{
    _isLogin = [self logged];
    if (!_isLogin){
        [self _reset];
        return;
    }
    
    NSString *newIdentifier = [self serviceIdentifier];
    if ([self.identifier isEqualToString:newIdentifier]){
        return;
    }

    [self _reset];
    self.identifier = newIdentifier;
}

- (void)refreshWithCompletionHandler:(void (^)(NSError * error))completionHandler{
    [self loggedWithCompletionHandler:^(BOOL status, NSError *error) {
        if (error){
            completionHandler(error);
            return;
        }
        
        self->_isLogin = status;
        if (!self->_isLogin){
            [self _reset];
            completionHandler(nil);
            return;
        }
        
        
        [self serviceIdentifierWithCompletionHandler:^(NSString *identifier, NSError *error) {
            if (error){
                completionHandler(error);
            }
            else{
                NSString *newIdentifier = identifier;
                if ([self.identifier isEqualToString:newIdentifier]){
                    completionHandler(nil);
                    return;
                }

                [self _reset];
                self.identifier = newIdentifier;
                completionHandler(nil);
            }
        }];
    }];
}

- (void)clearToken{
    self.changeToken = nil;
}

- (void)_reset{
    self.container = nil;
    self.database = nil;
    self.zoneDic = nil;
    self.identifier = nil;
    self.changeToken = nil;
}

- (BOOL)isLogin{
    return _isLogin;
}

- (CKServerChangeToken *)changeToken{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"iCloudService.Userscripts.changeToken"];
    return (CKServerChangeToken *)[NSKeyedUnarchiver unarchivedObjectOfClass:[CKServerChangeToken class] fromData:data error:nil];
}

- (void)setChangeToken:(CKServerChangeToken *)changeToken{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:changeToken requiringSecureCoding:YES error:nil];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"iCloudService.Userscripts.changeToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)identifier{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"iCloudService.Userscripts.identifier"];
}

- (void)setIdentifier:(NSString *)identifier{
    [[NSUserDefaults standardUserDefaults] setObject:identifier forKey:@"iCloudService.Userscripts.identifier"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loggedWithCompletionHandler:(void(^)(BOOL status,NSError *error))completionHandler{
    [self.container accountStatusWithCompletionHandler:^(CKAccountStatus accountStatus, NSError * _Nullable error) {
        completionHandler(accountStatus == CKAccountStatusAvailable,error);
    }];
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

- (void)serviceIdentifierWithCompletionHandler:(void(^)(NSString *identifier,NSError *error))completionHandler{
    [self.container fetchUserRecordIDWithCompletionHandler:^(CKRecordID * _Nullable recordID, NSError * _Nullable error) {
        if (error){
            completionHandler(nil,error);
        }
        else{
            completionHandler([recordID.recordName copy],nil);
        }
        
    }];
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

- (void)fetchUserscriptWithCompletionHandler:
(void (^)(NSDictionary<NSString *, UserScript *> *changedUserscripts,NSArray<NSString *> *deletedUUIDs))completionHandler{
    [self _getZoneOnAsync:^(CKRecordZone *zone, NSError *error) {
        CKFetchRecordZoneChangesConfiguration *config = [CKFetchRecordZoneChangesConfiguration new];
        config.previousServerChangeToken = self.changeToken;
        CKFetchRecordZoneChangesOperation *operation = [[CKFetchRecordZoneChangesOperation alloc]
                                                        initWithRecordZoneIDs:@[zone.zoneID]
                                                        configurationsByRecordZoneID:@{
            zone.zoneID:config
        }];
        
        NSMutableDictionary<NSString *, UserScript *> *userscriptToSave = [NSMutableDictionary new];
        NSMutableArray<NSString *> *userscriptToDelete = [NSMutableArray new];
        
        operation.recordChangedBlock = ^(CKRecord *record) {
            if ([record.recordType isEqualToString:UserscriptRecord.type]){
                UserscriptRecord *userscriptRecord = [UserscriptRecord ofRecord:record];
                UserScript *userscript = userscriptToSave[userscriptRecord.uuid];
                NSString *content = nil;
                if (nil != userscript){
                    content = userscript.content;
                }
                userscript = [UserScript ofDictionary:
                 [NSJSONSerialization JSONObjectWithData:[userscriptRecord.header dataUsingEncoding:NSUTF8StringEncoding]
                                                 options:0 error:nil]];
                userscript.uuid = userscriptRecord.uuid;
                userscript.content = content;
                userscriptToSave[userscriptRecord.uuid] = userscript;
            }
            else if ([record.recordType isEqualToString:ContentRecord.type]){
                ContentRecord *contentRecord = [ContentRecord ofRecord:record];
                UserScript *userscript = userscriptToSave[contentRecord.uuid];
                NSString *content = contentRecord.raw;
                if (nil == userscript){
                    userscript = [[UserScript alloc] init];
                }
                userscript.uuid = contentRecord.uuid;
                userscript.content = content;
                userscriptToSave[contentRecord.uuid] = userscript;
            }
        };
        
        operation.recordWithIDWasDeletedBlock = ^(CKRecordID *recordID, CKRecordType recordType) {
            NSString *uuid = recordID.recordName;
            if ([recordType isEqualToString:UserscriptRecord.type]){
                [userscriptToDelete addObject:uuid];
            }
        };
        
        operation.recordZoneChangeTokensUpdatedBlock = ^(CKRecordZoneID *recordZoneID,
                                                         CKServerChangeToken *token,
                                                         NSData *data) {
            self.changeToken = token;
        };

        // If the fetch for the current record zone completes
        // successfully, cache the final change token.
        operation.recordZoneFetchCompletionBlock = ^(CKRecordZoneID *recordZoneID,
                                                     CKServerChangeToken *token,
                                                     NSData *data, BOOL more,
                                                     NSError *error) {
            if (error) {
                // Handle the error.
            } else {
                self.changeToken = token;
            }
            completionHandler(userscriptToSave,userscriptToDelete);
        };
        
        operation.qualityOfService = NSQualityOfServiceUserInitiated;
        [self.database addOperation:operation];
        
    } zoneName:@"Userscripts" recordTypes:@[UserscriptRecord.type,ContentRecord.type]];
}

- (NSString *)firstInitKey{
    return [NSString stringWithFormat:@"iCloudService.%@.firstInit2",self.identifier];
}

- (void)checkFirstInit:(void (^)(BOOL firstInit, NSError *error))completionHandler{
    NSNumber *n = [[NSUserDefaults standardUserDefaults] objectForKey:[self firstInitKey]];
    if (n && ![n boolValue]){
        completionHandler(NO,nil);
        return;
    }
    
    [self _getZoneOnAsync:^(CKRecordZone *zone, NSError *error) {
        if (error){
            completionHandler(YES,error);
        }
        else{
            CKFetchRecordsOperation *operation = [[CKFetchRecordsOperation alloc] initWithRecordIDs:@[[[CKRecordID alloc] initWithRecordName:[self firstInitKey] zoneID:zone.zoneID]]];
            operation.fetchRecordsCompletionBlock = ^(NSDictionary<CKRecordID *,CKRecord *> * _Nullable recordsByRecordID, NSError * _Nullable operationError) {
                completionHandler(recordsByRecordID.count == 0, nil);
            };
            operation.qualityOfService = NSQualityOfServiceUserInitiated;
            [self.database addOperation:operation];
        }
    } zoneName:@"Userscripts" recordTypes:@[StatusRecord.type]];
}

- (NSString *)userscriptRecordName:(NSString *)uuid{
    return [NSString stringWithFormat:@"userscript.%@",uuid];
}

- (NSString *)contentRecordName:(NSString *)uuid{
    return [NSString stringWithFormat:@"content.%@",uuid];
}

- (void)removeUserscript:(UserScript *)userscript completionHandler:(void(^)(NSError *error))completionHandler{
    [self _getZoneOnAsync:^(CKRecordZone *zone, NSError *error) {
        if (error){
            completionHandler(error);
            return;
        }
        
        CKRecordID *ckUserscriptRecordID = [[CKRecordID alloc] initWithRecordName:[self userscriptRecordName:userscript.uuid] zoneID:zone.zoneID];
        CKRecordID *ckContentRecordID = [[CKRecordID alloc] initWithRecordName:[self contentRecordName:userscript.uuid] zoneID:zone.zoneID];
        
        CKModifyRecordsOperation *operation = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:nil recordIDsToDelete:@[ckUserscriptRecordID,ckContentRecordID]];
        operation.savePolicy = CKRecordSaveAllKeys;
        operation.qualityOfService = NSQualityOfServiceUserInitiated;
        operation.modifyRecordsCompletionBlock = ^(NSArray<CKRecord *> * _Nullable savedRecords, NSArray<CKRecordID *> * _Nullable deletedRecordIDs, NSError * _Nullable operationError) {
            completionHandler(operationError);
        };
        [self.database addOperation:operation];

    } zoneName:@"Userscripts" recordTypes:@[UserscriptRecord.type,ContentRecord.type]];
}

- (void)initUserscripts:(NSArray<UserScript *> *)userscripts
      completionHandler:(void (^)(NSError *error))completionHandler{
    [self _getZoneOnAsync:^(CKRecordZone *zone, NSError *error) {
        if (error){
            completionHandler(error);
            return;
        }
        
        NSString *identifier = self.identifier;
        NSMutableArray<CKRecord *> *recordToSave = [[NSMutableArray alloc] init];
        for (UserScript *userscript in userscripts){
            userscript.iCloudIdentifier = identifier;
            CKRecord *ckUserscriptRecord = [[CKRecord alloc] initWithRecordType:UserscriptRecord.type
                                                           recordID:[[CKRecordID alloc] initWithRecordName:[self userscriptRecordName:userscript.uuid] zoneID:zone.zoneID]];
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
            [recordToSave addObject:ckUserscriptRecord];
            
            CKRecord *ckContentRecord = [[CKRecord alloc] initWithRecordType:ContentRecord.type
                                                                    recordID:[[CKRecordID alloc] initWithRecordName:[self contentRecordName:userscript.uuid] zoneID:zone.zoneID]];
            ContentRecord *contentRecord = [[ContentRecord alloc] init];
            contentRecord.uuid = userscript.uuid;
            contentRecord.raw = [userscript.content copy];
            [contentRecord fillCKRecord:ckContentRecord];
            [recordToSave addObject:ckContentRecord];
        }
        
        CKRecord *ckStatusRecord = [[CKRecord alloc] initWithRecordType:StatusRecord.type
                                                               recordID:[[CKRecordID alloc] initWithRecordName:[self firstInitKey]zoneID:zone.zoneID]];
        StatusRecord *statusRecord = [[StatusRecord alloc] init];
        statusRecord.firstInitTimestamp = [[NSDate date] timeIntervalSince1970];
        [statusRecord fillCKRecord:ckStatusRecord];
        [recordToSave addObject:ckStatusRecord];
        
        CKModifyRecordsOperation *operation = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:recordToSave recordIDsToDelete:nil];
        operation.savePolicy = CKRecordSaveAllKeys;
        operation.qualityOfService = NSQualityOfServiceUserInitiated;
        operation.modifyRecordsCompletionBlock = ^(NSArray<CKRecord *> * _Nullable savedRecords, NSArray<CKRecordID *> * _Nullable deletedRecordIDs, NSError * _Nullable operationError) {
            completionHandler(operationError);
        };
        [self.database addOperation:operation];
        
    } zoneName:@"Userscripts" recordTypes:@[UserscriptRecord.type,ContentRecord.type,StatusRecord.type]];
}

- (void)addUserscript:(UserScript *)userscript completionHandler:(void(^)(NSError *error))completionHandler{
    [self _getZoneOnAsync:^(CKRecordZone *zone, NSError *error) {
        if (error){
            completionHandler(error);
            return;
        }
        userscript.iCloudIdentifier = self.identifier;
        CKRecord *ckUserscriptRecord = [[CKRecord alloc] initWithRecordType:UserscriptRecord.type
                                                       recordID:[[CKRecordID alloc] initWithRecordName:[self userscriptRecordName:userscript.uuid] zoneID:zone.zoneID]];
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
        
        CKModifyRecordsOperation *operation = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:@[ckUserscriptRecord] recordIDsToDelete:nil];
        operation.savePolicy = CKRecordSaveAllKeys;
        operation.qualityOfService = NSQualityOfServiceUserInitiated;
        operation.modifyRecordsCompletionBlock = ^(NSArray<CKRecord *> * _Nullable savedRecords, NSArray<CKRecordID *> * _Nullable deletedRecordIDs, NSError * _Nullable operationError) {
            if (operationError){
                completionHandler(operationError);
                return;
            }
            
            CKRecord *ckContentRecord = [[CKRecord alloc] initWithRecordType:ContentRecord.type
                                                                    recordID:[[CKRecordID alloc] initWithRecordName:[self contentRecordName:userscript.uuid] zoneID:zone.zoneID]];
            ContentRecord *contentRecord = [[ContentRecord alloc] init];
            contentRecord.uuid = userscript.uuid;
            contentRecord.raw = [userscript.content copy];
            [contentRecord fillCKRecord:ckContentRecord];
            
            CKModifyRecordsOperation *contentOperation = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:@[ckContentRecord] recordIDsToDelete:nil];
            contentOperation.savePolicy = CKRecordSaveAllKeys;
            contentOperation.qualityOfService = NSQualityOfServiceUserInitiated;
            contentOperation.modifyRecordsCompletionBlock = ^(NSArray<CKRecord *> * _Nullable savedRecords, NSArray<CKRecordID *> * _Nullable deletedRecordIDs, NSError * _Nullable operationError) {
                completionHandler(operationError);
            };
            [self.database addOperation:contentOperation];
        };
            
        [self.database addOperation:operation];
        
    } zoneName:@"Userscripts" recordTypes:@[UserscriptRecord.type,ContentRecord.type]];
}

- (void)showError:(NSError *)error inCer:(UIViewController *)cer{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"icloud.error", @"")
                                                                       message:[error localizedDescription]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *conform = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"")
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
            [cer.navigationController popViewControllerAnimated:YES];
            }];
        [alert addAction:conform];
        [cer presentViewController:alert animated:YES completion:nil];
    });
    
}

- (void)showErrorWithMessage:(NSString *)message inCer:(UIViewController *)cer{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"icloud.error", @"")
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *conform = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"")
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
            [cer.navigationController popViewControllerAnimated:YES];
            }];
        [alert addAction:conform];
        [cer presentViewController:alert animated:YES completion:nil];
    });
    
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
