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
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeVideoTitle:) name:@"changeVideoTitle" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeVideoDoc:) name:@"changeVideoDoc" object:nil];

}

- (void)changeVideoTitle:(NSNotification *)notification {
    [self.sYTextInputViewController dismiss];
    NSString *uuid = self.sYTextInputViewController.uuid;
    self.sYTextInputViewController = nil;
    NSString *title = notification.object;
    [[DataManager shareManager] updateVideoTitle:title uuid:uuid];
    [self reloadData];
}
- (void)changeVideoDoc:(NSNotification *)notification {
    [self reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   DownloadResource *downloadResource = self.array[indexPath.row];
//    if(downloadResource.status == 2) {
        return 137;
//    }
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
        request.fileDir = tab.path;
        request.fileName = [cell.downloadResource.allPath lastPathComponent];
        request.fileType = @"video";
        request.key =  cell.downloadResource.firstPath;
        Task *task =  [[DownloadManager shared]  enqueue:request];
        
        task.block = ^(float progress, NSString *speed, DMStatus status) {
            if(status == DMStatusFailed) {
                [[DataManager shareManager]updateDownloadResourceStatus:3 uuid:cell.downloadResource.downloadUuid];
                cell.downloadResource.status = 3;
            } else if(status == DMStatusDownloading) {
                if(cell.downloadResource.status != 0) {
                    [[DataManager shareManager]updateDownloadResourceStatus:0 uuid:cell.downloadResource.downloadUuid];
                }
//                [[DataManager shareManager] updateDownloadResourcProcess:progress * 100 uuid:cell.downloadResource.downloadUuid];
                cell.downloadResource.status = 0;
                cell.downloadResource.downloadProcess = progress * 100;
                dispatch_async(dispatch_get_main_queue(),^{
                    cell.progress.progress = progress;
                    cell.downloadRateLabel.text =  [NSString stringWithFormat:@"%@:%.1f%%",NSLocalizedString(@"Downloading",""),progress * 100];
                });
                
                return;
            } else if(status == DMStatusComplete) {
                [[DataManager shareManager]updateDownloadResourceStatus:2 uuid:cell.downloadResource.downloadUuid];
                AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:cell.downloadResource.allPath]];
                if (cell.downloadResource.icon.length == 0) {
                    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
                    CMTime time = CMTimeMake(1, 1);
                    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:nil error:nil];
                    if (imageRef != nil) {
                        UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
                        [[DataManager shareManager] updateIconByuuid:thumbnail uuid:cell.downloadResource.downloadUuid];
                    }
                    CGImageRelease(imageRef);
                }
                [[DataManager shareManager] updateVideoDuration:CMTimeGetSeconds(asset.duration) uuid:cell.downloadResource.downloadUuid];
                cell.downloadResource.status = 2;
                [self reloadData];
            } else if(status == DMStatusPending) {
                [[DataManager shareManager]updateDownloadResourceStatus:1 uuid:cell.downloadResource.downloadUuid];
                cell.downloadResource.status = 1;
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
    
    changeFloderAction.image = [ImageHelper sfNamed:@"arrowshape.turn.up.right" font:[UIFont systemFontOfSize:15]];

    changeFloderAction.backgroundColor = FCStyle.fcBlue;
    
    UIContextualAction *changeTitleAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        DownloadResource *downloadResource = self.array[indexPath.row];
        self.sYTextInputViewController.uuid = downloadResource.downloadUuid;
        [self.sYTextInputViewController show];
        [tableView setEditing:NO animated:YES];
    }];
    
    changeTitleAction.image = [ImageHelper sfNamed:@"pencil" font:[UIFont systemFontOfSize:15]];

    changeTitleAction.backgroundColor = FCStyle.accent;
    
    return [UISwipeActionsConfiguration configurationWithActions:@[deleteAction,changeFloderAction,changeTitleAction]];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadResource *downloadResource = self.array[indexPath.row];
    if(downloadResource.status == 2){
        PlayerViewController *playerController = [[PlayerViewController alloc] initWithResource:downloadResource];
        playerController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController pushViewController:playerController animated:YES];
    }
}

#pragma cellClickEvent

- (void)playVideo:(UIButton *)sender{
    DownloadResource *resource = objc_getAssociatedObject(sender,@"resource");
    PlayerViewController *playerController = [[PlayerViewController alloc] initWithResource:resource];
    playerController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController pushViewController:playerController animated:YES];
}

- (void)stopDownload:(UIButton *)sender {
    DownloadResource *resource = objc_getAssociatedObject(sender,@"resource");
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
    self.tabBarController.tabBar.hidden = YES;
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
