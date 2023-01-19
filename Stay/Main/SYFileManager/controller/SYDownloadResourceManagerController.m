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
#import <AVFoundation/AVFoundation.h>
#import "ToastCenter.h"
#import "SYTextInputViewController.h"
#import "SYChangeDocSlideController.h"
#import "DeviceHelper.h"
#import "QuickAccess.h"
#if iOS
#import "Stay-Swift.h"
#else
#import "Stay-Swift.h"
#endif
@interface SYDownloadResourceManagerController ()<
 UITableViewDelegate,
 UITableViewDataSource,
 UIDocumentPickerDelegate
>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ToastCenter *toastCenter;
@property (nonatomic, strong) SYTextInputViewController *sYTextInputViewController;
@property (nonatomic, strong) SYChangeDocSlideController *syChangeDocSlideController;
@end

@implementation SYDownloadResourceManagerController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadData];
    // Do any additional setup after loading the view.
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    // Do any additional setup after loading the view.
    self.tableView.sectionHeaderTopPadding = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeVideoDoc:) name:@"changeVideoDoc" object:nil];

}

- (void)changeVideoDoc:(NSNotification *)notification {
    [self reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   DownloadResource *downloadResource = self.array[indexPath.row];
    if(downloadResource.status == 2) {
        return 137;
    } else {
        return 128;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadResourceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DownloadResourcecellID"];
    
    DownloadResource *resource= self.array[indexPath.row];
    
    if(resource.status == 2) {
        if (cell == nil) {
            cell = [[DownloadResourceTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DownloadResourcecellID"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

        }
    } else {
        cell = [[DownloadResourceTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DownloadResourcecellIDR"];
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
        request.fileDir = tab.path;
        request.fileName = [cell.downloadResource.allPath lastPathComponent];
        request.fileType = @"video";
        request.key =  cell.downloadResource.firstPath;
        Task *task =  [[DownloadManager shared]  enqueue:request];
        
        resource.downloadProcess = task.progress;
        
        task.block = ^(float progress, NSString *speed, DMStatus status) {
            if(status == DMStatusFailed) {
                [[DataManager shareManager]updateDownloadResourceStatus:3 uuid:resource.downloadUuid];
                cell.downloadResource.status = 3;
            } else if(status == DMStatusDownloading) {
                if(resource.status != 0) {
                    [[DataManager shareManager]updateDownloadResourceStatus:0 uuid:resource.downloadUuid];
                }
//                [[DataManager shareManager] updateDownloadResourcProcess:progress * 100 uuid:cell.downloadResource.downloadUuid];
                resource.status = 0;
                resource.downloadProcess = progress * 100;
                dispatch_async(dispatch_get_main_queue(),^{
                    cell.progress.progress = progress;
                    cell.downloadRateLabel.text =  [NSString stringWithFormat:@"%@:%.1f%%",NSLocalizedString(@"Downloading",""),progress * 100];
                    [cell.downloadRateLabel sizeToFit];
                    cell.downloadSpeedLabel.left = cell.downloadRateLabel.right + 10;
                    cell.downloadSpeedLabel.text = speed;
                });
                
                return;
            } else if(status == DMStatusComplete) {
                [[DataManager shareManager]updateDownloadResourceStatus:2 uuid:resource.downloadUuid];
                AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:resource.allPath]];
                if (resource.icon.length == 0) {
                    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
                    CMTime time = CMTimeMake(1, 1);
                    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:nil error:nil];
                    if (imageRef != nil) {
                        UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
                        [[DataManager shareManager] updateIconByuuid:thumbnail uuid:resource.downloadUuid];
                    }
                    CGImageRelease(imageRef);
                }
                [[DataManager shareManager] updateVideoDuration:CMTimeGetSeconds(asset.duration) uuid:resource.downloadUuid];
                resource.status = 2;
                [self reloadData];
            } else if(status == DMStatusPending) {
                [[DataManager shareManager]updateDownloadResourceStatus:1 uuid:resource.downloadUuid];
                resource.status = 1;
            } else if(status == DMStatusTranscoding) {
                [[DataManager shareManager]updateDownloadResourceStatus:4 uuid:resource.downloadUuid];
                resource.status = 4;
            } else if(status == DMStatusFailedTranscode) {
                [[DataManager shareManager]updateDownloadResourceStatus:5 uuid:resource.downloadUuid];
                resource.status = 5;
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"FailedTranscode", @"")
                                                                               message:@""
                                                                        preferredStyle:UIAlertControllerStyleAlert];
               
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"")
                     style:UIAlertActionStyleCancel
                     handler:^(UIAlertAction * _Nonnull action) {
                 }];
                 [alert addAction:cancel];
                [self presentViewController:alert animated:YES completion:nil];
            } else if(status == DMStatusFailedNoSpace) {
                [[DataManager shareManager]updateDownloadResourceStatus:6 uuid:resource.downloadUuid];
                resource.status = 6;
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"FailedNoSpace", @"")
                                                                               message:@""
                                                                        preferredStyle:UIAlertControllerStyleAlert];
               
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"")
                     style:UIAlertActionStyleCancel
                     handler:^(UIAlertAction * _Nonnull action) {
                 }];
                 [alert addAction:cancel];
                [self presentViewController:alert animated:YES completion:nil];
            }
            
            dispatch_async(dispatch_get_main_queue(),^{
                [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
            });
        };
    }
    
    return cell;
    
}


- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    //Fixed retains self
    __weak SYDownloadResourceManagerController *weakSelf = self;
    
        UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
                    
            
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"needDeleteVideo", @"")
                                                                           message:@""
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *conform = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"")
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * _Nonnull action) {
                
                DownloadResource *downloadResource = weakSelf.array[indexPath.row];
                if(downloadResource.status == 2) {
                    NSFileManager *defaultManager;
                    defaultManager = [NSFileManager defaultManager];
                    [defaultManager removeItemAtPath:downloadResource.allPath error:nil];
                } else {
                    [[DownloadManager shared] remove:downloadResource.downloadUuid];
                }
                [[DataManager shareManager] deleteVideoByuuid:downloadResource.downloadUuid];
                [weakSelf.array removeObject:downloadResource];
                dispatch_async(dispatch_get_main_queue(),^{
                    [weakSelf.tableView reloadData];
                });
                
                
            }];
            [alert addAction:conform];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"")
                 style:UIAlertActionStyleCancel
                 handler:^(UIAlertAction * _Nonnull action) {
             }];
             [alert addAction:cancel];
            [self presentViewController:alert animated:YES completion:nil];
            [tableView setEditing:NO animated:YES];
        }];
        deleteAction.image = [UIImage imageNamed:@"delete"];
        deleteAction.backgroundColor = RGB(224, 32, 32);
        
    
    UIContextualAction *changeFloderAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        DownloadResource *downloadResource = weakSelf.array[indexPath.row];
        if (!weakSelf.syChangeDocSlideController.isShown){
            weakSelf.syChangeDocSlideController = [[SYChangeDocSlideController alloc] init];
            weakSelf.syChangeDocSlideController.dic = [[NSMutableDictionary alloc] init];
            weakSelf.syChangeDocSlideController.dic[@"title"] = downloadResource.title;
            weakSelf.syChangeDocSlideController.dic[@"downloadUuid"] = downloadResource.downloadUuid;
            weakSelf.syChangeDocSlideController.dic[@"uuid"] = downloadResource.firstPath;
            weakSelf.syChangeDocSlideController.controller = self.navigationController;
            [weakSelf.syChangeDocSlideController show];
        }
        [tableView setEditing:NO animated:YES];
    }];
    
    changeFloderAction.image = [ImageHelper sfNamed:@"pencil" font:[UIFont systemFontOfSize:15]];
    changeFloderAction.backgroundColor = FCStyle.accent;
    
    return [UISwipeActionsConfiguration configurationWithActions:@[deleteAction,changeFloderAction]];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadResource *downloadResource = self.array[indexPath.row];
    if(downloadResource.status == 2){
        NSArray<DownloadResource *> *resources = [[DataManager shareManager] selectDownloadComplete:self.pathUuid];
        int currIndex = 0;
        for (int i = 0; i < resources.count; i++) {
            if ([downloadResource.downloadUuid isEqualToString:resources[i].downloadUuid]) {
                currIndex = i;
                break;
            }
        }
        PlayerViewController *playerController = [[PlayerViewController alloc] initWithResources:resources folderName:[FCShared.tabManager tabNameWithUUID:self.pathUuid] initIndex:currIndex];
        playerController.modalPresentationStyle = UIModalPresentationFullScreen;
        if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
                      && [QuickAccess splitController].viewControllers.count >= 2){
            [[QuickAccess secondaryController] pushViewController:playerController];
        } else {
            [self.navigationController pushViewController:playerController animated:YES];
        }
    }
}

#pragma cellClickEvent

- (void)stopDownload:(UIButton *)sender {
    DownloadResource *resource = objc_getAssociatedObject(sender,@"resource");
    Request *request = [[Request alloc] init];
    request.url =  resource.downloadUrl;
    
    
    Task *task = [[DownloadManager shared]  queryByTaskId:resource.downloadUuid];;
    if(task != nil) {
        task.block = NULL;
        [[DataManager shareManager] updateDownloadResourcProcess:task.progress * 100 uuid:resource.downloadUuid];
    }
    [[DataManager shareManager]updateDownloadResourceStatus:1 uuid:resource.downloadUuid];
    [[DownloadManager shared] pause:resource.downloadUuid];
    [self reloadData];
}

- (void)retryDownload:(UIButton *)sender {
    DownloadResource *resource = objc_getAssociatedObject(sender,@"resource");
    [[DataManager shareManager]updateDownloadResourceStatus:0 uuid:resource.downloadUuid];
    [self reloadData];
}

- (void)continueDownload:(UIButton *)sender {
    DownloadResource *resource = objc_getAssociatedObject(sender,@"resource");
    [[DataManager shareManager]updateDownloadResourceStatus:0 uuid:resource.downloadUuid];
    [self reloadData];
}


- (void)saveToFile:(UIButton *)sender {
    DownloadResource *resource = objc_getAssociatedObject(sender,@"resource");
    NSURL *url = [NSURL fileURLWithPath:resource.allPath];
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initForExportingURLs:@[url] asCopy:YES];

    documentPicker.delegate = self;
    [self presentViewController:documentPicker animated:YES completion:nil];
}
- (void)saveToPhoto:(UIButton *)sender {
    DownloadResource *resource = objc_getAssociatedObject(sender,@"resource");

    NSURL *url = [NSURL fileURLWithPath:resource.allPath];
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.relativePath)){
        UISaveVideoAtPathToSavedPhotosAlbum(url.relativePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls{
    UIImage *image =  [UIImage systemImageNamed:@"checkmark.circle.fill"
                              withConfiguration:[UIImageSymbolConfiguration configurationWithFont:FCStyle.sfIcon]];
    image = [image imageWithTintColor:FCStyle.fcBlack
                        renderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.toastCenter show:image
                     mainTitle:NSLocalizedString(@"Video", @"")
                secondaryTitle:NSLocalizedString(@"SaveDone", @"")];
}


- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo {
    UIImage *image =  [UIImage systemImageNamed:@"checkmark.circle.fill"
                              withConfiguration:[UIImageSymbolConfiguration configurationWithFont:FCStyle.sfIcon]];
    image = [image imageWithTintColor:FCStyle.fcBlack
                        renderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.toastCenter show:image
                     mainTitle:NSLocalizedString(@"Video", @"")
                secondaryTitle:NSLocalizedString(@"SaveDone", @"")];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tableView.frame = self.view.bounds;
    self.tabBarController.tabBar.hidden = YES;
    [self reloadData];
}
 
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
}


- (void)reloadData {
    dispatch_async(dispatch_get_main_queue(),^{
        [self.array removeAllObjects];
        [self.array addObjectsFromArray:[[DataManager shareManager] selectUnDownloadComplete:self.pathUuid]];
        [self.array addObjectsFromArray:[[DataManager shareManager] selectDownloadComplete:self.pathUuid]];
        [self.tableView reloadData];
    });
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


- (SYTextInputViewController *)sYTextInputViewController {
    if(nil == _sYTextInputViewController) {
        _sYTextInputViewController = [[SYTextInputViewController alloc] init];
       _sYTextInputViewController.notificationName = @"changeVideoTitle";

    }
    return _sYTextInputViewController;
}


- (ToastCenter *)toastCenter{
    if (nil == _toastCenter){
        _toastCenter = [[ToastCenter alloc] init];
    }
    
    return _toastCenter;
}

@end
