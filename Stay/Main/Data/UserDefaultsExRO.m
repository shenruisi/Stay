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
    [coder encodeFloat:self.availableGiftPoints forKey:@"availableGiftPoints"];
    [coder encodeFloat:self.downloadConsumePoints forKey:@"downloadConsumePoints"];
    [coder encodeFloat:self.tagConsumePoints forKey:@"tagConsumePoints"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    if (self = [super init]){
        _pro = [coder decodeBoolForKey:@"pro"];
        _deviceID = [coder decodeObjectForKey:@"deviceID"];
        _availablePoints = [coder decodeFloatForKey:@"availablePoints"];
        _availableGiftPoints = [coder decodeFloatForKey:@"availableGiftPoints"];
        _downloadConsumePoints = [coder decodeFloatForKey:@"downloadConsumePoints"];
        if (_downloadConsumePoints == 0) _downloadConsumePoints = 1;
        _tagConsumePoints = [coder decodeFloatForKey:@"tagConsumePoints"];
        if (_tagConsumePoints == 0) _tagConsumePoints = 0.5;
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
    _availableGiftPoints = userDefaults.availableGiftPoints;
    _downloadConsumePoints = userDefaults.downloadConsumePoints;
    _tagConsumePoints = userDefaults.tagConsumePoints;
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

- (void)setAvailableGiftPoints:(CGFloat)availableGiftPoints{
    _availableGiftPoints = availableGiftPoints;
    [self flush];
}

- (void)setDownloadConsumePoints:(CGFloat)downloadConsumePoints{
    _downloadConsumePoints = downloadConsumePoints;
    [self flush];
}

- (void)setTagConsumePoints:(CGFloat)tagConsumePoints{
    _tagConsumePoints = tagConsumePoints;
    [self flush];
}


- (dispatch_queue_t _Nonnull)dispatchQueue {
    return  _userDefaultsExROQueue;
}
@end
