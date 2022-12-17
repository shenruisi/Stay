//
//  SYDownloadFolderChooseModalViewController.m
//  Stay
//
//  Created by ris on 2022/12/16.
//

#import "SYDownloadFolderChooseModalViewController.h"
#import "FCStyle.h"
#import "FCApp.h"
#import "ModalItemElement.h"
#import "ModalSectionElement.h"
#import "ModalItemView.h"
#import "ModalItemViewFactory.h"
#import "ModalSectionView.h"
#import "FCShared.h"
#import "FCTabManager.h"

@interface SYDownloadFolderChooseModalViewController()<
 UITableViewDelegate,
 UITableViewDataSource
>

@property (nonatomic, strong) NSArray<NSDictionary *> *dataSource;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<ModalItemElement *> *folderElements;
@end

@implementation SYDownloadFolderChooseModalViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationBar.hidden = NO;
    self.navigationBar.showCancel = YES;
    self.title = NSLocalizedString(@"SaveTo", @"");
    [self tableView];
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
                @"sectionElement" : [ModalSectionElement ofTitle:NSLocalizedString(@"Folders", @"")],
                @"itemElements" : self.folderElements
            }
        ];
        
    }
    
    return _dataSource;
}

- (NSArray<ModalItemElement *> *)folderElements{
    if (nil == _folderElements){
        ModalItemDataEntityGeneral *generalEntity;
        NSMutableArray *ret = [[NSMutableArray alloc] init];
        
        for (NSInteger i = 0; i < FCShared.tabManager.tabs.count; i++){
            FCTab *tab = FCShared.tabManager.tabs[i];
            ModalItemElement *element = [[ModalItemElement alloc] init];
            generalEntity = [[ModalItemDataEntityGeneral alloc] init];
            generalEntity.title = tab.config.name;
            element.generalEntity = generalEntity;
            element.type = ModalItemElementTypeClick;
            if (i == 0){
                element.renderMode = ModalItemElementRenderModeTop;
            }
            else if (i == FCShared.tabManager.tabs.count - 1){
                element.renderMode = ModalItemElementRenderModeBottom;
            }
            else{
                element.renderMode = ModalItemElementRenderModeMiddle;
            }
            [ret addObject:element];
        }
       
        _folderElements = ret;
    }
    
    return _folderElements;
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

@end
