//
//  SYScriptAddViewController.m
//  Stay
//
//  Created by zly on 2022/4/7.
//

#import "SYScriptAddViewController.h"
#import "SYEditViewController.h"

@interface SYScriptAddViewController ()

@property (strong, nonatomic) UITextView *webInputView;
@property (nonatomic, strong) UIBarButtonItem *rightIcon;
@end

@implementation SYScriptAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIColor *textColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return [UIColor blackColor];
            }
            else {
                return [UIColor whiteColor];
            }
        }];

    // Do any additional setup after loading the view.
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0.0,0.0,200,44.0)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setNumberOfLines:0];
    [label setTextColor:textColor];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setText:@"从链接添加"];
    label.font = [UIFont boldSystemFontOfSize:17];
    self.navigationItem.titleView = label;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    [self.view addSubview:self.webInputView];
    self.navigationItem.rightBarButtonItem = [self rightIcon];
    self.view.backgroundColor = [UIColor whiteColor];

}

- (UITextView *)webInputView {
    if(_webInputView == NULL) {
        _webInputView = [[UITextView alloc] initWithFrame:CGRectMake(45, 200, kScreenWidth - 90, 30)];
        _webInputView.backgroundColor = [UIColor lightGrayColor];
    }
    return _webInputView;
}

- (void)saveBtnClick:(id)sender{
    
    NSString *url = self.webInputView.text;
//    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
//    NSError *error;
//    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];

    if(data != nil ) {
        NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        SYEditViewController *cer = [[SYEditViewController alloc] init];
        cer.content = str;
        [self.navigationController pushViewController:cer animated:true];
    }else {
        NSString *content = @"下载脚本失败";
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:content preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *conform = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSLog(@"点击了确认按钮");
            }];
        [alert addAction:conform];
        [self presentViewController:alert animated:YES completion:nil];

    }
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}
 
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
}

- (UIBarButtonItem *)rightIcon {
    if (nil == _rightIcon){
        _rightIcon = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"settings.create","Create") style:UIBarButtonItemStylePlain target:self action:@selector(saveBtnClick:)];
    }
    return _rightIcon;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
