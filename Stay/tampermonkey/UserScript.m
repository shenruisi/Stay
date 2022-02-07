//
//  UserScript.m
//  Stay
//
//  Created by ris on 2021/11/18.
//

#import "UserScript.h"

@implementation UserScript

+ (instancetype)ofDictionary:(NSDictionary *)dic{
    UserScript *userScript = [[UserScript alloc] init];
    userScript.name = dic[@"name"];
    userScript.namespace = dic[@"namespace"];
    userScript.author = dic[@"author"];
    userScript.version = dic[@"version"];
    userScript.desc = dic[@"description"];
    userScript.homepage = dic[@"homepage"];
    userScript.icon = dic[@"icon"];
    userScript.includes = dic[@"includes"];
    NSArray *matches = dic[@"matches"];
    if (matches.count == 0){
        matches = @[@"*://*/*"];
    }
    userScript.mathes = matches;
    userScript.excludes = dic[@"excludes"];
    userScript.runAt = dic[@"runAt"];
    userScript.grants = dic[@"grants"];
    userScript.noFrames = [dic[@"noFrames"] boolValue];
    userScript.pass = [dic[@"pass"] boolValue];
    userScript.errorMessage = dic[@"errorMessage"];
    userScript.requireUrls = dic[@"requireUrls"];
    userScript.updateUrl = dic[@"updateUrl"];
    userScript.downloadUrl = dic[@"downloadUrl"];
    userScript.requireCodes = dic[@"requireCodes"];
    userScript.resourceUrls = dic[@"resourceUrls"];
    userScript.notes = dic[@"notes"];
    userScript.locales = dic[@"locales"];
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
        @"active":@(self.active),
        @"updateUrl":self.updateUrl ? self.updateUrl: @"",
        @"downloadUrl":self.downloadUrl ? self.downloadUrl: @"",
        @"requireCodes":self.requireCodes ? self.requireCodes: @[],
        @"resourceUrls":self.resourceUrls ? self.resourceUrls: @[],
        @"notes":self.notes ? self.notes: @[],
        @"locales":self.locales ? self.locales : @{}
    };
}

@end
