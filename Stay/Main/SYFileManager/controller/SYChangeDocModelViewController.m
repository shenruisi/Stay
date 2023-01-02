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
    self.title = NSLocalizedString(@"ChangeDoc", @"");
    [self tableView];
    [self startDownloadButton];
}

- (void)viewWillAppear{
    [super viewWillAppear];
    
    NSString *uuid = FCShared.tabManager.tabs[0].uuid;
    if(self.dic != NULL && self.dic[@"uuid"] != nil) {
        uuid = self.dic[@"uuid"];
    }
    ModalItemElement *element = self.saveToElements.firstObject;
    element.generalEntity.title = [FCShared.tabManager tabNameWithUUID:uuid];
    element.generalEntity.uuid = uuid;
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
                @"sectionElement" : [ModalSectionElement ofTitle:NSLocalizedString(@"SaveTo", @"")],
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
    NSString *path = self.saveToElements[0].generalEntity.uuid;
    [[DataManager  shareManager] updateVideoPath:path uuid:self.dic[@"downloadUuid"]];
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
