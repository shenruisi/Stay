//
//  UserDefaultsExRO.m
//  Stay
//
//  Created by ris on 2022/7/28.
//

#import "UserDefaultsExRO.h"

@implementation UserDefaultsExRO

+ (BOOL)supportsSecureCoding{
    return YES;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeBool:self.pro forKey:@"pro"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    if (self = [super init]){
        _pro = [coder decodeBoolForKey:@"pro"];
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
}

- (void)setPro:(BOOL)pro{
    _pro = pro;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self flush];
    });
    
}

- (dispatch_queue_t _Nonnull)dispatchQueue {
    return  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}
@end
