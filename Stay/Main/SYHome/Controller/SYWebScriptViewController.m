//
//  SYWebScriptViewController.m
//  Stay
//
//  Created by zly on 2022/4/7.
//

#import "SYWebScriptViewController.h"
#import <WebKit/WebKit.h>
#import "SYEditViewController.h"
#import "LoadingSlideController.h"
#import "FCStyle.h"
#ifdef Mac
#import "QuickAccess.h"
#endif


@interface SYWebScriptViewController ()<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>
@property (nonatomic, strong) WKWebView *wkwebView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIBarButtonItem *backBtn;
@property (nonatomic, strong) UIBarButtonItem *closeBtn;
@property (nonatomic, strong) LoadingSlideController *loadingSlideController;

@end

@implementation SYWebScriptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = FCStyle.background;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    [self.view addSubview:self.wkwebView];
#ifdef Mac
    self.navigationController.navigationBarHidden = YES;
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 43,self.view.frame.size.width, 0.5f)];
#else
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 82,self.view.frame.size.width, 0.5f)];
#endif
    
    self.progressView.backgroundColor =  FCStyle.background;
    //设置进度条的高度，下面这句代码表示进度条的宽度变为原来的1倍，高度变为原来的1.5倍.
//    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 0.5f);
    [self.progressView setProgressViewStyle:UIProgressViewStyleDefault];
    [self.progressView setProgressTintColor:RGB(185,101,223)];
    [self.view addSubview:self.progressView];
    [self.wkwebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    self.navigationItem.leftBarButtonItems = @[self.backBtn,self.closeBtn];

}

- (void)navigateViewDidLoad{
    self.progressView.frame = CGRectMake(0, 43,self.view.frame.size.width, 0.5f);
    self.wkwebView.frame = CGRectMake(0,50,self.view.width,self.view.height-43);
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}
 
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
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
        
        _wkwebView = [[WKWebView alloc] initWithFrame:CGRectMake(0,self.progressView.bottom,self.view.width,self.view.height-self.progressView.bottom) configuration:config];
        _wkwebView.backgroundColor = FCStyle.background;
        _wkwebView.UIDelegate = self;
        _wkwebView.navigationDelegate = self;
        [_wkwebView setOpaque:false];
        _wkwebView.allowsBackForwardNavigationGestures = YES;
        NSString *urlStr = @"https://greasyfork.org/zh-CN/scripts";
        
        if (![[UserScript localeCodeLanguageCodeOnly] isEqualToString:@"zh"]) {
            urlStr = @"https://greasyfork.org/en/scripts/";
        }
        NSURL *url = [NSURL URLWithString:urlStr];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [_wkwebView loadRequest:request];
    }

    return _wkwebView;
}

- (BOOL)canGoback{
    return [self.wkwebView canGoBack];
}

- (void)goback{
    [self.wkwebView goBack];
}

- (void)backItemAction:(UIButton *)sender
{
    if ([self.wkwebView canGoBack] == YES) { //如果当前H5可以返回
        //则返回上一个H5页面
        [self.wkwebView goBack];
    }else{
        //否则回到原生页面
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    NSLog(@"开始加载网页");
    //开始加载网页时展示出progressView
    self.progressView.hidden = NO;
    //开始加载网页的时候将progressView的Height恢复为1.5倍
    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 0.4f);
    //防止progressView被网页挡住
    [self.view bringSubviewToFront:self.progressView];
    NSString *url = [webView.URL absoluteString];
    BOOL isScript = [url containsString:@"https://greasyfork.org/scripts"];
    if(isScript) {
        [self.loadingSlideController show];
        dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT),^{

            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]]];
            if(data != nil ) {
                NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                dispatch_async(dispatch_get_main_queue(),^{
                    SYEditViewController *cer = [[SYEditViewController alloc] init];
                    cer.content = str;
                    cer.downloadUrl = url;
#ifdef Mac
                    [[QuickAccess secondaryController] pushViewController:cer];
#else
                    [self.navigationController pushViewController:cer animated:true];
#endif
                });
            }
        });
        
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressView.progress = self.wkwebView.estimatedProgress;
        if (self.progressView.progress == 1) {
            /*
             *添加一个简单的动画，将progressView的Height变为1.4倍，在开始加载网页的代理中会恢复为1.5倍
             *动画时长0.25s，延时0.3s后开始动画
             *动画结束后将progressView隐藏
             */
            __weak typeof (self)weakSelf = self;
            [UIView animateWithDuration:0.25f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                weakSelf.progressView.transform = CGAffineTransformMakeScale(1.0f, 0.4f);
            } completion:^(BOOL finished) {
                weakSelf.progressView.hidden = YES;

            }];
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


//加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"加载完成");
    //加载完成后隐藏progressView
    self.progressView.hidden = YES;
    NSString *url = [webView.URL absoluteString];
    BOOL isScript = [url containsString:@"https://greasyfork.org/scripts"];
    if(isScript) {
       [self.wkwebView goBack];
    }
    NSString *jsString = @"localStorage.setItem('manualOverrideInstallJS', 1)";
    [self.wkwebView evaluateJavaScript:jsString completionHandler:nil];
    [self.loadingSlideController dismiss];

}

//加载失败
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"加载失败");
    //加载失败同样需要隐藏progressView
    self.progressView.hidden = YES;
}

- (void)dealloc {
    [self.wkwebView removeObserver:self forKeyPath:@"estimatedProgress"];
}

- (void)clickBack:(id)sender{
    if (self.wkwebView.canGoBack==YES) {
            //返回上级页面
            [self.wkwebView goBack];
            
    }else{
            //退出控制器
            [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)clickClose:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIBarButtonItem *)backBtn {
    if(_backBtn == nil) {
        _backBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"webback@3x"] style:UIBarButtonItemStylePlain target:self action:@selector(clickBack:)];
    }
    return _backBtn;
}

- (UIBarButtonItem *)closeBtn {
    if(_closeBtn == nil) {
        _closeBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"settings.close","close") style:UIBarButtonItemStylePlain target:self action:@selector(clickClose:)];
    }
    return _closeBtn;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (LoadingSlideController *)loadingSlideController{
    if (nil == _loadingSlideController){
        _loadingSlideController = [[LoadingSlideController alloc] init];
        _loadingSlideController.originMainText = NSLocalizedString(@"settings.downloadScript", @"");
    }
    
    return _loadingSlideController;
}


@end
