//
//  SharedStorageManager.h
//  Stay
//
//  Created by ris on 2022/5/31.
//

#import <Foundation/Foundation.h>
#import "UserscriptHeaders.h"
#import "UserscriptInfo.h"
#import "ActivateChanged.h"

NS_ASSUME_NONNULL_BEGIN

static inline NSString * _Nonnull FCSharedDirectory(void){
    return [[[NSFileManager defaultManager]
             containerURLForSecurityApplicationGroupIdentifier:
                 @"group.com.dajiu.stay.pro"] path];
}

static inline NSString * _Nonnull FCDataDirectory(void){
    return [FCSharedDirectory() stringByAppendingPathComponent:@".stay/data"];
}

@interface SharedStorageManager : NSObject

+ (instancetype)shared;
@property (nonatomic, strong, nullable) UserscriptHeaders *userscriptHeaders;
@property (nonatomic, strong, nullable) ActivateChanged *activateChanged;
- (UserscriptInfo *)getInfoOfUUID:(NSString *)uuid;
@end

NS_ASSUME_NONNULL_END
