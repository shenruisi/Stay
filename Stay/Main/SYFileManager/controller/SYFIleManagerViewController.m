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
#import "DownloadManager.h"
#import <objc/runtime.h>
#import <AVFoundation/AVFoundation.h>
#import "DownloadResourceTableViewCell.h"
#import "DeviceHelper.h"
#import "QuickAccess.h"
#import "SYDownloadPreviewController.h"

#if iOS
#import "Stay-Swift.h"
#else
#import "Stay-Swift.h"
#endif
#import "SYDownloadSlideController.h"

static CGFloat kMacToolbar = 50.0;

@interface _FileEmptyTipsView : UIView

@property (nonatomic, strong) UIImageView *part1Img;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) UIViewController *controller;
- (void)movePart;
@end

@implementation _FileEmptyTipsView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        [self part1Img];
        [self addButton];
    }
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    self.part1Img.centerX = self.width / 2;
    self.part1Img.bottom = self.height / 2;
    self.addButton.top = self.part1Img.bottom + 29;
    self.addButton.centerX = self.width / 2;

//    self.addButton.frame = CGRectMake(self.part1Label.right, y, self.addButton.width, self.addButton.height);
//    self.part2Label.frame = CGRectMake(self.addButton.right, y, self.part2Label.width, self.part2Label.height);
}

- (void)movePart {
    self.part1Img.centerX = self.width / 2;
    self.part1Img.bottom = self.height / 2;
    self.addButton.top = self.part1Img.bottom + 29;
    self.addButton.centerX = self.width / 2;
}

- (UIImageView *)part1Img{
    if (nil == _part1Img){
        _part1Img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 88, 95)];
        _part1Img.image = [ImageHelper sfNamed:@"square.and.arrow.down.fill" font:[UIFont systemFontOfSize:80] color:RGB(138, 138, 138)];
        [self addSubview:_part1Img];
    }
    return _part1Img;
}

- (UIButton *)addButton{
    if (nil == _addButton){
        _addButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 175, 29)];
        [_addButton setTitle:NSLocalizedString(@"UpgradeTo", @"") forState:UIControlStateNormal];
        _addButton.layer.borderColor = FCStyle.borderGolden.CGColor;
        _addButton.layer.borderWidth = 1;
        _addButton.backgroundColor =  FCStyle.backgroundGolden;
        [_addButton setTitleColor:FCStyle.fcGolden forState:UIControlStateNormal];
        _addButton.font = FCStyle.subHeadline;
        _addButton.layer.cornerRadius = 10;
        [self addSubview:_addButton];
    }
    
    return _addButton;
}



@end

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
@property (nonatomic, strong) UIBarButtonItem *addItem;
@property (nonatomic, strong) SYDownloadSlideController *downloadSlideController;
@property (nonatomic, strong) UITableView *searchTableView;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) _FileEmptyTipsView *emptyTipsView;
@property (nonatomic, strong) NSMutableArray *searchData;
@property (nonatomic, strong) SYDownloadPreviewController *sYDownloadPreviewController;


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
    
    self.searchController = search;
    self.searchController.delegate = self;
    self.searchController.searchBar.delegate = self;
    [self.searchController.searchBar setTintColor:FCStyle.accent];
    [self.searchController.view addSubview:self.searchTableView];
    
    self.tableView.sectionHeaderTopPadding = 0;
    self.tableView.frame = self.view.bounds;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(buildFolder:)
                                                 name:@"app.stay.notification.SYFolderChangeNotification"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showUpgrade)
                                                 name:@"showUpgrade"
                                               object:nil];

    Boolean isPro = [[FCStore shared] getPlan:NO] == FCPlan.None?FALSE:TRUE;

    if(isPro) {
        self.navigationItem.rightBarButtonItems = @[[self addItem]];
    }

    [self emptyTipsView];

}

- (void)showUpgrade {
#ifdef Mac
            [self presentViewController:
             [[UINavigationController alloc] initWithRootViewController:[[SYSubscribeController alloc] init]]
                               animated:YES completion:^{}];
#else
            [self.navigationController pushViewController:[[SYSubscribeController alloc] init] animated:YES];
#endif
    
}

- (UIBarButtonItem *)addItem{
    if (nil == _addItem){
        _addItem = [[UIBarButtonItem alloc] initWithImage:[ImageHelper sfNamed:@"plus"
                                                                            font:FCStyle.sfNavigationBar
                                                                           color:FCStyle.fcMacIcon]
                                                      style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(addBtnClick:)];
    }
    return _addItem;
}


#pragma cellClickEvent

- (void)stopDownload:(UIButton *)sender {
    DownloadResource *resource = objc_getAssociatedObject(sender,@"resource");
    [[DataManager shareManager]updateDownloadResourceStatus:1 uuid:resource.downloadUuid];
    [[DownloadManager shared] pause:resource.downloadUuid];
    [self.searchTableView reloadData];
}

- (void)retryDownload:(UIButton *)sender {
    DownloadResource *resource = objc_getAssociatedObject(sender,@"resource");
    [[DataManager shareManager]updateDownloadResourceStatus:0 uuid:resource.downloadUuid];
    [self.searchTableView reloadData];
}

- (void)continueDownload:(UIButton *)sender {
    DownloadResource *resource = objc_getAssociatedObject(sender,@"resource");
    [[DataManager shareManager]updateDownloadResourceStatus:0 uuid:resource.downloadUuid];
    [self.searchTableView reloadData];
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

#pragma mark -searchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
//    [searchBar resignFirstResponder];
    [self.searchController setActive:NO];
    [self.searchData removeAllObjects];
}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self.searchController setActive:YES];
    [self.searchData removeAllObjects];
    [self.searchTableView reloadData];
    return YES;
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.searchData removeAllObjects];
    if(searchText.length > 0) {
        [self.searchData addObjectsFromArray:[[DataManager shareManager] selectDownloadResourceByTitle:searchText]];
    }
    [self.searchTableView reloadData];
}


- (void)buildFolder:(id)sender{
    [self.tableView reloadData];
}

- (void)addBtnClick:(id)sender{
    if (!self.downloadSlideController.isShown){
        self.downloadSlideController = [[SYDownloadSlideController alloc] init];
        self.downloadSlideController.dic = [[NSMutableDictionary alloc] init];
        self.downloadSlideController.controller = self.navigationController;
        [self.downloadSlideController show];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([tableView isEqual:self.searchTableView]) {
        return self.searchData.count;
    } else {
        return [FCShared tabManager].tabs.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([tableView isEqual:self.searchTableView]) {
        return 137;
    } else {
        return 46;
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if([tableView isEqual:self.searchTableView]) {
        return 0.1f;
    } else {
        return 38;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if([tableView isEqual:self.searchTableView]) {
        DownloadResource *downloadResource = self.searchData[indexPath.row];
        if(downloadResource.status == 2){
            NSArray<DownloadResource *> *resources = [[DataManager shareManager] selectDownloadComplete:downloadResource.firstPath];
            int currIndex = 0;
            for (int i = 0; i < resources.count; i++) {
                if ([downloadResource.downloadUuid isEqualToString:resources[i].downloadUuid]) {
                    currIndex = i;
                    break;
                }
            }
            
            
            
            PlayerViewController *playerController = [[PlayerViewController alloc] initWithResources:resources folderName:[FCShared.tabManager tabNameWithUUID:downloadResource.firstPath] initIndex:currIndex];
            playerController.modalPresentationStyle = UIModalPresentationFullScreen;
            if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
                          && [QuickAccess splitController].viewControllers.count >= 2){
                [[QuickAccess secondaryController] pushViewController:playerController];
            } else {
                [self.navigationController pushViewController:playerController animated:YES];
            }
        }
    } else {
        SYDownloadResourceManagerController *controller = [[SYDownloadResourceManagerController alloc] init];
        controller.pathUuid = [FCShared tabManager].tabs[indexPath.row].uuid;
        controller.title = [FCShared tabManager].tabs[indexPath.row].config.name;
        controller.array = [NSMutableArray array];
        [controller.array addObjectsFromArray: [[DataManager shareManager] selectDownloadResourceByPath:controller.pathUuid]];
        [self.navigationController pushViewController:controller animated:TRUE];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if([tableView isEqual:self.searchTableView]) {
        return nil;
    } else {
        UIView *headrView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 46)];
        headrView.backgroundColor = FCStyle.secondaryBackground;
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
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:self.searchTableView]) {
        DownloadResourceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DownloadResourcecellID"];
        if (cell == nil) {
            cell = [[DownloadResourceTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DownloadResourcecellID"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

        }
        for (UIView *subView in cell.contentView.subviews) {
            [subView removeFromSuperview];
        }
        
        
        cell.contentView.backgroundColor = FCStyle.secondaryBackground;

        cell.contentView.width = self.view.width;
        cell.downloadResource = self.searchData[indexPath.row];
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
    } else {
        DownloadFileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DownloadcellID"];
        if (cell == nil) {
            cell = [[DownloadFileTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DownloadcellID"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        for (UIView *subView in cell.contentView.subviews) {
            [subView removeFromSuperview];
        }
        
        cell.contentView.backgroundColor = FCStyle.secondaryBackground;
    
        cell.contentView.width = self.view.width;
        cell.cer = self;
        cell.fctab = [FCShared tabManager].tabs[indexPath.row];
        
        return cell;
    }
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    //Fixed retains self
    __weak SYFIleManagerViewController *weakSelf = self;
    
        UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
                    
            
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"needDeleteTab", @"")
                                                                           message:@""
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *conform = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"")
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * _Nonnull action) {
                
                if([FCShared tabManager].tabs.count == 1){
                    UIAlertController *onlyOneAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"needNotDelete", @"")
                                                                                   message:@""
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *onlyOneConform = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"")
                                                                      style:UIAlertActionStyleDefault
                                                                    handler:^(UIAlertAction * _Nonnull action) {
                    
                        
                        
                    }];
                    
                    [onlyOneAlert addAction:onlyOneConform];

                    
                    [self presentViewController:onlyOneAlert animated:YES completion:nil];
                } else {
                    FCTab *tab = [FCShared tabManager].tabs[indexPath.row];
                      
                    NSArray *resources = [[DataManager shareManager] selectDownloadResourceByPath:tab.uuid];
                    
                    if(resources != nil) {
                        for (int i = 0; i < resources.count; i++) {
                            DownloadResource * resource =  resources[i];
                            if (resource.status == 2) {
                                NSFileManager *defaultManager;
                                defaultManager = [NSFileManager defaultManager];
                                [defaultManager removeItemAtPath:resource.allPath error:nil];
                            } else {
                                [[DownloadManager shared] remove:resource.downloadUuid];
                            }
                        }
                    }
                    
                    [[DataManager shareManager] deleteVideoByuuidPath:tab.uuid];
                    [[FCShared tabManager] deleteTab:tab];
                    dispatch_async(dispatch_get_main_queue(),^{
                        [weakSelf.tableView  reloadData];
                    });
                }
            
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
        
    UIContextualAction *changeTitleAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        FCTab *tab = [FCShared tabManager].tabs[indexPath.row];
        weakSelf.folderSlideController =  [[FolderSlideController alloc] initWithFolderTab:tab];
        [self.folderSlideController show];
        [tableView setEditing:NO animated:YES];
    }];
    
    changeTitleAction.image = [ImageHelper sfNamed:@"pencil" font:[UIFont systemFontOfSize:15]];

    changeTitleAction.backgroundColor = FCStyle.accent;
    
    return [UISwipeActionsConfiguration configurationWithActions:@[deleteAction,changeTitleAction]];
}

-(void)addFolder:(UITapGestureRecognizer *)tap{
    self.folderSlideController = nil;
    [self.folderSlideController show];
}

- (void)buyStay:(id)sender {
#ifdef Mac
            [self presentViewController:
             [[UINavigationController alloc] initWithRootViewController:[[SYSubscribeController alloc] init]]
                               animated:YES completion:^{}];
#else
            [self.navigationController pushViewController:[[SYSubscribeController alloc] init] animated:YES];
#endif
            
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


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tableView.frame = self.view.bounds;
    [self emptyTipsView];

#ifdef Mac
        self.emptyTipsView.frame =CGRectMake(0, kMacToolbar, self.view.width, self.view.height - kMacToolbar);
#else
        self.emptyTipsView.frame = self.view.bounds;
#endif
    
    
    [self.emptyTipsView movePart];
    Boolean isPro = [[FCStore shared] getPlan:NO] == FCPlan.None?FALSE:TRUE;
    self.emptyTipsView.hidden = isPro;
    
    
#ifndef Mac
    NSUserDefaults *groupUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dajiu.stay.pro"];
    if(nil ==  [groupUserDefaults objectForKey:@"userDefaults.firstDownloadGuide"]){
        self.sYDownloadPreviewController = [[SYDownloadPreviewController alloc] init];
        [self.sYDownloadPreviewController show];
        [groupUserDefaults setObject:@(YES) forKey:@"userDefaults.firstDownloadGuide"];
    }
#endif
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
#ifdef Mac
    [self.tableView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
#else
        self.tableView.frame = self.view.bounds;
#endif
    
    
#ifdef Mac
        self.emptyTipsView.frame =CGRectMake(0, kMacToolbar, self.view.width, self.view.height - kMacToolbar);
#else
        self.emptyTipsView.frame = self.view.bounds;
#endif
    
    [self.emptyTipsView movePart];

    
        [self.tableView reloadData];
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:@"app.stay.notification.SYFolderChangeNotification"
                                                      object:nil];
}


- (UITableView *)searchTableView {
    if (_searchTableView == nil) {
        _searchTableView = [[UITableView alloc]initWithFrame:self.searchController.view.bounds style:UITableViewStylePlain];
        _searchTableView.delegate = self;
        _searchTableView.dataSource = self;
        _searchTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _searchTableView.sectionHeaderTopPadding = 0;
        _searchTableView.backgroundColor = FCStyle.background;
    }
    return _searchTableView;
}

- (NSMutableArray *)searchData {
    if(_searchData == nil) {
        _searchData = [NSMutableArray array];
    }
    return _searchData;
}

- (_FileEmptyTipsView *)emptyTipsView{
    if (nil == _emptyTipsView){
#ifdef Mac
        _emptyTipsView = [[_FileEmptyTipsView alloc] initWithFrame:CGRectMake(0, kMacToolbar, self.view.width, self.view.height - kMacToolbar)];
#else
        _emptyTipsView = [[_FileEmptyTipsView alloc] initWithFrame:self.view.bounds];
#endif
        Boolean isPro = [[FCStore shared] getPlan:NO] == FCPlan.None?FALSE:TRUE;
        
        _emptyTipsView.hidden = isPro;
        [_emptyTipsView.addButton addTarget:self action:@selector(buyStay:) forControlEvents:UIControlEventTouchUpInside];
        _emptyTipsView.backgroundColor = FCStyle.secondaryBackground;
        [self.view addSubview:_emptyTipsView];
    }
    
    return _emptyTipsView;
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
