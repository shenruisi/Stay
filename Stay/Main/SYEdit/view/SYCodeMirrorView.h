//
//  SYCodeMirrorView.h
//  Stay
//
//  Created by zly on 2021/12/10.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SYCodeMirrorView : UIView<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *wkwebView;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, assign) BOOL active;


- (void)changeContent:(NSString *) jsContent;
- (void)insertContent;
- (void)updateContent;
- (void)undo;
- (void)redo;
- (void)clearAll;
- (void)blur;




@end

NS_ASSUME_NONNULL_END
