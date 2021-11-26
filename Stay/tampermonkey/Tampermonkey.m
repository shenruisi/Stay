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
    NSString *script = [self _getScript:scriptName];
    JSValue *parseUserScript = [self.jsContext evaluateScript:@"window.parseUserScript"];
    JSValue *userScriptHeader = [parseUserScript callWithArguments:@[script,@""]];
    
    UserScript *userScript = [UserScript ofDictionary:[userScriptHeader toDictionary]];
    userScript.uuid = [[NSUUID UUID] UUIDString];
    userScript.content = script;
    NSString *scriptWithoutComment = [self _removeComment:script];
    if (userScript.grants.count > 0){ //repleace gm apis
        JSValue *createGMApisWithUserScript = [self.jsContext evaluateScript:@"window.createGMApisWithUserScript"];
        JSValue *gmApisSource = [createGMApisWithUserScript callWithArguments:@[userScript.grants,userScript.uuid]];
        scriptWithoutComment = [NSString stringWithFormat:@"async function gm_init(){\n%@%@\n}\ngm_init();\n",gmApisSource,scriptWithoutComment];
        userScript.content = scriptWithoutComment;
    }
    else{
        userScript.content = scriptWithoutComment;
    }
   
    return userScript;
}


- (void)conventScriptContent:(UserScript *)userScript{
    NSString *scriptWithoutComment = [self _removeComment:userScript.content];
    if (userScript.grants.count > 0){ //repleace gm apis
        JSValue *createGMApisWithUserScript = [self.jsContext evaluateScript:@"window.createGMApisWithUserScript"];
        JSValue *gmApisSource = [createGMApisWithUserScript callWithArguments:@[userScript.grants,userScript.uuid]];
        scriptWithoutComment = [NSString stringWithFormat:@"async function gm_init(){\n%@%@\n}\ngm_init();\n",gmApisSource,scriptWithoutComment];
    }
    userScript.parsedContent = scriptWithoutComment;
}



- (NSString *)_removeComment:(NSString *)script{
    NSString *process = [script copy];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"((?<!:)\\/\\/.*|\\/\\*(\\s|.)*?\\*\\/)" options:NSRegularExpressionAnchorsMatchLines error:NULL];
    
    process = [regex stringByReplacingMatchesInString:process
                                              options:0
                                                range:NSMakeRange(0, process.length)
                                         withTemplate:@""];
    
    process = [process stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    return process;
}

//- (NSString *)_gmApisReplaced:(NSString *)scriptWithoutComment{
//    NSString *ret;
//    ret = [scriptWithoutComment stringByReplacingOccurrencesOfString:@"GM_log" withString:[NSString stringWithFormat:@"await GM_log"]];
//    ret = [ret stringByReplacingOccurrencesOfString:@"GM_setValue" withString:[NSString stringWithFormat:@"await GM_setValue"]];
//    ret = [ret stringByReplacingOccurrencesOfString:@"GM_getValue" withString:[NSString stringWithFormat:@"await GM_getValue"]];
//    ret = [ret stringByReplacingOccurrencesOfString:@"GM_deleteValue" withString:[NSString stringWithFormat:@"await GM_deleteValue"]];
//    ret = [ret stringByReplacingOccurrencesOfString:@"GM_listValues" withString:[NSString stringWithFormat:@"await GM_deleteValue"]];
//    return ret;
//}

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
