//
//  Tampermonkey.m
//  Stay
//
//  Created by ris on 2021/11/17.
//

#import "Tampermonkey.h"


@interface Tampermonkey()

@property (nonatomic, strong) JSContext *jsContext;
@end

@implementation Tampermonkey

static Tampermonkey *kInstance = nil;
+ (instancetype)shared{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (nil == kInstance){
            kInstance = [[self alloc] init];
        }
    });
    
    return kInstance;
}

- (void)nslog:(id)object{
    NSLog(@"log:\n{\nvalue: %@\ntype: %@\n}",object,[object class]);
}

- (UserScript *)parseScript:(NSString *)scriptName{
    NSString *scriptContent = [self _getScript:scriptName];
    return [self parseWithScriptContent:scriptContent];
}

//Enter
- (UserScript *)parseWithScriptContent:(NSString *)scriptContent{
    JSValue *parseUserScript = [self.jsContext evaluateScript:@"window.parseUserScript"];
    JSValue *userScriptHeader = [parseUserScript callWithArguments:@[scriptContent,@""]];
    
    UserScript *userScript = [UserScript ofDictionary:[userScriptHeader toDictionary]];
    userScript.uuid = [[NSUUID UUID] UUIDString];
    userScript.content = scriptContent;
    
    //Check if unsupported grants api really used in content.
    if (userScript.pass && userScript.unsupportedGrants.count > 0){
        NSString *scriptWithoutComment = [self _removeComment:userScript.content];
        NSMutableString *builder = [[NSMutableString alloc] initWithString:@"("];
        
        for (int i = 0; i < userScript.unsupportedGrants.count; i++){
            NSString *unsupportedGrant = userScript.unsupportedGrants[i];
            if (i != userScript.unsupportedGrants.count - 1){
                [builder appendFormat:@"%@|",unsupportedGrant];
            }
            else{
                [builder appendFormat:@"%@)",unsupportedGrant];
            }
        }
        
        NSRegularExpression *unsupportedGrantsExpr = [[NSRegularExpression alloc] initWithPattern:builder options:0 error:nil];
        NSArray<NSTextCheckingResult *> *results = [unsupportedGrantsExpr matchesInString:scriptWithoutComment options:0 range:NSMakeRange(0, scriptWithoutComment.length)];
        if (results.count > 0){
            userScript.pass = NO;
            NSMutableString *errorMessage = [[NSMutableString alloc] initWithString:userScript.errorMessage ? userScript.errorMessage : @""];
            for (NSString *unsupportedGrant in userScript.unsupportedGrants){
                [errorMessage appendFormat:@"Unsupport grant api %@\n",unsupportedGrant];
            }
            userScript.errorMessage = errorMessage;
        }
        
    }
    
    return userScript;
}


- (void)conventScriptContent:(UserScript *)userScript{
    NSString *scriptWithoutComment = [self _removeComment:userScript.content];
    JSValue *createGMApisWithUserScript = [self.jsContext evaluateScript:@"window.createGMApisWithUserScript"];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];

    BOOL pageMode = [userScript.grants containsObject:@"unsafeWindow"];
    userScript.installType = pageMode ? @"page" : @"content";
    
    JSValue *gmApisSource = [createGMApisWithUserScript callWithArguments:@[userScript.toDictionary,userScript.uuid,appVersion,scriptWithoutComment,userScript.installType]];
    
    if ([userScript.installType isEqualToString:@"page"]){
        scriptWithoutComment = [NSString stringWithFormat:
                                @"async function stay_script_%@(){\n\t%@\n\t%@\n}\nstay_script_%@();\n",
                                [userScript.uuid stringByReplacingOccurrencesOfString:@"-" withString:@"_"],gmApisSource,scriptWithoutComment,[userScript.uuid stringByReplacingOccurrencesOfString:@"-" withString:@"_"]];
    }
    else{
        scriptWithoutComment = [NSString stringWithFormat:
                                @"async function gm_init(){\n\t%@\n\t%@\n}\ngm_init().catch((e)=>browser.runtime.sendMessage({ from: 'gm-apis', operate: 'GM_error', message: e.message, uuid:'%@'}));\n"
                                ,gmApisSource,scriptWithoutComment,userScript.uuid];
    }
    
    userScript.parsedContent = scriptWithoutComment;
}



- (NSString *)_removeComment:(NSString *)script{
    NSString *process = [script copy];
    
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"((?<!:)\\/\\/.*|\\/\\*(\\s|.)*?\\*\\/)" options:NSRegularExpressionAnchorsMatchLines error:NULL];
    
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\/\\*[\\s\\S]*?\\*\\/|([^\\\\:]|^)\\/\\/.*$" options:NSRegularExpressionAnchorsMatchLines error:NULL];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^\\/\\/.*" options:NSRegularExpressionAnchorsMatchLines error:NULL];
    
    process = [regex stringByReplacingMatchesInString:process
                                              options:0
                                                range:NSMakeRange(0, process.length)
                                         withTemplate:@""];
    
    process = [process stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    return process;
}

- (JSContext *)jsContext{
    if (nil == _jsContext){
        //init js from lib
        NSArray *files = @[
            @"stay-bootstrap",
            @"gm-api-create",
            @"supported-apis",
            @"convert2RegExp",
            @"MatchPattern",
            @"parse-meta-line",
            @"parse-user-script"
        ];
        _jsContext = [[JSContext alloc] initWithVirtualMachine:[[JSVirtualMachine alloc] init]];
        _jsContext[@"native"] = self;
        for (NSString *file in files){
            [_jsContext evaluateScript:[self _getScript:file]];
        }
        
    }
    
    return _jsContext;
}

- (NSString *)_getScript:(NSString *)scriptName{
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:scriptName ofType:@"js"]];
    return [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
}

@end
