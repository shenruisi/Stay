//
//  SYCodeMirrorView.m
//  Stay
//
//  Created by zly on 2021/12/10.
//

#import "SYCodeMirrorView.h"
#import "Tampermonkey.h"
#import "DataManager.h"

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

        NSString *htmlString = [[NSBundle mainBundle] pathForResource:@"newTab" ofType:@"html"];

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
          
        } else {
           UserScript *userScript =  [[Tampermonkey shared] parseNormalScript:self.content];
           if(userScript != nil) {
               [[DataManager shareManager] insertUserConfigByUserScript:userScript];
           }

        }
    }];
}

- (void)updateContent{
    [_wkwebView evaluateJavaScript:@"getCode()" completionHandler:^(id _Nullable, NSError * _Nullable error) {
        if(error != nil) {
            NSLog(error.description);
        } else {
           UserScript *userScript =  [[Tampermonkey shared] parseNormalScript:self.content];
           userScript.uuid = self.uuid;
           if(userScript != nil) {
               [[DataManager shareManager] updateUserScript:userScript];
           }
        }
    }];
}

- (void)changeContent:(NSString *) jsContent {
    jsContent = [jsContent stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    jsContent = [jsContent stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
    jsContent = [jsContent stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n\\\n"];
    NSString *script = [NSString stringWithFormat:@"setCode(\"%@\")",jsContent];
    [_wkwebView evaluateJavaScript:script completionHandler:^(id _Nullable, NSError * _Nullable error) {
        if(error != nil) {
            NSLog(error.description);
        }
    }];
}


@end
