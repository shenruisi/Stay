//
//  UserDefaults.m
//  Stay
//
//  Created by ris on 2022/7/21.
//

#import "UserDefaults.h"

@implementation UserDefaults

+ (BOOL)supportsSecureCoding{
    return YES;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeBool:self.safariExtensionEnabled forKey:@"safariExtensionEnabled"];
    [coder encodeObject:self.lastFolderUUID forKey:@"lastFolderUUID"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    if (self = [super init]){
        _safariExtensionEnabled = [coder decodeBoolForKey:@"safariExtensionEnabled"];
        _lastFolderUUID = [coder decodeObjectForKey:@"lastFolderUUID"];
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
    UserDefaults *userDefaults = [NSKeyedUnarchiver unarchivedObjectOfClasses:classesSet
                                                                     fromData:data
                                                                        error:nil];
    _safariExtensionEnabled = userDefaults.safariExtensionEnabled;
    _lastFolderUUID = userDefaults.lastFolderUUID;
}

- (void)setSafariExtensionEnabled:(BOOL)safariExtensionEnabled{
    _safariExtensionEnabled = safariExtensionEnabled;
    [self flush];
}

- (void)setLastFolderUUID:(NSString *)lastFolderUUID{
    _lastFolderUUID = lastFolderUUID;
    [self flush];
}

- (dispatch_queue_t _Nonnull)dispatchQueue {
    return  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}
@end
