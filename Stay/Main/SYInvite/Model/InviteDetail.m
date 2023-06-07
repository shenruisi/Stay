//
//  InviteDetail.m
//  Stay
//
//  Created by zly on 2023/5/31.
//

#import "InviteDetail.h"

@implementation InviteDetail
+ (instancetype)ofDictionary:(NSDictionary *)jsonObject{
    InviteDetail *inviteDtail = [[InviteDetail alloc] init];
    inviteDtail.candidateCovers = jsonObject[@"candidate_covers"];
    inviteDtail.cover = jsonObject[@"cover"];
    inviteDtail.inviteCode = jsonObject[@"invite_code"];
    inviteDtail.level = [jsonObject[@"level"] integerValue];
    inviteDtail.link = jsonObject[@"link"];
    inviteDtail.name = jsonObject[@"name"];
    inviteDtail.process = jsonObject[@"process"];
    inviteDtail.since = jsonObject[@"since"];
    inviteDtail.status = [jsonObject[@"status"] integerValue];
    inviteDtail.taskId = jsonObject[@"task_id"];
    inviteDtail.visitedCount = [jsonObject[@"visited_count"] integerValue];
    return inviteDtail;
}
@end
