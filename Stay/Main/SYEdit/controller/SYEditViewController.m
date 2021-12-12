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
    if (self.userScript != nil && self.userScript.name != NULL) {
        [label setText:self.userScript.name];
    } else {
        [label setText:NSLocalizedString(@"settings.newScript","New Script")];
    }
    label.font = [UIFont boldSystemFontOfSize:17];
    self.navigationItem.titleView = label;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    self.navigationItem.rightBarButtonItem = [self rightIcon];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(saveSuccess:) name:@"saveSuccess" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(saveError:) name:@"saveError" object:nil];
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

- (void)saveSuccess:(id)sender{
    NSString *content = _isEdit?@"保存成功":@"创建成功";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:content preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *conform = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
        }];
    [alert addAction:conform];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)saveError:(id)sender{
    NSString *content = _isEdit?@"保存失败":@"创建失败";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:content preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *conform = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"点击了确认按钮");
        }];
    [alert addAction:conform];
    [self presentViewController:alert animated:YES completion:nil];
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
        [SYCodeMirrorView shareCodeView].active = self.userScript.active;
        [[SYCodeMirrorView shareCodeView] updateContent];
    } else {
        [[SYCodeMirrorView shareCodeView] insertContent];
    }
}

- (UIBarButtonItem *)rightIcon {
    if (nil == _rightIcon){
        if(self.isEdit) {
            _rightIcon = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"settings.save","save") style:UIBarButtonItemStylePlain target:self action:@selector(saveBtnClick:)];
        } else {
            _rightIcon = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"settings.create","Create") style:UIBarButtonItemStylePlain target:self action:@selector(saveBtnClick:)];
        }
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

- (void)initScrpitContent{
    NSUserDefaults *groupUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dajiu.stay.pro"];
    NSMutableArray *array =  [[NSMutableArray alloc] init];
    NSArray *datas =  [[DataManager shareManager] findScript:1];
    if(datas != NULL && datas.count > 0) {
        for(int i = 0; i < datas.count; i++) {
            UserScript *scrpit = datas[i];
            [array addObject: [scrpit toDictionary]];
        }
        [groupUserDefaults setObject:array forKey:@"ACTIVE_SCRIPTS"];
        [groupUserDefaults synchronize];
    }
}


@end
