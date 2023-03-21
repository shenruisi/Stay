//
//  SYChangeDocModelViewController.m
//  Stay
//
//  Created by zly on 2023/1/2.
//
#import "FCApp.h"
#import "ModalItemElement.h"
#import "UIView+Layout.h"
#import "ModalItemView.h"
#import "ModalItemViewFactory.h"
#import "ModalSectionView.h"
#import "FCStyle.h"
#import "DownloadResource.h"
#import "FCShared.h"
#import <CommonCrypto/CommonDigest.h>
#import "DataManager.h"
#import "DownloadManager.h"
#import "SYDownloadResourceManagerController.h"
#import "SYDownloadFolderChooseModalViewController.h"
#import "SYChangeDocModelViewController.h"
@interface SYChangeDocModelViewController()<
 UITableViewDelegate,
 UITableViewDataSource
>

@property (nonatomic, strong) NSArray<NSDictionary *> *dataSource;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<ModalItemElement *> *nameElements;
@property (nonatomic, strong) NSArray<ModalItemElement *> *saveToElements;
@property (nonatomic, strong) UIButton *startDownloadButton;
@end

@implementation SYChangeDocModelViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationBar.hidden = NO;
    self.navigationBar.showCancel = YES;
    self.title = NSLocalizedString(@"EDIT", @"");
    [self tableView];
    [self startDownloadButton];
}

- (void)viewWillAppear{
    [super viewWillAppear];
    
    NSString *uuid = self.dic[@"uuid"];
    ModalItemElement *element = self.saveToElements.firstObject;
    if(uuid.length == 0) {
        uuid = SharedStorageManager.shared.userDefaults.lastFolderUUID;
        if(uuid.length == 0) {
            uuid = FILEUUID;
        }
    }
    
    if([uuid isEqualToString:FILEUUID]) {
        NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"MY_PHONE_STORAGE"];
        NSString *text = @"Undefined";
        if (dic != NULL) {
            text = dic[@"fileName"];
        }
        
        if(self.dic[@"pathName"] != NULL) {
            text = self.dic[@"pathName"];
        }
        element.generalEntity.title = text;
        element.generalEntity.uuid = uuid;
    } else {
        element.generalEntity.title = [FCShared.tabManager tabNameWithUUID:uuid];
        element.generalEntity.uuid = uuid;
    }
    [element clear];
    
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ModalItemElement *element = ((NSArray *)self.dataSource[indexPath.section][@"itemElements"])[indexPath.row];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:nil];
    ModalItemView *modalItemView = [ModalItemViewFactory ofElement:element];
    [cell.contentView addSubview:modalItemView];
    modalItemView.cell = cell;
    [modalItemView attachGesture];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    ModalSectionElement *element = self.dataSource[section][@"sectionElement"];
    ModalSectionView *sectionView = [[ModalSectionView alloc] initWithElement:element];
    return sectionView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return ((NSArray *)self.dataSource[section][@"itemElements"]).count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ModalItemElement *element = ((NSArray *)self.dataSource[indexPath.section][@"itemElements"])[indexPath.row];
    CGFloat contentHeight = [element contentHeightWithWidth:self.view.width];
    return contentHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    ModalSectionElement *element = self.dataSource[section][@"sectionElement"];
    return [element height];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (NSArray<NSDictionary *> *)dataSource{
    if (nil == _dataSource){
        _dataSource = @[
            @{
                @"sectionElement" : [ModalSectionElement ofTitle:NSLocalizedString(@"Name", @"")],
                @"itemElements" : self.nameElements
            },
            @{
                @"sectionElement" : [ModalSectionElement ofTitle:NSLocalizedString(@"Location", @"")],
                @"itemElements" : self.saveToElements
            }
        ];
        
    }
    
    return _dataSource;
}

- (NSArray<ModalItemElement *> *)nameElements{
    if (nil == _nameElements){
        ModalItemDataEntityGeneral *generalEntity;
        ModalItemDataEntityInput *inputEntity;
        NSMutableArray *ret = [[NSMutableArray alloc] init];
        ModalItemElement *nameElement = [[ModalItemElement alloc] init];
        generalEntity = [[ModalItemDataEntityGeneral alloc] init];
        inputEntity = [[ModalItemDataEntityInput alloc] init];
        inputEntity.keyboardType = UIKeyboardTypeDefault;
        inputEntity.textChanged = ^(NSString * _Nonnull text) {
            
        };
        if(self.dic != NULL && self.dic[@"title"] != nil) {
            inputEntity.text = self.dic[@"title"];
        }
        nameElement.generalEntity = generalEntity;
        nameElement.inputEntity = inputEntity;
        nameElement.tapEnabled = NO;
        nameElement.type = ModalItemElementTypeInput;
        nameElement.renderMode = ModalItemElementRenderModeSingle;
        nameElement.action = ^(ModalItemElement * _Nonnull element) {
        };
        [ret addObject:nameElement];
        
        _nameElements = ret;
    }
    
    return _nameElements;
}

- (NSArray<ModalItemElement *> *)saveToElements{
    if (nil == _saveToElements){
        ModalItemDataEntityGeneral *generalEntity;
        NSMutableArray *ret = [[NSMutableArray alloc] init];
        ModalItemElement *saveToElement = [[ModalItemElement alloc] init];
        generalEntity = [[ModalItemDataEntityGeneral alloc] init];
        NSString *uuid = FCShared.tabManager.tabs[0].uuid;
        if(self.dic != NULL && self.dic[@"uuid"] != nil) {
            uuid = self.dic[@"uuid"];
        }
        generalEntity.title = [FCShared.tabManager tabNameWithUUID:uuid];
        generalEntity.uuid = uuid;
        saveToElement.generalEntity = generalEntity;
        saveToElement.type = ModalItemElementTypeAccessory;
        saveToElement.renderMode = ModalItemElementRenderModeSingle;
        saveToElement.action = ^(ModalItemElement * _Nonnull element) {
            SYDownloadFolderChooseModalViewController *cer = [[SYDownloadFolderChooseModalViewController alloc] init];
            cer.dic = self.dic;
            cer.nav = self.nav;
            [self.navigationController pushModalViewController:cer];
        };
        [ret addObject:saveToElement];
        
        _saveToElements = ret;
    }
    
    return _saveToElements;
}

- (UIButton *)startDownloadButton{
    if (nil == _startDownloadButton){
        _startDownloadButton = [[UIButton alloc] initWithFrame:CGRectMake(15, self.view.height - 10 - 45, self.view.frame.size.width - 30, 45)];
        [_startDownloadButton setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Save", @"")
                                                                                 attributes:@{
                             NSForegroundColorAttributeName : UIColor.whiteColor,
                             NSFontAttributeName : FCStyle.bodyBold}]
                                        forState:UIControlStateNormal];
        [_startDownloadButton addTarget:self
                                 action:@selector(startDownloadAction:)
                       forControlEvents:UIControlEventTouchUpInside];
        _startDownloadButton.backgroundColor = FCStyle.accent;
        _startDownloadButton.layer.cornerRadius = 10;
        _startDownloadButton.layer.masksToBounds = YES;
        [self.view addSubview:_startDownloadButton];
    }
    
    return _startDownloadButton;
}

- (void)startDownloadAction:(id)sender{
 
    
    
    if([FILEUUID isEqualToString:self.dic[@"uuid"]]) {
        
        DownloadResource *resource = [[DataManager shareManager] selectDownloadResourceByDownLoadUUid:self.dic[@"downloadUuid"]];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *sourceURL = [NSURL fileURLWithPath:resource.allPath];
        NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"MY_PHONE_STORAGE"];
        NSString *path = self.dic[@"allPath"] == NULL?dic[@"url"]:self.dic[@"allPath"] ;
        NSString *title = self.nameElements[0].inputEntity.text;

        NSString *removePath = [NSString stringWithFormat:@"%@/%@.%@",path,title,@"mp4"];

        NSURL *destinationURL = [NSURL fileURLWithPath:removePath];
        NSUserDefaults *groupUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dajiu.stay.pro"];
        
        NSData *loadPath =[groupUserDefaults objectForKey:@"bookmark"];
        
        NSURL *loadUrl = [NSURL URLByResolvingBookmarkData:loadPath options:0 relativeToURL:nil bookmarkDataIsStale:nil error:nil];
        BOOL fileUrlAuthozied =[loadUrl startAccessingSecurityScopedResource];

        NSError *error1 = nil;
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];

        if(!fileUrlAuthozied) {
            return;
        }
        
        [fileCoordinator coordinateWritingItemAtURL:destinationURL options:0 error:&error1 byAccessor:^(NSURL *newURL) {
            NSError *error = nil;
            BOOL success = [fileManager moveItemAtURL:sourceURL toURL:newURL error:&error];
            if (success) {
                NSLog(@"移动文件成功");
            } else {
                NSLog(@"移动文件失败：%@", error);
            }
            
        }];
        
    }
    NSString *path = self.saveToElements[0].generalEntity.uuid;
    [[DataManager  shareManager] updateVideoPath:path uuid:self.dic[@"downloadUuid"]];
    NSString *title = self.nameElements[0].inputEntity.text;
    [[DataManager shareManager] updateVideoTitle:title uuid:self.dic[@"downloadUuid"]];
    
    
    [self.navigationController.slideController dismiss];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeVideoDoc"
                                                        object:nil];
}

- (UITableView *)tableView{
    if (nil == _tableView){
        _tableView = [[UITableView alloc] init];
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        //TODO:
        if (@available(ios 15.0, *)){
           _tableView.sectionHeaderTopPadding = 0;
        }
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.sectionFooterHeight = 0;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.backgroundColor = FCStyle.popup;
        [self.view addSubview:_tableView];
        
        [[_tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor] setActive:YES];
        [[_tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor] setActive:YES];
        [[_tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor] setActive:YES];
        [[_tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-10-10-45] setActive:YES];
    }
    
    return _tableView;
}

- (void)clear{
}

- (CGSize)mainViewSize{
    return CGSizeMake(MIN(FCApp.keyWindow.frame.size.width - 30, 360), 420);
}

- (NSString* )md5HexDigest:(NSString* )input {
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", digest[i]];
    }
    return result;
}


@end
