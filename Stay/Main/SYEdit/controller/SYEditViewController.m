//
//  SYEditViewController.m
//  Stay
//
//  Created by zly on 2021/12/3.
//

#import "SYEditViewController.h"
#import "SYCodeMirrorView.h"
#import "Tampermonkey.h"
#import "DataManager.h"

@interface SYEditViewController ()
@property (nonatomic, strong) WKWebView *wkwebView;
@property (nonatomic, strong) UIBarButtonItem *rightIcon;

@end

@implementation SYEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGB(242, 242, 246);
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0.0,0.0,200,44.0)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setNumberOfLines:0];
    [label setTextColor:[UIColor blackColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setText:@"content"];
    label.font = [UIFont boldSystemFontOfSize:17];
    self.navigationItem.titleView = label;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    self.navigationItem.rightBarButtonItem = [self rightIcon];

    [self createView];
 
    // Do any additional setup after loading the view.
}

- (void)createView{
//    [self.view addSubview:self.wkwebView];
    [self.view addSubview:[SYCodeMirrorView shareCodeView]];
    if(self.isEditing == NO) {
        [[SYCodeMirrorView shareCodeView] changeContent:@""];

    }
    if(self.content != nil && self.content.length > 0) {
        [[SYCodeMirrorView shareCodeView] changeContent:self.content];
    }
    
}

- (void)viewWillAppear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = YES;
}
 
- (void)viewWillDisappear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = NO;
}

- (void)saveBtnClick:(id)sender{
    if(self.uuid != nil && self.uuid.length > 0) {
        [SYCodeMirrorView shareCodeView].uuid = self.uuid;
        [[SYCodeMirrorView shareCodeView] updateContent];
    } else {
        [[SYCodeMirrorView shareCodeView] insertContent];
    }
}

- (UIBarButtonItem *)rightIcon {
    if (nil == _rightIcon){
        _rightIcon = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"settings.save","") style:UIBarButtonItemStylePlain target:self action:@selector(saveBtnClick:)];
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
