//
//  UserScript.m
//  Stay
//
//  Created by ris on 2021/11/18.
//

#import "UserScript.h"

@implementation UserScript

+ (instancetype)ofDictionary:(NSDictionary *)dict{
    UserScript *userScript = [[UserScript alloc] init];
    userScript.name = dict[@"name"];
    userScript.namespace = dict[@"namespace"];
    userScript.author = dict[@"author"];
    userScript.version = dict[@"version"];
    userScript.desc = dict[@"description"];
    userScript.homepage = dict[@"homepage"];
    userScript.icon = dict[@"icon"];
    userScript.includes = dict[@"includes"];
    userScript.mathes = dict[@"matches"];
    userScript.excludes = dict[@"excludes"];
    userScript.runAt = dict[@"runAt"];
    userScript.grants = dict[@"grants"];
    userScript.noFrames = [dict[@"noFrames"] boolValue];
    userScript.pass = [dict[@"pass"] boolValue];
    userScript.errorMessage = dict[@"errorMessage"];
    userScript.requireUrls = dict[@"requireUrls"];
    userScript.updateUrl = dict[@"updateUrl"];
    userScript.downloadUrl = dict[@"downloadUrl"];
    return userScript;
}

- (NSDictionary *)toDictionary{
    return @{
        @"uuid":self.uuid ? self.uuid : @"",
        @"name":self.name ? self.name : @"",
        @"namespace":self.namespace ? self.namespace : @"",
        @"author":self.author ? self.author : @"",
        @"version":self.version ? self.version : @"",
        @"description":self.desc ? self.desc : @"",
        @"homepage":self.homepage ? self.homepage : @"",
        @"icon":self.icon ? self.icon : @"",
        @"includes":self.includes,
        @"matches":self.mathes,
        @"excludes":self.excludes,
        @"runAt":self.runAt,
        @"grants":self.grants,
        @"noFrames":@(self.noFrames),
        @"requireUrls":self.requireUrls,
        @"content":self.parsedContent ? self.parsedContent : @"",
        @"active":@(self.active)
    };
}

@end
