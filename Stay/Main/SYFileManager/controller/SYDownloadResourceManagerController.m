//
//  SYDownloadResourceManagerController.m
//  Stay
//
//  Created by zly on 2022/12/5.
//

#import "SYDownloadResourceManagerController.h"
#import "FCShared.h"
#import "DownloadResourceTableViewCell.h"
#import "FCStyle.h"
#import "ImageHelper.h"
#import "DataManager.h"
#import "DownloadManager.h"
#import <objc/runtime.h>

#if iOS
#import "Stay-Swift.h"
#else
#import "Stay-Swift.h"
#endif
@interface SYDownloadResourceManagerController ()<
UITableViewDelegate,
UITableViewDataSource
>
@property (nonatomic, strong) UITableView *tableView;



@end

@implementation SYDownloadResourceManagerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.array = [[DataManager shareManager] selectDownloadResourceByPath:self.pathUuid];
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    // Do any additional setup after loading the view.
    self.tableView.sectionHeaderTopPadding = 0;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 107;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadResourceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DownloadResourcecellID"];
    if (cell == nil) {
        cell = [[DownloadResourceTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DownloadResourcecellID"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

    }
    for (UIView *subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    
    cell.contentView.width = self.view.width;
    cell.downloadResource = self.array[indexPath.row];
    cell.controller = self;
    
    if( cell.downloadResource.status == 0) {
        FCTab *tab = [[FCShared tabManager] tabOfUUID:cell.downloadResource.firstPath];
        Request *request = [[Request alloc] init];
        request.url =  cell.downloadResource.downloadUrl;
        request.fileDir = tab.config.name;
        request.fileType = @"video";
        request.key =  cell.downloadResource.firstPath;
        Task *task =  [[DownloadManager shared]  enqueue:request];
        task.block = ^(float progress, DMStatus status) {
            if(status == DMStatusFailed) {
                [[DataManager shareManager]updateDownloadResourceStatus:3 uuid:cell.downloadResource.downloadUuid];
                cell.downloadResource.status = 3;
            } else if(status == DMStatusDownloading) {
                [[DataManager shareManager] updateDownloadResourcProcess:progress * 100 uuid:cell.downloadResource.downloadUuid];
                cell.downloadResource.status = 0;

            } else if(status == DMStatusComplete) {
                [[DataManager shareManager]updateDownloadResourceStatus:2 uuid:cell.downloadResource.downloadUuid];
                [[DataManager shareManager] updateDownloadResourcProcess:100 uuid:cell.downloadResource.downloadUuid];
                cell.downloadResource.status = 2;

            } else if(status == DMStatusPending) {
                [[DataManager shareManager]updateDownloadResourceStatus:1 uuid:cell.downloadResource.downloadUuid];
                cell.downloadResource.status = 1;
           }

            cell.downloadResource.downloadProcess = progress;

            dispatch_async(dispatch_get_main_queue(),^{
                [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
            });
        };
    }
    
    return cell;
    
}



- (void)playVideo:(UIButton *)sender{
    
}

- (void)stopDownload:(UIButton *)sender {
    DownloadResource *resource = objc_getAssociatedObject(sender,@"resource");
    [[DataManager shareManager]updateDownloadResourceStatus:1 uuid:resource.downloadUuid];
//    [[DownloadManager shared] pause:resource.downloadUuid];
    self.array = [[DataManager shareManager] selectDownloadResourceByPath:self.pathUuid];
    [self.tableView reloadData];
}

- (void)retryDownload:(UIButton *)sender {
    DownloadResource *resource = objc_getAssociatedObject(sender,@"resource");
    [[DataManager shareManager]updateDownloadResourceStatus:0 uuid:resource.downloadUuid];
    self.array = [[DataManager shareManager] selectDownloadResourceByPath:self.pathUuid];
    [self.tableView reloadData];

}

- (void)continueDownload:(UIButton *)sender {
    DownloadResource *resource = objc_getAssociatedObject(sender,@"resource");
    [[DataManager shareManager]updateDownloadResourceStatus:0 uuid:resource.downloadUuid];
    self.array = [[DataManager shareManager] selectDownloadResourceByPath:self.pathUuid];
    [self.tableView reloadData];


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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
