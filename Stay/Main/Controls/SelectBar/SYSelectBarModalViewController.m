//
//  SYSelectBarModalViewController.m
//  Stay
//
//  Created by zly on 2022/6/10.
//

#import "SYSelectBarModalViewController.h"
#import "FCStyle.h"
@implementation SYSelectBarModalViewController

- (void)viewDidLoad{
    [super viewDidLoad];

    [self shareUrlBtn];
    [self shareContentBtn];
    if (self.url == NULL || self.url.length == 0) {
        self.shareUrlBtn.hidden = true;
        [self getMainView].height = 82;
    }
}

- (void)shareUrlClick {
    
    //分享的url
    NSURL *urlToShare = [NSURL URLWithString:self.url];

    NSArray *activityItems = @[urlToShare];
        
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];

    activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll];

    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:activityVC animated:YES completion:nil];
        
}


- (void)shareContentClick {
    NSString *textToShare =self.content;


    NSArray *activityItems = @[textToShare];
        
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];

    activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:activityVC animated:YES completion:nil];
}


- (UIView *)shareUrlBtn {
    if(_shareUrlBtn == nil) {
        _shareUrlBtn = [[UIView alloc] initWithFrame:CGRectMake(25, 17 + 45 + 16, kScreenWidth - 80, 45)];
        _shareUrlBtn.backgroundColor = RGB(247, 247, 247);
        _shareUrlBtn.layer.cornerRadius = 10;
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareUrlClick)];
        [_shareUrlBtn addGestureRecognizer:tapGesture];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 18)];
        label.font = FCStyle.body;
        label.text = NSLocalizedString(@"settings.shareUrl", @"Share Url");
        label.userInteractionEnabled = NO;
        label.centerY = 22.5;
        [_shareUrlBtn addSubview:label];
        
        UIImage *image = [UIImage systemImageNamed:@"link.circle.fill" withConfiguration:[UIImageSymbolConfiguration configurationWithFont:[UIFont systemFontOfSize:22]]];
        image = [image imageWithTintColor:DynamicColor([UIColor whiteColor],[UIColor blackColor]) renderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(15,15,23,23)] ;
        imageview.image = image;
        imageview.centerY = 22.5;
        imageview.right = kScreenWidth - 95;
        [_shareUrlBtn addSubview:imageview];

        [self.view addSubview:_shareUrlBtn];
    }
    return _shareUrlBtn;
}

- (UIView *)shareContentBtn {
    if(_shareContentBtn == nil) {
        _shareContentBtn = [[UIView alloc] initWithFrame:CGRectMake(25, 17, kScreenWidth - 80, 45)];
        _shareContentBtn.backgroundColor = RGB(247, 247, 247);
        _shareContentBtn.layer.cornerRadius = 10;
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareContentClick)];
        [_shareContentBtn addGestureRecognizer:tapGesture];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 18)];
        label.font = FCStyle.body;
        label.text = NSLocalizedString(@"settings.shareContent", @"Share Content");
        label.userInteractionEnabled = NO;
        label.centerY = 22.5;
        [_shareContentBtn addSubview:label];
        UIImage *image = [UIImage systemImageNamed:@"doc.circle.fill" withConfiguration:[UIImageSymbolConfiguration configurationWithFont:[UIFont systemFontOfSize:22]]];
        image = [image imageWithTintColor:DynamicColor([UIColor whiteColor],[UIColor blackColor]) renderingMode:UIImageRenderingModeAlwaysOriginal];

        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(15,15,23,23)] ;
        imageview.image = image;
        imageview.centerY = 22.5;
        imageview.right = kScreenWidth - 95;
        [_shareContentBtn addSubview:imageview];

        [self.view addSubview:_shareContentBtn];
    }
    
    return _shareContentBtn;
}


- (CGSize)mainViewSize{
    CGFloat width = kScreenWidth - 30;
    CGFloat height = 152;
    return CGSizeMake(width, height);
}
@end
