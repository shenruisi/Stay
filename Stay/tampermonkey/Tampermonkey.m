//
//  Tampermonkey.m
//  Stay
//
//  Created by ris on 2021/11/17.
//

#import "Tampermonkey.h"
#import "SYVersionUtils.h"


@interface Tampermonkey()

@property (nonatomic, strong) JSContext *jsContext;
@property (nonatomic, strong) NSSet<NSString *> *windowProperties;
@property (nonatomic, strong) NSSet<NSString *> *windowMethods;
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
        NSString *scriptWithoutComment = [self _removeComment:scriptContent];
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
        
        if (userScript.stayEngine.length > 0 && [SYVersionUtils compareVersion:userScript.stayEngine toVersion:[self appVersion]]){
            userScript.pass = NO;
            userScript.errorCode = 1000;
            userScript.errorMessage = [NSString stringWithFormat:NSLocalizedString(@"StayEngineError", @""),userScript.stayEngine];
        }
    }
    else {
        if (userScript.pass){
            if (userScript.stayEngine.length > 0 && [SYVersionUtils compareVersion:userScript.stayEngine toVersion:[self appVersion]] > 0){
                userScript.pass = NO;
                userScript.errorCode = 1000;
                userScript.errorMessage = [NSString stringWithFormat:NSLocalizedString(@"StayEngineError", @""),userScript.stayEngine];
            }
        }
        else{
            userScript.errorCode = 500;
        }
        
    }
    
    return userScript;
}

- (NSString *)appVersion{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}


- (void)conventScriptContent:(UserScript *)userScript{
    NSString *scriptWithoutComment = [self _removeComment:userScript.content];
    JSValue *createGMApisWithUserScript = [self.jsContext evaluateScript:@"window.createGMApisWithUserScript"];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];

    if (userScript.injectInto.length == 0 || [[userScript.injectInto lowercaseString] isEqualToString:@"auto"]){
        BOOL pageMode = [userScript.grants containsObject:@"unsafeWindow"];
        userScript.installType = pageMode ? @"page" : @"content";
        
        if (![userScript.installType isEqualToString:@"page"] && [self usedCustomWindowPropertyOrMethod:scriptWithoutComment name:userScript.name]){
            userScript.installType = @"page";
        }
        
        if ([self containsUnsafeWindow:scriptWithoutComment name:userScript.name]){
            NSMutableArray *newGrants = [NSMutableArray arrayWithArray:userScript.grants];
            [newGrants addObject:@"unsafeWindow"];
            userScript.grants = newGrants;
            userScript.installType = @"page";
        }
        
        if (![userScript.installType isEqualToString:@"page"] && [self isES6:scriptWithoutComment name:userScript.name]){
            userScript.installType = @"page";
        }
    }
    else{
        userScript.installType = [userScript.injectInto lowercaseString];
    }
    
    if ([self needInjectBuiltinJQuery:scriptWithoutComment name:userScript.name uuid:userScript.uuid]){
        if (![userScript.requireUrls containsObject:@"stay://vendor/jquery.min.js"]){
            NSMutableArray *newRequireUrls = [[NSMutableArray alloc] initWithArray:userScript.requireUrls];
            [newRequireUrls insertObject:@"stay://vendor/jquery.min.js" atIndex:0];
            userScript.requireUrls = newRequireUrls;
        }
    }
    
    
    JSValue *apiSource = [createGMApisWithUserScript callWithArguments:@[userScript.toDictionary,userScript.uuid,appVersion,scriptWithoutComment,userScript.installType]];
    
    if ([userScript.installType isEqualToString:@"page"]){
        userScript.parsedContent = [NSString stringWithFormat:
                                    @"async function stay_script_%@(){\n\t%@\n\t%@\n}\nstay_script_%@();\n",
                                    [userScript.uuid stringByReplacingOccurrencesOfString:@"-" withString:@"_"],apiSource,scriptWithoutComment,[userScript.uuid stringByReplacingOccurrencesOfString:@"-" withString:@"_"]];
        userScript.otherContent = [NSString stringWithFormat:
                                   @"async function gm_init(){\n\t%@\n\t%@\n}\ngm_init().catch((e)=>browser.runtime.sendMessage({ from: 'gm-apis', operate: 'GM_error', message: e.message, uuid:'%@'}));\n"
                                   ,apiSource,scriptWithoutComment,userScript.uuid];
    }
    else{
        userScript.parsedContent = [NSString stringWithFormat:
                                    @"async function gm_init(){\n\t%@\n\t%@\n}\ngm_init().catch((e)=>browser.runtime.sendMessage({ from: 'gm-apis', operate: 'GM_error', message: e.message, uuid:'%@'}));\n"
                                    ,apiSource,scriptWithoutComment,userScript.uuid];
    }
}

- (BOOL)needInjectBuiltinJQuery:(NSString *)script name:(NSString *)name uuid:(NSString *)uuid{
    if ([[self explictNotInjectJQueryList] containsObject:uuid]){
        return NO;
    }
    NSRegularExpression *jqueryExpr = [[NSRegularExpression alloc] initWithPattern:@"(\\$[\\.a-zA-z]*)\\(+" options:0 error:nil];
    NSArray<NSTextCheckingResult *> *results = [jqueryExpr matchesInString:script options:0 range:NSMakeRange(0, script.length)];
    if (results.count > 0){
        NSRegularExpression *requiredjQueryExpr = [[NSRegularExpression alloc] initWithPattern:@"\\/\\/\\s*@require\\s+.*\\/(jquery[^a-zA-Z]*)[.min]*.js" options:0 error:nil];
        results = [requiredjQueryExpr  matchesInString:script options:0 range:NSMakeRange(0, script.length)];
        return results.count == 0;
    }
    return NO;
}

- (NSArray *)explictNotInjectJQueryList{
    return @[@"70178DD295CDA688CD996F65C573FF3C",@"3E1B1AFFA1FB63E8A5AE8ED3422079F2"];
}

- (BOOL)isES6:(NSString *)script name:(NSString *)name{
    NSRegularExpression *es6Expr = [[NSRegularExpression alloc] initWithPattern:@"(\\.\\.\\.\\w+)" options:0 error:nil];
    NSArray<NSTextCheckingResult *> *results = [es6Expr matchesInString:script options:0 range:NSMakeRange(0, script.length)];
    return results.count > 0;
}

- (BOOL)containsUnsafeWindow:(NSString *)script name:(NSString *)name{
    NSRegularExpression *unsafeWindowExpr = [[NSRegularExpression alloc] initWithPattern:@"(unsafeWindow\\.[a-zA-z]+)\\(*" options:0 error:nil];
    NSArray<NSTextCheckingResult *> *results = [unsafeWindowExpr matchesInString:script options:0 range:NSMakeRange(0, script.length)];
    return results.count > 0;
}

- (BOOL)usedCustomWindowPropertyOrMethod:(NSString *)script name:(NSString *)name{
    NSRegularExpression *windowExpr = [[NSRegularExpression alloc] initWithPattern:@"(window\\.[a-zA-z]+)\\(*" options:0 error:nil];
    NSArray<NSTextCheckingResult *> *results = [windowExpr matchesInString:script options:0 range:NSMakeRange(0, script.length)];
    for (NSTextCheckingResult *result in results){
        NSInteger n = result.numberOfRanges;
        for (int i = 1; i < n; i++){
            NSString *windowPM = [script substringWithRange:[result rangeAtIndex:i]];
            if (![self.windowProperties containsObject:windowPM]
                && ![self.windowMethods containsObject:windowPM]){
                NSLog(@"windowPM,%@ %@",name,windowPM);
                return YES;
            }
        }
    }
    
    return NO;
}

- (NSSet<NSString *> *)windowProperties{
    return [NSSet setWithArray:@[
        @"window.clientInformation",
        @"window.navigator",
        @"window.closed",
        @"window.console",
        @"window.customElements",
        @"window.crypto",
        @"window.devicePixelRatio",
        @"window.document",
        @"window.event",
        @"window.external",
        @"window.frameElement",
        @"window.frames",
        @"window.fullScreen",
        @"window.history",
        @"window.innerHeight",
        @"window.innerWidth",
        @"window.length",
        @"window.frames",
        @"window.location",
        @"window.locationbar",
        @"window.localStorage",
        @"window.menubar",
        @"window.messageManager",
        @"window.mozInnerScreenX",
        @"window.mozInnerScreenY",
        @"window.name",
        @"window.navigator",
        @"window.opener",
        @"window.outerHeight",
        @"window.outerWidth",
        @"window.pageXOffset",
        @"window.pageYOffset",
        @"window.parent",
        @"window.performance",
        @"window.personalbar",
        @"window.screen",
        @"window.screenX",
        @"window.screenY",
        @"window.scrollbars",
        @"window.scrollMaxX",
        @"window.scrollMaxY",
        @"window.scrollX",
        @"window.scrollY",
        @"window.self",
        @"window.sessionStorage",
        @"window.sidebar",
        @"window.speechSynthesis",
        @"window.status",
        @"window.statusbar",
        @"window.toolbar",
        @"window.top",
        @"window.visualViewport",
        @"window.window",
        @"window.content",
        @"window.defaultStatus",
        @"window.orientation",
        @"window.returnValue",
        @"window.opera",
        @"window.self",
        @"window.onload",
        @"window.MutationObserver",
        @"window.WebKitMutationObserver",
        @"window.MozMutationObserver"
    ]];
}

- (NSSet<NSString *> *)windowMethods{
    return [NSSet setWithArray:@[
        @"window.alert",
        @"window.blur",
        @"window.cancelAnimationFrame",
        @"window.cancelIdleCallback",
        @"window.clearImmediate",
        @"window.close",
        @"window.confirm",
        @"window.dump",
        @"window.find",
        @"window.focus",
        @"window.getComputedStyle",
        @"window.getDefaultComputedStyle",
        @"window.getSelection",
        @"window.matchMedia",
        @"window.moveBy",
        @"window.moveTo",
        @"window.open",
        @"window.postMessage",
        @"window.print",
        @"window.prompt",
        @"window.requestAnimationFrame",
        @"window.requestIdleCallback",
        @"window.resizeBy",
        @"window.resizeTo",
        @"window.scroll",
        @"window.scrollBy",
        @"window.scrollByLines",
        @"window.scrollByPages",
        @"window.scrollTo",
        @"window.setImmediate",
        @"window.setResizable",
        @"window.sizeToContent",
        @"window.showOpenFilePicker",
        @"window.showSaveFilePicker",
        @"window.showDirectoryPicker",
        @"window.stop",
        @"window.updateCommands",
        @"window.back",
        @"window.captureEvents",
        @"window.forward",
        @"window.home",
        @"window.openDialog",
        @"window.releaseEvents",
        @"window.showModalDialog",
        @"window.dispatchEvent",
        @"window.addEventListener",
        @"window.removeEventListener",
        @"window.setTimeout",
        @"window.XMLHttpRequest",
        @"window.GM_openInTab",
        @"window.onurlchange"
    ]];
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
