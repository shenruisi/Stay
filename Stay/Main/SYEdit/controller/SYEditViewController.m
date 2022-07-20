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
#import "ScriptMananger.h"
#import "SharedStorageManager.h"
#import "LoadingSlideController.h"
#ifdef Mac
#import "QuickAccess.h"
#endif
#import "FCStyle.h"

@interface SYEditViewController ()
@property (nonatomic, strong) UIBarButtonItem *rightIcon;
@property (nonatomic, strong) UIView *componetView;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIButton *onBtn;
@property (nonatomic, strong) SYCodeMirrorView *syCodeMirrorView;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, assign) int requireCount;
@property (nonatomic, assign) int resourceCount;
@property (nonatomic, assign) int sumCount;
@property (nonatomic, strong) LoadingSlideController *loadingSlideController;


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
    self.view.backgroundColor = FCStyle.background;
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
    self.syCodeMirrorView.downloadUrl = self.downloadUrl;
    [self.view addSubview:self.componetView];
    self.componetView.bottom = kScreenHeight - 20;
    if(!self.isSearch) {
        self.navigationItem.rightBarButtonItem = [self rightIcon];
    }
    
#ifdef Mac
    self.navigationController.navigationBarHidden = YES;
#endif
    // Do any additional setup after loading the view.
}

- (void)navigateViewDidLoad{
#ifdef Mac
    [super navigateViewDidLoad];
    [self.syCodeMirrorView setFrame:CGRectMake(0, [QuickAccess splitController].toolbar.height, self.view.frame.size.width, self.view.frame.size.height - [QuickAccess splitController].toolbar.height)];
    self.componetView.hidden = YES;
#endif
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
#ifdef Mac
    [self.syCodeMirrorView setFrame:CGRectMake(0, [QuickAccess splitController].toolbar.height, self.view.frame.size.width, self.view.frame.size.height - [QuickAccess splitController].toolbar.height)];
    [self.syCodeMirrorView reload];
    NSLog(@"self.syCodeMirrorView %@",NSStringFromCGRect(self.syCodeMirrorView.frame));
#endif
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
//        self.loadingSlideController.originSubText = self.userScript.name;
        [self.loadingSlideController show];
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
    [self.loadingSlideController updateSubText:[NSString stringWithFormat:@"(%d/%d)",downloadCount,self.sumCount]];
    
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
    if(self.isEditing == NO && self.content != nil) {
        [self.syCodeMirrorView changeContent:@""];
    }
    if(self.content != nil && self.content.length > 0) {
        [self.syCodeMirrorView changeContent:self.content];
    }
    [self.syCodeMirrorView clearAll];
}

- (void)keyboardShowAction:(NSNotification*)sender{
//    NSValue *endFrameValue = sender.userInfo[UIKeyboardFrameEndUserInfoKey];
//    CGRect endFrame = [endFrameValue CGRectValue];
//    self.componetView.bottom = endFrame.origin.y - 10;
}
- (void)keyboardHideAction:(NSNotification*)sender{
    self.componetView.bottom = kScreenHeight - 20;
}

- (void)saveSuccess:(NSNotification*) sender{
    NSString *uuid =  [sender object];
    [self.loadingSlideController dismiss];
    NSString *content = _isEdit? NSLocalizedString(@"Saved", @"") :  NSLocalizedString(@"Created", @"");
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:content preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *conform = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
        }];
    [alert addAction:conform];
    [self initScrpitContent];
    NSNotification *notification = [NSNotification notificationWithName:@"scriptSaveSuccess" object:nil];
    [[NSNotificationCenter defaultCenter]postNotification:notification];
    if(_isEdit) {
        NSNotification *notification = [NSNotification notificationWithName:@"app.stay.notification.userscriptDidUpdateNotification" object:nil userInfo:@{@"uuid":uuid}];
                [[NSNotificationCenter defaultCenter]postNotification:notification];
    } else {
        NSNotification *notification = [NSNotification notificationWithName:@"app.stay.notification.userscriptDidAddNotification" object:nil userInfo:@{@"uuid":uuid}];
                [[NSNotificationCenter defaultCenter]postNotification:notification];
    }
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)saveError:(NSNotification*) notification{
    dispatch_async(dispatch_get_main_queue(),^{
        [self.loadingSlideController dismiss];
    });
    NSString *errorMessage =  [notification object];
    NSString *content = errorMessage;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:content preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *conform = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
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
    self.componetView.bottom = kScreenHeight - 20;
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

- (void)save{
    [self saveBtnClick:nil];
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
        _componetView = [[UIView alloc] initWithFrame:CGRectMake(0,0.0,kScreenWidth,60)];
        _componetView.backgroundColor = DynamicColor([UIColor blackColor],[UIColor whiteColor]);
//        _componetView.layer.cornerRadius = 12;
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
        CGFloat width = (kScreenWidth - 57 - 56 * 4) / 3;
        
        UIImage *image =  [UIImage systemImageNamed:@"arrow.uturn.backward"
                                     withConfiguration:[UIImageSymbolConfiguration configurationWithFont:[UIFont systemFontOfSize:23]]];
        image = [image imageWithTintColor:DynamicColor([UIColor whiteColor],[UIColor blackColor]) renderingMode:UIImageRenderingModeAlwaysOriginal];
        
        _backBtn = [self createBtn:image text:NSLocalizedString(@"Undo", @"")];
        _backBtn.enabled = false;
        [_backBtn addTarget:self action:@selector(editerCancel:) forControlEvents:UIControlEventTouchUpInside];
        _backBtn.centerY = 30;
        _backBtn.left = 28.5;
        [_componetView addSubview:_backBtn];

        UIImage *onImage =  [UIImage systemImageNamed:@"arrow.uturn.forward"
                                     withConfiguration:[UIImageSymbolConfiguration configurationWithFont:[UIFont systemFontOfSize:23]]];
        onImage = [onImage imageWithTintColor: DynamicColor([UIColor whiteColor],[UIColor blackColor]) renderingMode:UIImageRenderingModeAlwaysOriginal];
        
        _onBtn = [self createBtn:onImage text:NSLocalizedString(@"Redo", @"")];
        _onBtn.enabled = false;
        [_onBtn addTarget:self action:@selector(editerOn:) forControlEvents:UIControlEventTouchUpInside];
        _onBtn.centerY = 30;
        _onBtn.left = 56 + width + 28.5;
        [_componetView addSubview:_onBtn];
        
        UIImage *clearImage = [UIImage systemImageNamed:@"trash"
                                     withConfiguration:[UIImageSymbolConfiguration configurationWithFont:[UIFont systemFontOfSize:23]]];
        clearImage = [clearImage imageWithTintColor: DynamicColor([UIColor whiteColor],[UIColor blackColor]) renderingMode:UIImageRenderingModeAlwaysOriginal];
        
        UIButton *clearBtn = [self createBtn:clearImage text:NSLocalizedString(@"Clear", @"")];
        [clearBtn addTarget:self action:@selector(clearContext:) forControlEvents:UIControlEventTouchUpInside];
        clearBtn.centerY = 30;
        clearBtn.left = 56 * 2  + width * 2 + 28.5;
        [_componetView addSubview:clearBtn];

        UIImage *pasteImage =  [UIImage systemImageNamed:@"arrow.up.doc.on.clipboard"
                                     withConfiguration:[UIImageSymbolConfiguration configurationWithFont:[UIFont systemFontOfSize:23]]];
        pasteImage = [pasteImage imageWithTintColor: DynamicColor([UIColor whiteColor],[UIColor blackColor]) renderingMode:UIImageRenderingModeAlwaysOriginal];
        
        UIButton *pasteLabelBtn = [self createBtn:pasteImage text:NSLocalizedString(@"Clipboard", @"")];
    
        [pasteLabelBtn addTarget:self action:@selector(copyPasteBoard:) forControlEvents:UIControlEventTouchUpInside];
        pasteLabelBtn.centerY = 30;
        pasteLabelBtn.left = 56 * 3  + width * 3 + 28.5;
        [_componetView addSubview:pasteLabelBtn];
        
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
//    NSUserDefaults *groupUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dajiu.stay.pro"];
//    NSMutableArray *array =  [[NSMutableArray alloc] init];
//    NSArray *datas =  [[DataManager shareManager] findScript:1];
//    if(datas != NULL && datas.count > 0) {
//        for(int i = 0; i < datas.count; i++) {
//            UserScript *scrpit = datas[i];
//            [groupUserDefaults setObject:[scrpit toDictionary] forKey:[NSString stringWithFormat:@"STAY_SCRIPTS_%@",scrpit.uuid]];
//            scrpit.parsedContent = @"";
//            scrpit.icon = @"";
//            [array addObject: [scrpit toDictionary]];
//        }
//        [groupUserDefaults setObject:array forKey:@"STAY_SCRIPTS"];
//        [groupUserDefaults synchronize];
//        [[ScriptMananger shareManager] buildData];
//    }
    
    NSMutableArray *array =  [[NSMutableArray alloc] init];
    NSArray *datas =  [[DataManager shareManager] findScript:1];
    if(datas.count > 0) {
        for(int i = 0; i < datas.count; i++) {
            UserScript *scrpit = datas[i];
            UserscriptInfo *info = [[SharedStorageManager shared] getInfoOfUUID:scrpit.uuid];
            info.content = [scrpit toDictionary];
            [info flush];
            scrpit.parsedContent = @"";
            [array addObject: [scrpit toDictionary]];
        }
        [SharedStorageManager shared].userscriptHeaders.content = array;
        [[SharedStorageManager shared].userscriptHeaders flush];
        [[ScriptMananger shareManager] buildData];
    }
    
}

- (UIColor *)createBgColor {
    UIColor *viewBgColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return RGB(242, 242, 246);
                
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
        _syCodeMirrorView = [[SYCodeMirrorView alloc] initWithFrame:CGRectMake(0, StatusBarHeight, self.view.frame.size.width, self.view.frame.size.height - StatusBarHeight - 70)];
    }
    return _syCodeMirrorView;
}

- (UILabel *)countLabel {
    if(_countLabel == NULL) {
        _countLabel = [[UILabel alloc] init];
        _countLabel.textColor = [UIColor blackColor];
        _countLabel.font = [UIFont systemFontOfSize:18];
    }
    return _countLabel;
}

- (UIButton *)createBtn:(UIImage *)image text:(NSString *)text {
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [btn setTitle:text forState:UIControlStateNormal];
    [btn setImage:image forState:UIControlStateNormal];
    
    btn.frame = CGRectMake(0, 0, 56, 45);
    [btn setTitleColor:DynamicColor([UIColor whiteColor],[UIColor blackColor]) forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [btn setTitleEdgeInsets:
           UIEdgeInsetsMake(btn.frame.size.height/2 + 10,
                           (btn.frame.size.width-btn.titleLabel.intrinsicContentSize.width)/2-btn.imageView.frame.size.width,
                            0,
                           (btn.frame.size.width-btn.titleLabel.intrinsicContentSize.width)/2)];
    [btn setImageEdgeInsets:
               UIEdgeInsetsMake(
                           0,
                           (btn.frame.size.width-btn.imageView.frame.size.width)/2,
                            btn.titleLabel.intrinsicContentSize.height,
                           (btn.frame.size.width-btn.imageView.frame.size.width)/2)];
    return  btn;
}


- (LoadingSlideController *)loadingSlideController{
    if (nil == _loadingSlideController){
        _loadingSlideController = [[LoadingSlideController alloc] init];
        _loadingSlideController.originMainText = NSLocalizedString(@"settings.downloadScript", @"");
    }
    
    return _loadingSlideController;
}


@end
