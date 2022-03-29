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
#import "UserscriptUpdateManager.h"


@interface SYEditViewController ()
@property (nonatomic, strong) UIBarButtonItem *rightIcon;
@property (nonatomic, strong) UIView *componetView;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIButton *onBtn;
@property (nonatomic, strong) SYCodeMirrorView *syCodeMirrorView;
@property (nonatomic, strong) UIView *uploadView;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, assign) int requireCount;
@property (nonatomic, assign) int resourceCount;
@property (nonatomic, assign) int sumCount;

@end

@implementation SYEditViewController

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
    self.view.backgroundColor = [self createBgColor];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0.0,0.0,200,44.0)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setNumberOfLines:0];
    [label setTextColor:textColor];
    [label setTextAlignment:NSTextAlignmentCenter];
    if (self.userScript != nil && self.userScript.name != NULL) {
        [label setText:self.userScript.name];
    } else {
        [label setText:NSLocalizedString(@"settings.newScript","New Script")];
    }
    label.font = [UIFont boldSystemFontOfSize:17];
    self.navigationItem.titleView = label;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(saveSuccess:) name:@"saveSuccess" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(saveError:) name:@"saveError" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reDoHistoryChange:) name:@"reDoHistoryChange" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onDoHistoryChange:) name:@"onDoHistoryChange" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(htmlLoadSuccess:) name:@"htmlLoadSuccess" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(startSave:) name:@"startSave" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(startSaveRequire:) name:@"startSaveRequire" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(startSaveResource:) name:@"startSaveResource" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShowAction:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHideAction:) name:UIKeyboardWillHideNotification object:nil];
    
    [self.view addSubview:self.syCodeMirrorView];
    [self.view addSubview:self.componetView];
    self.componetView.bottom = kScreenHeight - 45;
    if(!self.isSearch) {
        self.navigationItem.rightBarButtonItem = [self rightIcon];
    }
    
    self.uploadView.center = self.view.center;
    [self.view addSubview:self.uploadView];
    self.uploadView.hidden = true;
    // Do any additional setup after loading the view.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"saveSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"saveError" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reDoHistoryChange" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"onDoHistoryChange" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"htmlLoadSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"startSave" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"startSaveRequire" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"startSaveResource" object:nil];
}

- (void)startSave:(NSNotification*) notification{
    NSString *sumCount = [notification object];
    self.sumCount = sumCount.intValue;
    self.requireCount = 0;
    self.resourceCount = 0;
    dispatch_async(dispatch_get_main_queue(),^{
        self.uploadView.hidden = NO;
        [self reloadCount];
    });
    
}

- (void)startSaveRequire:(NSNotification*) notification{
    NSString *requireCount = [notification object];
    self.requireCount = requireCount.intValue;
    dispatch_async(dispatch_get_main_queue(),^{
        [self reloadCount];
    });
}
- (void)startSaveResource:(NSNotification*) notification{
    NSString *resourceCount = [notification object];
    self.resourceCount = resourceCount.intValue;
    dispatch_async(dispatch_get_main_queue(),^{
        [self reloadCount];
    });
}

- (void)reloadCount {
    int downloadCount = self.resourceCount + self.requireCount;

//    dispatch_async(dispatch_get_main_queue(),^{
        self.countLabel.text = [NSString stringWithFormat:@"(%d/%d)",downloadCount,self.sumCount];
        [self.countLabel sizeToFit];
        self.countLabel.centerX = (kScreenWidth - 100) / 2;
//    });
}

- (void)reDoHistoryChange:(NSNotification*) notification{
    NSString *haveHistory =  [notification object];
    self.backBtn.enabled = [haveHistory isEqual:@"true"];
}
- (void)onDoHistoryChange:(NSNotification*) notification{
    NSString *haveHistory =  [notification object];
    self.onBtn.enabled = [haveHistory isEqual:@"true"];
}

- (void)htmlLoadSuccess:(NSNotification*) notification{
    if(self.isEditing == NO) {
        [self.syCodeMirrorView changeContent:@""];
    }
    if(self.content != nil && self.content.length > 0) {
        [self.syCodeMirrorView changeContent:self.content];
    }
    [self.syCodeMirrorView clearAll];
}

- (void)keyboardShowAction:(NSNotification*)sender{
    NSValue *endFrameValue = sender.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect endFrame = [endFrameValue CGRectValue];
    self.componetView.bottom = endFrame.origin.y - 10;
}
- (void)keyboardHideAction:(NSNotification*)sender{
    self.componetView.bottom = kScreenHeight - 45;
}

- (void)saveSuccess:(id)sender{
    self.uploadView.hidden = true;
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

- (void)saveError:(NSNotification*) notification{
    dispatch_async(dispatch_get_main_queue(),^{
            self.uploadView.hidden = true;
    });
    NSString *errorMessage =  [notification object];
    NSString *content = errorMessage;
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
    self.componetView.bottom = kScreenHeight - 45;
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

- (void)saveBtnClick:(id)sender{
    if(self.uuid != nil && self.uuid.length > 0) {
        self.syCodeMirrorView.uuid = self.uuid;
        self.syCodeMirrorView.active = self.userScript.active;
        [self.syCodeMirrorView updateContent];
    } else {
        [self.syCodeMirrorView insertContent];
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
        _componetView.backgroundColor = [self createBgColor];
        _componetView.layer.cornerRadius = 12;
        _componetView.layer.borderWidth = 0.5;
        UIColor *borderColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
                if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                    return RGB(216, 216, 216);
                }
                else {
                    return RGB(37, 37, 40);
                }
            }];
        _componetView.layer.borderColor = [borderColor CGColor];
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _backBtn.frame = CGRectMake(0, 0, 31, 23);
        _backBtn.enabled = false;
        [_backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(editerCancel:) forControlEvents:UIControlEventTouchUpInside];
        _backBtn.centerY = 22.5;
        _backBtn.left = 31;
        [_componetView addSubview:_backBtn];
        _onBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _onBtn.frame = CGRectMake(0, 0, 31, 23);
        _onBtn.enabled = false;
        [_onBtn setImage:[UIImage imageNamed:@"on"] forState:UIControlStateNormal];
        [_onBtn addTarget:self action:@selector(editerOn:) forControlEvents:UIControlEventTouchUpInside];
        _onBtn.centerY = 22.5;
        _onBtn.left = 83;
        [_componetView addSubview:_onBtn];
        
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
    [self.syCodeMirrorView undo];
}

- (void)editerOn:(id)sender {
    [self.syCodeMirrorView redo];
}

- (void)copyPasteBoard:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [self.syCodeMirrorView changeContent:pasteboard.string];

}

- (void)clearContext:(id)sender {
    [self.syCodeMirrorView changeContent:@""];
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

- (UIColor *)createBgColor {
    UIColor *viewBgColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return RGB(242, 242, 246);
            }
            else {
                return [UIColor blackColor];
            }
        }];
    return viewBgColor;
}

- (SYCodeMirrorView *)syCodeMirrorView {
    if (_syCodeMirrorView == nil) {
        _syCodeMirrorView = [[SYCodeMirrorView alloc] initWithFrame:CGRectMake(0, StatusBarHeight, kScreenWidth, kScreenHeight - StatusBarHeight)];
    }
    return _syCodeMirrorView;
}


- (UIView *)uploadView {
    if(_uploadView == NULL) {
        _uploadView = [[UIView alloc] initWithFrame:CGRectMake(50, 0, kScreenWidth - 100, 100)];
        [_uploadView setBackgroundColor:RGB(230, 230, 230)];
        _uploadView.layer.cornerRadius = 10;
        _uploadView.layer.masksToBounds = 10;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = NSLocalizedString(@"settings.uploadTips","Handling script resources");
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.textColor = [UIColor blackColor];
        [titleLabel sizeToFit];
        
        titleLabel.top = 30;
        titleLabel.centerX = (kScreenWidth - 100) / 2;
        [_uploadView addSubview:titleLabel];
        
        self.countLabel.top = titleLabel.bottom + 5;
        self.countLabel.centerX = (kScreenWidth - 100) / 2;
        [_uploadView addSubview:self.countLabel];
    }
    return _uploadView;
}

- (UILabel *)countLabel {
    if(_countLabel == NULL) {
        _countLabel = [[UILabel alloc] init];
        _countLabel.textColor = [UIColor blackColor];
        _countLabel.font = [UIFont systemFontOfSize:18];
    }
    return _countLabel;
}

@end
