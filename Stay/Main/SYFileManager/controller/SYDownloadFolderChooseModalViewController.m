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
        NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"MY_PHONE_STORAGE"];
        if(dic != nil && !_noExternalFolder) {
            NSString *text = dic[@"fileName"];
            ModalItemElement *element = [[ModalItemElement alloc] init];
            generalEntity = [[ModalItemDataEntityGeneral alloc] init];
            generalEntity.title = text;
            generalEntity.uuid = FILEUUID;
            element.generalEntity = generalEntity;
            element.type = ModalItemElementTypeClick;
            element.renderMode = ModalItemElementRenderModeTop;
            element.action = ^(ModalItemElement * _Nonnull element) {
                if([element.generalEntity.uuid isEqualToString:FILEUUID]) {
                    self.dic[@"uuid"] = FILEUUID;
                    [self.navigationController popModalViewController];
                }
            };
            [ret addObject:element];
        }

        for (NSInteger i = 0; i < FCShared.tabManager.tabs.count; i++){
            FCTab *tab = FCShared.tabManager.tabs[i];
            if ([tab.uuid isEqualToString:self.excludeUUID]){
                continue;
            }
            ModalItemElement *element = [[ModalItemElement alloc] init];
            generalEntity = [[ModalItemDataEntityGeneral alloc] init];
            generalEntity.title = tab.config.name;
            generalEntity.uuid = tab.uuid;
            element.generalEntity = generalEntity;
            element.type = ModalItemElementTypeClick;
            if (ret.count == 0){
                element.renderMode = ModalItemElementRenderModeTop;
            }
            else if (i == FCShared.tabManager.tabs.count - 1){
                element.renderMode = ModalItemElementRenderModeBottom;
            }
            else{
                element.renderMode = ModalItemElementRenderModeMiddle;
            }
            element.action = ^(ModalItemElement * _Nonnull element) {
                self.dic[@"uuid"] = element.generalEntity.uuid;
                [self.navigationController popModalViewController];
            };
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
- (UIViewController *)findCurrentShowingViewControllerFrom:(UIViewController *)vc
{
    // 递归方法 Recursive method
    UIViewController *currentShowingVC;
    if ([vc presentedViewController]) {
        // 当前视图是被presented出来的
        UIViewController *nextRootVC = [vc presentedViewController];
        currentShowingVC = [self findCurrentShowingViewControllerFrom:nextRootVC];

    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        UIViewController *nextRootVC = [(UITabBarController *)vc selectedViewController];
        currentShowingVC = [self findCurrentShowingViewControllerFrom:nextRootVC];

    } else if ([vc isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        UIViewController *nextRootVC = [(UINavigationController *)vc visibleViewController];
        currentShowingVC = [self findCurrentShowingViewControllerFrom:nextRootVC];

    } else {
        // 根视图为非导航类
        currentShowingVC = vc;
    }

    return currentShowingVC;
}



@end
