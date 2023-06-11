//
//  InviteDetail.h
//  Stay
//
//  Created by zly on 2023/5/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface InviteDetail : NSObject
@property (nonatomic, strong) NSArray<NSString *> *candidateCovers;
@property (nonatomic, copy) NSString *cover;
@property (nonatomic, copy) NSString *inviteCode;
@property (nonatomic, assign) NSInteger level;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSArray<NSDictionary *> *process;
@property (nonatomic, copy) NSString *sinceEn;
@property (nonatomic, copy) NSString *sinceCn;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, copy) NSString *taskId;
@property (nonatomic, assign) NSInteger visitedCount;

+ (instancetype)ofDictionary:(NSDictionary *)jsonObject;


@end

NS_ASSUME_NONNULL_END
