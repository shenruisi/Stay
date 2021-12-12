//
//  SYCodeMirrorView.m
//  Stay
//
//  Created by zly on 2021/12/10.
//

#import "SYCodeMirrorView.h"
#import "Tampermonkey.h"
#import "DataManager.h"
#import "NSString+Urlencode.h"

@implementation SYCodeMirrorView

+ (instancetype)shareCodeView {
    
    static SYCodeMirrorView *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[SYCodeMirrorView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        [instance addSubview:instance.wkwebView];
    });
    return instance;
    
}

- (WKWebView *)wkwebView {
    if(_wkwebView == nil) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        WKPreferences *preferences = [[WKPreferences alloc] init];
        preferences.javaScriptEnabled = true;
        [config setPreferences:preferences];

        WKUserContentController * wkUController = [[WKUserContentController alloc] init];

        config.userContentController = wkUController;
        
        _wkwebView = [[WKWebView alloc] initWithFrame:CGRectMake(0.0,0.0,kScreenWidth,self.height) configuration:config];
        _wkwebView.UIDelegate = self;
        _wkwebView.navigationDelegate = self;
        _wkwebView.allowsBackForwardNavigationGestures = YES;
        
        [_wkwebView.configuration.userContentController addScriptMessageHandler:self  name:@"contentGet"];
  
        [_wkwebView.configuration.userContentController addScriptMessageHandler:self  name:@"contentComplete"];

        NSString *htmlString = [[NSBundle mainBundle] pathForResource:@"editor" ofType:@"html"];

        NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:htmlString]];
        [_wkwebView loadData:data MIMEType:@"text/html" characterEncodingName:@"utf-8" baseURL:[NSBundle mainBundle].resourceURL];
    }

    return _wkwebView;
}


- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    if([message.name isEqualToString:@"contentGet"]){
        self.content = message.body;
    }
}

- (void)insertContent{
    [_wkwebView evaluateJavaScript:@"getCode()" completionHandler:^(id _Nullable, NSError * _Nullable error) {
        if(error != nil) {
            NSLog(error.description);
            [self initScrpitContent:false];
        } else {
           UserScript *userScript =  [[Tampermonkey shared] parseWithScriptContent:self.content];
           if(userScript != nil) {
               [[DataManager shareManager] insertUserConfigByUserScript:userScript];
               [self initScrpitContent:true];
           }

        }
    }];
}

- (void)updateContent{
    [_wkwebView evaluateJavaScript:@"getCode()" completionHandler:^(id _Nullable, NSError * _Nullable error) {
        if(error != nil) {
            NSLog(error.description);
            [self initScrpitContent:false];
        } else {
           UserScript *userScript =  [[Tampermonkey shared] parseWithScriptContent:self.content];
           userScript.uuid = self.uuid;
           userScript.active = self.active;
           if(userScript != nil) {
               [[DataManager shareManager] updateUserScript:userScript];
               [self initScrpitContent:true];
           }
        }
    }];
}

- (void)changeContent:(NSString *) jsContent {
//    jsContent = [jsContent stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
//    jsContent = [jsContent stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
//    jsContent = [jsContent stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n\\\n"];
    
    NSString *script = [NSString stringWithFormat:@"setCode(\"%@\")",[jsContent encodeString]];
    [_wkwebView evaluateJavaScript:script completionHandler:^(id _Nullable, NSError * _Nullable error) {
        if(error != nil) {
            NSLog(error.description);
        }
    }];
}
- (void)initScrpitContent:(BOOL)success{
//    NSUserDefaults *groupUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dajiu.stay.pro"];
//    NSMutableArray *array =  [[NSMutableArray alloc] init];
//    for(int i = 0; i < self.datas.count; i++) {
//        UserScript *scrpit = self.datas[i];
//        [array addObject: [scrpit toDictionary]];
//    }
//    [groupUserDefaults setObject:array forKey:@"ACTIVE_SCRIPTS"];
//    [groupUserDefaults synchronize];
    if(success) {
        NSNotification *notification = [NSNotification notificationWithName:@"saveSuccess" object:nil];
        [[NSNotificationCenter defaultCenter]postNotification:notification];
    } else {
        NSNotification *notification = [NSNotification notificationWithName:@"saveError" object:nil];
        [[NSNotificationCenter defaultCenter]postNotification:notification];
    }
}

@end
