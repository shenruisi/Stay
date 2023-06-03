//
//  AddSubscribeModalViewController.m
//  Stay
//
//  Created by ris on 2023/6/1.
//

#import "AddSubscribeModalViewController.h"
#import "FCApp.h"
#import "ModalSectionElement.h"
#import "ModalItemElement.h"
#import "ModalItemViewFactory.h"
#import "ModalSectionView.h"
#import "FCButton.h"
#import "AlertHelper.h"
#import "FCShared.h"
#import "FCStyle.h"
#import "ContentFilter2.h"
#import "DataManager.h"
#import "SubscribeContentFilterManager.h"

@interface AddSubscribeModalViewController()<
 UITableViewDelegate,
 UITableViewDataSource
>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSDictionary *> *dataSource;
@property (nonatomic, strong) ModalItemElement *titleElement;
@property (nonatomic, strong) ModalItemElement *linkElement;
@property (nonatomic, strong) FCButton *addButton;
@property (nonatomic, strong) FCButton *cancelButton;
@property (nonatomic, strong) ContentFilter *contentFilter;
@end

@implementation AddSubscribeModalViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationBar.showCancel = YES;
    self.title = NSLocalizedString(@"NewSubscription", @"");
    [self tableView];
    [self addButton];
    [self cancelButton];
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
        [[_tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-120] setActive:YES];
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

- (FCButton *)addButton{
    if (nil == _addButton){
        _addButton = [[FCButton alloc] init];
        [_addButton addTarget:self action:@selector(addAction:) forControlEvents:UIControlEventTouchUpInside];
        [_addButton setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Add", @"")
                                                                attributes:@{
            NSForegroundColorAttributeName : FCStyle.accent,
            NSFontAttributeName : FCStyle.bodyBold
        }] forState:UIControlStateNormal];
        _addButton.loadingBackgroundColor = UIColor.clearColor;
        _addButton.loadingTitleColor = FCStyle.fcSeparator;
        _addButton.loadingBorderColor = FCStyle.fcSeparator;
        _addButton.loadingViewColor = FCStyle.fcSecondaryBlack;
        _addButton.backgroundColor = UIColor.clearColor;
        _addButton.layer.cornerRadius = 10;
        _addButton.layer.borderColor = FCStyle.accent.CGColor;
        _addButton.layer.borderWidth = 1;
        _addButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_addButton];
        
        [NSLayoutConstraint activateConstraints:@[
            [_addButton.bottomAnchor constraintEqualToAnchor:self.cancelButton.topAnchor constant:-15],
            [_addButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:15],
            [_addButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-15],
            [_addButton.heightAnchor constraintEqualToConstant:45]
        ]];
    }
    
    return _addButton;
}

- (void)addAction:(FCButton *)button{
    if (self.titleElement.inputEntity.text.length > 0 && self.linkElement.inputEntity.text.length > 0){
        [self.navigationController.slideController startLoading];
        [button startLoading];
        
        NSString *uuid = [[NSUUID UUID] UUIDString];
        ContentFilter *subscribe = [[ContentFilter alloc] init];
        subscribe.defaultTitle = self.titleElement.inputEntity.text;
        subscribe.title =  self.titleElement.inputEntity.text;
        subscribe.path = [NSString stringWithFormat:@"%@.txt",uuid];
        subscribe.rulePath = @"Subscribe.json";
        subscribe.defaultUrl = self.linkElement.inputEntity.text;
        subscribe.downloadUrl = self.linkElement.inputEntity.text;
        subscribe.enable = 0;
        subscribe.status = 1;
        subscribe.sort = 1;
        subscribe.load = 1;
        subscribe.expires = @"4 days (update frequency)";
        subscribe.version = @"";
        subscribe.homepage = @"";
        subscribe.uuid = uuid;
#ifdef FC_MAC
        subscribe.contentBlockerIdentifier = @"com.dajiu.stay.pro.Stay-Content-Subscribe-Mac";
#else
        subscribe.contentBlockerIdentifier = @"com.dajiu.stay.pro.Stay-Content-Subscribe";
#endif
        subscribe.type = ContentFilterTypeSubscribe;
        self.contentFilter  = subscribe;
        
        __weak AddSubscribeModalViewController *weakSelf = self;
        [[SubscribeContentFilterManager shared] checkUpdatingIfNeeded:self.contentFilter
                                                                focus:YES
                                                           completion:^(NSError * _Nonnull error, BOOL updated) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.navigationController.slideController stopLoading];
                [button stopLoading];
            });
            
            if (error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.navigationController.slideController stopLoading];
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle: NSLocalizedString(@"AdBlock", @"")
                                                                                   message:[error localizedDescription]
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *confirm = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"")
                                                                      style:UIAlertActionStyleDefault
                                                                    handler:^(UIAlertAction * _Nonnull action) {
                        }];
                    [alert addAction:confirm];
                    [weakSelf.navigationController.slideController.baseCer presentViewController:alert animated:YES completion:nil];
                });
            }
            else{
                [[DataManager shareManager] insertContentFilter:self.contentFilter error:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:ContentFilterDidAddNotification object:nil];
                [self.navigationController.slideController dismiss];
            }
            
        }];
    }
    else{
        UIImage *image =  [UIImage systemImageNamed:@"x.circle.fill"
                                  withConfiguration:[UIImageSymbolConfiguration configurationWithFont:FCStyle.sfIcon]];
        image = [image imageWithTintColor:UIColor.redColor
                            renderingMode:UIImageRenderingModeAlwaysOriginal];
        [FCShared.toastCenter show:image
                         mainTitle:NSLocalizedString(@"AdBlock", @"")
                    secondaryTitle:NSLocalizedString(@"FillCompleteInfo", @"")];
    }
}

- (FCButton *)cancelButton{
    if (nil == _cancelButton){
        _cancelButton = [[FCButton alloc] init];
        [_cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
        [_cancelButton setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"cancel", @"")
                                                                attributes:@{
            NSForegroundColorAttributeName : FCStyle.fcSecondaryBlack,
            NSFontAttributeName : FCStyle.bodyBold
        }] forState:UIControlStateNormal];
        _cancelButton.backgroundColor = UIColor.clearColor;
        _cancelButton.layer.cornerRadius = 10;
        _cancelButton.layer.borderColor = FCStyle.fcSeparator.CGColor;
        _cancelButton.layer.borderWidth = 1;
        _cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_cancelButton];
        
        [NSLayoutConstraint activateConstraints:@[
            [_cancelButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-15],
            [_cancelButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:15],
            [_cancelButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-15],
            [_cancelButton.heightAnchor constraintEqualToConstant:45]
        ]];
    }
    
    return _cancelButton;
}

- (void)cancelAction:(id)sender{
    [self.navigationController.slideController dismiss];
}

- (CGSize)mainViewSize{
    return CGSizeMake(MIN(FCApp.keyWindow.frame.size.width - 30, 360), 390);
}
@end
