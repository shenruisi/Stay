//
//  SafariWebExtensionHandler.m
//  Stay-Mac Extension
//
//  Created by ris on 2022/6/23.
//

#import "SafariWebExtensionHandler.h"

#import <SafariServices/SafariServices.h>
#import "MatchPattern.h"
#import "Stroge.h"
#import "SharedStorageManager.h"
#import "API.h"
#import "FCShared.h"
#import "ContentFilterManager.h"
#import "MyAdditions.h"


#if __MAC_OS_X_VERSION_MIN_REQUIRED < 110000
NSString * const SFExtensionMessageKey = @"message";
#endif

@interface SafariWebExtensionHandler()

@property (nonatomic, strong) NSString *handlerVersion;
@property (nonatomic, strong) NSString *sharedGroupPath;
@end

@implementation SafariWebExtensionHandler

- (instancetype)init{
    if (self = [super init]){
//        [[NSDistributedNotificationCenter defaultCenter] addObserver:self
//                                                            selector:@selector(showPref:)
//                                                                name:@"app.stay.distributed.showPref"
//                                                              object:nil];
    }
    
    return self;
}

//https://wiki.greasespot.net/Include_and_exclude_rules
- (NSRegularExpression *)convert2GlobsRegExp:(NSString *)str{
    NSString *expr = [[[[str stringByReplacingOccurrencesOfString:@"." withString:@"\\."]
                       stringByReplacingOccurrencesOfString:@"?" withString:@"\\?"]
                        stringByReplacingOccurrencesOfString:@"*" withString:@".*"]
                       stringByReplacingOccurrencesOfString:@"*." withString:@"*\\."];
    return [[NSRegularExpression alloc] initWithPattern:[NSString stringWithFormat:@"^%@$",expr]  options:0 error:nil];
}

- (BOOL)matchesCheck:(NSDictionary *)userscript url:(NSString *)url{
    NSArray *whitelist = userscript[@"whitelist"];
    BOOL matched = NO;
    if (whitelist.count > 0){
        for (NSString *white in whitelist){
            @autoreleasepool {
                NSRegularExpression *whiteExpr = [self convert2GlobsRegExp:white];
                NSArray<NSTextCheckingResult *> *result = [whiteExpr matchesInString:url options:0 range:NSMakeRange(0, url.length)];
                if (result.count > 0){
                    matched = YES;
                    break;
                }
            }
        }
    }
    
    if (!matched && whitelist.count > 0) return NO;
    
    NSArray *blacklist = userscript[@"blacklist"];
    if (blacklist.count > 0){
        for (NSString *black in blacklist){
            @autoreleasepool {
                NSRegularExpression *blackExpr = [self convert2GlobsRegExp:black];
                NSArray<NSTextCheckingResult *> *result = [blackExpr matchesInString:url options:0 range:NSMakeRange(0, url.length)];
                if (result.count > 0){
                    return NO;
                }
            }
        }
    }
    
    if (matched) return YES;
    
    NSArray *matches = userscript[@"matches"];
    for (NSString *match in matches){
        @autoreleasepool {
            MatchPattern *matchPattern = [[MatchPattern alloc] initWithPattern:match];
            if ([matchPattern doMatch:url]){
                matched = YES;
                break;
            }
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

- (NSString *)disabledWebsitesCheck:(NSDictionary *)userscript url:(NSString *)url{
    NSArray *blacklist = userscript[@"disabledWebsites"];
    if (blacklist.count > 0){
        for (NSString *black in blacklist){
            @autoreleasepool {
                NSRegularExpression *blackExpr = [self convert2GlobsRegExp:black];
                NSArray<NSTextCheckingResult *> *result = [blackExpr matchesInString:url options:0 range:NSMakeRange(0, url.length)];
                if (result.count > 0){
                    return black;
                }
            }
        }
    }

    return nil;
}

- (void)beginRequestWithExtensionContext:(NSExtensionContext *)context
{
    NSDictionary *message = (NSDictionary *)[context.inputItems.firstObject userInfo][SFExtensionMessageKey];
    NSExtensionItem *response = [[NSExtensionItem alloc] init];
    
    id body = [NSNull null];
    if ([message[@"type"] hasPrefix:@"script.v2."]){
        body = [self scriptV2Handler:message];
    }
    else if ([message[@"type"] isEqualToString:@"fetchScripts"]){
        NSString *url = message[@"url"];
        NSString *digest = message[@"digest"];
        BOOL requireCompleteScript = digest.length == 0 || [digest isEqualToString:@"no"];
        [SharedStorageManager shared].userscriptHeaders = nil;
        NSMutableArray<NSDictionary *> *datas = [NSMutableArray arrayWithArray:[SharedStorageManager shared].userscriptHeaders.content];
        
        for(int i = 0;i < datas.count; i++) {
            NSDictionary *data = datas[i];
            if ((requireCompleteScript && ![data[@"active"] boolValue]) || ![self matchesCheck:data url:url]){
                [datas removeObjectAtIndex:i];
                i--;
                continue;
            }
            
            NSString *disabledUrl = nil;
            if ((disabledUrl = [self disabledWebsitesCheck:data url:url]) != nil){
                if (requireCompleteScript){
                    [datas removeObjectAtIndex:i];
                    i--;
                    continue;
                }
            }
            
            if (requireCompleteScript){
                NSArray<NSDictionary *> *requireUrlsAndCodes = [self getUserScriptRequireListByUserScript:data];
                NSMutableDictionary *mulDic = [NSMutableDictionary dictionaryWithDictionary:data];
                if (requireUrlsAndCodes != nil) {
                    mulDic[@"requireCodes"] = requireUrlsAndCodes;
                }
                
                UserscriptInfo *info = [self getInfoWithUUID:data[@"uuid"]];
                mulDic[@"content"] = info.content[@"content"];
                mulDic[@"otherContent"] = info.content[@"otherContent"];
                [datas replaceObjectAtIndex:i withObject:mulDic];
            }
            else{
                NSMutableDictionary *mulDic = [NSMutableDictionary dictionaryWithDictionary:data];
                mulDic[@"disabledUrl"] = disabledUrl;
                [datas replaceObjectAtIndex:i withObject:mulDic];
            }
            
            NSNumber *number = [SharedStorageManager shared].runsRecord.contentDic[data[@"uuid"]];
            [SharedStorageManager shared].runsRecord.contentDic[data[@"uuid"]] = number ? @(number.integerValue+1) : @(1);
            [[SharedStorageManager shared].runsRecord flush];
        }
       
        [SharedStorageManager shared].extensionConfig = nil;
        body = @{
            @"showBadge": @([SharedStorageManager shared].extensionConfig.showBadge),
            @"scripts":datas
        };
        if (!requireCompleteScript){
            [SharedStorageManager shared].userDefaultsExRO = nil;
            [[API shared] active:[SharedStorageManager shared].userDefaultsExRO.deviceID
                           isPro:[SharedStorageManager shared].userDefaultsExRO.pro
                     isExtension:YES];
        }
    }
    else if ([message[@"type"] isEqualToString:@"fetchTheScript"]){
        NSString *uuid = message[@"uuid"];
        [SharedStorageManager shared].userscriptHeaders = nil;
        NSMutableArray<NSDictionary *> *datas = [NSMutableArray arrayWithArray:[SharedStorageManager shared].userscriptHeaders.content];
        
        for(int i = 0;i < datas.count; i++) {
            NSDictionary *data = datas[i];
            if ([data[@"uuid"] isEqualToString:uuid]){
                NSArray<NSDictionary *> *requireUrlsAndCodes = [self getUserScriptRequireListByUserScript:data];
                NSMutableDictionary *mulDic = [NSMutableDictionary dictionaryWithDictionary:data];
                if (requireUrlsAndCodes != nil) {
                    mulDic[@"requireCodes"] = requireUrlsAndCodes;
                }
                mulDic[@"content"] = [self getContentWithUUID:data[@"uuid"]];
                body = mulDic;
                break;
            }
        }
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
        NSMutableArray<NSDictionary *> *datas = [NSMutableArray arrayWithArray:[SharedStorageManager shared].userscriptHeaders.content];
        NSString *uuid = message[@"uuid"];
        bool activeVal = [message[@"active"] boolValue];
        if (datas != NULL && datas.count > 0) {
            for(int i = 0; i < datas.count;i++) {
                NSDictionary *dic = datas[i];
                if([dic[@"uuid"] isEqualToString:uuid]) {
                    NSMutableDictionary *mdic = [NSMutableDictionary dictionaryWithDictionary:dic];
                    [mdic setValue:@(activeVal) forKey:@"active"];
                    [datas replaceObjectAtIndex:i withObject:mdic];
                    [SharedStorageManager shared].userscriptHeaders.content = datas;
                    [[SharedStorageManager shared].userscriptHeaders flush];
                    break;
                }
            }
        }
        
        NSMutableDictionary<NSString *,NSNumber *> *changed = [NSMutableDictionary dictionaryWithDictionary:[SharedStorageManager shared].activateChanged.content];
        changed[uuid] = activeVal?@(YES):@(NO);
        [SharedStorageManager shared].activateChanged.content = changed;
        [[SharedStorageManager shared].activateChanged flush];
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
        NSMutableArray<NSDictionary *> *datas = [NSMutableArray arrayWithArray:[SharedStorageManager shared].userscriptHeaders.content];
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
        NSMutableArray<NSDictionary *> *datas = [NSMutableArray arrayWithArray:[SharedStorageManager shared].userscriptHeaders.content];
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
    }
    else if ([message[@"type"] isEqualToString:@"p"]){
        [SharedStorageManager shared].userDefaultsExRO = nil;
        body = [SharedStorageManager shared].userDefaultsExRO.pro ? @"a":@"b";
    }
    else if ([message[@"type"] isEqualToString:@"GM_xmlhttpRequest"]){
        NSDictionary *details = message[@"details"];
        body = [self xmlHttpRequestProxy:details];
    }
    else if ([message[@"type"] isEqualToString:@"fetchFolders"]){
        NSMutableArray<NSDictionary *> *datas = [[NSMutableArray alloc] init];
        [FCShared.tabManager resetAllTabs];
        NSArray *tabs = FCShared.tabManager.tabs;
        SharedStorageManager.shared.userDefaults = nil;
        NSString *selectedUUID = SharedStorageManager.shared.userDefaults.lastFolderUUID;
        if (selectedUUID.length == 0) {
            selectedUUID = ((FCTab *)[tabs objectAtIndex:0]).uuid;
        }
        NSString *exteralFolderName = SharedStorageManager.shared.userDefaults.exteralFolderName;
        if (exteralFolderName.length > 0) {
            [datas addObject:@{
                @"uuid": @"FILEUUID0000",
                @"name": exteralFolderName,
                @"selected": @([selectedUUID isEqualToString:@"FILEUUID0000"]),
            }];
        }
        for (FCTab *tab in tabs) {
            [datas addObject:@{
                @"uuid": tab.uuid,
                @"name": tab.config.name,
                @"selected": @([selectedUUID isEqualToString:tab.uuid]),
            }];
        }
        body = datas;
    }
    else if ([message[@"type"] isEqualToString:@"yt_element"]){
        NSString *path = message[@"path"];
        NSString *location = message[@"location"];
        NSDictionary *response = [[API shared] downloadYoutube:path location:location];
        NSString *code = response[@"biz"][@"code"];
        NSString *nCode = response[@"biz"][@"n_code"];
        body = @{
            @"status_code" : response[@"status_code"],
            @"code" : code ? code : @"",
            @"n_code" : nCode ? nCode : @""
        };
    }
    else if ([message[@"type"] isEqualToString:@"yt_element_ci"]){
        NSString *path = message[@"path"];
        NSString *code = message[@"code"];
        NSString *nCode = message[@"n_code"];
        if (path.length > 0 && code.length > 0){
            [[API shared] commitYoutbe:path code:code nCode:nCode];
        }
    }
    else if ([message[@"type"] isEqualToString:@"ADB_tag_ad"]){
        NSArray<NSString *> *urls = message[@"urls"];
        NSString *selector = message[@"selector"];
        
        if (urls.count > 0 && selector.length > 0){
            NSMutableString *content = [[NSMutableString alloc] init];
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (NSString *url in urls){
                NSMutableCharacterSet *set  = [[NSCharacterSet URLFragmentAllowedCharacterSet] mutableCopy];
                [set addCharactersInString:@"#"];
                NSURL *uri = [NSURL URLWithString:[url stringByAddingPercentEncodingWithAllowedCharacters:set]];
                NSString *host = uri.host;
                NSString *path = uri.path;
                if ([path isEqualToString:@"/"]){
                    path = @"";
                }
                path = path ? path : @"";
                NSString *rule = [NSString stringWithFormat:@"||%@%@##%@\n",host,path,selector];
                [content appendString:rule];
                [array addObject:@{
                    @"trigger" : @{
                        @"url-filter" : [NSString stringWithFormat:@"^https?://%@%@",host,path]
                    },
                    @"action" : @{
                        @"type" : @"css-display-none",
                        @"selector" : selector
                    }
                }];
            }
            
            [[ContentFilterManager shared] appendTextToFileName:@"Tag.txt" content:content error:nil];
            [SharedStorageManager shared].extensionConfig = nil;
            [SharedStorageManager shared].extensionConfig.tagUpdate = [NSDate date];
            [[ContentFilterManager shared] appendJSONToFileName:@"Tag.json" array:array error:nil];
            
            NSString *contentBlockerIdentifier = @"com.dajiu.stay.pro.Stay-Content-Tag";
            [SFContentBlockerManager reloadContentBlockerWithIdentifier:contentBlockerIdentifier completionHandler:^(NSError * _Nullable error) {
                NSLog(@"ReloadContentBlockerWithIdentifier:%@ error:%@",contentBlockerIdentifier, error);
            }];
        }
    }
    else if ([message[@"type"] isEqualToString:@"fetchTagStatus"]){
        dispatch_time_t deadline = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        NSString *contentBlockerIdentifier = @"com.dajiu.stay.pro.Stay-Content-Tag-Mac";
        __block BOOL enabled;
        [SFContentBlockerManager getStateOfContentBlockerWithIdentifier:contentBlockerIdentifier completionHandler:^(SFContentBlockerState * _Nullable state, NSError * _Nullable error) {
            enabled = state.enabled;
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, deadline);
        
        [SharedStorageManager shared].extensionConfig = nil;
        NSNumber *tagStatus = [SharedStorageManager shared].extensionConfig.tagStatus;
            
        body = @{
            @"enabled" : @(enabled),
            @"tag_status" : tagStatus
        };
    }
    else if ([message[@"type"] isEqualToString:@"fetchTagRules"]){
        NSString *url = message[@"url"];
        NSUInteger urlLength = url.length;
        NSError *error;
        NSMutableArray *rules = [[NSMutableArray alloc] init];
        NSArray *jsonArray = [[ContentFilterManager shared] ruleJSONArray:@"Tag.json" error:&error];
        for (NSDictionary *rule in jsonArray){
            NSString *urlFilter = rule[@"trigger"][@"url-filter"];
            urlFilter = [urlFilter stringByReplacingOccurrencesOfString:@"\\" withString:@""];
            NSRegularExpression *expression = [[NSRegularExpression alloc] initWithPattern:urlFilter options:0 error:nil];
            NSArray *results = [expression matchesInString:url options:0 range:NSMakeRange(0, urlLength)];
            if (results.count > 0){
                NSString *selector = rule[@"action"][@"selector"];
                if (selector.length > 0){
                    NSString *urlAndSelector = [NSString stringWithFormat:@"%@%@",urlFilter,selector];
                    [rules addObject:@{
                        @"uuid":[urlAndSelector md5],
                        @"url-filter": urlFilter,
                        @"selector": selector
                    }];
                }
            }
        }
        
        body = @{
            @"rules":rules
        };
    }
    else if ([message[@"type"] isEqualToString:@"deleteTagRule"]){
        NSString *targetUUID = message[@"uuid"];
        
        NSString *content = [[ContentFilterManager shared] ruleText:@"Tag.txt" error:nil];
        NSMutableString *newContent = [[NSMutableString alloc] init];
        if (content.length > 0){
            NSArray<NSString *> *lines = [content componentsSeparatedByString:@"\n"];
            for (NSString *line in lines){
                NSString *newLine = [line stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                if (newLine.length > 0){
                    if ([newLine hasPrefix:@"!"]){
                        [newContent appendFormat:@"%@\n",newLine];
                    }
                    else{
                        NSArray<NSString *> *urlFilterAndSelector = [newLine componentsSeparatedByString:@"##"];
                        if (urlFilterAndSelector.count == 2){
                            NSString *urlFilter = [urlFilterAndSelector[0] stringByReplacingOccurrencesOfString:@"||" withString:@"^https?://"];
                            NSString *selector = urlFilterAndSelector[1];
                            NSString *uuid = [[NSString stringWithFormat:@"%@%@",urlFilter,selector] md5];
                            if (![uuid isEqualToString:targetUUID]){
                                [newContent appendFormat:@"%@\n",newLine];
                            }
                        }
                        else{
                            [newContent appendFormat:@"%@\n",newLine];
                        }
                    }
                }
            }
            
            NSMutableArray *jsonArray = [NSMutableArray arrayWithArray:[[ContentFilterManager shared] ruleJSONArray:@"Tag.json" error:nil]];
            
            for (int i = 0; i < jsonArray.count; i++){
                NSDictionary *rule = jsonArray[i];
                NSString *urlFilter = rule[@"trigger"][@"url-filter"];
                urlFilter = [urlFilter stringByReplacingOccurrencesOfString:@"\\" withString:@""];
                NSString *selector = rule[@"action"][@"selector"];
                NSString *uuid = [[NSString stringWithFormat:@"%@%@",urlFilter,selector] md5];
                if ([targetUUID isEqualToString:uuid]){
                    [jsonArray removeObjectAtIndex:i];
                    i--;
                }
            }
            
            [[ContentFilterManager shared] writeTextToFileName:@"Tag.txt" content:newContent error:nil];
            [[ContentFilterManager shared] writeJSONToFileName:@"Tag.json" array:jsonArray error:nil];
            
            NSString *contentBlockerIdentifier = @"com.dajiu.stay.pro.Stay-Content-Tag-Mac";
            [SFContentBlockerManager reloadContentBlockerWithIdentifier:contentBlockerIdentifier completionHandler:^(NSError * _Nullable error) {
                NSLog(@"ReloadContentBlockerWithIdentifier:%@ error:%@",contentBlockerIdentifier, error);
            }];
        }
    }

    response.userInfo = @{ SFExtensionMessageKey: @{ @"type": message[@"type"],
                                                     @"body": body == nil ? [NSNull null]:body,
                                                    }
    };
    [context completeRequestReturningItems:@[ response ] completionHandler:nil];
}

- (NSDictionary *)scriptV2Handler:(NSDictionary *)message{
    NSString *type = message[@"type"];
    if ([type isEqualToString:@"script.v2.getInjectFiles"]){
        NSString *url = message[@"url"];
        BOOL isTop = [message[@"isTop"] boolValue];
        
        NSMutableArray *jsFiles = [[NSMutableArray alloc] init];
        NSString *scriptHandler = @"stay";
        NSString *scriptHandlerVersion = [self handlerVersion];
        [SharedStorageManager shared].userscriptHeaders = nil;
        NSMutableArray<NSDictionary *> *datas = [NSMutableArray arrayWithArray:[SharedStorageManager shared].userscriptHeaders.content];
        
        for(int i = 0;i < datas.count; i++) {
            NSDictionary *data = datas[i];
            
            BOOL noFrames = [data[@"noFrames"] boolValue];
            if (noFrames && !isTop){
                [datas removeObjectAtIndex:i--];
                continue;
            }
            
            if (![data[@"active"] boolValue] || ![self matchesCheck:data url:url]){
                [datas removeObjectAtIndex:i--];
                continue;
            }
            
            NSString *disabledUrl = nil;
            if ((disabledUrl = [self disabledWebsitesCheck:data url:url]) != nil){
                [datas removeObjectAtIndex:i--];
                continue;
            }
            
            NSString *requiredScripts = [self getRequiredScriptsWithUUID:data];
            
            NSDictionary *scriptMeta  = @{
                @"description": data[@"description"],
                @"excludes": data[@"excludes"],
                @"includes": data[@"includes"],
                @"matches": data[@"matches"],
                @"name": data[@"name"],
                @"namespace": data[@"namespace"],
                @"resources": data[@"resourceUrls"],
                @"run-at": data[@"runAt"],
                @"version": data[@"version"]
            };
            
            NSMutableDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:scriptMeta];
            
            [metadata addEntriesFromDictionary:@{
                @"grants": data[@"grants"],
                @"icon": data[@"iconUrl"],
                @"locales": data[@"locales"],
                @"inject-into": [data[@"injectInto"] lowercaseString],
                @"noframes": data[@"noFrames"]
            }];
            
            NSString *scriptMetaStr = [[NSString alloc] initWithData:
                                       [NSJSONSerialization dataWithJSONObject:scriptMeta options:0 error:nil]
                                                            encoding:NSUTF8StringEncoding];
            
            UserscriptInfo *info = [self getInfoWithUUID:data[@"uuid"]];
            
            NSDictionary *script = @{
                @"uuid": data[@"uuid"],
                @"metadata": metadata,
                @"requiredScripts": requiredScripts,
                @"code": info.content[@"content"],
                @"type": @"js",
                @"scriptMetaStr": scriptMetaStr ? scriptMetaStr : @""
            };
            
            [jsFiles addObject:script];
            
            NSNumber *number = [SharedStorageManager shared].runsRecord.contentDic[data[@"uuid"]];
            [SharedStorageManager shared].runsRecord.contentDic[data[@"uuid"]] = number ? @(number.integerValue+1) : @(1);
            [[SharedStorageManager shared].runsRecord flush];
        }
       
        [SharedStorageManager shared].extensionConfig = nil;
        return @{
            @"showBadge" : @([SharedStorageManager shared].extensionConfig.showBadge),
            @"scriptHandler": scriptHandler,
            @"scriptHandlerVersion": scriptHandlerVersion,
            @"jsFiles": jsFiles
        };
    }
    
    return nil;
}

- (NSDictionary *)xmlHttpRequestProxy:(NSDictionary *)details{
    if (nil == details) return @{@"status":@(500), @"responseText":@""};
    NSString *method = details[@"method"];
    NSString *url = details[@"url"];
    NSDictionary *headers = details[@"headers"];
    NSString *data = details[@"data"];
    NSString *overrideMimeType = details[@"overrideMimeType"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:method];
    if (headers != nil && [headers isKindOfClass:[NSDictionary class]]){
        for (NSString *key in headers.allKeys){
            [request setValue:headers[key] forHTTPHeaderField:key];
        }
    }
    
    if (overrideMimeType.length == 0){
        overrideMimeType = @"text/xml";
    }
    
    [request setValue:overrideMimeType forHTTPHeaderField:@"Content-Type"];
    
    if (![data isKindOfClass:[NSNull class]] && data.length > 0){
        [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    
    __block NSInteger status = 200;
    __block NSString *statusText = @"";
    __block NSString *responseText = @"";
    __block NSString *type = @"";
    __block NSString *responseData = @"";
    __block NSString *responseType = @"";
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        status = httpResponse.statusCode;
        statusText = [NSHTTPURLResponse localizedStringForStatusCode:status];
        if (nil == error){
            type = [httpResponse allHeaderFields][@"Content-Type"];
            if ([type hasPrefix:@"image/"]
                ||[type hasPrefix:@"video/"]){
                NSString *base64Encoded = [data base64EncodedStringWithOptions:0];
                responseData = [NSString stringWithFormat:@"data:%@;base64,%@",type,base64Encoded];
                responseType = @"blob";
            }
            else{
                responseText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
        }
        
        dispatch_semaphore_signal(sem);

        }] resume];
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    return @{
        @"status":@(status),
        @"statusText":statusText,
        @"responseText":responseText,
        @"data":responseData,
        @"type":type,
        @"responseType":responseType
    };
}

- (NSString *)getContentWithUUID:(NSString *)uuid{
    UserscriptInfo *info = [[SharedStorageManager shared] getInfoOfUUID:uuid];
    return info.content[@"content"];
}

- (UserscriptInfo *)getInfoWithUUID:(NSString *)uuid{
    return [[SharedStorageManager shared] getInfoOfUUID:uuid];
}

- (NSString *)getRequiredScriptsWithUUID:(NSDictionary *)script{
    if (script[@"requireUrls"] == nil) return @"";
    NSArray *array = script[@"requireUrls"];
    NSMutableString *requiredScripts = [[NSMutableString alloc] initWithString:@""];
    for (int i = 0; i < array.count; i++){
        NSString *requireUrl = array[i];
        if ([requireUrl hasPrefix:@"stay://vendor"]){
            continue;
        }
        NSString *fileName = requireUrl.lastPathComponent;
        NSString *storageUrl = [NSString stringWithFormat:@"%@/%@/require/%@",self.sharedGroupPath,script[@"uuid"],fileName];
        if(![[NSFileManager defaultManager] fileExistsAtPath:storageUrl]) {
            continue;
        }
        
        NSString *requiredScript = [NSString stringWithContentsOfFile:storageUrl encoding:NSUTF8StringEncoding error:nil];
        if (requiredScript.length > 0){
            [requiredScripts appendString:requiredScript];
            [requiredScripts appendString:@"\n"];
        }
    }
    
    return requiredScripts;
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
            if ([requireUrl hasPrefix:@"stay://vendor"]){
                continue;
            }
            NSString *fileName = requireUrl.lastPathComponent;
            NSString *strogeUrl = [NSString stringWithFormat:@"%@/%@/require/%@",groupPath,scrpit[@"uuid"],fileName];
            if(![[NSFileManager defaultManager] fileExistsAtPath:strogeUrl]) {
                continue;
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


- (NSString *)handlerVersion{
    if (nil == _handlerVersion){
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        _handlerVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    }
    
    return _handlerVersion;
}

- (NSString *)sharedGroupPath{
    if (nil == _sharedGroupPath){
        _sharedGroupPath = [[[NSFileManager defaultManager]
                             containerURLForSecurityApplicationGroupIdentifier:@"group.com.dajiu.stay.pro"] path];
    }
    
    return _sharedGroupPath;
}

- (void)stateOfExtension{
//    [SFSafariApplication get]
    [SFSafariExtensionManager getStateOfSafariExtensionWithIdentifier:@"com.dajiu.stay.pro.Mac-Extension" completionHandler:^(SFSafariExtensionState * _Nullable state, NSError * _Nullable error) {
        
    }];
}

@end
