//
//  VideoParser.m
//  Stay
//
//  Created by ris on 2023/2/6.
//

#import "VideoParser.h"


@interface VideoParser()<
 WKNavigationDelegate,
 WKScriptMessageHandler
>


@property (nonatomic, copy) void(^completionBlock)(NSArray<NSDictionary *> *videoItems);
@end

@implementation VideoParser
static VideoParser *_kVideoParser;

+ (instancetype)shared{
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        if (nil == _kVideoParser){
            _kVideoParser = [[VideoParser alloc] init];
        }
    });
    return _kVideoParser;
}

- (instancetype)init{
    if (self = [super init]){
        [self webView];
    }
    
    return self;
}

- (WKWebView *)webView{
    if (nil == _webView){
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        WKPreferences *preferences = [[WKPreferences alloc] init];
        preferences.javaScriptEnabled = true;
        [preferences setValue:@YES forKey:@"allowFileAccessFromFileURLs"];
        [config setPreferences:preferences];
        WKUserContentController * wkUController = [[WKUserContentController alloc] init];
        [wkUController addScriptMessageHandler:self name:@"stayapp"];
        NSString *sinffer = [self _getScript:@"sniffer.app"];
        WKUserScript *userscript = [[WKUserScript alloc] initWithSource:sinffer injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
        [wkUController addUserScript:userscript];
        config.userContentController = wkUController;
        
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
        _webView.navigationDelegate = self;
        [_webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(NSString *userAgent, NSError *error) {
                NSString *newUserAgent = [userAgent stringByAppendingString:@" Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1"];
                [config.defaultWebpagePreferences setValue:newUserAgent forKey:@"_webUserAgent"];
            }];
    }
    
    return _webView;
}

- (NSString *)_getScript:(NSString *)scriptName{
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:scriptName ofType:@"js"]];
    return [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
}

- (void)parse:(NSString *)urlString completionBlock:(nonnull void (^)(NSArray<NSDictionary *> * _Nonnull))completionBlock{
    [self.webView stopLoading];
    self.completionBlock = completionBlock;
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void)stopParse{
    [self.webView stopLoading];
    self.completionBlock = nil;
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
    NSLog(@"headers %@ %ld",[response allHeaderFields],response.statusCode);
//    [webView evaluateJavaScript:<#(nonnull NSString *)#> completionHandler:<#^(id _Nullable, NSError * _Nullable error)completionHandler#>]
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    if (self.completionBlock){
        self.completionBlock(message.body);
    }
}

//- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
//    NSLog(@"navigation url %@",navigation)
//}

@end
