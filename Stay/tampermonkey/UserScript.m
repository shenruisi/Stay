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
    userScript.icon = dic[@"iconUrl"];
    userScript.includes = dic[@"includes"];
    userScript.mathes = dic[@"matches"];
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
    userScript.unsupportedGrants = dic[@"unsupportedGrants"];
    userScript.stayEngine = dic[@"stayEngine"];
    userScript.injectInto = dic[@"injectInto"];
    userScript.license = dic[@"license"];
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
        @"resourceUrls":self.resourceUrls ? self.resourceUrls: @{},
        @"notes":self.notes ? self.notes: @[],
        @"locales":self.locales ? self.locales : @{},
        @"installType":self.installType ? self.installType : @"content",
        @"unsupportedGrants":self.unsupportedGrants ? self.unsupportedGrants : @[],
        @"stayEngine":self.stayEngine ? self.stayEngine : @"",
        @"excludeSites":self.excludeSites ? self.excludeSites : @[],
        @"injectInto":self.injectInto ? self.injectInto : @"auto",
        @"license":self.license ? self.license : @""
    };
}

- (NSString *)description
{
    NSMutableString *builder = [[NSMutableString alloc] init];
    if (self.name.length > 0){
        [builder appendFormat:@"name: %@\n",self.name];
    }
    
    if (self.namespace.length > 0){
        [builder appendFormat:@"namespace: %@\n",self.namespace];
    }
    
    if (self.author.length > 0){
        [builder appendFormat:@"author: %@\n",self.author];
    }
    
    if (self.version.length > 0){
        [builder appendFormat:@"version: %@\n",self.version];
    }
    
    if (self.desc.length > 0){
        [builder appendFormat:@"description: %@\n",self.desc];
    }
    
    if (self.runAt.length > 0){
        [builder appendFormat:@"runAt: %@\n",self.runAt];
    }
    
    for (NSString *match in self.mathes){
        [builder appendFormat:@"match: %@\n",match];
    }
    
    for (NSString *include in self.includes){
        [builder appendFormat:@"include: %@\n",include];
    }
    
    for (NSString *exclude in self.excludes){
        [builder appendFormat:@"exclude: %@\n",exclude];
    }
    
    for (NSString *grant in self.grants){
        [builder appendFormat:@"grant: %@\n",grant];
    }
    
    return builder;
}

+ (NSString *)localeCode{
    NSLocale *locale = [NSLocale currentLocale];
    return [NSString stringWithFormat:@"%@-%@",locale.languageCode,locale.countryCode];
}

+ (NSString *)localeCodeLanguageCodeOnly{
    NSLocale *locale = [NSLocale currentLocale];
    return locale.languageCode;
}

@end
