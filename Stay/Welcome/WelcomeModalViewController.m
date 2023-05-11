//
//  WelcomeModalViewController.m
//  Stay
//
//  Created by ris on 2023/5/1.
//

#import "WelcomeModalViewController.h"
#import "FCApp.h"
#import "FCStyle.h"
#import "ModalSectionElement.h"
#import "ModalItemElement.h"
#import "ModalItemViewFactory.h"
#import "ModalSectionView.h"
#import "FCButton.h"
#import "EnableStayModalViewController.h"
#import "InstallUserscriptModalViewController.h"
#if FC_IOS
#import "Stay-Swift.h"
#else
#import "Stay-Swift.h"
#endif

#import "SharedStorageManager.h"
#import "QuickAccess.h"


@interface WelcomeModalViewController()<
 UITableViewDelegate,
 UITableViewDataSource
>

@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@property (nonatomic, strong) UILabel *welcomeLabel;
@property (nonatomic, strong) UILabel *stayLabel;
@property (nonatomic, strong) UILabel *developedLabel1;
@property (nonatomic, strong) UIImageView *djImageView;
@property (nonatomic, strong) UILabel *developedLabel2;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSDictionary *> *dataSource;
@property (nonatomic, strong) ModalItemElement *enableStayElemnt;
@property (nonatomic, strong) ModalItemElement *installUserscriptElement;
@property (nonatomic, strong) ModalItemElement *doneElement;
@property (nonatomic, strong) FCButton *skipButton;
@property (nonatomic, strong) LottieView *congratulationsLottieView;
@end

@implementation WelcomeModalViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationBar.backgroundColor = UIColor.clearColor;
    self.navigationBar.showCancel = NO;
    [self gradientLayer];
    [self welcomeLabel];
    [self stayLabel];
    [self developedLabel2];
    [self djImageView];
    [self developedLabel1];
    [self tableView];
    [self skipButton];
}

- (void)viewWillAppear{
    [super viewWillAppear];
    [SharedStorageManager shared].userDefaults = nil;
    BOOL safariExtensionEnabled = [SharedStorageManager shared].userDefaults.safariExtensionEnabled;
    self.enableStayElemnt.accessoryEntity.animation = !safariExtensionEnabled;
    self.enableStayElemnt.accessoryEntity.checkmark = safariExtensionEnabled;
    self.enableStayElemnt.enable = YES;
    
    NSArray *datas =  [[DataManager shareManager] findScript:1];
    BOOL userscriptInstalled = datas.count > 0;
    self.installUserscriptElement.accessoryEntity.animation = safariExtensionEnabled && !userscriptInstalled;
    self.installUserscriptElement.enable = safariExtensionEnabled;
    self.installUserscriptElement.accessoryEntity.checkmark = userscriptInstalled;
    
    
    
    if (safariExtensionEnabled && userscriptInstalled){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            [[self congratulationsLottieView] playWithCompletion:^(BOOL complete) {
                [self.congratulationsLottieView removeFromSuperview];
                self.congratulationsLottieView = nil;
                self.doneElement.enable = safariExtensionEnabled && userscriptInstalled;
                self.doneElement.accessoryEntity.animation = safariExtensionEnabled && userscriptInstalled;
                [self.tableView reloadData];
                
                NSUserDefaults *groupUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dajiu.stay.pro"];
                [groupUserDefaults setObject:@(YES) forKey:@"tips"];
                [groupUserDefaults setObject:@(YES) forKey:@"userDefaults.firstGuide"];
                [groupUserDefaults synchronize];
            }];
        });
    }
    else{
        self.doneElement.enable = safariExtensionEnabled && userscriptInstalled;
        self.doneElement.accessoryEntity.animation = safariExtensionEnabled && userscriptInstalled;
        [self.tableView reloadData];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ModalItemElement *element = ((NSArray *)self.dataSource[indexPath.section][@"itemElements"])[indexPath.row];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:nil];
    cell.backgroundColor = UIColor.clearColor;
    ModalItemView *modalItemView = [ModalItemViewFactory ofElement:element];
    modalItemView.backgroundColor = UIColor.clearColor;
    [cell.contentView addSubview:modalItemView];
    modalItemView.cell = cell;
    [modalItemView attachGesture];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    ModalSectionElement *element = self.dataSource[section][@"sectionElement"];
    ModalSectionView *sectionView = [[ModalSectionView alloc] initWithElement:element];
    sectionView.backgroundColor = UIColor.clearColor;
    sectionView.contentView.backgroundColor = UIColor.clearColor;
    return sectionView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return ((NSArray *)self.dataSource[section][@"itemElements"]).count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ModalItemElement *element = ((NSArray *)self.dataSource[indexPath.section][@"itemElements"])[indexPath.row];
    CGFloat contentHeight = [element contentHeightWithWidth:self.view.width];
    return contentHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 15;
}

- (CAGradientLayer *)gradientLayer{
    if (nil == _gradientLayer){
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.frame = [self getMainView].bounds;
        NSArray<UIColor *> *colors = FCStyle.accentGradient;
        _gradientLayer.colors = @[(id)colors[0].CGColor, (id)colors[1].CGColor];
        [[self getMainView].layer insertSublayer:_gradientLayer atIndex:0];
    }
    
    return _gradientLayer;
}

- (UILabel *)welcomeLabel{
    if (nil == _welcomeLabel){
        _welcomeLabel = [[UILabel alloc] init];
        _welcomeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _welcomeLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"WelcomeTo", @"") attributes:@{
            NSForegroundColorAttributeName:FCStyle.accent,
            NSFontAttributeName: [UIFont boldSystemFontOfSize:60],
            NSKernAttributeName : @(0.5)
            
        }];
        _welcomeLabel.backgroundColor = UIColor.clearColor;
        _welcomeLabel.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:_welcomeLabel];
        [NSLayoutConstraint activateConstraints:@[
            [_welcomeLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
            [_welcomeLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
            [_welcomeLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:60],
        ]];
    }
    
    return _welcomeLabel;
}

- (UILabel *)stayLabel{
    if (nil == _stayLabel){
        _stayLabel = [[UILabel alloc] init];
        _stayLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _stayLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Stay", @"") attributes:@{
            NSForegroundColorAttributeName:FCStyle.accent,
            NSFontAttributeName: [UIFont boldSystemFontOfSize:60],
            NSKernAttributeName : @(0.5)
            
        }];
        _stayLabel.backgroundColor = UIColor.clearColor;
        _stayLabel.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:_stayLabel];
        [NSLayoutConstraint activateConstraints:@[
            [_stayLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
            [_stayLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
            [_stayLabel.topAnchor constraintEqualToAnchor:self.welcomeLabel.bottomAnchor]
        ]];
    }
    
    return _stayLabel;
}

- (UILabel *)developedLabel2{
    if (nil == _developedLabel2){
        _developedLabel2 = [[UILabel alloc] init];
        _developedLabel2.translatesAutoresizingMaskIntoConstraints = NO;
        _developedLabel2.text = @"APPS";
        _developedLabel2.textColor = FCStyle.fcSecondaryBlack;
        _developedLabel2.font = FCStyle.footnoteBold;
        [self.view addSubview:_developedLabel2];
        [NSLayoutConstraint activateConstraints:@[
            [_developedLabel2.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
            [_developedLabel2.topAnchor constraintEqualToAnchor:self.stayLabel.bottomAnchor constant:10]
        ]];
    }
    
    return _developedLabel2;
}

- (UIImageView *)djImageView{
    if (nil == _djImageView){
        _djImageView = [[UIImageView alloc] init];
        _djImageView.image = [UIImage imageNamed:@"DJIcon"];
        _djImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_djImageView];
        [NSLayoutConstraint activateConstraints:@[
            [_djImageView.trailingAnchor constraintEqualToAnchor:self.developedLabel2.leadingAnchor constant:-5],
            [_djImageView.topAnchor constraintEqualToAnchor:self.stayLabel.bottomAnchor constant:10]
        ]];
    }
    
    return _djImageView;
}

- (UILabel *)developedLabel1{
    if (nil == _developedLabel1){
        _developedLabel1 = [[UILabel alloc] init];
        _developedLabel1.translatesAutoresizingMaskIntoConstraints = NO;
        _developedLabel1.text = @"Developed by";
        _developedLabel1.textColor = FCStyle.fcSecondaryBlack;
        _developedLabel1.font = FCStyle.footnoteBold;
        [self.view addSubview:_developedLabel1];
        [NSLayoutConstraint activateConstraints:@[
            [_developedLabel1.trailingAnchor constraintEqualToAnchor:self.djImageView.leadingAnchor constant:-5],
            [_developedLabel1.topAnchor constraintEqualToAnchor:self.stayLabel.bottomAnchor constant:10]
        ]];
    }
    
    return _developedLabel1;
}

- (UITableView *)tableView{
    if (nil == _tableView){
        _tableView = [[UITableView alloc] init];
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
        if (@available(iOS 15.0, *)){
           _tableView.sectionHeaderTopPadding = 0;
        }
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.sectionFooterHeight = 0;
        _tableView.allowsSelection = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.backgroundColor = UIColor.clearColor;
        [self.view addSubview:_tableView];
        [NSLayoutConstraint activateConstraints:@[
            [_tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:5],
            [_tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-5],
            [_tableView.topAnchor constraintEqualToAnchor:self.developedLabel1.bottomAnchor constant:30],
            [_tableView.heightAnchor constraintEqualToConstant:15 * self.dataSource.count + 45 * 3]
        ]];
    }
    
    return _tableView;
}

- (NSArray<NSDictionary *> *)dataSource{
    if (nil == _dataSource){
        _dataSource = @[
            @{
                @"sectionElement" : [ModalSectionElement ofTitle:NSLocalizedString(@"", @"")],
                @"itemElements" : @[self.enableStayElemnt]
            },
            @{
                @"sectionElement" : [ModalSectionElement ofTitle:NSLocalizedString(@"", @"")],
                @"itemElements" : @[self.installUserscriptElement]
            },
            @{
                @"sectionElement" : [ModalSectionElement ofTitle:NSLocalizedString(@"", @"")],
                @"itemElements" : @[self.doneElement]
            }
        ];
    }
    
    return _dataSource;
}

- (ModalItemElement *)enableStayElemnt{
    if (nil == _enableStayElemnt){
        _enableStayElemnt = [[ModalItemElement alloc] init];
        __weak WelcomeModalViewController *weakSelf = (WelcomeModalViewController *)self;
        _enableStayElemnt.shadowRound = YES;
        ModalItemDataEntityGeneral *general = [[ModalItemDataEntityGeneral alloc] init];
        general.title = NSLocalizedString(@"EnableStayStep1", @"");
        general.titleFont = FCStyle.headlineBold;
        general.accessoryFont = FCStyle.sfSecondaryIconBold;
        ModalItemDataEntityAccessory *accessory = [[ModalItemDataEntityAccessory alloc] init];
        _enableStayElemnt.generalEntity = general;
        _enableStayElemnt.accessoryEntity = accessory;
        _enableStayElemnt.renderMode = ModalItemElementRenderModeSingle;
        _enableStayElemnt.type = ModalItemElementTypeAccessory;
        _enableStayElemnt.action = ^(ModalItemElement * _Nonnull element) {
            if (element.enable){
                EnableStayModalViewController *cer = [[EnableStayModalViewController alloc] init];
                cer.fullScreen = YES;
                [weakSelf.navigationController pushModalViewController:cer];
            }
        };
    }
    
    return _enableStayElemnt;
}

- (ModalItemElement *)installUserscriptElement{
    if (nil == _installUserscriptElement){
        _installUserscriptElement = [[ModalItemElement alloc] init];
        __weak WelcomeModalViewController *weakSelf = (WelcomeModalViewController *)self;
        _installUserscriptElement.shadowRound = YES;
        ModalItemDataEntityGeneral *general = [[ModalItemDataEntityGeneral alloc] init];
        general.title = NSLocalizedString(@"InstallUserscriptStep2", @"");
        general.titleFont = FCStyle.headlineBold;
        general.accessoryFont = FCStyle.sfSecondaryIconBold;
        ModalItemDataEntityAccessory *accessory = [[ModalItemDataEntityAccessory alloc] init];
        _installUserscriptElement.generalEntity = general;
        _installUserscriptElement.accessoryEntity = accessory;
        _installUserscriptElement.renderMode = ModalItemElementRenderModeSingle;
        _installUserscriptElement.type = ModalItemElementTypeAccessory;
        _installUserscriptElement.action = ^(ModalItemElement * _Nonnull element) {
            if (element.enable){
                InstallUserscriptModalViewController *cer = [[InstallUserscriptModalViewController alloc] init];
                cer.fullScreen = YES;
                [weakSelf.navigationController pushModalViewController:cer];
            }
        };
    }
    
    return _installUserscriptElement;
}

- (ModalItemElement *)doneElement{
    if (nil == _doneElement){
        _doneElement = [[ModalItemElement alloc] init];
        __weak WelcomeModalViewController *weakSelf = (WelcomeModalViewController *)self;
        _doneElement.shadowRound = YES;
        ModalItemDataEntityGeneral *general = [[ModalItemDataEntityGeneral alloc] init];
        general.title = NSLocalizedString(@"DoneStep3", @"");
        general.titleFont = FCStyle.headlineBold;
        general.accessoryFont = FCStyle.sfSecondaryIconBold;
        ModalItemDataEntityAccessory *accessory = [[ModalItemDataEntityAccessory alloc] init];
        _doneElement.generalEntity = general;
        _doneElement.accessoryEntity = accessory;
        _doneElement.renderMode = ModalItemElementRenderModeSingle;
        _doneElement.type = ModalItemElementTypeAccessory;
        _doneElement.action = ^(ModalItemElement * _Nonnull element) {
            if (element.enable){
                [[QuickAccess primaryController].fcTabBar selectIndex:1];
                [weakSelf.navigationController.slideController dismiss];
            }
        };
        
    }
    
    return _doneElement;
}

- (FCButton *)skipButton{
    if (nil == _skipButton){
        _skipButton = [[FCButton alloc] init];
        [_skipButton addTarget:self action:@selector(skipAction:) forControlEvents:UIControlEventTouchUpInside];
        [_skipButton setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"WelcomeSkip", @"")
                                                                attributes:@{
            NSForegroundColorAttributeName : FCStyle.accent,
            NSFontAttributeName : FCStyle.bodyBold
        }] forState:UIControlStateNormal];
        _skipButton.backgroundColor = UIColor.clearColor;
        _skipButton.layer.cornerRadius = 10;
        _skipButton.layer.borderColor = FCStyle.accent.CGColor;
        _skipButton.layer.borderWidth = 1;
        _skipButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_skipButton];
        
        [NSLayoutConstraint activateConstraints:@[
            [_skipButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-88],
            [_skipButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
            [_skipButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
            [_skipButton.heightAnchor constraintEqualToConstant:45]
        ]];
    }
    
    return _skipButton;
}

- (void)skipAction:(id)sender{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Stay"
                                                                   message:NSLocalizedString(@"WelcomeSkipAlert", @"")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"")
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
        NSUserDefaults *groupUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dajiu.stay.pro"];
        [groupUserDefaults setObject:@(YES) forKey:@"tips"];
        [groupUserDefaults setObject:@(YES) forKey:@"userDefaults.firstGuide"];
        [groupUserDefaults synchronize];
        [self.navigationController.slideController dismiss];
    }];
    [alert addAction:confirm];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"")
         style:UIAlertActionStyleCancel
         handler:^(UIAlertAction * _Nonnull action) {
     }];
     [alert addAction:cancel];
    [FCApp.keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    
}

- (LottieView *)congratulationsLottieView{
    if (nil == _congratulationsLottieView){
        _congratulationsLottieView = [[LottieView alloc] initWithAnimationName:@"congratulation"];
        _congratulationsLottieView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_congratulationsLottieView];
        [NSLayoutConstraint activateConstraints:@[
            [_congratulationsLottieView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
            [_congratulationsLottieView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
            [_congratulationsLottieView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
            [_congratulationsLottieView.topAnchor constraintEqualToAnchor:self.view.topAnchor]
        ]];
    }
    
    return _congratulationsLottieView;
}

- (CGSize)mainViewSize{
    return FCApp.keyWindow.size;
}

@end
