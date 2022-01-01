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
        [preferences setValue:@YES forKey:@"allowFileAccessFromFileURLs"];
        [config setPreferences:preferences];

        WKUserContentController * wkUController = [[WKUserContentController alloc] init];

        config.userContentController = wkUController;
        
        _wkwebView = [[WKWebView alloc] initWithFrame:CGRectMake(0.0,0.0,kScreenWidth,self.height) configuration:config];
        _wkwebView.UIDelegate = self;
        _wkwebView.navigationDelegate = self;
        _wkwebView.allowsBackForwardNavigationGestures = YES;
    
        [_wkwebView.configuration.userContentController addScriptMessageHandler:self  name:@"contentGet"];
        [_wkwebView.configuration.userContentController addScriptMessageHandler:self  name:@"contentComplete"];
        [_wkwebView.configuration.userContentController addScriptMessageHandler:self  name:@"revocationAction"];
        [_wkwebView.configuration.userContentController addScriptMessageHandler:self  name:@"forwardAction"];
        [_wkwebView.configuration.userContentController addScriptMessageHandler:self  name:@"clearAction"];
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
            [self initScrpitContent:false];
        } else {
           UserScript *userScript =  [[Tampermonkey shared] parseWithScriptContent:self.content];
           if(userScript != nil && userScript.name != nil) {
               [[DataManager shareManager] insertUserConfigByUserScript:userScript];
               [self initScrpitContent:true];
           } else {
               [self initScrpitContent:false];
           }

        }
    }];
}

- (void)updateContent{
    [_wkwebView evaluateJavaScript:@"getCode()" completionHandler:^(id _Nullable, NSError * _Nullable error) {
        if(error != nil) {
            [self initScrpitContent:false];
        } else {
           UserScript *userScript =  [[Tampermonkey shared] parseWithScriptContent:self.content];
           userScript.uuid = self.uuid;
           userScript.active = self.active;
           if(userScript != nil && userScript.name != nil) {
               [[DataManager shareManager] updateUserScript:userScript];
               [self initScrpitContent:true];
           } else {
               [self initScrpitContent:false];
           }
        }
    }];
}

- (void)undo {
    [_wkwebView evaluateJavaScript:@"revocationAction()" completionHandler:^(id _Nullable, NSError * _Nullable error) {
      
    }];
}
- (void)redo {
    [_wkwebView evaluateJavaScript:@"forwardAction()" completionHandler:^(id _Nullable, NSError * _Nullable error) {
    
    }];
}

- (void)clearAll {
    [_wkwebView evaluateJavaScript:@"clearAction()" completionHandler:^(id _Nullable, NSError * _Nullable error) {

    }];
}

- (void)changeContent:(NSString *) jsContent {
    NSString *script = [NSString stringWithFormat:@"setCode(\"%@\")",[jsContent encodeString]];
    [_wkwebView evaluateJavaScript:script completionHandler:^(id _Nullable, NSError * _Nullable error) {
        if(error != nil) {
            NSLog(error.description);
        }
    }];
}
- (void)initScrpitContent:(BOOL)success{
    if(success) {
        NSNotification *notification = [NSNotification notificationWithName:@"saveSuccess" object:nil];
        [[NSNotificationCenter defaultCenter]postNotification:notification];
    } else {
        NSNotification *notification = [NSNotification notificationWithName:@"saveError" object:nil];
        [[NSNotificationCenter defaultCenter]postNotification:notification];
    }
}

@end
