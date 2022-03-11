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
#import "UserscriptUpdateManager.h"
#import <CommonCrypto/CommonDigest.h>



@implementation SYCodeMirrorView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.wkwebView];
        _activityIndicator =  [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0,0,100,100)];
        _activityIndicator.center = self.center;
        _activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [self addSubview:_activityIndicator];
        self.backgroundColor = [self createBgColor];
    }
    return self;
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
        _wkwebView.backgroundColor = [self createBgColor];
        _wkwebView.UIDelegate = self;
        _wkwebView.navigationDelegate = self;
        [_wkwebView setOpaque:false];
        _wkwebView.allowsBackForwardNavigationGestures = YES;
        [_wkwebView.configuration.userContentController addScriptMessageHandler:self  name:@"contentGet"];
        [_wkwebView.configuration.userContentController addScriptMessageHandler:self  name:@"contentComplete"];
        [_wkwebView.configuration.userContentController addScriptMessageHandler:self  name:@"revocationAction"];
        [_wkwebView.configuration.userContentController addScriptMessageHandler:self  name:@"forwardAction"];
        [_wkwebView.configuration.userContentController addScriptMessageHandler:self  name:@"clearAction"];
        [_wkwebView.configuration.userContentController addScriptMessageHandler:self  name:@"reDoHistoryChange"];
        [_wkwebView.configuration.userContentController addScriptMessageHandler:self  name:@"onDoHistoryChange"];
        [_wkwebView.configuration.userContentController addScriptMessageHandler:self  name:@"loadSuccess"];

        NSString *htmlString = [[NSBundle mainBundle] pathForResource:@"editor" ofType:@"html"];

        NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:htmlString]];
        [_wkwebView loadData:data MIMEType:@"text/html" characterEncodingName:@"utf-8" baseURL:[NSBundle mainBundle].resourceURL];
    }

    return _wkwebView;
}


- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    if([message.name isEqualToString:@"contentGet"]){
        self.content = message.body;
    } else if([message.name isEqualToString:@"reDoHistoryChange"]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"reDoHistoryChange" object:message.body];
    } else if([message.name isEqualToString:@"onDoHistoryChange"]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"onDoHistoryChange" object:message.body];
    } else if([message.name isEqualToString:@"loadSuccess"]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"htmlLoadSuccess" object:nil];
    }
}

- (void)insertContent{
    [_activityIndicator startAnimating];
    [_wkwebView evaluateJavaScript:@"getCode()" completionHandler:^(id _Nullable, NSError * _Nullable error) {
        if(error != nil) {
            [self initScrpitContent:false];
        } else {
           UserScript *userScript =  [[Tampermonkey shared] parseWithScriptContent:self.content];
           if(userScript != nil && userScript.errorMessage != nil && userScript.errorMessage.length <= 0) {
               NSString *uuidName = [NSString stringWithFormat:@"%@%@",userScript.name,userScript.namespace];
               NSString *uuid = [self md5HexDigest:uuidName];
               userScript.uuid = uuid;
                       
               BOOL saveSuccess = [[UserscriptUpdateManager shareManager] saveRequireUrl:userScript];
               BOOL saveResourceSuccess = [[UserscriptUpdateManager shareManager] saveResourceUrl:userScript];

               if(!saveSuccess) {
                   [self saveError:@"requireUrl下载失败,请检查后重试"];
                   return;
               }
               if(!saveResourceSuccess) {
                   [self saveError:@"resourceUrl下载失败,请检查后重试"];
                   return;
               }
               
               UserScript *tmpScript = [[DataManager shareManager] selectScriptByUuid:uuid];
               if(tmpScript != nil && tmpScript.uuid != nil) {
                   [[DataManager shareManager] updateUserScript:userScript];
               } else {
                   [[DataManager shareManager] insertUserConfigByUserScript:userScript];
               }
               [self initScrpitContent:true];
         
           } else {
               [self saveError:userScript.errorMessage];
           }
        }
    }];
}

- (void)updateContent{
    [_activityIndicator startAnimating];
    [_wkwebView evaluateJavaScript:@"getCode()" completionHandler:^(id _Nullable, NSError * _Nullable error) {
        if(error != nil) {
            [self initScrpitContent:false];
        } else {
           UserScript *userScript =  [[Tampermonkey shared] parseWithScriptContent:self.content];
           userScript.uuid = self.uuid;
           userScript.active = self.active;
           BOOL saveSuccess = [[UserscriptUpdateManager shareManager] saveRequireUrl:userScript];
           BOOL saveResourceSuccess = [[UserscriptUpdateManager shareManager] saveResourceUrl:userScript];
           
            if(!saveSuccess) {
                [self saveError:@"requireUrl下载失败,请检查后重试"];
                return;
            }
            if(!saveResourceSuccess) {
                [self saveError:@"resourceUrl下载失败,请检查后重试"];
                return;
            }
            
            
           if(userScript != nil && userScript.errorMessage != nil && userScript.errorMessage.length <= 0) {
               [[DataManager shareManager] updateUserScript:userScript];
               [self initScrpitContent:true];
           } else {
               [self saveError:userScript.errorMessage];
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

- (void)blur {
    [_wkwebView evaluateJavaScript:@"blur()" completionHandler:^(id _Nullable, NSError * _Nullable error) {

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
    [_activityIndicator stopAnimating];
    if(success) {
        NSNotification *notification = [NSNotification notificationWithName:@"saveSuccess" object:nil];
        [[NSNotificationCenter defaultCenter]postNotification:notification];
    }
}

- (void)saveError:(NSString *)errorMessage{
    [_activityIndicator stopAnimating];
    NSNotification *notification = [NSNotification notificationWithName:@"saveError" object:errorMessage];
    [[NSNotificationCenter defaultCenter]postNotification:notification];
}

- (UIColor *)createBgColor {
    UIColor *viewBgColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return RGB(242, 242, 246);
            }
            else {
                return RGB(21, 21, 21);
            }
        }];
    return viewBgColor;
}

- (NSString* )md5HexDigest:(NSString* )input {
    const char* str =[input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);
    NSMutableString* ret = [NSMutableString stringWithCapacity: CC_MD5_DIGEST_LENGTH];
    for(int i=0; i< CC_MD5_DIGEST_LENGTH; i++){
        [ret appendFormat:@"%02X", result];
    }
    return ret;
}

@end
