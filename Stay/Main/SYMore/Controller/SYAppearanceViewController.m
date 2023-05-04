//
//  SYAppearanceViewController.m
//  Stay
//
//  Created by zly on 2022/8/12.
//

#import "SYAppearanceViewController.h"
#import "FCStyle.h"
#import "FCConfig.h"
#import <objc/runtime.h>
#import "ImageHelper.h"
#ifdef FC_MAC
#import "FCShared.h"
#import "Plugin.h"
#endif

#import "QuickAccess.h"
#import "DeviceHelper.h"

NSNotificationName const _Nonnull AppearanceDidChangeAccentColorNotification = @"app.stay.notification.AppearanceDidChangeAccentColorNotification";


@interface _AppearanceTableViewCell : UITableViewCell
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *entity;
@property (nonatomic, strong) UIImageView *accessory;

@end

@implementation _AppearanceTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.textLabel.font = FCStyle.body;
        self.textLabel.textColor = FCStyle.fcBlack;
        self.backgroundColor = FCStyle.secondaryBackground;
    }
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
}



- (void)setEntity:(NSDictionary<NSString *, NSString *>  *)entity{
    _entity = entity;
    
    NSMutableAttributedString *builder = [[NSMutableAttributedString alloc] init];
    NSString *title = entity[@"title"];
    if (title.length > 0){
        [builder appendAttributedString:[[NSAttributedString alloc] initWithString:title attributes:@{
            NSForegroundColorAttributeName:FCStyle.fcBlack,
            NSFontAttributeName:FCStyle.body
            
        }]];
    }
    
    NSString *subtitle = entity[@"subtitle"];
    if (subtitle.length > 0){
        [builder appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",subtitle] attributes:@{
            NSForegroundColorAttributeName:FCStyle.fcSecondaryBlack,
            NSFontAttributeName:FCStyle.footnote,
        }]];
    }
    

    NSString *type = entity[@"type"];
    if (type != nil && type.length > 0) {
        NSString *themeType = [[FCConfig shared] getStringValueOfKey:GroupUserDefaultsKeyAppearanceMode];
        if (themeType == nil) {
            themeType = @"System";
        }
        
        if ([themeType isEqualToString:type]) {
            [self accessory];
        }
        
        NSString *backgroundType = [[FCConfig shared] getStringValueOfKey:GroupUserDefaultsKeyBackgroundColorType];
        
        if (backgroundType == nil) {
            themeType = @"gradient";
        }
        
        if ([backgroundType isEqualToString:type]) {
            [self accessory];
        }
        
    }
    NSString *colorListStr = entity[@"colorList"];
    
    if(colorListStr != nil && colorListStr.length > 0) {
        CGFloat left = 10;
        NSArray *colorList = [colorListStr componentsSeparatedByString:@","];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *themeColor = [userDefaults objectForKey:@"themeColor"];
        
        if(themeColor == nil ) {
            themeColor = @"#B620E0";
        }

        for (int i = 0; i < colorList.count; i++) {
    
            
            NSString *color = colorList[i];
        
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setBackgroundColor:[self colorWithHexString:color alpha:1]];
            btn.frame = CGRectMake(0, 0, 23, 23);
            btn.layer.cornerRadius = 11.5;
#ifdef FC_MAC
            btn.frame = CGRectMake(0, 0, 18, 18);
            btn.layer.cornerRadius = 9;
#endif
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 29, 29)];
            btn.centerY = 14.5;
            btn.centerX = 14.5;
            
#ifdef FC_MAC
            view.frame = CGRectMake(0, 0, 24, 24);
            btn.centerY = 12;
            btn.centerX = 12;
#endif
            
            

            [btn addTarget:self action:@selector(changeColor:) forControlEvents:UIControlEventTouchUpInside];
            objc_setAssociatedObject (btn , @"color", color, OBJC_ASSOCIATION_COPY_NONATOMIC);

            if([themeColor isEqualToString:color]) {
                view.layer.borderWidth = 2;
                view.layer.borderColor = [self colorWithHexString:color alpha:0.5].CGColor;
                view.layer.cornerRadius = 14.5;

#ifdef FC_MAC
                view.layer.cornerRadius = 12;
#endif

            }
            
            [view addSubview:btn];
#ifdef FC_MAC
            view.centerY = 17.5;
#else
            view.centerY = 22.5;
#endif
    

            view.left = left;
            [self.contentView addSubview:view];
     
            left += 27 + 10;
        }
    
    }
    self.textLabel.attributedText = builder;;
}

- (void)changeColor:(UIButton *)sender {
    NSString *color = objc_getAssociatedObject(sender,@"color");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeThemeColor" object:color];
}

- (UIImageView *)accessory{
    if (nil == _accessory){
        _accessory = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 23, 23)];
        UIImage *image = [ImageHelper sfNamed:@"checkmark.circle.fill" font:FCStyle.headline color:FCStyle.accent];
        [_accessory setImage:image];
        self.accessoryView =_accessory;
    }
    
    return _accessory;
}

- (UIColor *)colorWithHexString:(NSString *)string alpha:(CGFloat) alpha
{
    if ([string hasPrefix:@"#"])
        string = [string substringFromIndex:1];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.length = 2;
    
    range.location = 0;
    NSString *rString = [string substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [string substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [string substringWithRange:range];
    
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r/255.0f) green:((float)g/255.0f) blue:((float)b/255.0f) alpha:alpha];
}



@end




@interface SYAppearanceViewController ()<
UITableViewDelegate,
UITableViewDataSource
>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSDictionary *> *dataSource;
@property (nonatomic, strong) UIBarButtonItem *closeBtn;
@end

@implementation SYAppearanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.view.backgroundColor = FCStyle.background;
    [self tableView];
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    self.title = NSLocalizedString(@"settings.appearance",@"Appearance");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeThemeColor:) name:@"changeThemeColor" object:nil];
    // Do any additional setup after loading the view.
#if FC_MAC
    self.navigationItem.leftBarButtonItem = self.closeBtn;
#endif
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:true];
    NSString *type = [[FCConfig shared] getStringValueOfKey:GroupUserDefaultsKeyAppearanceMode];
    if([@"System" isEqual:type]) {
        [[UIApplication sharedApplication].keyWindow setOverrideUserInterfaceStyle:UIUserInterfaceStyleUnspecified];
    } else if([@"Dark" isEqual:type]){
        [[UIApplication sharedApplication].keyWindow setOverrideUserInterfaceStyle:UIUserInterfaceStyleDark];
    }else if([@"Light" isEqual:type]){
        [[UIApplication sharedApplication].keyWindow setOverrideUserInterfaceStyle:UIUserInterfaceStyleLight];
    }
    [self.tableView setFrame:self.view.bounds];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return ((NSArray *)self.dataSource[section][@"cells"]).count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return self.dataSource[section][@"section"];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    _AppearanceTableViewCell *cell = nil;
    NSDictionary *entity = self.dataSource[indexPath.section][@"cells"][indexPath.row];
    cell = [[_AppearanceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.entity = entity;
    return cell;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
#ifdef FC_MAC
    return 35.0;
#else
    return 45.0;
#endif
    
}

- (void)clickClose:(id)sender{
    [self dismissModalViewControllerAnimated:true];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dict = self.dataSource[indexPath.section][@"cells"][indexPath.row];
    NSString *url = dict[@"url"];
    NSString *type = dict[@"type"];
    if (url.length > 0){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]
                                           options:@{} completionHandler:^(BOOL succeed){}];
    } else if([@"System" isEqual:type]) {
        [[UIApplication sharedApplication].keyWindow setOverrideUserInterfaceStyle:UIUserInterfaceStyleUnspecified];
#if FC_MAC
        for(UIWindow *window in [[UIApplication sharedApplication] windows]) {
            [window setOverrideUserInterfaceStyle:UIUserInterfaceStyleUnspecified];
        }
        [FCShared.plugin.appKit appearanceChanged:type];
#endif
        [[FCConfig shared] setStringValueOfKey:GroupUserDefaultsKeyAppearanceMode value:@"System"];
    } else if([@"Dark" isEqual:type]){
        [[UIApplication sharedApplication].keyWindow setOverrideUserInterfaceStyle:UIUserInterfaceStyleDark];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
#if FC_MAC
        for(UIWindow *window in [[UIApplication sharedApplication] windows]) {
            [window setOverrideUserInterfaceStyle:UIUserInterfaceStyleDark];
        }
        [FCShared.plugin.appKit appearanceChanged:type];
#endif
        [[FCConfig shared] setStringValueOfKey:GroupUserDefaultsKeyAppearanceMode value:@"Dark"];
    }else if([@"Light" isEqual:type]){
        [[UIApplication sharedApplication].keyWindow setOverrideUserInterfaceStyle:UIUserInterfaceStyleLight];
#if FC_MAC
        for(UIWindow *window in [[UIApplication sharedApplication] windows]) {
            [window setOverrideUserInterfaceStyle:UIUserInterfaceStyleLight];
        }
        [FCShared.plugin.appKit appearanceChanged:type];
#endif
        [[FCConfig shared] setStringValueOfKey:GroupUserDefaultsKeyAppearanceMode value:@"Light"];
    }
    else if ([@"gradient" isEqualToString:type]){
        [[FCConfig shared] setStringValueOfKey:GroupUserDefaultsKeyBackgroundColorType value:@"gradient"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BackgroundColorDidChange" object:nil];
    }
    else if ([@"solid" isEqualToString:type]){
        [[FCConfig shared] setStringValueOfKey:GroupUserDefaultsKeyBackgroundColorType value:@"solid"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BackgroundColorDidChange" object:nil];
    }
    
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return 0.0F;
    }
    return 20;
}


- (NSArray *)dataSource{
    if (nil == _dataSource){
        _dataSource = @[
            @{
                @"cells":@[
                    @{@"title":NSLocalizedString(@"settings.system",@"System"),
                      @"type":@"System"
                    },
                    @{@"title":NSLocalizedString(@"settings.dark",@"Dark"),
                      @"type":@"Dark"

                    },
                    @{@"title":NSLocalizedString(@"settings.light",@"Light"),
                      @"type":@"Light"
                    }
                ]
            },
            @{
                @"section":NSLocalizedString(@"BackgroundColor",@""),
                @"cells":@[
                    @{@"title":NSLocalizedString(@"GradientColor",@""),
                      @"type":@"gradient"
                    },
                    @{@"title":NSLocalizedString(@"SolidColor",@""),
                      @"type":@"solid"

                    }
                ]
            },
            @{
                @"section":NSLocalizedString(@"AccentColor",@"ACCENT COLOR"),
                @"cells":@[
                    @{@"colorList":@"#B620E0,#0091FF,#D91D06,#FA6400,#F7B500,#6236FF,#6D7278"
                    },
                ]
            },
        ];
    }
    
    return _dataSource;
}

- (void)changeThemeColor:(NSNotification *)notification {
    NSString *color = notification.object;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:color forKey:@"themeColor"];
    [userDefaults synchronize];
    [[UINavigationBar appearance] setTintColor:[FCStyle colorWithHexString:color alpha:1]];
    NSArray *list = @[@"rectangle.stack.fill",@"square.grid.2x2.fill",@"square.and.arrow.down.fill",@"gearshape.fill"];
    for(int i = 0; i < 4; i++){
        UITabBarItem *item =  self.navigationController.tabBarController.tabBar.items[i];
        NSString *imageName = list[i];
        item.selectedImage =  [ImageHelper sfNamed:imageName font:[UIFont systemFontOfSize:18] color:FCStyle.accent];
            
    }
    [self.tableView reloadData];

#ifndef FC_MAC
    for (UINavigationController *navigationController in self.navigationController.tabBarController.viewControllers){
        for (UIBarButtonItem *item in navigationController.topViewController.navigationItem.leftBarButtonItems){
            item.image = [item.image imageWithTintColor:FCStyle.accent renderingMode:UIImageRenderingModeAlwaysOriginal];
        }
        for (UIBarButtonItem *item in navigationController.topViewController.navigationItem.rightBarButtonItems){
            item.image = [item.image imageWithTintColor:FCStyle.accent renderingMode:UIImageRenderingModeAlwaysOriginal];
        }
    }
#endif
    
    
//#ifdef FC_MAC
//    [FCShared.plugin.appKit accentColorChanged:color];
//    for(int i = 0; i < 3; i++){
//        UITabBarItem *item = [QuickAccess  primaryController].tabBar.items[i];
//        NSString *imageName = list[i];
//        item.selectedImage =  [ImageHelper sfNamed:imageName font:[UIFont systemFontOfSize:18] color:FCStyle.accent];
//    }
//    
//    self.navigationItem.leftBarButtonItem.tintColor = FCStyle.accent;
//#endif
    
    if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
        && [QuickAccess splitController].viewControllers.count >= 2){
        [[QuickAccess secondaryController] setTintColor:[FCStyle colorWithHexString:color alpha:1]];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AppearanceDidChangeAccentColorNotification object:nil];
    
}

- (void)statusBarChange{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tableView.frame = self.view.bounds;
        [self.tableView reloadData];
    });
}


- (UITableView *)tableView{
    if (nil == _tableView){
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleInsetGrouped];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorInset = UIEdgeInsetsMake(0, 20, 0, 0);
        _tableView.separatorColor = FCStyle.fcSeparator;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_tableView];
    }
    
    return _tableView;
}

- (UIBarButtonItem *)closeBtn {
    if(_closeBtn == nil) {
        _closeBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"settings.close","close") style:UIBarButtonItemStylePlain target:self action:@selector(clickClose:)];
        _closeBtn.tintColor = FCStyle.accent;
    }
    return _closeBtn;
}

@end
