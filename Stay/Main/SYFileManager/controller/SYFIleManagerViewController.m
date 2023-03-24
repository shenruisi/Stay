//
//  SYFIleManagerViewController.m
//  Stay
//
//  Created by zly on 2022/12/4.
//

#import "SYFIleManagerViewController.h"
#import "FCShared.h"
#import "Plugin.h"
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
#import "ColorHelper.h"
#import "SYChangeDocSlideController.h"
#import "UserscriptUpdateManager.h"
#if FC_IOS
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
@property (nonatomic, strong) UIButton *downloadBtn;
@property (nonatomic, strong) UIButton *downloadingBtn;
@property (nonatomic, strong) UIView *slideLine;
@property (nonatomic, assign) NSInteger selectedIdx;
@property (nonatomic, strong) NSMutableArray *videoArray;
@property (nonatomic, strong) SYChangeDocSlideController *syChangeDocSlideController;
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
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeDownloading)
                                                 name:@"changeDownloading"
                                               object:nil];

    Boolean isPro = [[FCStore shared] getPlan:NO] == FCPlan.None?FALSE:TRUE;

    if(isPro) {
        self.navigationItem.rightBarButtonItems = @[[self addItem]];
    }

    [self emptyTipsView];

    
    [self.videoArray addObjectsFromArray:[[DataManager shareManager] selectAllUnDownloadComplete]];
    if(self.videoArray.count > 0) {
      [self.downloadingBtn setTitle:[NSString stringWithFormat:@"%@(%ld)",NSLocalizedString(@"Downloading","Downloading"),self.videoArray.count] forState:UIControlStateNormal];
      [self.downloadingBtn sizeToFit];
    }

    UIView *topHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 25)];
    
    self.downloadBtn.left = 70;
    self.downloadingBtn.left = self.downloadBtn.right + 53;
    self.downloadingBtn.centerY =  self.downloadBtn.centerY;
    self.slideLine.centerX = self.downloadBtn.centerX;
    self.slideLine.top = self.downloadBtn.bottom + 5;
    [topHeaderView addSubview:self.downloadBtn];
    [topHeaderView addSubview:self.downloadingBtn];
    [topHeaderView addSubview:self.slideLine];
    self.navigationItem.titleView = topHeaderView;
    self.selectedIdx = 0;
}

- (void)showUpgrade {
#ifdef FC_MAC
            [self presentViewController:
             [[UINavigationController alloc] initWithRootViewController:[[SYSubscribeController alloc] init]]
                               animated:YES completion:^{}];
#else
            [self.navigationController pushViewController:[[SYSubscribeController alloc] init] animated:YES];
#endif
    
}

- (void)changeDownloading {
    self.downloadBtn.selected = false;
    self.downloadingBtn.selected = true;
    self.selectedIdx = 1;
    [UIView animateWithDuration:0.25F animations:^{
        self.slideLine.centerX = self.downloadingBtn.centerX;
    }];
    [self.videoArray removeAllObjects];
    [self.videoArray addObjectsFromArray:[[DataManager shareManager] selectAllUnDownloadComplete]];
    [self updateDownloadingText];
    [self.tableView reloadData];
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

#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(nonnull UISearchController *)searchController {
    NSString *inputStr = searchController.searchBar.text;
    return;
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



#pragma cellClickEvent

- (void)stopDownload:(UIButton *)sender {
    DownloadResource *resource = objc_getAssociatedObject(sender,@"resource");
    [[DataManager shareManager]updateDownloadResourceStatus:1 uuid:resource.downloadUuid];
    [[DownloadManager shared] pause:resource.downloadUuid];
    
    
    Task *task = [[DownloadManager shared]  queryByTaskId:resource.downloadUuid];;
    if(task != nil) {
        task.block = NULL;
        [[DataManager shareManager] updateDownloadResourcProcess:task.progress * 100 uuid:resource.downloadUuid];
    }
    if(self.selectedIdx == 1) {
        [self.videoArray removeAllObjects];
        [self.videoArray addObjectsFromArray:[[DataManager shareManager] selectAllUnDownloadComplete]];
        [self.tableView reloadData];
    }
    [self.searchTableView reloadData];
    
}

- (void)retryDownload:(UIButton *)sender {
    DownloadResource *resource = objc_getAssociatedObject(sender,@"resource");
    [[DataManager shareManager]updateDownloadResourceStatus:0 uuid:resource.downloadUuid];
    [self.searchTableView reloadData];
    if(self.selectedIdx == 1) {
        [self.videoArray removeAllObjects];
        [self.videoArray addObjectsFromArray:[[DataManager shareManager] selectAllUnDownloadComplete]];
        [self.tableView reloadData];
    }
}

- (void)continueDownload:(UIButton *)sender {
    DownloadResource *resource = objc_getAssociatedObject(sender,@"resource");
    [[DataManager shareManager]updateDownloadResourceStatus:0 uuid:resource.downloadUuid];
    [self.searchTableView reloadData];
    if(self.selectedIdx == 1) {
        [self.videoArray removeAllObjects];
        [self.videoArray addObjectsFromArray:[[DataManager shareManager] selectAllUnDownloadComplete]];
        [self.tableView reloadData];
    }
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
        if(self.selectedIdx == 1) {
            return self.videoArray.count;
        } else {
            return [FCShared tabManager].tabs.count + 1;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([tableView isEqual:self.searchTableView]) {
        return 137;
    } else {
        if(self.selectedIdx == 1) {
            return 152;
        } else {
            return 61.5;
        }
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if([tableView isEqual:self.searchTableView]) {
        return 0.1f;
    } else {
        if(self.selectedIdx == 1) {
            return 0.1f;
        } else {
            return 38;
        }
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
            
            PlayerViewController *playerController = [PlayerViewController controllerWithResources:resources folderName:[FCShared.tabManager tabNameWithUUID:downloadResource.firstPath] initIndex:currIndex];
            playerController.modalPresentationStyle = UIModalPresentationFullScreen;
            if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
                          && [QuickAccess splitController].viewControllers.count >= 2){
                [[QuickAccess secondaryController] pushViewController:playerController];
            } else {
                [self.navigationController pushViewController:playerController animated:YES];
            }
        }
    } else {
        
        if(self.selectedIdx == 0) {
            if(indexPath.row != 0) {
                SYDownloadResourceManagerController *controller = [[SYDownloadResourceManagerController alloc] init];
                controller.pathUuid = [FCShared tabManager].tabs[indexPath.row - 1].uuid;
                controller.title = [FCShared tabManager].tabs[indexPath.row - 1].config.name;
                controller.array = [NSMutableArray array];
                [controller.array addObjectsFromArray: [[DataManager shareManager] selectDownloadResourceByPath:controller.pathUuid]];
                [self.navigationController pushViewController:controller animated:TRUE];
            } else {
                NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"MY_PHONE_STORAGE"];

                if(dic == NULL) {
                    [self changeFileDir:nil];
                } else {

                    if (FCDeviceTypeMac == [DeviceHelper type]) {
                        NSUserDefaults *groupUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dajiu.stay.pro"];
                        NSData *loadPath =[groupUserDefaults objectForKey:@"bookmark"];
                        NSURL *loadUrl = [NSURL URLByResolvingBookmarkData:loadPath options:0 relativeToURL:nil bookmarkDataIsStale:nil error:nil];
                        Boolean success =  [loadUrl startAccessingSecurityScopedResource];
                        
                        [FCShared.plugin.appKit openFinder:loadUrl];
                        [loadUrl stopAccessingSecurityScopedResource];

                    } else {
                        NSURL *fileURL = [NSURL fileURLWithPath:dic[@"url"]];
                        fileURL = [NSURL URLWithString:[fileURL.absoluteString stringByReplacingOccurrencesOfString:@"file://" withString:@"shareddocuments://"]];
                        if([[UIApplication sharedApplication] canOpenURL:fileURL]) {
                            [[UIApplication sharedApplication] openURL:fileURL];
                        }
                    }
                }
            }
             
                
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if([tableView isEqual:self.searchTableView]) {
        return nil;
    } else {
        
        if(self.selectedIdx == 1) {
            return nil;
        }
        
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
            request.audioUrl = cell.downloadResource.audioUrl;
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
                
        
                    [self.videoArray removeObject:cell.downloadResource];
                    dispatch_async(dispatch_get_main_queue(),^{
                        [self updateDownloadingText];
                        [tableView reloadData];
                    })  ;
                    return;
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
        
        if(self.selectedIdx == 1) {
            DownloadResourceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DownloadResourcecellID"];
            
            DownloadResource *resource= self.videoArray[indexPath.row];
            
            if(resource.status == 2) {
                if (cell == nil) {
                    cell = [[DownloadResourceTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DownloadResourcecellID"];
                }
            } else {
                cell = [[DownloadResourceTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DownloadResourcecellIDR"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            for (UIView *subView in cell.contentView.subviews) {
                [subView removeFromSuperview];
            }
            
            
            
            cell.contentView.width = self.view.width;
            cell.downloadResource = resource;
            cell.controller = self;
            
            if( cell.downloadResource.status == 0 || cell.downloadResource.status == 4) {
                FCTab *tab = [[FCShared tabManager] tabOfUUID:cell.downloadResource.firstPath];
                Request *request = [[Request alloc] init];
                request.url =  cell.downloadResource.downloadUrl;
                if(tab == nil) {
                    request.fileDir = cell.downloadResource.allPath;
                } else {
                    request.fileDir = tab.path;
                }
                request.fileName = [cell.downloadResource.allPath lastPathComponent];
                request.fileType = @"video";
                request.audioUrl = cell.downloadResource.audioUrl;
                request.key =  cell.downloadResource.firstPath;
                Task *task =  [[DownloadManager shared]  enqueue:request];
                
                resource.downloadProcess = task.progress * 100;
                
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
                        
                      
                        [self.videoArray removeObject:cell.downloadResource];
                        dispatch_async(dispatch_get_main_queue(),^{
    
                            if([FILEUUID isEqualToString:cell.downloadResource.firstPath]) {
                                NSUserDefaults *groupUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dajiu.stay.pro"];
                                NSData *loadPath =[groupUserDefaults objectForKey:@"bookmark"];
                                
                                NSURL *loadUrl = [NSURL URLByResolvingBookmarkData:loadPath options:0 relativeToURL:nil bookmarkDataIsStale:nil error:nil];
                                BOOL fileUrlAuthozied =[loadUrl startAccessingSecurityScopedResource];
                                NSFileManager *fileManager = [NSFileManager defaultManager];

                                NSURL *fileURL = [NSURL fileURLWithPath:cell.downloadResource.allPath];
                                NSURL *parentDirectoryURL = [fileURL URLByDeletingLastPathComponent];
                                NSString *parentDirectoryPath = [parentDirectoryURL path];
                                NSString *removePath = [NSString stringWithFormat:@"%@/%@.%@",[loadUrl path],cell.downloadResource.title,@"mp4"];
                                [self renameFile:removePath originPath:cell.downloadResource.allPath];

                                [[DataManager shareManager] deleteVideoByuuid:cell.downloadResource.downloadUuid];
                                
                                
                                [loadUrl stopAccessingSecurityScopedResource];
                            } else {
                                NSFileManager *fileManager = [NSFileManager defaultManager];
                                NSURL *fileURL = [NSURL fileURLWithPath:cell.downloadResource.allPath];
                            
                                NSURL *parentDirectoryURL = [fileURL URLByDeletingLastPathComponent];
                                NSString *parentDirectoryPath = [parentDirectoryURL path];
                                NSString *removePath = [NSString stringWithFormat:@"%@/%@.%@",parentDirectoryPath,cell.downloadResource.title,@"mp4"];
                                NSError *error = nil;
                                NSString *finalPath = [self renameFile:removePath originPath:cell.downloadResource.allPath];
                                [[DataManager shareManager] updateVideoAllPath:finalPath uuid:cell.downloadResource.downloadUuid];
                                
                                
                            }
                            [self updateDownloadingText];
                            [tableView reloadData];
                        })  ;
                        return;
                        
                    } else if(status == DMStatusPending) {
                        [[DataManager shareManager]updateDownloadResourceStatus:1 uuid:resource.downloadUuid];
                        resource.status = 1;
                    } else if(status == DMStatusTranscoding) {
                        [[DataManager shareManager]updateDownloadResourceStatus:4 uuid:resource.downloadUuid];
                        dispatch_async(dispatch_get_main_queue(),^{
        //                    cell.downloadSpeedLabel.left = cell.downloadRateLabel.right + 10;
                            cell.downloadSpeedLabel.text = speed;
                            cell.downloadSpeedLabel.left = cell.downloadRateLabel.right + 10;
                        });
                        resource.status = 4;
                        if(speed != nil && speed.length > 0) {
                            return;
                        }
                    } else if(status == DMStatusFailedTranscode) {
                        [[DataManager shareManager]updateDownloadResourceStatus:5 uuid:resource.downloadUuid];
                        resource.status = 5;
                        dispatch_async(dispatch_get_main_queue(),^{
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"FailedTranscode", @"")
                                                                                           message:@""
                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                           
                            UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"")
                                 style:UIAlertActionStyleCancel
                                 handler:^(UIAlertAction * _Nonnull action) {
                             }];
                             [alert addAction:cancel];
                            [self presentViewController:alert animated:YES completion:nil];
                        });
                    } else if(status == DMStatusFailedNoSpace) {
                        [[DataManager shareManager]updateDownloadResourceStatus:6 uuid:resource.downloadUuid];
                        resource.status = 6;
                        dispatch_async(dispatch_get_main_queue(),^{
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"FailedNoSpace", @"")
                                                                                           message:@""
                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                           
                            UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"")
                                 style:UIAlertActionStyleCancel
                                 handler:^(UIAlertAction * _Nonnull action) {
                             }];
                             [alert addAction:cancel];
                            [self presentViewController:alert animated:YES completion:nil];
                        });
                    }
                    
                    dispatch_async(dispatch_get_main_queue(),^{
                        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
                    });
                };
            }
            return cell;
        } else {
            if(indexPath.row == 0) {
                NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"MY_PHONE_STORAGE"];
                UITableViewCell *cell = [[DownloadFileTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DownloadcellID"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.contentView.backgroundColor = FCStyle.secondaryBackground;

                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 21, 27, 20)];
                [imageView setImage:[ImageHelper sfNamed:@"folder.fill" font:[UIFont systemFontOfSize:26] color: RGB(146, 209, 243)]];
                imageView.contentMode = UIViewContentModeBottom;
                [cell.contentView addSubview:imageView];

                
                UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(0, 13, self.self.view.width - 100, 18)];
                name.text = @"Undefined";
                if (dic != NULL) {
                    name.text = dic[@"fileName"];
                }
                name.font = FCStyle.body;
                [name sizeToFit];
    //            name.centerY = imageView.centerY;
                name.left = imageView.right + 10;
                [cell.contentView addSubview:name];
                
                UILabel *subTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 13, self.self.view.width - 100, 18)];
                subTitle.text = @"On My iPhone";
                subTitle.font = FCStyle.footnoteBold;
                subTitle.textColor = FCStyle.subtitleColor;
                [subTitle sizeToFit];
                subTitle.top = name.bottom;
                subTitle.left = imageView.right + 10;
                [cell.contentView addSubview:subTitle];
                
                
                UIImageView *rightIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 8, 15)];
                [rightIcon setImage:[ImageHelper sfNamed:@"chevron.right" font:[UIFont systemFontOfSize:15] color: FCStyle.grayNoteColor]];
                rightIcon.centerY = imageView.centerY;
                rightIcon.right = self.view.width - 20;
                rightIcon.contentMode = UIViewContentModeBottom;
                [cell.contentView addSubview:rightIcon];
                
                
                UIButton *setDicBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 144, 25)];
                [setDicBtn setTitle:@"Setup Directory" forState:UIControlStateNormal];
                if (dic != NULL) {
                    [setDicBtn setTitle:@"Change Directory" forState:UIControlStateNormal];
                }
                [setDicBtn setTitleColor:FCStyle.accent forState:UIControlStateNormal];
                [setDicBtn addTarget:self action:@selector(changeFileDir:) forControlEvents:UIControlEventTouchUpInside];
                setDicBtn.layer.cornerRadius = 10;
                setDicBtn.backgroundColor = FCStyle.background;
                setDicBtn.font = FCStyle.footnoteBold;
                setDicBtn.centerY = imageView.centerY;
                setDicBtn.right = rightIcon.left - 16;
                [cell.contentView addSubview:setDicBtn];
                UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0, self.view.width - 10, 0.5)];
                line.backgroundColor = FCStyle.fcSeparator;
                line.bottom =  imageView.bottom + 21;
                line.left = 10;
                [cell.contentView addSubview:line];
                return  cell;
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
                cell.fctab = [FCShared tabManager].tabs[indexPath.row - 1];
                
                return cell;
                
            }
        }
    }
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    //Fixed retains self
    __weak SYFIleManagerViewController *weakSelf = self;
    
    
    if ([tableView isEqual:self.tableView] && indexPath.row > 0 && self.selectedIdx == 0) {
        
    
    
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
                        FCTab *tab = [FCShared tabManager].tabs[indexPath.row - 1];
                          
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
            FCTab *tab = [FCShared tabManager].tabs[indexPath.row - 1];
            weakSelf.folderSlideController =  [[FolderSlideController alloc] initWithFolderTab:tab];
            [self.folderSlideController show];
            [tableView setEditing:NO animated:YES];
        }];
        
        changeTitleAction.image = [ImageHelper sfNamed:@"pencil" font:[UIFont systemFontOfSize:15]];

        changeTitleAction.backgroundColor = FCStyle.accent;
        
        return [UISwipeActionsConfiguration configurationWithActions:@[deleteAction,changeTitleAction]];
    } else if ([tableView isEqual:self.tableView] && self.selectedIdx == 1) {
        UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
                    
            
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"needDeleteVideo", @"")
                                                                           message:@""
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *conform = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"")
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * _Nonnull action) {
                
                DownloadResource *downloadResource = weakSelf.videoArray[indexPath.row];
                if(downloadResource.status == 2) {
                    NSFileManager *defaultManager;
                    defaultManager = [NSFileManager defaultManager];
                    [defaultManager removeItemAtPath:downloadResource.allPath error:nil];
                } else {
                    [[DownloadManager shared] remove:downloadResource.downloadUuid];
                }
                [[DataManager shareManager] deleteVideoByuuid:downloadResource.downloadUuid];
                [weakSelf.videoArray removeObject:downloadResource];
                dispatch_async(dispatch_get_main_queue(),^{
                    [self updateDownloadingText];
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
        

    return [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
    } else {
        return NULL;
    }
}

-(void)addFolder:(UITapGestureRecognizer *)tap{
    self.folderSlideController = nil;
    [self.folderSlideController show];
}

#pragma mark - UIDocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    //获取授权
    BOOL fileUrlAuthozied = [urls.firstObject startAccessingSecurityScopedResource];
    if (fileUrlAuthozied) {
        //通过文件协调工具来得到新的文件地址，以此得到文件保护功能
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
        NSError *error;

       
        
        [fileCoordinator coordinateReadingItemAtURL:urls.firstObject options:0 error:&error byAccessor:^(NSURL *newURL) {
            //读取文件
            NSString *fileName = [newURL lastPathComponent];
       
            NSData *bookmarkData = [newURL bookmarkDataWithOptions:0 includingResourceValuesForKeys:nil relativeToURL:nil error:nil];
                            
            NSUserDefaults *groupUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dajiu.stay.pro"];

            [groupUserDefaults setObject:bookmarkData forKey:@"bookmark"];
            [groupUserDefaults  synchronize];
            SharedStorageManager.shared.userDefaults.exteralFolderName = fileName;
            
            dispatch_async(dispatch_get_main_queue(), ^{
            [[NSUserDefaults standardUserDefaults] setObject:@{@"fileName":fileName ,
                                                               @"url": [newURL path],
                                    
                                                             }
                                                      forKey:@"MY_PHONE_STORAGE"];
            
            
                
                
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self.tableView reloadData];
            });
            
            [self dismissViewControllerAnimated:YES completion:NULL];
        
        }];
        
        
        [urls.firstObject stopAccessingSecurityScopedResource];
    } else {
        //授权失败
    }
}

- (void)buyStay:(id)sender {
#ifdef FC_MAC
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
    self.tabBarController.tabBar.hidden = NO;


    
#ifdef FC_MAC
        self.emptyTipsView.frame =CGRectMake(0, kMacToolbar, self.view.width, self.view.height - kMacToolbar);
#else
        self.emptyTipsView.frame = self.view.bounds;
#endif
    
    
    [self.emptyTipsView movePart];
    Boolean isPro = [[FCStore shared] getPlan:NO] == FCPlan.None?FALSE:TRUE;
    self.emptyTipsView.hidden = isPro;
    
    
#ifndef FC_MAC
    NSUserDefaults *groupUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dajiu.stay.pro"];
    if(nil ==  [groupUserDefaults objectForKey:@"userDefaults.firstDownloadGuide"]){
        self.sYDownloadPreviewController = [[SYDownloadPreviewController alloc] init];
        [self.sYDownloadPreviewController show];
        [groupUserDefaults setObject:@(YES) forKey:@"userDefaults.firstDownloadGuide"];
    }
#endif
    
    if( self.selectedIdx == 0) {
        [self.tableView reloadData];
    }
    
}

- (void)updateDownloadingText {
    if(self.videoArray.count > 0) {
      [self.downloadingBtn setTitle:[NSString stringWithFormat:@"%@(%ld)",NSLocalizedString(@"Downloading","Downloading"),self.videoArray.count] forState:UIControlStateNormal];
      [self.downloadingBtn sizeToFit];
    } else {
        [self.downloadingBtn setTitle:NSLocalizedString(@"Downloading","Downloading") forState:UIControlStateNormal];
        [self.downloadingBtn sizeToFit];
    }
    
    self.downloadingBtn.left = self.downloadBtn.right + 53;
    self.downloadingBtn.centerY =  self.downloadBtn.centerY;
    
    if(_selectedIdx == 1) {
        self.slideLine.centerX = self.downloadingBtn.centerX;
    }
    
}

- (void)changeDownloadTab:(UIButton *)sender {
    if ([sender isEqual:self.downloadBtn]) {
        if(self.selectedIdx == 1) {
            self.downloadBtn.selected = true;
            self.downloadingBtn.selected = false;
            self.selectedIdx = 0;
            [UIView animateWithDuration:0.25F animations:^{
                self.slideLine.centerX = self.downloadBtn.centerX;
            }];
            [self.tableView reloadData];
        }
    } else {
        if(self.selectedIdx == 0) {
            self.downloadBtn.selected = false;
            self.downloadingBtn.selected = true;
            self.selectedIdx = 1;
            [UIView animateWithDuration:0.25F animations:^{
                self.slideLine.centerX = self.downloadingBtn.centerX;
            }];
            [self.videoArray removeAllObjects];
            [self.videoArray addObjectsFromArray:[[DataManager shareManager] selectAllUnDownloadComplete]];

            [self.tableView reloadData];
        }
    }
}

- (void)changeFileDir:(UIButton *)sender {
    NSArray *documentTypes = @[@"public.folder"];
//
    UIDocumentPickerViewController *documentPicker =   [[UIDocumentPickerViewController alloc]  initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeOpen];

    documentPicker.delegate = self;
    documentPicker.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:documentPicker animated:YES completion:nil];
    
}


- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
#ifdef FC_MAC
    [self.tableView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
#else
        self.tableView.frame = self.view.bounds;
#endif
    
    
#ifdef FC_MAC
        self.emptyTipsView.frame =CGRectMake(0, kMacToolbar, self.view.width, self.view.height - kMacToolbar);
#else
        self.emptyTipsView.frame = self.view.bounds;
#endif
    
    [self.emptyTipsView movePart];

    
        [self.tableView reloadData];
    
    
    CGFloat space = (self.view.width - self.downloadBtn.width - self.downloadingBtn.width - 53 - 50) / 2;
    self.downloadBtn.left = space;
    self.downloadingBtn.left = self.downloadBtn.right + 53;
    self.slideLine.top = self.downloadBtn.bottom + 5;
    if(_selectedIdx == 0) {
        self.slideLine.centerX = self.downloadBtn.centerX;
    } else {
        self.slideLine.centerX = self.downloadingBtn.centerX;
    }
}


- (NSString *)renameFile:(NSString *)fileName originPath:(NSString *)originPath {
    NSString *finalFileName = fileName;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        NSString *name = [fileName stringByDeletingPathExtension];
        NSString *ext = [fileName pathExtension];
        int copyCount = 1;
        do {
            finalFileName = [NSString stringWithFormat:@"%@%d.%@", name, copyCount++, ext];
        } while ([[NSFileManager defaultManager] fileExistsAtPath:finalFileName]);
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSURL *fileURL = [NSURL fileURLWithPath:originPath];
    NSURL *destinationURL = [NSURL fileURLWithPath:finalFileName];
    BOOL success = [fileManager moveItemAtURL:fileURL toURL:destinationURL error:&error];
    return finalFileName;
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
#ifdef FC_MAC
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

- (UIButton *)downloadBtn {
    if(_downloadBtn == nil) {
        _downloadBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 18)];
        [_downloadBtn setTitle:NSLocalizedString(@"Downloaded","Downloaded") forState:UIControlStateNormal];
        [_downloadBtn setTitleColor:FCStyle.fcBlack forState:UIControlStateNormal];
        [_downloadBtn setTitleColor:FCStyle.accent forState:UIControlStateSelected];
        [_downloadBtn addTarget:self action:@selector(changeDownloadTab:) forControlEvents:UIControlEventTouchUpInside];
        _downloadBtn.font = FCStyle.body;
        [_downloadBtn sizeToFit];
        _downloadBtn.height = 18;
        _downloadBtn.selected = true;
        
    }
    
    return  _downloadBtn;
}

- (UIButton *)downloadingBtn {
    if(_downloadingBtn == nil) {
        _downloadingBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 18)];
        [_downloadingBtn setTitle:NSLocalizedString(@"Downloading","Downloading") forState:UIControlStateNormal];
        [_downloadingBtn setTitleColor:FCStyle.fcBlack forState:UIControlStateNormal];
        [_downloadingBtn setTitleColor:FCStyle.accent forState:UIControlStateSelected];
        [_downloadingBtn addTarget:self action:@selector(changeDownloadTab:) forControlEvents:UIControlEventTouchUpInside];
        _downloadingBtn.font = FCStyle.body;
    }
    
    return  _downloadingBtn;
}

- (UIView *)slideLine {
    if (_slideLine == nil) {
        _slideLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 2)];
        _slideLine.backgroundColor = FCStyle.accent;
    }
    return _slideLine;
}


- (NSArray *)videoArray {
    if (_videoArray == nil) {
        _videoArray = [NSMutableArray array];
    }
    
    return _videoArray;
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
