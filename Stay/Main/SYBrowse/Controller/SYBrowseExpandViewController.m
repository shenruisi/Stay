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
#ifdef Mac
#import "QuickAccess.h"
#endif

@interface SYBrowseExpandViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) LoadingSlideController *loadingSlideController;


@end

@implementation SYBrowseExpandViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView reloadData];
//    self.title = self.titleName;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    // Do any additional setup after loading the view.
#ifdef Mac
    self.navigationController.navigationBarHidden = YES;
#endif
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
    cell.entity = self.data[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 138;
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

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
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
    NSString *downloadUrl = objc_getAssociatedObject(sender,@"downloadUrl");
    NSString *name = objc_getAssociatedObject(sender,@"name");

    self.loadingSlideController.originSubText = name;
    [self.loadingSlideController show];
    NSMutableCharacterSet *set  = [[NSCharacterSet URLFragmentAllowedCharacterSet] mutableCopy];
     [set addCharactersInString:@"#"];
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT),^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[downloadUrl stringByAddingPercentEncodingWithAllowedCharacters:set]]];
        dispatch_async(dispatch_get_main_queue(),^{
            if(data != nil ) {
                
                if (self.loadingSlideController.isShown){
                    [self.loadingSlideController dismiss];
                    self.loadingSlideController = nil;
                }
                NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                SYEditViewController *cer = [[SYEditViewController alloc] init];
                cer.content = str;
                cer.downloadUrl = downloadUrl;
#ifdef Mac
                [[QuickAccess secondaryController] pushViewController:cer];
#else
                [self.navigationController pushViewController:cer animated:true];
#endif
                
            }
            else{
                [self.loadingSlideController updateSubText:NSLocalizedString(@"Error", @"")];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),
                dispatch_get_main_queue(), ^{
                    if (self.loadingSlideController.isShown){
                        [self.loadingSlideController dismiss];
                        self.loadingSlideController = nil;
                    }
                });
            }
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




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
