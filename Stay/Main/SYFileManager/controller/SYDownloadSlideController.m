//
//  SYDownloadSlideController.m
//  Stay
//
//  Created by ris on 2022/12/16.
//

#import "SYDownloadSlideController.h"
#import "SYDownloadModalViewController.h"
#import "SYParseModalViewController.h"

@interface SYDownloadSlideController()

@property (nonatomic, strong) ModalNavigationController *navController;
@end

@implementation SYDownloadSlideController

- (ModalNavigationController *)modalNavigationController{
    return self.navController;
}

- (CGFloat)marginToFrom{
    return 30;
}

- (ModalNavigationController *)navController{
    if (nil == _navController){
        NSString *downloadUrl = self.dic[@"downloadUrl"];
        if (downloadUrl.length > 0) {
            NSURL *linkURL = [NSURL URLWithString:downloadUrl];
            if (linkURL != nil && ([[linkURL.lastPathComponent lowercaseString] hasSuffix:@".mp4"]
                                   || [[linkURL.lastPathComponent lowercaseString] hasSuffix:@".m3u8"]
                                   || ([linkURL.host containsString:@"telegram"] && [[linkURL.path lowercaseString] containsString:@".mp4"]))) {
                SYDownloadModalViewController *cer = [[SYDownloadModalViewController alloc] init];
                cer.dic = self.dic;
                cer.nav = self.controller;
                _navController = [[ModalNavigationController alloc] initWithRootModalViewController:cer slideController:self];
            }
        }
        if (_navController == nil) {
            SYParseModalViewController *cer = [[SYParseModalViewController alloc] init];
            cer.dic = self.dic;
            cer.nav = self.controller;
            _navController = [[ModalNavigationController alloc] initWithRootModalViewController:cer slideController:self];
        }
    }
    
    return _navController;
}

- (void)setDic:(NSMutableDictionary *)dic {
    _dic = dic;
    _navController = nil;
}

- (BOOL)blockAction{
    return YES;
}


@end
