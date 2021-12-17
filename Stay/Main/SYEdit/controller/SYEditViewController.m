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
@property (nonatomic, strong) UIView *componetView;

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShowAction:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHideAction:) name:UIKeyboardWillHideNotification object:nil];
    [self createView];
    [self.view addSubview:self.componetView];
    self.componetView.bottom = kScreenHeight - 20;
    [[SYCodeMirrorView shareCodeView] clearAll];
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


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"saveSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"saveError" object:nil];
}

- (void)keyboardShowAction:(NSNotification*)sender{
    NSValue *endFrameValue = sender.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect endFrame = [endFrameValue CGRectValue];
    self.componetView.bottom = endFrame.origin.y;

}
- (void)keyboardHideAction:(NSNotification*)sender{
    self.componetView.bottom = kScreenHeight - 20;
}

- (void)saveSuccess:(id)sender{
    NSString *content = _isEdit?@"保存成功":@"创建成功";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:content preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *conform = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
        }];
    [alert addAction:conform];
    [self initScrpitContent];
    NSNotification *notification = [NSNotification notificationWithName:@"scriptSaveSuccess" object:nil];
    [[NSNotificationCenter defaultCenter]postNotification:notification];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)saveError:(id)sender{
    NSString *content = _isEdit?@"保存失败":@"创建失败";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:content preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *conform = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"点击了确认按钮");
        }];
    [alert addAction:conform];
    [self initScrpitContent];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}
 
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
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

- (UIView *)componetView {
    if (nil == _componetView){
        _componetView = [[UIView alloc] initWithFrame:CGRectMake(10,0.0,kScreenWidth - 20,45)];
        _componetView.backgroundColor = [UIColor whiteColor];
        _componetView.layer.cornerRadius = 12;
        _componetView.layer.borderWidth = 0.5;
        _componetView.layer.borderColor = [RGB(151, 151, 151) CGColor];
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(0, 0, 31, 23);
        [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(editerCancel:) forControlEvents:UIControlEventTouchUpInside];
        backBtn.centerY = 22.5;
        backBtn.left = 31;
        [_componetView addSubview:backBtn];
        UIButton *onBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        onBtn.frame = CGRectMake(0, 0, 31, 23);
        [onBtn setImage:[UIImage imageNamed:@"on"] forState:UIControlStateNormal];
        [onBtn addTarget:self action:@selector(editerOn:) forControlEvents:UIControlEventTouchUpInside];
        onBtn.centerY = 22.5;
        onBtn.left = 83;
        [_componetView addSubview:onBtn];
        
        UIButton *pasteLabelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        pasteLabelBtn.frame = CGRectMake(0, 0, 120, 24);
        [pasteLabelBtn setTitle:@"从剪贴板粘贴" forState:UIControlStateNormal];
        pasteLabelBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [pasteLabelBtn setTitleColor:RGB(182, 32, 224) forState:UIControlStateNormal];
        [pasteLabelBtn addTarget:self action:@selector(copyPasteBoard:) forControlEvents:UIControlEventTouchUpInside];
        pasteLabelBtn.centerY = 22.5;
        pasteLabelBtn.right = kScreenWidth - 31;
        [_componetView addSubview:pasteLabelBtn];
        
        UIButton *clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        clearBtn.frame = CGRectMake(0, 0, 50, 24);
        [clearBtn setTitle:@"清空" forState:UIControlStateNormal];
        clearBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [clearBtn setTitleColor:RGB(182, 32, 224) forState:UIControlStateNormal];
        [clearBtn addTarget:self action:@selector(clearContext:) forControlEvents:UIControlEventTouchUpInside];
        clearBtn.centerY = 22.5;
        clearBtn.right = pasteLabelBtn.left - 25;
        [_componetView addSubview:clearBtn];
        
    }
    return _componetView;
}


- (void)editerCancel:(id)sender {
    [[SYCodeMirrorView shareCodeView] undo];
}

- (void)editerOn:(id)sender {
    [[SYCodeMirrorView shareCodeView] redo];
}

- (void)copyPasteBoard:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [[SYCodeMirrorView shareCodeView] changeContent:pasteboard.string];

}

- (void)clearContext:(id)sender {
    [[SYCodeMirrorView shareCodeView] changeContent:@""];
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
