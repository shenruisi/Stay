//
//  SafariWebExtensionHandler.m
//  Stay Extension
//
//  Created by ris on 2021/10/15.
//

#import "SafariWebExtensionHandler.h"
#import "Stroge.h"
#import <SafariServices/SafariServices.h>
#import "MatchPattern.h"

@implementation SafariWebExtensionHandler

//https://wiki.greasespot.net/Include_and_exclude_rules
- (NSRegularExpression *)convert2GlobsRegExp:(NSString *)str{
    NSString *expr = [[[[str stringByReplacingOccurrencesOfString:@"." withString:@"\\."]
                       stringByReplacingOccurrencesOfString:@"?" withString:@"\\?"]
                        stringByReplacingOccurrencesOfString:@"*" withString:@".*"]
                       stringByReplacingOccurrencesOfString:@"*." withString:@"*\\."];
    return [[NSRegularExpression alloc] initWithPattern:[NSString stringWithFormat:@"^%@$",expr]  options:0 error:nil];
}

- (BOOL)matchesCheck:(NSDictionary *)userscript url:(NSString *)url{
    NSArray *matches = userscript[@"matches"];
    
    BOOL matched = NO;
    for (NSString *match in matches){
        MatchPattern *matchPattern = [[MatchPattern alloc] initWithPattern:match];
        if ([matchPattern doMatch:url]){
            matched = YES;
            break;
        }
    }
    
    if (!matched){ //Fallback and treat match as globs expr
        for (NSString *match in matches){
            NSRegularExpression *fallbackMatchExpr = [self convert2GlobsRegExp:match];
            NSArray<NSTextCheckingResult *> *result = [fallbackMatchExpr matchesInString:url options:0 range:NSMakeRange(0, url.length)];
            if (result.count > 0){
                matched = YES;
                break;
            }
        }
    }
    
    if (!matched){
        NSArray *includes =  userscript[@"includes"];
        for (NSString *include in includes){
            NSRegularExpression *includeExpr = [self convert2GlobsRegExp:include];
            NSArray<NSTextCheckingResult *> *result = [includeExpr matchesInString:url options:0 range:NSMakeRange(0, url.length)];
            if (result.count > 0){
                matched = YES;
                break;
            }
        }
    }
    
    if (matched){
        NSArray *excludes =  userscript[@"excludes"];
        for (NSString *exclude in excludes){
            NSRegularExpression *excludeExpr = [self convert2GlobsRegExp:exclude];
            NSArray<NSTextCheckingResult *> *result = [excludeExpr matchesInString:url options:0 range:NSMakeRange(0, url.length)];
            if (result.count > 0){
                matched = NO;
                break;
            }
        }
    }
    
    return matched;
}

- (void)beginRequestWithExtensionContext:(NSExtensionContext *)context
{
    NSDictionary *message = (NSDictionary *)[context.inputItems.firstObject userInfo][SFExtensionMessageKey];
    NSExtensionItem *response = [[NSExtensionItem alloc] init];
    
    NSUserDefaults *groupUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dajiu.stay.pro"];
    
    id body = [NSNull null];
    if ([message[@"type"] isEqualToString:@"fetchScripts"]){
        NSString *url = message[@"url"];
        NSMutableArray<NSDictionary *> *datas = [NSMutableArray arrayWithArray:[groupUserDefaults arrayForKey:@"ACTIVE_SCRIPTS"]];
        
        for(int i = 0;i < datas.count; i++) {
            NSDictionary *data = datas[i];
            if (![self matchesCheck:data url:url]){
                [datas removeObjectAtIndex:i];
                i--;
                continue;
            }
            
            NSArray<NSDictionary *> *requireUrlsAndCodes = [self getUserScriptRequireListByUserScript:data];
            if (requireUrlsAndCodes != nil) {
                NSMutableDictionary *mulDic = [NSMutableDictionary dictionaryWithDictionary:data];
                mulDic[@"requireCodes"] = requireUrlsAndCodes;
                [datas replaceObjectAtIndex:i withObject:mulDic];
            }
        }
       
        body = datas;
        
    }
    else if ([message[@"type"] isEqualToString:@"GM_setValue"]){
        NSString *uuid = message[@"uuid"];
        NSString *key = message[@"key"];
        NSString *value = message[@"value"];
        if (uuid.length > 0 && key.length > 0 && value != nil){
            [Stroge setValue:value forKey:key uuid:uuid];
        }
    }
    else if ([message[@"type"] isEqualToString:@"GM_getValue"]){
        NSString *uuid = message[@"uuid"];
        NSString *key = message[@"key"];
        id defaultValue = message[@"defaultValue"];
        if (uuid.length > 0 && key.length > 0){
            body = [Stroge valueForKey:key uuid:uuid defaultValue:defaultValue];
        }
    }
    else if ([message[@"type"] isEqualToString:@"GM_deleteValue"]){
        NSString *uuid = message[@"uuid"];
        NSString *key = message[@"key"];
        if (uuid.length > 0 && key.length > 0){
            [Stroge deleteValueForKey:key uuid:uuid];
        }
    }
    else if ([message[@"type"] isEqualToString:@"GM_listValues"]){
        NSString *uuid = message[@"uuid"];
        if (uuid.length > 0){
            body = [Stroge listValues:uuid];
        }
    }
    else if ([message[@"type"] isEqualToString:@"setScriptActive"]){
        NSMutableArray<NSDictionary *> *datas = [NSMutableArray arrayWithArray:[groupUserDefaults arrayForKey:@"ACTIVE_SCRIPTS"]];
        NSString *uuid = message[@"uuid"];
        bool activeVal = [message[@"active"] boolValue];
        if (datas != NULL && datas.count > 0) {
            for(int i = 0; i < datas.count;i++) {
                NSDictionary *dic = datas[i];
                if([dic[@"uuid"] isEqualToString:uuid]) {
                    NSMutableDictionary *mdic = [NSMutableDictionary dictionaryWithDictionary:dic];
                    [datas removeObject:dic];
                    [mdic setValue:@(activeVal) forKey:@"active"];
                    [datas addObject:mdic];
                    [groupUserDefaults setObject:datas forKey:@"ACTIVE_SCRIPTS"];
                    [groupUserDefaults synchronize];
                    break;
                }
            }
        }
        
        
        if([groupUserDefaults arrayForKey:@"ACTIVE_CHANGE"] != NULL && [groupUserDefaults arrayForKey:@"ACTIVE_CHANGE"].count > 0){
            NSMutableArray<NSDictionary *> *datas = [NSMutableArray arrayWithArray:[groupUserDefaults arrayForKey:@"ACTIVE_CHANGE"]];
            NSDictionary *dic = @{@"uuid":uuid,@"active":activeVal?@"1":@"0"};
            [datas addObject:dic];
            NSUserDefaults *groupUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dajiu.stay.pro"];
            [groupUserDefaults setObject:datas forKey:@"ACTIVE_CHANGE"];
            [groupUserDefaults synchronize];
        } else {
            NSMutableArray<NSDictionary *> *datas = [[NSMutableArray alloc] init];
            NSDictionary *dic = @{@"uuid":uuid,@"active":activeVal?@"1":@"0"};
            [datas addObject:dic];
            NSUserDefaults *groupUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dajiu.stay.pro"];
            [groupUserDefaults setObject:datas forKey:@"ACTIVE_CHANGE"];
            [groupUserDefaults synchronize];
        }
    }
    else if ([message[@"type"] isEqualToString:@"GM_getResourceText"]){
        NSString *uuid = message[@"uuid"];
        NSString *key = message[@"key"];
        
        NSString *value = [self getResourceByKey:uuid fileName:key];
        if(value != nil && value.length > 0) {
            body = [[NSString alloc] initWithData:
                   [NSJSONSerialization dataWithJSONObject: value
                                                options:0
                                                  error:nil]
                                     encoding:NSUTF8StringEncoding];
        }
        
    }
    else if ([message[@"type"] isEqualToString:@"GM_getAllResourceText"]){
        NSString *uuid = message[@"uuid"];
        NSMutableDictionary *dic = [self getResourceByUuid:uuid];
        if(dic != nil && dic.count > 0) {
            body = dic;
        }
        
    }
    else if ([message[@"type"] isEqualToString:@"GM_getResourceUrl"]){
        NSMutableArray<NSDictionary *> *datas = [NSMutableArray arrayWithArray:[groupUserDefaults arrayForKey:@"ACTIVE_SCRIPTS"]];
        NSString *uuid = message[@"uuid"];
        NSString *key = message[@"key"];
        if (datas != NULL && datas.count > 0) {
            for(int i = 0; i < datas.count;i++) {
                NSDictionary *dic = datas[i];
                if([dic[@"uuid"] isEqualToString:uuid]) {
                    NSMutableDictionary *mdic = [NSMutableDictionary dictionaryWithDictionary:dic];
                    NSDictionary *resourceDic = dic[@"resourceUrls"];
                    NSString *str = resourceDic[key];
                    body = str;
                    break;
                }
            }
        }
    }
    else if ([message[@"type"] isEqualToString:@"GM_getAllResourceUrl"]){
        NSMutableArray<NSDictionary *> *datas = [NSMutableArray arrayWithArray:[groupUserDefaults arrayForKey:@"ACTIVE_SCRIPTS"]];
        NSString *uuid = message[@"uuid"];
        NSString *key = message[@"key"];
        if (datas != NULL && datas.count > 0) {
            for(int i = 0; i < datas.count;i++) {
                NSDictionary *dic = datas[i];
                if([dic[@"uuid"] isEqualToString:uuid]) {
                    NSMutableDictionary *mdic = [NSMutableDictionary dictionaryWithDictionary:dic];
                    NSDictionary *resourceDic = dic[@"resourceUrls"];
                    body = resourceDic;
                    break;
                }
            }
        }
    } else if ([message[@"type"] isEqualToString:@"GM_getUserscriptByUuid"]){
        NSString *uuid = message[@"uuid"];

        NSUserDefaults *groupUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dajiu.stay.pro"];
        if([groupUserDefaults dictionaryForKey:@"SCRIPT_INSTANCE"] != NULL && [groupUserDefaults dictionaryForKey:@"SCRIPT_INSTANCE"].allValues.count > 0){
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[groupUserDefaults dictionaryForKey:@"SCRIPT_INSTANCE"]];
            NSDictionary *scriptEntity = dic[uuid];
            body = scriptEntity[@"script"];
        }
    }

    response.userInfo = @{ SFExtensionMessageKey: @{ @"type": message[@"type"],
                                                     @"body": body == nil ? [NSNull null]:body,
                                                    }
    };
    [context completeRequestReturningItems:@[ response ] completionHandler:nil];
}




- (NSArray<NSDictionary *> *)getUserScriptRequireListByUserScript:(NSDictionary *)scrpit  {
    if(scrpit != nil && scrpit[@"requireUrls"] != nil){
        NSArray *array = scrpit[@"requireUrls"];
        NSString *groupPath = [[[NSFileManager defaultManager]
                     containerURLForSecurityApplicationGroupIdentifier:
                         @"group.com.dajiu.stay.pro"] path];
        NSMutableArray *requireList = [[NSMutableArray alloc] init];
        for(int j = 0; j < array.count; j++) {
            NSString *requireUrl = array[j];
            NSString *fileName = requireUrl.lastPathComponent;
            NSString *strogeUrl = [NSString stringWithFormat:@"%@/%@/require/%@",groupPath,scrpit[@"uuid"],fileName];
            if(![[NSFileManager defaultManager] fileExistsAtPath:strogeUrl]) {
                return nil;
            }
            NSData *data=[NSData dataWithContentsOfFile:strogeUrl];
            NSString *responData =  [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];

            [requireList addObject:@{@"url":requireUrl,@"code":responData,@"name":fileName}];
        }
        return requireList;
    }
    return nil;
}

- (NSString *)getResourceByKey:(NSString *)uuid fileName:(NSString *)key   {
  
    NSString *groupPath = [[[NSFileManager defaultManager]
                 containerURLForSecurityApplicationGroupIdentifier:
                     @"group.com.dajiu.stay.pro"] path];

    NSString *strogeUrl = [NSString stringWithFormat:@"%@/%@/resource/%@",groupPath,uuid,key];
    if(![[NSFileManager defaultManager] fileExistsAtPath:strogeUrl]) {
        return nil;
    }
    NSData *data=[NSData dataWithContentsOfFile:strogeUrl];
    NSString *responData =  [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    if(responData != nil) {
        return responData;
    }
    
    return nil;
}

- (NSMutableDictionary *)getResourceByUuid:(NSString *)uuid{

    NSString *groupPath = [[[NSFileManager defaultManager]
                 containerURLForSecurityApplicationGroupIdentifier:
                     @"group.com.dajiu.stay.pro"] path];

    NSString *strogeUrl = [NSString stringWithFormat:@"%@/%@/resource/",groupPath,uuid];
    if(![[NSFileManager defaultManager] fileExistsAtPath:strogeUrl]) {
        return nil;
    }

    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSFileManager *fileManger = [NSFileManager defaultManager];
    NSArray * dirArray = [fileManger contentsOfDirectoryAtPath:strogeUrl error:nil];

    NSString * subPath = nil;
    for (NSString * str in dirArray) {
        subPath  = [strogeUrl stringByAppendingPathComponent:str];
        BOOL issubDir = NO;
        [fileManger fileExistsAtPath:subPath isDirectory:&issubDir];
        NSData *data=[NSData dataWithContentsOfFile:subPath];
        NSString *responData =  [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        dic[str] = responData;
    }
    return dic;
}

@end
