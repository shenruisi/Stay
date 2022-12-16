//
//  SYFIleManagerViewController.m
//  Stay
//
//  Created by zly on 2022/12/4.
//

#import "SYFIleManagerViewController.h"
#import "FCShared.h"
#import "DownloadFileTableViewCell.h"
#import "FCStyle.h"
#import "SYDownloadResourceManagerController.h"
#import "ImageHelper.h"
#import "DataManager.h"
#if iOS
#import "Stay-Swift.h"
#else
#import "Stay-Swift.h"
#endif
@interface SYFIleManagerViewController ()<
UITableViewDelegate,
UITableViewDataSource,
UISearchResultsUpdating,
UISearchBarDelegate,
UISearchControllerDelegate,
UIPopoverPresentationControllerDelegate,
UIDocumentPickerDelegate
>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) FolderSlideController *folderSlideController;

@end

@implementation SYFIleManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    // Do any additional setup after loading the view.
    
    UISearchController *search = [[UISearchController alloc]initWithSearchResultsController:nil];
       // 设置结果更新代理
//    search.searchResultsUpdater = self;
    search.searchBar.placeholder = NSLocalizedString(@"SearchVideo", @"");
    self.navigationItem.searchController = search;
    self.navigationItem.searchController.delegate = self;
    self.navigationItem.searchController.searchBar.delegate = self;
    self.navigationItem.searchController.obscuresBackgroundDuringPresentation = false;
    self.navigationItem.hidesSearchBarWhenScrolling = false;

    self.tableView.sectionHeaderTopPadding = 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [FCShared tabManager].tabs.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 42;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 38;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SYDownloadResourceManagerController *controller = [[SYDownloadResourceManagerController alloc] init];
    controller.pathUuid = [FCShared tabManager].tabs[indexPath.row].uuid;
    controller.title = [FCShared tabManager].tabs[indexPath.row].config.name;
    controller.array = [NSMutableArray array];
    [controller.array addObjectsFromArray: [[DataManager shareManager] selectDownloadResourceByPath:controller.pathUuid]];
    [self.navigationController pushViewController:controller animated:TRUE];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {    UIView *headrView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 46)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 100, 18)];
    label.font = FCStyle.headlineBold;
    label.text = NSLocalizedString(@"Folders", @"");
    
    [headrView addSubview:label];
    
    
    UIImageView *addImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [addImage setImage:[ImageHelper sfNamed:@"plus.circle" font:[UIFont systemFontOfSize:17] color:FCStyle.accent]];
    
    addImage.centerY = label.centerY;
    addImage.right = self.view.width - 17;
    [headrView addSubview:addImage];

    UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addFolder:)];
    [addImage addGestureRecognizer:tapGestureRecognizer1];
    //让UIImageView和它的父类开启用户交互属性
    [addImage setUserInteractionEnabled:YES];
    
    return headrView;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadFileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DownloadcellID"];
    if (cell == nil) {
        cell = [[DownloadFileTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DownloadcellID"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    for (UIView *subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    
    cell.contentView.width = self.view.width;
    cell.cer = self;
    cell.fctab = [FCShared tabManager].tabs[indexPath.row];
    
    return cell;
}


-(void)addFolder:(UITapGestureRecognizer *)tap{
    NSLog(@"点击图片");
    [self.folderSlideController show];
}


- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = DynamicColor(RGB(28, 28, 28),[UIColor whiteColor]);
        [self.view addSubview:_tableView];
    }
    return _tableView;
}


- (FolderSlideController *)folderSlideController {
    if(_folderSlideController == nil) {
        _folderSlideController = [[FolderSlideController alloc] initWithFolderTab:nil];
    }
    return _folderSlideController;
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
