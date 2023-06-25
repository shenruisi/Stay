//
//  SYFIleManagerViewController.m
//  Stay
//
//  Created by zly on 2022/12/4.
//

#import "SYFIleManagerViewController.h"
#import "FCShared.h"
#ifdef FC_MAC
#import "Plugin.h"
#endif
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
#import "SYTaskTableViewCell.h"
#import "SYDownloadedViewCell.h"
#import "UIColor+Convert.h"

static CGFloat kMacToolbar = 50.0;

@interface _FileEmptyTipsView : UIView

@property (nonatomic, strong) UIImageView *part1Img;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) UIViewController *controller;
@end

@implementation _FileEmptyTipsView

- (instancetype)init{
    if (self = [super init]){
        [self part1Img];
        [self addButton];
    }
    
    return self;
}


- (UIImageView *)part1Img{
    if (nil == _part1Img){
        _part1Img = [[UIImageView alloc] init];
        _part1Img.image = [ImageHelper sfNamed:@"square.and.arrow.down.fill" font:[UIFont systemFontOfSize:80] color:RGB(138, 138, 138)];
        _part1Img.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_part1Img];
        [NSLayoutConstraint activateConstraints:@[
            [_part1Img.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [_part1Img.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
            [_part1Img.widthAnchor constraintEqualToConstant:88],
            [_part1Img.widthAnchor constraintEqualToConstant:95]
        ]];
    }
    return _part1Img;
}

- (UIButton *)addButton{
    if (nil == _addButton){
        _addButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 175, 29)];
        _addButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_addButton setTitle:NSLocalizedString(@"UpgradeTo", @"") forState:UIControlStateNormal];
        _addButton.layer.borderColor = FCStyle.borderGolden.CGColor;
        _addButton.layer.borderWidth = 1;
        _addButton.backgroundColor =  FCStyle.backgroundGolden;
        [_addButton setTitleColor:FCStyle.fcGolden forState:UIControlStateNormal];
        _addButton.font = FCStyle.subHeadline;
        _addButton.layer.cornerRadius = 10;
        [self addSubview:_addButton];
        [NSLayoutConstraint activateConstraints:@[
            [_addButton.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [_addButton.topAnchor constraintEqualToAnchor:self.part1Img.bottomAnchor constant:10],
            [_addButton.widthAnchor constraintEqualToConstant:175],
            [_addButton.heightAnchor constraintEqualToConstant:29]
        ]];
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
@property (nonatomic, strong) FCTabButtonItem *downloadBtn;
@property (nonatomic, strong) FCTabButtonItem *downloadingBtn;
@property (nonatomic, assign) NSInteger selectedIdx;
@property (nonatomic, strong) NSMutableArray *videoArray;
@property (nonatomic, strong) SYChangeDocSlideController *syChangeDocSlideController;
@property (nonatomic, assign) Boolean searchStatus;

@end

@implementation SYFIleManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.enableTabItem = YES;
    self.enableSearchTabItem = YES;
    self.searchUpdating = self;
    self.navigationTabItem.leftTabButtonItems = @[self.downloadBtn, self.downloadingBtn];
    self.leftTitle  = NSLocalizedString(@"Downloader","Downloader");
    self.searchViewController = [[FCViewController alloc] init];
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

//    Boolean isPro = [[FCStore shared] getPlan:NO] != FCPlan.None;
//    if(isPro) {
    self.navigationItem.rightBarButtonItems = @[[self addItem]];
//    }
    
    [self.videoArray addObjectsFromArray:[[DataManager shareManager] selectAllUnDownloadComplete]];
    if(self.videoArray.count > 0) {
      self.downloadingBtn.title  = [NSString stringWithFormat:@"%@(%ld)",NSLocalizedString(@"Downloading","Downloading"),self.videoArray.count];
    }
    self.selectedIdx = 0;
    [self.navigationTabItem activeItem:self.downloadBtn];
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
    self.selectedIdx = 1;
    [self.navigationTabItem activeItem:self.downloadingBtn];
    dispatch_async(dispatch_get_main_queue(),^{
        [self.videoArray removeAllObjects];
        [self.videoArray addObjectsFromArray:[[DataManager shareManager] selectAllUnDownloadComplete]];
        [self updateDownloadingText];
        [self.tableView reloadData];
    });
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


- (void)didBeganSearch {
    self.searchStatus = YES;
    [self.searchData removeAllObjects];
    [self.searchTableView reloadData];
}

- (void)searchTextDidChange:(NSString *)text {
    [self.searchData removeAllObjects];
    if(text.length > 0) {
        [self.searchData addObjectsFromArray:[[DataManager shareManager] selectDownloadResourceByTitle:text]];
    }
    [self.searchTableView reloadData];
}

- (void)didEndSearch {
    self.searchStatus = NO;
    [self.searchData removeAllObjects];
    [self.searchTableView reloadData];
}


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

#pragma fcnavigator

- (void)tabItemDidClick:(FCTabButtonItem *)item refresh:(BOOL)refresh{
    if (item == self.downloadBtn){
        self.selectedIdx = 0;
        [self.tableView reloadData];
        
    } else if(item == self.downloadingBtn){
        self.selectedIdx = 1;
        [self.videoArray removeAllObjects];
        [self.videoArray addObjectsFromArray:[[DataManager shareManager] selectAllUnDownloadComplete]];

        [self.tableView reloadData];
    }
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
    if([tableView isEqual:_searchTableView]) {
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
    if([tableView isEqual:_searchTableView]) {
        return 160;
    } else {
        if(self.selectedIdx == 1) {
            return 150;
        } else {
            if(indexPath.row == 0) {
                return 105;
            }
            return 61.5;
        }
    }
}


//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 1;
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    if([tableView isEqual:self.searchTableView]) {
//        return 0.1f;
//    } else {
//        if(self.selectedIdx == 1) {
//            return 0.1f;
//        } else {
//            return 38;
//        }
//    }
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if([tableView isEqual:_searchTableView]) {
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
                [controller.array addObjectsFromArray: [[DataManager shareManager] selectDownloadComplete:controller.pathUuid]];
                [self.navigationController pushViewController:controller animated:TRUE];
            } else {
                NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"MY_PHONE_STORAGE"];

                if(dic == NULL) {
                    [self changeFileDir:nil];
                } else {

                    if (FCDeviceTypeMac == [DeviceHelper type]) {
#ifdef FC_MAC
                        NSUserDefaults *groupUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dajiu.stay.pro"];
                        NSData *loadPath =[groupUserDefaults objectForKey:@"bookmark"];
                        NSURL *loadUrl = [NSURL URLByResolvingBookmarkData:loadPath options:0 relativeToURL:nil bookmarkDataIsStale:nil error:nil];
                        Boolean success =  [loadUrl startAccessingSecurityScopedResource];
                        [FCShared.plugin.appKit openFinder:loadUrl];
                        [loadUrl stopAccessingSecurityScopedResource];
#endif
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:_searchTableView]) {
        SYDownloadedViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SYDownloadedViewCell"];
        
        DownloadResource *resource= self.searchData[indexPath.row];
        
        if(resource.status == 2) {
            if (cell == nil) {
                cell = [[SYDownloadedViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SYDownloadedViewCell"];
            }
            
            cell.contentView.width = self.view.width;
            cell.downloadResource = self.searchData[indexPath.row];
            cell.controller = self;
            return cell;
        } else {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                           reuseIdentifier:nil];
            return cell;
        }
        
        
    } else {
        
        if(self.selectedIdx == 1) {
            SYTaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SYTASKCELL"];
            DownloadResource *resource= self.videoArray[indexPath.row];
            cell = [[SYTaskTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SYTASKCELL"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
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
                            cell.progress = progress;
                            cell.downloadRateLabel.text =  [NSString stringWithFormat:@"%@:%.1f%%",NSLocalizedString(@"Downloading",""),progress * 100];
                            [cell.downloadRateLabel sizeToFit];
//                            cell.downloadSpeedLabel.left = cell.downloadRateLabel.right + 10;
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
                        if(resource.status  != 4) {
                            [[DataManager shareManager]updateDownloadResourceStatus:4 uuid:resource.downloadUuid];
                        }
                        dispatch_async(dispatch_get_main_queue(),^{
        //                    cell.downloadSpeedLabel.left = cell.downloadRateLabel.right + 10;
                            
                            NSString *str2 = [NSString stringWithFormat: @"%@: %@",NSLocalizedString(@"Transcoding",""),speed];
                            NSMutableAttributedString *noteStr = [[NSMutableAttributedString alloc] initWithString:str2];

                            NSRange range = [str2 rangeOfString:speed];
                           
                            [noteStr addAttribute:NSForegroundColorAttributeName value:FCStyle.titleGrayColor range:range];
                            [noteStr addAttribute:NSFontAttributeName value:FCStyle.footnote range:range];
                            cell.downloadRateLabel.attributedText = noteStr;
//                            cell.downloadSpeedLabel.text = speed;
//                            cell.downloadSpeedLabel.left = cell.downloadRateLabel.right + 10;
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
                UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DownloadcellID1"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.contentView.backgroundColor =  [UIColor clearColor];
                cell.backgroundColor = [UIColor clearColor];
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 71, 27, 20)];
                [imageView setImage:[ImageHelper sfNamed:@"folder.fill" font:[UIFont systemFontOfSize:22] color: RGB(146, 209, 243)]];
                imageView.contentMode = UIViewContentModeBottom;
                [cell.contentView addSubview:imageView];

                
                UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, self.self.view.width - 100, 18)];
                name.text = NSLocalizedString(@"Undefined","");
                if (dic != NULL) {
                    name.text = dic[@"fileName"];
                }
                name.font = FCStyle.body;
                [name sizeToFit];
                name.left = imageView.right + 10;
                
                cell.contentView.backgroundColor = [UIColor clearColor];

                [cell.contentView addSubview:name];
                
                UILabel *subTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 13, self.self.view.width - 100, 18)];
#ifdef FC_MAC
                subTitle.text =NSLocalizedString(@"OnMyMac","");
#else
                subTitle.text =NSLocalizedString(@"OnMyiPhone","");
#endif
                subTitle.font = FCStyle.footnoteBold;
                subTitle.textColor = FCStyle.subtitleColor;
                [subTitle sizeToFit];
                subTitle.left = name.left;
                subTitle.top = name.bottom;
                [cell.contentView addSubview:subTitle];
                
                
                UIImageView *rightIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 8, 15)];
                [rightIcon setImage:[ImageHelper sfNamed:@"chevron.right" font:[UIFont systemFontOfSize:15] color: FCStyle.grayNoteColor]];
                rightIcon.centerY = imageView.centerY;
                rightIcon.right = self.view.width - 20;
                rightIcon.contentMode = UIViewContentModeBottom;
                [cell.contentView addSubview:rightIcon];
                
                
                UIButton *setDicBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 140, 25)];
                [setDicBtn setTitle:NSLocalizedString(@"SetupDirectory","") forState:UIControlStateNormal];
                if (dic != NULL) {
                    [setDicBtn setTitle:NSLocalizedString(@"ChangeDirectory","") forState:UIControlStateNormal];
                }
                [setDicBtn setTitleColor:FCStyle.accent forState:UIControlStateNormal];
                [setDicBtn addTarget:self action:@selector(changeFileDir:) forControlEvents:UIControlEventTouchUpInside];
                setDicBtn.layer.cornerRadius = 10;
                setDicBtn.backgroundColor = FCStyle.background;
                setDicBtn.font = FCStyle.footnoteBold;
                [setDicBtn sizeToFit];
                setDicBtn.width = setDicBtn.width + 20;
                setDicBtn.centerY = imageView.centerY;
                setDicBtn.right = rightIcon.left - 16;
                setDicBtn.layer.borderWidth = 1;
                setDicBtn.layer.borderColor = FCStyle.accent.CGColor;
                [cell.contentView addSubview:setDicBtn];
                UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0, self.view.width - 10, 0.5)];
                line.backgroundColor = FCStyle.fcSeparator;
                line.bottom =  setDicBtn.bottom + 9;
                line.left = 10;
                [cell.contentView addSubview:line];
                
                
                UIButton *addDocBtn =  [[UIButton alloc] init];
                [addDocBtn setImage:[ImageHelper sfNamed:@"folder.badge.plus" font:FCStyle.body color:FCStyle.accent] forState:UIControlStateNormal];
                [addDocBtn setTitle:NSLocalizedString(@"NEWFOLDER", @"") forState:UIControlStateNormal];
                [addDocBtn setTitleColor:FCStyle.fcSecondaryBlack forState:UIControlStateNormal];
                addDocBtn.titleLabel.font = FCStyle.footnoteBold;
        //        [_savePhotoBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 8)];
                addDocBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 8);
                addDocBtn.layer.cornerRadius = 10;
                addDocBtn.layer.borderWidth = 1;
                addDocBtn.layer.borderColor = FCStyle.borderColor.CGColor;
                addDocBtn.translatesAutoresizingMaskIntoConstraints = NO;

                [addDocBtn addTarget:self action:@selector(addFolder:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:addDocBtn];
                [NSLayoutConstraint activateConstraints:@[
                    [addDocBtn.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor constant:14],
                    [addDocBtn.heightAnchor constraintEqualToConstant:35],
                    [addDocBtn.widthAnchor constraintEqualToConstant:134],
                    [addDocBtn.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:15],
                ]];
                
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
                
            
                cell.contentView.width = self.view.width;
                cell.cer = self;
                cell.fctab = [FCShared tabManager].tabs[indexPath.row - 1];
                
                return cell;
                
            }
        }
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
    __weak SYFIleManagerViewController *weakSelf = self;
    
    
    if ([tableView isEqual:_tableView] && indexPath.row > 0 && self.selectedIdx == 0) {
        
    
    
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
        deleteAction.image = [[UIImage imageNamed:@"delete"] imageWithTintColor:RGB(224, 32, 32) renderingMode:UIImageRenderingModeAlwaysOriginal];
        deleteAction.backgroundColor =  [UIColor clearColor];
            
        UIContextualAction *changeTitleAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            FCTab *tab = [FCShared tabManager].tabs[indexPath.row - 1];
            weakSelf.folderSlideController =  [[FolderSlideController alloc] initWithFolderTab:tab];
            [self.folderSlideController show];
            [tableView setEditing:NO animated:YES];
        }];
        
        changeTitleAction.image = [ImageHelper sfNamed:@"pencil" font:[UIFont systemFontOfSize:15] color:FCStyle.accent];

        changeTitleAction.backgroundColor = [UIColor clearColor];
        
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
                    
                    Boolean isPro = [[FCStore shared] getPlan:NO] != FCPlan.None;

                    if(!isPro){
                        float downloadNeedPoint = [SharedStorageManager shared].userDefaultsExRO.downloadConsumePoints;
                        [DeviceHelper rollbackPoints:downloadNeedPoint];
                    }
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
        deleteAction.image = [[UIImage imageNamed:@"delete"] imageWithTintColor:RGB(224, 32, 32) renderingMode:UIImageRenderingModeAlwaysOriginal];
        deleteAction.backgroundColor =  [UIColor clearColor];
        

    return [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
    } else {
        return NULL;
    }
}

-(void)addFolder:(UIButton *)tap{
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
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        if (@available(iOS 15.0, *)){
           _tableView.sectionHeaderTopPadding = 0;
        }
        _tableView.sectionFooterHeight = 0;
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


- (FolderSlideController *)folderSlideController {
    if(_folderSlideController == nil) {
        _folderSlideController = [[FolderSlideController alloc] initWithFolderTab:nil];
        _folderSlideController.baseCer = self;
    }
    return _folderSlideController;
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
//    Boolean isPro = [[FCStore shared] getPlan:NO] != FCPlan.None;
//    if (isPro){
//        if (_emptyTipsView){
//            [_emptyTipsView removeFromSuperview];
//            _emptyTipsView = nil;
//        }
//    }
//    else{
//        [self emptyTipsView];
//    }
        
//    self.tableView.hidden = !isPro;
    
    
//#ifndef FC_MAC
//    NSUserDefaults *groupUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dajiu.stay.pro"];
//    if(nil ==  [groupUserDefaults objectForKey:@"userDefaults.firstDownloadGuide"]){
//        self.sYDownloadPreviewController = [[SYDownloadPreviewController alloc] init];
//        [self.sYDownloadPreviewController show];
//        [groupUserDefaults setObject:@(YES) forKey:@"userDefaults.firstDownloadGuide"];
//    }
//#endif
    
    if( self.selectedIdx == 0) {
        [self.tableView reloadData];
    }
    
    if(self.videoArray.count > 0) {
        [self.videoArray removeAllObjects];
        [self.videoArray addObjectsFromArray:[[DataManager shareManager] selectAllUnDownloadComplete]];
    }
    
    [self updateDownloadingText];
}

- (void)updateDownloadingText {
    if(self.videoArray.count > 0) {
      self.downloadingBtn.title = [NSString stringWithFormat:@"%@(%ld)",NSLocalizedString(@"Task","Task"),self.videoArray.count];
    } else {
        self.downloadingBtn.title =NSLocalizedString(@"Task","Task");
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
    [self.tableView reloadData];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:@"showUpgrade"
                                                      object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:@"changeDownloading"
                                                      object:nil];
}


- (UITableView *)searchTableView {
    if (_searchTableView == nil) {
        _searchTableView = [[UITableView alloc]init];
        _searchTableView.delegate = self;
        _searchTableView.dataSource = self;
        _searchTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        if (@available(iOS 15.0, *)){
            _searchTableView.sectionHeaderTopPadding = 0;
        }
        _searchTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _searchTableView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.searchViewController.view addSubview:_searchTableView];

        _searchTableView.backgroundColor = [UIColor clearColor];
        [NSLayoutConstraint activateConstraints:@[
            [_searchTableView.leadingAnchor constraintEqualToAnchor:self.searchViewController.view.leadingAnchor],
            [_searchTableView.trailingAnchor constraintEqualToAnchor:self.searchViewController.view.trailingAnchor],
            [_searchTableView.topAnchor constraintEqualToAnchor:self.searchViewController.view.topAnchor constant:self.navigationBarBaseLine],
            [_searchTableView.heightAnchor constraintEqualToConstant:self.view.height - self.navigationController.tabBarController.tabBar.height - self.navigationBarBaseLine]
        ]];
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
        _emptyTipsView = [[_FileEmptyTipsView alloc] init];
        _emptyTipsView.translatesAutoresizingMaskIntoConstraints = NO;
        [_emptyTipsView.addButton addTarget:self action:@selector(buyStay:) forControlEvents:UIControlEventTouchUpInside];
        _emptyTipsView.backgroundColor = UIColor.clearColor;
        [self.view addSubview:_emptyTipsView];
        [NSLayoutConstraint activateConstraints:@[
            [_emptyTipsView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
            [_emptyTipsView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
            [_emptyTipsView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
            [_emptyTipsView.heightAnchor constraintEqualToConstant:self.view.height - self.navigationController.tabBarController.tabBar.height]
        ]];
    }
    
    return _emptyTipsView;
}

- (FCTabButtonItem *)downloadBtn {
    if(_downloadBtn == nil) {
        _downloadBtn = [[FCTabButtonItem alloc] init];
        _downloadBtn.title = NSLocalizedString(@"Folders","");
    }
    
    return  _downloadBtn;
}

- (FCTabButtonItem *)downloadingBtn {
    if(_downloadingBtn == nil) {
        _downloadingBtn = [[FCTabButtonItem alloc] init];
        _downloadingBtn.title = NSLocalizedString(@"Task","Task") ;
    }
    
    return  _downloadingBtn;
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
