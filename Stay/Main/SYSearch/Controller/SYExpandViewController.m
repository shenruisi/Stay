//
//  SYExpandViewController.m
//  Stay
//
//  Created by zly on 2022/6/16.
//

#import "SYExpandViewController.h"
#import "ScriptMananger.h"
#import "ScriptEntity.h"
#import <CommonCrypto/CommonDigest.h>
#import "DataManager.h"
#import "SYDetailViewController.h"
#import "LoadingSlideController.h"
#import "SYEditViewController.h"
#import <objc/runtime.h>
#import "FCStyle.h"
#ifdef FC_MAC
#import "QuickAccess.h"
#endif

@interface SYExpandViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) LoadingSlideController *loadingSlideController;


@end

@implementation SYExpandViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView reloadData];
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;

}



#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.backgroundColor = DynamicColor(RGB(20, 20, 20),RGB(246, 246, 246));
    cell.contentView.backgroundColor =DynamicColor(RGB(20, 20, 20),RGB(246, 246, 246));
    for (UIView *subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    

    CGFloat leftWidth = self.view.frame.size.width - 30;

    CGFloat titleLabelLeftSize = 0;
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15 + titleLabelLeftSize , 15, leftWidth - titleLabelLeftSize, 24)];
    titleLabel.font = FCStyle.headlineBold;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.lineBreakMode= NSLineBreakByTruncatingTail;
    titleLabel.text = self.data[indexPath.row][@"name"];
    [titleLabel sizeToFit];
    [cell.contentView addSubview:titleLabel];

    UILabel *authorLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, leftWidth , 19)];
    authorLabel.font = FCStyle.body;
    authorLabel.textAlignment = NSTextAlignmentLeft;
    authorLabel.text = self.data[indexPath.row][@"author"];
    authorLabel.top = titleLabel.bottom + 5;
    [authorLabel sizeToFit];
    [cell.contentView addSubview:authorLabel];
    
    UILabel *descLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, leftWidth, 50)];
    descLabel.font = FCStyle.subHeadline;
    descLabel.textAlignment = NSTextAlignmentLeft;
    descLabel.lineBreakMode= NSLineBreakByTruncatingTail;
    descLabel.text = self.data[indexPath.row][@"description"];
    descLabel.numberOfLines = 2;
    [descLabel sizeToFit];
    descLabel.top = authorLabel.bottom + 5;
    descLabel.textColor = [UIColor grayColor];
    [cell.contentView addSubview:descLabel];
    

    NSString *uuidName = [NSString stringWithFormat:@"%@%@",self.data[indexPath.row][@"name"],self.data[indexPath.row][@"namespace"]];
    NSString *uuid = [self md5HexDigest:uuidName];
    ScriptEntity *entity = [ScriptMananger shareManager].scriptDic[uuid];

        
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 60, 25);
    btn.backgroundColor = FCStyle.accent;
    
    if(entity != nil) {
        [btn setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Detail", @"")
                                                                attributes:@{
            NSForegroundColorAttributeName : FCStyle.fcWhite,
            NSFontAttributeName : FCStyle.subHeadline
        }] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(queryDetail:) forControlEvents:UIControlEventTouchUpInside];
        objc_setAssociatedObject (btn , @"uuid", uuid, OBJC_ASSOCIATION_COPY_NONATOMIC);
    } else {
        [btn setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Get", @"")
                                                                attributes:@{
            NSForegroundColorAttributeName : FCStyle.fcWhite,
            NSFontAttributeName : FCStyle.subHeadline
        }] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(getDetail:) forControlEvents:UIControlEventTouchUpInside];
        objc_setAssociatedObject (btn , @"downloadUrl", self.data[indexPath.row][@"downloadURL"], OBJC_ASSOCIATION_COPY_NONATOMIC);
        objc_setAssociatedObject (btn , @"name", self.data[indexPath.row][@"name"], OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.layer.cornerRadius = 12;
    btn.top = descLabel.bottom + 15;
    btn.left = 15;

    [cell.contentView addSubview:btn];
    
    UIImage *image =  [UIImage systemImageNamed:@"v.circle.fill"
                                 withConfiguration:[UIImageSymbolConfiguration configurationWithFont:[UIFont systemFontOfSize:15]]];
    image = [image imageWithTintColor:FCStyle.fcBlack renderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, 15, 15);
    imageView.centerY = btn.centerY;
    imageView.left = btn.right + 12;
    [cell.contentView addSubview:imageView];
    
    UILabel *version = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 15)];
    version.font = FCStyle.footnote;
    version.text = self.data[indexPath.row][@"version"];
    version.textColor = FCStyle.fcBlack;
    version.centerY = btn.centerY;
    version.left = imageView.right + 5;
    [cell.contentView addSubview:version];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *str = self.data[indexPath.row][@"description"];
    if(str == nil) {
     return 133;
    } else {
        UILabel *descLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, kScreenWidth - 30, 50)];
        descLabel.font = [UIFont systemFontOfSize:15];
        descLabel.textAlignment = NSTextAlignmentLeft;
        descLabel.lineBreakMode= NSLineBreakByTruncatingTail;
        descLabel.numberOfLines = 2;
        descLabel.text = self.data[indexPath.row][@"description"];
        [descLabel sizeToFit];
        if (descLabel.height > 30) {
            return 153;
        } else {
            return 133;
        }
    }
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
#ifdef FC_MAC
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
#ifdef FC_MAC
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
