//
//  ContentFilterEditModalViewController.m
//  Stay
//
//  Created by ris on 2023/4/13.
//

#import "ContentFilterEditModalViewController.h"
#import "FCApp.h"
#import "FCStyle.h"
#import "ModalSectionElement.h"
#import "ModalItemElement.h"
#import "ModalItemViewFactory.h"
#import "ModalSectionView.h"

@interface ContentFilterEditModalViewController()<
 UITableViewDelegate,
 UITableViewDataSource
>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSDictionary *> *dataSource;
@property (nonatomic, strong) ModalItemElement *titleElement;
@property (nonatomic, strong) ModalItemElement *linkElement;
@end

@implementation ContentFilterEditModalViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationBar.hidden = NO;
    self.navigationBar.showCancel = YES;
    self.title = self.contentFilter.title;
    [self tableView];
}

- (void)viewWillAppear{
    [super viewWillAppear];
    self.titleElement.inputEntity.text = self.contentFilter.title;
    self.linkElement.inputEntity.text = self.contentFilter.downloadUrl;
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
    return [ModalSectionView fixedHeight];
}

- (NSArray<NSDictionary *> *)dataSource{
    if (nil == _dataSource){
        _dataSource = @[
            @{
                @"sectionElement" : [ModalSectionElement ofTitle:NSLocalizedString(@"Title", @"")],
                @"itemElements" : @[self.titleElement]
            },
            @{
                @"sectionElement" : [ModalSectionElement ofTitle:NSLocalizedString(@"Link", @"")],
                @"itemElements" : @[self.linkElement]
            }
        ];
    }
    
    return _dataSource;
}

- (UITableView *)tableView{
    if (nil == _tableView){
        _tableView = [[UITableView alloc] init];
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        if (@available(iOS 15.0, *)){
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
        [[_tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor] setActive:YES];
    }
    
    return _tableView;
}

- (ModalItemElement *)titleElement{
    if (nil == _titleElement){
        _titleElement = [[ModalItemElement alloc] init];
        ModalItemDataEntityGeneral *general = [[ModalItemDataEntityGeneral alloc] init];
        ModalItemDataEntityInput *input = [[ModalItemDataEntityInput alloc] init];
        input.placeholder = NSLocalizedString(@"Title", @"");
        _titleElement.generalEntity = general;
        _titleElement.inputEntity = input;
        _titleElement.renderMode = ModalItemElementRenderModeSingle;
        _titleElement.type = ModalItemElementTypeInput;
    }
    
    return _titleElement;
}

- (ModalItemElement *)linkElement{
    if (nil == _linkElement){
        _linkElement = [[ModalItemElement alloc] init];
        ModalItemDataEntityGeneral *general = [[ModalItemDataEntityGeneral alloc] init];
        ModalItemDataEntityInput *input = [[ModalItemDataEntityInput alloc] init];
        input.placeholder = NSLocalizedString(@"Link", @"");
        _linkElement.generalEntity = general;
        _linkElement.inputEntity = input;
        _linkElement.renderMode = ModalItemElementRenderModeSingle;
        _linkElement.type = ModalItemElementTypeInput;
    }
    
    return _linkElement;
}

- (CGSize)mainViewSize{
    return CGSizeMake(MIN(FCApp.keyWindow.frame.size.width - 30, 360), 450);
}

@end
