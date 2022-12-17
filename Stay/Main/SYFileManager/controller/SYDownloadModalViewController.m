//
//  SYDownloadModalViewController.m
//  Stay
//
//  Created by ris on 2022/12/16.
//

#import "SYDownloadModalViewController.h"
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

@interface SYDownloadModalViewController()<
 UITableViewDelegate,
 UITableViewDataSource
>

@property (nonatomic, strong) NSArray<NSDictionary *> *dataSource;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<ModalItemElement *> *linkElements;
@property (nonatomic, strong) NSArray<ModalItemElement *> *nameElements;
@property (nonatomic, strong) NSArray<ModalItemElement *> *saveToElements;
@property (nonatomic, strong) UIButton *startDownloadButton;
@end

@implementation SYDownloadModalViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationBar.hidden = NO;
    self.navigationBar.showCancel = YES;
    self.title = NSLocalizedString(@"ToBeDownload", @"");
    [self tableView];
    [self startDownloadButton];
}

- (void)viewWillAppear{
    [super viewWillAppear];
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
                @"sectionElement" : [ModalSectionElement ofTitle:NSLocalizedString(@"Link", @"")],
                @"itemElements" : self.linkElements
            },
            @{
                @"sectionElement" : [ModalSectionElement ofTitle:NSLocalizedString(@"Name", @"")],
                @"itemElements" : self.nameElements
            },
            @{
                @"sectionElement" : [ModalSectionElement ofTitle:NSLocalizedString(@"SaveTo", @"")],
                @"itemElements" : self.saveToElements
            }
        ];
        
    }
    
    return _dataSource;
}

- (NSArray<ModalItemElement *> *)linkElements{
    if (nil == _linkElements){
        ModalItemDataEntityGeneral *generalEntity;
        ModalItemDataEntityInput *inputEntity;
        NSMutableArray *ret = [[NSMutableArray alloc] init];
        ModalItemElement *linkElement = [[ModalItemElement alloc] init];
        generalEntity = [[ModalItemDataEntityGeneral alloc] init];
        inputEntity = [[ModalItemDataEntityInput alloc] init];
        inputEntity.keyboardType = UIKeyboardTypeDefault;
        inputEntity.textChanged = ^(NSString * _Nonnull text) {
            
        };
        if(self.dic != NULL && self.dic[@"downloadUrl"] != nil) {
            inputEntity.text = self.dic[@"downloadUrl"];
            linkElement.enable = NO;
        }
        linkElement.generalEntity = generalEntity;
        linkElement.inputEntity = inputEntity;
        linkElement.tapEnabled = NO;
        linkElement.type = ModalItemElementTypeInput;
        linkElement.renderMode = ModalItemElementRenderModeSingle;
        linkElement.action = ^(ModalItemElement * _Nonnull element) {
        };
        [ret addObject:linkElement];
        _linkElements = ret;
    }
    
    return _linkElements;
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
        generalEntity.title = @"Default";
        if(self.dic != NULL && self.dic[@"uuid"] != nil) {
            generalEntity.uuid = self.dic[@"uuid"];
        } else {
            FCTab *tab = [FCShared tabManager].tabs[0];
            generalEntity.uuid = tab.uuid;
        }
        saveToElement.generalEntity = generalEntity;
        saveToElement.type = ModalItemElementTypeAccessory;
        saveToElement.renderMode = ModalItemElementRenderModeSingle;
        saveToElement.action = ^(ModalItemElement * _Nonnull element) {
            
        };
        [ret addObject:saveToElement];
        
        _saveToElements = ret;
    }
    
    return _saveToElements;
}

- (UIButton *)startDownloadButton{
    if (nil == _startDownloadButton){
        _startDownloadButton = [[UIButton alloc] initWithFrame:CGRectMake(15, self.view.height - 10 - 45, self.view.frame.size.width - 30, 45)];
        [_startDownloadButton setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"StartDownload", @"")
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

    DownloadResource *resource = [[DownloadResource alloc] init];
    NSString *downLoadUrl = self.linkElements[0].inputEntity.text;
    resource.title = self.nameElements[0].inputEntity.text;

    resource.downloadUrl = downLoadUrl;
    if(self.dic != NULL) {
        resource.icon = self.dic[@"poster"];
        resource.host = self.dic[@"hostUrl"];
    }
    
    resource.firstPath = self.saveToElements[0].generalEntity.uuid;
    
    resource.downloadUuid = [self md5HexDigest:downLoadUrl];
    DownloadResource *oldResource =  [[DataManager shareManager] selectDownloadResourceByDownLoadUUid:[self md5HexDigest:downLoadUrl]];
    if(!(oldResource != nil && oldResource.downloadUrl != nil)) {
        

        FCTab *tab = [[FCShared tabManager] tabOfUUID:self.saveToElements[0].generalEntity.uuid];
        Request *request = [[Request alloc] init];
        request.url = downLoadUrl;
        request.fileDir = tab.path;
        request.fileType = @"video";
        request.fileName = resource.title.length > 0 ? resource.title : downLoadUrl.lastPathComponent;
        if (![request.fileName hasSuffix:@".mp4"]) {
            request.fileName = [request.fileName stringByAppendingString:@".mp4"];
        }
        request.key = tab.uuid;
        Task *task = [[DownloadManager shared] enqueue:request];

        resource.status = 0;
        resource.watchProcess = 0;
        resource.downloadProcess = 0;
        resource.videoDuration = 0;
        resource.allPath = task.filePath;
        resource.sort = 0;
        [[DataManager shareManager] addDownloadResource:resource];
        SYDownloadResourceManagerController *controller = [[SYDownloadResourceManagerController alloc] init];
        controller.pathUuid = tab.uuid;
        controller.title = tab.config.name;
        controller.array = [NSMutableArray array];
        [controller.array addObjectsFromArray: [[DataManager shareManager] selectDownloadResourceByPath:controller.pathUuid]];

        [self.nav pushViewController:controller animated:true];
        
        [self.navigationController.slideController dismiss];
    } else {
        
    }
    
    
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
        [result appendFormat:@"%02X", digest[i]];
    }
    return result;
}

@end
