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
#import "SharedStorageManager.h"
#import "API.h"
#import "FCShared.h"
#import <Speech/Speech.h>

@interface SafariWebExtensionHandler()<SFSpeechRecognizerDelegate>

@property (nonatomic, strong) SFSpeechRecognizer *speechRecognizer;
@property (nonatomic, strong) SFSpeechURLRecognitionRequest *recognitionRequest;
@property (nonatomic, strong) SFSpeechRecognitionTask *recognitionTask;
@end

@implementation SafariWebExtensionHandler

- (instancetype)init{
    if (self = [super init]){
        self.speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en-US"]];
        self.speechRecognizer.delegate = self;
//        [self requestSpeechAuthorization];
//        [self startRecognition];
    }
    
    return self;
}

- (void)requestSpeechAuthorization:(NSData *)data{
//    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (status == SFSpeechRecognizerAuthorizationStatusAuthorized) {
//                [self startRecognition:data];
//            }
//        });
//    }];
    
    [self startRecognition:data];
}

- (void)startRecognition:(NSData *)data{
    NSString * audioFilePath =[FCSharedDirectory() stringByAppendingPathComponent:@"gpt.m4a"];
    NSError *error;
    BOOL success = [data writeToFile:audioFilePath options:0 error:&error];
    if (!success) {
        NSLog(@"Failed to write audio data to disk");
        return;
    }
    NSURL *audioFileURL = [NSURL fileURLWithPath:audioFilePath];
    self.recognitionRequest = [[SFSpeechURLRecognitionRequest alloc] initWithURL:audioFileURL];
    self.recognitionTask = [self.speechRecognizer recognitionTaskWithRequest:self.recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        if (result) {
            NSString *result1 = result.bestTranscription.formattedString;
            NSLog(@"Recognition result: %@", result.bestTranscription.formattedString);
        }

        if (error || result.isFinal) {
            self.recognitionTask = nil;
            self.recognitionRequest = nil;
        }
    }];
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
    BOOL matched = NO;
    
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
    if ([message[@"type"] isEqualToString:@"fetchScripts"]){
        [SharedStorageManager shared].userDefaults.safariExtensionEnabled = YES;
        NSString *url = message[@"url"];
        NSString *digest = message[@"digest"];
        BOOL requireCompleteScript = digest.length == 0 || [digest isEqualToString:@"no"];
        [SharedStorageManager shared].userscriptHeaders = nil;
        [SharedStorageManager shared].runsRecord = nil;
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
    else if ([message[@"type"] isEqualToString:@"setDisabledWebsites"]){
        NSMutableArray<NSDictionary *> *datas = [NSMutableArray arrayWithArray:[SharedStorageManager shared].userscriptHeaders.content];
        NSString *uuid = message[@"uuid"];
        NSString *disabledUrl = message[@"disabledUrl"];
        BOOL on = [message[@"on"] boolValue];
        NSMutableArray *disabledWebsites = [[NSMutableArray alloc] init];
        if (datas != NULL && datas.count > 0) {
            for(int i = 0; i < datas.count;i++) {
                NSDictionary *dic = datas[i];
                if([dic[@"uuid"] isEqualToString:uuid]) {
                    NSMutableDictionary *mdic = [NSMutableDictionary dictionaryWithDictionary:dic];
                    disabledWebsites = [NSMutableArray arrayWithArray:[mdic objectForKey:@"disabledWebsites"]];
                    if (on){
                        if (![disabledWebsites containsObject:disabledUrl]){
                            [disabledWebsites addObject:disabledUrl];
                        }
                    }
                    else{
                        if ([disabledWebsites containsObject:disabledUrl]){
                            [disabledWebsites removeObject:disabledUrl];
                        }
                    }
                    
                    [mdic setValue:disabledWebsites forKey:@"disabledWebsites"];
                    [datas replaceObjectAtIndex:i withObject:mdic];
                    [SharedStorageManager shared].userscriptHeaders.content = datas;
                    [[SharedStorageManager shared].userscriptHeaders flush];
                    break;
                }
            }
        }
        
        
        NSMutableDictionary<NSString *,NSArray *> *changed = [NSMutableDictionary dictionaryWithDictionary:[SharedStorageManager shared].disabledWebsites.contentDic];
        changed[uuid] = disabledWebsites;
        [SharedStorageManager shared].disabledWebsites.contentDic = changed;
        [[SharedStorageManager shared].disabledWebsites flush];
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
        NSDictionary *response = [[API shared] downloadYoutube:path];
        NSString *code;
        if ((code = response[@"biz"][@"code"]) != nil){
            body = @{
                @"code" : code
            };
        }
    }
    else if ([message[@"type"] isEqualToString:@"yt_element_ci"]){
        NSString *path = message[@"path"];
        NSString *code = message[@"code"];
        if (path.length > 0 && code.length > 0){
            [[API shared] commitYoutbe:path code:code];
        }
    }
    else if ([message[@"type"] isEqualToString:@"ST_speechToText"]){
        NSString *audioStr = message[@"data"];
        audioStr = [audioStr stringByReplacingOccurrencesOfString:@"data:audio/ogg; codecs=opus;base64," withString:@""];
        NSData *data = [[NSData alloc] initWithBase64EncodedString:audioStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
        [self requestSpeechAuthorization:data];
        NSLog(@"%@",data);
    }

    response.userInfo = @{ SFExtensionMessageKey: @{ @"type": message[@"type"],
                                                     @"body": body == nil ? [NSNull null]:body,
                                                    }
    };
    [context completeRequestReturningItems:@[ response ] completionHandler:nil];
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
        if ([response isKindOfClass:[NSHTTPURLResponse class]]){
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

- (NSString *)getOtherContentWithUUID:(NSString *)uuid{
    UserscriptInfo *info = [[SharedStorageManager shared] getInfoOfUUID:uuid];
    return info.content[@"otherContent"];
}

- (UserscriptInfo *)getInfoWithUUID:(NSString *)uuid{
    return [[SharedStorageManager shared] getInfoOfUUID:uuid];
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

- (void)speechRecognitionDidDetectSpeech:(SFSpeechRecognitionTask *)task{
    
}

// Called for all recognitions, including non-final hypothesis
- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didHypothesizeTranscription:(SFTranscription *)transcription{
    
}

// Called only for final recognitions of utterances. No more about the utterance will be reported
- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didFinishRecognition:(SFSpeechRecognitionResult *)recognitionResult{
    
}


@end
