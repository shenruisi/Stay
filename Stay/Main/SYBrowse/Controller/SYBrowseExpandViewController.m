//
//  SYExpandViewController.m
//  Stay
//
//  Created by zly on 2022/6/16.
//

#import "SYBrowseExpandViewController.h"
#import "ScriptMananger.h"
#import "ScriptEntity.h"
#import <CommonCrypto/CommonDigest.h>
#import "DataManager.h"
#import "SYDetailViewController.h"
#import "LoadingSlideController.h"
#import "SYEditViewController.h"
#import <objc/runtime.h>
#import "FCStyle.h"
#import "BrowseDetailTableViewCell.h"
#import "SYNetworkUtils.h"
#import "Tampermonkey.h"
#import "NSString+Urlencode.h"
#import "UserscriptUpdateManager.h"
#import "SharedStorageManager.h"
#import "SYNetworkUtils.h"
#ifdef Mac
#import "QuickAccess.h"
#endif

@interface SYBrowseExpandViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) LoadingSlideController *loadingSlideController;
@property (nonatomic, strong) NSString  *selectedUrl;


@end

@interface BroExpandSimpleLoadingView : UIView

@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) UILabel *label;
- (void)start;
- (void)stop;
@end

@implementation BroExpandSimpleLoadingView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        [self indicator];
        [self label];
    }

    return self;
}

- (void)start{
    [self.superview bringSubviewToFront:self];
    self.hidden = NO;
    [self.indicator startAnimating];
}

- (void)stop{
    [self.superview sendSubviewToBack:self];
    self.hidden = YES;
    [self.indicator stopAnimating];
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    [self.label sizeToFit];
    CGFloat width = self.indicator.frame.size.width + self.label.frame.size.width;
    CGFloat left = (self.frame.size.width - width) / 2;
    [self.indicator setFrame:CGRectMake(left,
                                        (self.frame.size.height - self.indicator.frame.size.height)/2,
                                        self.indicator.frame.size.width,
                                        self.indicator.frame.size.height)];
    [self.label setFrame:CGRectMake(self.indicator.frame.origin.x + self.indicator.frame.size.width + 15,
                                    (self.frame.size.height - self.label.frame.size.height)/2,
                                    self.label.frame.size.width,
                                    self.label.frame.size.height)];
    [self.indicator startAnimating];
}

- (UIActivityIndicatorView *)indicator{
    if (nil == _indicator){
        _indicator = [[UIActivityIndicatorView alloc] init];
        [self addSubview:_indicator];
    }
    return _indicator;
}

- (UILabel *)label{
    if (nil == _label){
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        _label.font = FCStyle.body;
        _label.textColor = FCStyle.fcBlack;
        _label.text = NSLocalizedString(@"Loading", @"");
        [self addSubview:_label];
    }

    return _label;
}


- (void)setHidden:(BOOL)hidden{
    [super setHidden:hidden];

}

@end

@implementation SYBrowseExpandViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.url != nil && self.url.length > 0) {
        [self queryData];
    }
    
    [self.tableView reloadData];
//    self.title = self.titleName;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    // Do any additional setup after loading the view.

}

- (void)queryData{
//    [self.simpleLoadingView start];
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT),^{

        [[SYNetworkUtils shareInstance] requestGET:_url params:nil successBlock:^(NSString * _Nonnull responseObject) {
                NSData *jsonData = [responseObject dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
            options:NSJSONReadingMutableContainers
            error:nil];
            self.data = dic[@"biz"];
            dispatch_async(dispatch_get_main_queue(),^{
//                        [self.simpleLoadingView stop];
                        [self.tableView reloadData];
            });

            } failBlock:^(NSError * _Nonnull error) {
                  
            }];
    });
}



#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BrowseDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (cell == nil) {
        cell = [[BrowseDetailTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.contentView.width = self.view.width;
    cell.navigationController = self.navigationController;
    cell.controller = self;
    cell.selectedUrl = _selectedUrl;
    cell.entity = self.data[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 138;
}


- (void)notSupport:(id)sender {
    NSString *name = objc_getAssociatedObject(sender,@"name");

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:name
                                                                   message:NSLocalizedString(@"Not supported on this device", @"")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *conform = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"")
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
        }];
    [alert addAction:conform];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    [self.tableView reloadData];
}
 
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
}

- (void)queryDetail:(UIButton *)sender {
    NSString *uuid = objc_getAssociatedObject(sender,@"uuid");
    UserScript *model = [[DataManager shareManager] selectScriptByUuid:uuid];
    SYDetailViewController *cer = [[SYDetailViewController alloc] init];
    cer.isSearch = false;
    cer.script = model;
#ifdef Mac
    [[QuickAccess secondaryController] pushViewController:cer];
#else
    [self.navigationController pushViewController:cer animated:true];
#endif
}

- (void)getDetail:(UIButton *)sender {
    NSString *url = objc_getAssociatedObject(sender,@"downloadUrl");
    NSString *name = objc_getAssociatedObject(sender,@"name");
    NSArray *platforms = objc_getAssociatedObject(sender,@"platforms");
    _selectedUrl = url;
    [self.tableView reloadData];

    self.loadingSlideController.originSubText = name;
    [self.loadingSlideController show];

    
    
    NSMutableCharacterSet *set  = [[NSCharacterSet URLFragmentAllowedCharacterSet] mutableCopy];
     [set addCharactersInString:@"#"];
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT),^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[url stringByAddingPercentEncodingWithAllowedCharacters:set]]];
        NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        UserScript *userScript =  [[Tampermonkey shared] parseWithScriptContent:str];

        NSString *uuidName = [NSString stringWithFormat:@"%@%@",userScript.name,userScript.namespace];
        NSString *uuid = [self md5HexDigest:uuidName];
        userScript.uuid = uuid;
        userScript.active = true;
        userScript.downloadUrl = url;
        userScript.plafroms = platforms;
        _selectedUrl = nil;

        BOOL saveSuccess = [[UserscriptUpdateManager shareManager] saveRequireUrl:userScript];
        BOOL saveResourceSuccess = [[UserscriptUpdateManager shareManager] saveResourceUrl:userScript];
        if(!saveSuccess || !saveResourceSuccess) {
            [self.loadingSlideController updateSubText:NSLocalizedString(@"Error", @"")];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),
            dispatch_get_main_queue(), ^{
                if (self.loadingSlideController.isShown){
                    [self.loadingSlideController dismiss];
                    self.loadingSlideController = nil;
                }
            });
            [self.tableView reloadData];
            return;
        }
        if ([[DataManager shareManager] selectScriptByUuid:userScript.uuid].name.length == 0){
            [[DataManager shareManager] insertUserConfigByUserScript:userScript];
            NSNotification *notification = [NSNotification notificationWithName:@"scriptSaveSuccess" object:nil];
            [[NSNotificationCenter defaultCenter]postNotification:notification];
            NSNotification *addNotification = [NSNotification notificationWithName:@"app.stay.notification.userscriptDidAddNotification" object:nil userInfo:@{@"uuid":uuid}];
            [[NSNotificationCenter defaultCenter]postNotification:addNotification];
            dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT),^{
                NSString *url = [NSString stringWithFormat:@"%@%@",@"https://api.shenyin.name/stay-fork/install/",uuid];
                
                [[SYNetworkUtils shareInstance] requestGET:url params:nil successBlock:^(NSString * _Nonnull responseObject) {
                        NSData *jsonData = [responseObject dataUsingEncoding:NSUTF8StringEncoding];
             
                        } failBlock:^(NSError * _Nonnull error) {
                          
                        }];
            });
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),
        dispatch_get_main_queue(), ^{
            if (self.loadingSlideController.isShown){
                [self.loadingSlideController dismiss];
                self.loadingSlideController = nil;
            }
            [self initScrpitContent];
            NSString *content =  NSLocalizedString(@"Created", @"");
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:content preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *conform = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                }];
            [alert addAction:conform];
            [self presentViewController:alert animated:YES completion:nil];

            [self.tableView reloadData];
        });
    });
    
}


- (LoadingSlideController *)loadingSlideController{
    if (nil == _loadingSlideController){
        _loadingSlideController = [[LoadingSlideController alloc] init];
        _loadingSlideController.originMainText = NSLocalizedString(@"settings.downloadScript", @"");
    }
    
    return _loadingSlideController;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor =  DynamicColor(RGB(20, 20, 20),RGB(246, 246, 246));
        [self.view addSubview:_tableView];
    }
    
    return _tableView;
}


- (NSArray *)data {
    if (_data == nil) {
        _data = [NSArray array];
    }
    return _data;
}

- (NSString* )md5HexDigest:(NSString* )input {
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02X", digest[i]];
    }
    return result;
}

- (void)initScrpitContent{
    NSMutableArray *array =  [[NSMutableArray alloc] init];
    NSArray *datas =  [[DataManager shareManager] findScript:1];
    if(datas.count > 0) {
        for(int i = 0; i < datas.count; i++) {
            UserScript *script = datas[i];
            UserscriptInfo *info = [[SharedStorageManager shared] getInfoOfUUID:script.uuid];
            info.content = [script toDictionary];
            [info flush];
            script.parsedContent = @"";
            script.otherContent = @"";
            [array addObject: [script toDictionary]];
        }
        [SharedStorageManager shared].userscriptHeaders.content = array;
        [[SharedStorageManager shared].userscriptHeaders flush];
        [[ScriptMananger shareManager] buildData];
    }
    
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
