//
//  SYTextInputModelViewController.m
//  Stay
//
//  Created by zly on 2022/7/6.
//

#import "SYTextInputModelViewController.h"
#import "FCStyle.h"

@implementation SYTextInputModelViewController
- (void)viewDidLoad{
    [self inputView];
    [self confirmBtn];
}


-(void) addBlackSite {
    [[NSNotificationCenter defaultCenter] postNotificationName:self.notificationName object:self.inputView.text];
}

- (void)updateNotificationName:(NSString *)text {
    self.notificationName = text;
}

- (UITextView *)inputView {
    if(_inputView == nil) {
        _inputView = [[UITextView alloc] initWithFrame:CGRectMake(10, 0, self.mainViewSize.width -20, 200)];
        _inputView.backgroundColor = FCStyle.secondaryPopup;
        _inputView.layer.cornerRadius = 8;
        _inputView.font = FCStyle.body;
        [self.view addSubview:_inputView];

    }
    return _inputView;
}

- (UIButton *)confirmBtn {
    if(nil == _confirmBtn) {
        _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmBtn.frame = CGRectMake(10, 210, self.mainViewSize.width - 20, 48);
        _confirmBtn.backgroundColor = FCStyle.accent;
        [_confirmBtn setTitle:NSLocalizedString(@"settings.save","Save") forState:UIControlStateNormal];
        [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _confirmBtn.titleLabel.font = FCStyle.headlineBold;
        _confirmBtn.layer.cornerRadius = 8;
        [_confirmBtn addTarget:self action:@selector(addBlackSite) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_confirmBtn];
    }
    return _confirmBtn;
}

- (CGSize)mainViewSize{
#ifdef Mac
    CGFloat width = 300;
#else
    CGFloat width = kScreenWidth - 30;
#endif
    
    CGFloat height = 270 + self.navigationBar.height;
//    if (self.url == NULL || self.url.length == 0) {
//        self.shareUrlBtn.hidden = true;
//        height = 82;
//    } else {
//        self.shareUrlBtn.hidden = false;
//    }
    return CGSizeMake(width, height);
}
@end
