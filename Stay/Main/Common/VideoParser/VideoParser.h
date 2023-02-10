//
//  VideoParser.h
//  Stay
//
//  Created by ris on 2023/2/6.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoParser : NSObject

+ (instancetype)shared;
- (void)parse:(NSString *)urlString completionBlock:(void(^)(NSArray<NSDictionary *> *videoItems))completionBlock;
- (void)stopParse;

@property (nonatomic, strong) WKWebView *webView;
@end

NS_ASSUME_NONNULL_END
