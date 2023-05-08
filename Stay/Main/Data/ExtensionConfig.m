//
//  ExtensionConfig.m
//  Stay
//
//  Created by ris on 2022/10/18.
//

#import "ExtensionConfig.h"

@interface ExtensionConfig(){
    dispatch_queue_t _extensionConfigQueue;
}

@end

@implementation ExtensionConfig

- (instancetype)initWithPath:(NSString *)path isDirectory:(BOOL)isDirectory{
    if (self = [super initWithPath:path isDirectory:isDirectory]){
        _extensionConfigQueue = dispatch_queue_create([[self queueName:@"extensionConfigQueue"] UTF8String],
                                              DISPATCH_QUEUE_SERIAL);
    }
    
    return  self;
}

+ (BOOL)supportsSecureCoding{
    return YES;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeBool:self.showBadge forKey:@"showBadge"];
    [coder encodeObject:self.tagStatus forKey:@"tagStatus"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    if (self = [super init]){
        _showBadge = [coder decodeBoolForKey:@"showBadge"];
        _tagStatus = [coder decodeObjectForKey:@"tagStatus"];
    }
    
    return self;
}

- (void)initOnEmpty{
    _showBadge = NO;
    _tagStatus = @(1);
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
    ExtensionConfig *extensionConfig = [NSKeyedUnarchiver unarchivedObjectOfClasses:classesSet
                                                                     fromData:data
                                                                        error:nil];
    _showBadge = extensionConfig.showBadge;
    _tagStatus = extensionConfig.tagStatus ? extensionConfig.tagStatus : @(1);
}

- (void)setShowBadge:(BOOL)showBadge{
    _showBadge = showBadge;
    [self flush];
}

- (void)setTagStatus:(NSNumber *)tagStatus{
    _tagStatus = tagStatus;
    [self flush];
}


- (dispatch_queue_t _Nonnull)dispatchQueue {
    return  _extensionConfigQueue;
}

@end
