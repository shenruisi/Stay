//
//  UserDefaultsExRO.m
//  Stay
//
//  Created by ris on 2022/7/28.
//

#import "UserDefaultsExRO.h"

@interface UserDefaultsExRO(){
    dispatch_queue_t _userDefaultsExROQueue;
}

@end

@implementation UserDefaultsExRO

- (instancetype)initWithPath:(NSString *)path isDirectory:(BOOL)isDirectory{
    if (self = [super initWithPath:path isDirectory:isDirectory]){
        _userDefaultsExROQueue = dispatch_queue_create([[self queueName:@"userDefaultsExROQueue"] UTF8String],
                                              DISPATCH_QUEUE_SERIAL);
    }
    
    return  self;
}

+ (BOOL)supportsSecureCoding{
    return YES;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeBool:self.pro forKey:@"pro"];
    [coder encodeObject:self.deviceID forKey:@"deviceID"];
    [coder encodeFloat:self.availablePoints forKey:@"availablePoints"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    if (self = [super init]){
        _pro = [coder decodeBoolForKey:@"pro"];
        _deviceID = [coder decodeObjectForKey:@"deviceID"];
        _availablePoints = [coder decodeFloatForKey:@"availablePoints"];
    }
    
    return self;
}

- (NSData * _Nullable)archiveData {
    NSError *error = nil;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self
                                         requiringSecureCoding:YES
                                                         error:&error];
    return data;
}

- (void)unarchiveData:(NSData * _Nullable)data {
    NSSet *classesSet = [NSSet setWithObjects:[self class],[NSString class],nil];
    UserDefaultsExRO *userDefaults = [NSKeyedUnarchiver unarchivedObjectOfClasses:classesSet
                                                                     fromData:data
                                                                        error:nil];
    _pro = userDefaults.pro;
    _deviceID = userDefaults.deviceID;
    _availablePoints = userDefaults.availablePoints;
}

- (void)setPro:(BOOL)pro{
    _pro = pro;
    [self flush];
}

- (void)setDeviceID:(NSString *)deviceID{
    _deviceID = deviceID;
    [self flush];
}

- (void)setAvailablePoints:(CGFloat)availablePoints{
    _availablePoints = availablePoints;
    [self flush];
}


- (dispatch_queue_t _Nonnull)dispatchQueue {
    return  _userDefaultsExROQueue;
}
@end
