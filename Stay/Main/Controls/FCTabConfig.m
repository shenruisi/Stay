//
//  FCTabConfig.m
//  FastClip-iOS
//
//  Created by ris on 2022/1/18.
//

#import "FCTabConfig.h"

@interface FCTabConfig(){
    dispatch_queue_t _configQueue;
}
@end

@implementation FCTabConfig

- (void)onInit{
    _configQueue = dispatch_queue_create([[self queueName:@"tabConfig"] UTF8String],
                                          DISPATCH_QUEUE_SERIAL);
}

+ (BOOL)supportsSecureCoding{
    return YES;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.hexColor forKey:@"hexColor"];
    [coder encodeInteger:self.position forKey:@"position"];
    [coder encodeDouble:self.operateTimestamp forKey:@"operateTimestamp"];
    [coder encodeBool:self.faceIDEnabled forKey:@"faceIDEnabled"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    if (self = [super init]){
        _name = [coder decodeObjectForKey:@"name"];
        _hexColor = [coder decodeObjectForKey:@"hexColor"];
        _position = [coder decodeIntegerForKey:@"position"];
        _operateTimestamp = [coder decodeDoubleForKey:@"operateTimestamp"];
        _faceIDEnabled = [coder decodeBoolForKey:@"faceIDEnabled"];
    }
    
    return self;
}

- (NSData * _Nullable)archiveData {
    return [NSKeyedArchiver archivedDataWithRootObject:self
                                 requiringSecureCoding:YES
                                                 error:nil];
}

- (void)unarchiveData:(NSData * _Nullable)data {
    NSSet *classesSet = [NSSet setWithObjects:[self class],[NSString class],[NSMutableArray class],nil];
    FCTabConfig *config = [NSKeyedUnarchiver unarchivedObjectOfClasses:classesSet
                                                            fromData:data
                                                               error:nil];
    _name = config.name;
    _hexColor = config.hexColor;
    _position = config.position;
    _operateTimestamp = config.operateTimestamp;
    _faceIDEnabled = config.faceIDEnabled;
}

- (void)setName:(NSString *)name{
    _name = [name copy];
    [self flush];
}

- (void)setHexColor:(NSString *)hexColor{
    _hexColor = [hexColor copy];
    [self flush];
}

- (void)setPosition:(NSInteger)position{
    _position = position;
    [self flush];
}

- (void)setOperateTimestamp:(double)operateTimestamp{
    _operateTimestamp = operateTimestamp;
    [self flush];
}

- (void)setFaceIDEnabled:(BOOL)faceIDEnabled{
    _faceIDEnabled = faceIDEnabled;
    [self flush];
}

- (void)operateUpdate{
    [self setOperateTimestamp:[[NSDate date] timeIntervalSince1970]];
}

- (dispatch_queue_t)dispatchQueue{
    return _configQueue;
}

@end
