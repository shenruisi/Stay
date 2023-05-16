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
#import "SYDownloadedViewCell.h"
#if FC_IOS
#import "Stay-Swift.h"
#else
#import "Stay-Swift.h"
#endif
#import "UIColor+Convert.h"

@interface SYDownloadResourceManagerController ()<
 UITableViewDelegate,
 UITableViewDataSource,
 UIDocumentPickerDelegate
>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) SYTextInputViewController *sYTextInputViewController;
@property (nonatomic, strong) SYChangeDocSlideController *syChangeDocSlideController;
@end

@implementation SYDownloadResourceManagerController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadData];
    self.hidesBottomBarWhenPushed = YES;
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
        return 160;
    } else {
        return 128;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SYDownloadedViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SYDownloadedViewCell"];
    
    DownloadResource *resource= self.array[indexPath.row];
    
    if(resource.status == 2) {
        if (cell == nil) {
            cell = [[SYDownloadedViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SYDownloadedViewCell"];
        }
        
        cell.contentView.width = self.view.width;
        cell.downloadResource = self.array[indexPath.row];
        cell.controller = self;
        __weak SYDownloadResourceManagerController *weakSelf = (SYDownloadResourceManagerController *)self;

        cell.tapAction = ^(id element) {
            DownloadResource *downloadResource = weakSelf.array[indexPath.row];
            if(downloadResource.status == 2){
                NSArray<DownloadResource *> *resources = [[DataManager shareManager] selectDownloadComplete:weakSelf.pathUuid];
                int currIndex = 0;
                for (int i = 0; i < resources.count; i++) {
                    if ([downloadResource.downloadUuid isEqualToString:resources[i].downloadUuid]) {
                        currIndex = i;
                        break;
                    }
                }
                PlayerViewController *playerController = [PlayerViewController controllerWithResources:resources folderName:[FCShared.tabManager tabNameWithUUID:weakSelf.pathUuid] initIndex:currIndex];
                playerController.modalPresentationStyle = UIModalPresentationFullScreen;
                if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
                    && [QuickAccess splitController].viewControllers.count >= 2){
                    [[QuickAccess secondaryController] pushViewController:playerController];
                } else {
                    [weakSelf.navigationController pushViewController:playerController animated:YES];
                }
            }
            
        };
        return cell;
    } else {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                       reuseIdentifier:nil];
        return cell;
    }
    
    

    
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    for (UIView *view in tableView.subviews){
        if ([view isKindOfClass:NSClassFromString(@"_UITableViewCellSwipeContainerView")]){
            for (UIView *pullView in view.subviews){
                if ([pullView isKindOfClass:NSClassFromString(@"UISwipeActionPullView")]) {
                    for (UIView *buttonView in pullView.subviews){
                        if ([buttonView isKindOfClass:NSClassFromString(@"UISwipeActionStandardButton")]) {
                            for (UIView *targetView in buttonView.subviews){
                                if (![targetView isKindOfClass:NSClassFromString(@"UIButtonLabel")]){
                                    targetView.backgroundColor = [[FCStyle.accent colorWithAlphaComponent:0.1] rgba2rgb:FCStyle.secondaryBackground];
                                }
                            }
                        }
                    }
                }
            }
        }
    }
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
    
    deleteAction.image = [[UIImage imageNamed:@"delete"] imageWithTintColor:RGB(224, 32, 32) renderingMode:UIImageRenderingModeAlwaysOriginal];

    deleteAction.backgroundColor = [UIColor clearColor];
        
    
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
    
    changeFloderAction.image = [ImageHelper sfNamed:@"pencil" font:[UIFont systemFontOfSize:15] color:FCStyle.accent];
    changeFloderAction.backgroundColor = [UIColor clearColor];
    
    return [UISwipeActionsConfiguration configurationWithActions:@[deleteAction,changeFloderAction]];
    
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    DownloadResource *downloadResource = self.array[indexPath.row];
//    if(downloadResource.status == 2){
//        NSArray<DownloadResource *> *resources = [[DataManager shareManager] selectDownloadComplete:self.pathUuid];
//        int currIndex = 0;
//        for (int i = 0; i < resources.count; i++) {
//            if ([downloadResource.downloadUuid isEqualToString:resources[i].downloadUuid]) {
//                currIndex = i;
//                break;
//            }
//        }
//        PlayerViewController *playerController = [PlayerViewController controllerWithResources:resources folderName:[FCShared.tabManager tabNameWithUUID:self.pathUuid] initIndex:currIndex];
//        playerController.modalPresentationStyle = UIModalPresentationFullScreen;
//        if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
//                      && [QuickAccess splitController].viewControllers.count >= 2){
//            [[QuickAccess secondaryController] pushViewController:playerController];
//        } else {
//            [self.navigationController pushViewController:playerController animated:YES];
//        }
//
//    }
//}

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
    [FCShared.toastCenter show:image
                     mainTitle:NSLocalizedString(@"Video", @"")
                secondaryTitle:NSLocalizedString(@"SaveDone", @"")];
}


- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo {
    UIImage *image =  [UIImage systemImageNamed:@"checkmark.circle.fill"
                              withConfiguration:[UIImageSymbolConfiguration configurationWithFont:FCStyle.sfIcon]];
    image = [image imageWithTintColor:FCStyle.fcBlack
                        renderingMode:UIImageRenderingModeAlwaysOriginal];
    [FCShared.toastCenter show:image
                     mainTitle:NSLocalizedString(@"Video", @"")
                secondaryTitle:NSLocalizedString(@"SaveDone", @"")];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    self.tableView.frame = self.view.bounds;
    self.tabBarController.tabBar.hidden = YES;
    [self reloadData];
}
 
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
#ifdef FC_MAC
//    [self.tableView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
#else
//        self.tableView.frame = self.view.bounds;
#endif
    
    
    [self.tableView reloadData];
    
}


- (void)reloadData {
    dispatch_async(dispatch_get_main_queue(),^{
        [self.array removeAllObjects];
        [self.array addObjectsFromArray:[[DataManager shareManager] selectDownloadComplete:self.pathUuid]];
        [self.tableView reloadData];
    });
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_tableView];
        
        [NSLayoutConstraint activateConstraints:@[
            [_tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
            [_tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
            [_tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
            [_tableView.heightAnchor constraintEqualToConstant:self.view.height - self.navigationController.tabBarController.tabBar.height]
        ]];
        
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

@end
