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
#import "FCButton.h"
#import "AlertHelper.h"
#import "DataManager.h"
#import "AdBlockDetailViewController.h"
#import "FCShared.h"

@interface ContentFilterEditModalViewController()<
 UITableViewDelegate,
 UITableViewDataSource
>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSDictionary *> *dataSource;
@property (nonatomic, strong) ModalItemElement *titleElement;
@property (nonatomic, strong) ModalItemElement *linkElement;
@property (nonatomic, strong) FCButton *saveButton;
@property (nonatomic, strong) FCButton *restoreButton;
@end

@implementation ContentFilterEditModalViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.hideNavigationBar = NO;
    self.navigationBar.showCancel = YES;
    self.title = self.contentFilter.title;
    [self tableView];
    [self restoreButton];
    [self saveButton];
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

- (FCButton *)saveButton{
    if (nil == _saveButton){
        _saveButton = [[FCButton alloc] init];
        [_saveButton addTarget:self action:@selector(saveAction:) forControlEvents:UIControlEventTouchUpInside];
        [_saveButton setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Save", @"")
                                                                attributes:@{
            NSForegroundColorAttributeName : FCStyle.accent,
            NSFontAttributeName : FCStyle.bodyBold
        }] forState:UIControlStateNormal];
        _saveButton.loadingBackgroundColor = UIColor.clearColor;
        _saveButton.loadingTitleColor = FCStyle.fcSeparator;
        _saveButton.loadingBorderColor = FCStyle.fcSeparator;
        _saveButton.loadingViewColor = FCStyle.fcSecondaryBlack;
        _saveButton.backgroundColor = UIColor.clearColor;
        _saveButton.layer.cornerRadius = 10;
        _saveButton.layer.borderColor = FCStyle.accent.CGColor;
        _saveButton.layer.borderWidth = 1;
        _saveButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_saveButton];
        
        [NSLayoutConstraint activateConstraints:@[
            [_saveButton.bottomAnchor constraintEqualToAnchor:self.restoreButton.topAnchor constant:-15],
            [_saveButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:15],
            [_saveButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-15],
            [_saveButton.heightAnchor constraintEqualToConstant:45]
        ]];
    }
    
    return _saveButton;
}

- (void)saveAction:(id)sender{
    FCButton *button = (FCButton *)sender;

    NSString *originDownloadUrl = self.contentFilter.downloadUrl;
    if (self.linkElement.inputEntity.text.length > 0){
        [self.navigationController.slideController startLoading];
        [button startLoading];
        self.contentFilter.downloadUrl = self.linkElement.inputEntity.text;
        __weak ContentFilterEditModalViewController *weakSelf = self;
        [self.contentFilter checkUpdatingIfNeeded:YES completion:^(NSError * _Nonnull error) {
            [button stopLoading];
            if (nil == error || (error && [error.domain isEqualToString:@"Content Filter Error"])){
                [[DataManager shareManager] updateContentFilterDownloadUrl:weakSelf.contentFilter.downloadUrl uuid:weakSelf.contentFilter.uuid];
                AdBlockDetailViewController *cer = (AdBlockDetailViewController *)self.navigationController.slideController.baseCer;
                [cer refreshRules];
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
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.navigationController.slideController stopLoading];
                        UIImage *image =  [UIImage systemImageNamed:@"checkmark.circle.fill"
                                                  withConfiguration:[UIImageSymbolConfiguration configurationWithFont:FCStyle.sfIcon]];
                        image = [image imageWithTintColor:FCStyle.fcBlack
                                            renderingMode:UIImageRenderingModeAlwaysOriginal];
                        [FCShared.toastCenter show:image
                                         mainTitle:weakSelf.contentFilter.title
                                    secondaryTitle:NSLocalizedString(@"SaveDone", @"")];
                    });
                }
            }
            else{
                self.contentFilter.downloadUrl = originDownloadUrl;
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
        }];
    }
    
    NSString *originTitle = self.contentFilter.title;
    if (self.titleElement.inputEntity.text.length > 0
        && ![self.titleElement.inputEntity.text isEqualToString:originTitle]){
        self.contentFilter.title = self.titleElement.inputEntity.text;
        self.title = self.titleElement.inputEntity.text;
        [[DataManager shareManager] updateContentFilterTitle:self.contentFilter.title uuid:self.contentFilter.uuid];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ContentFilterDidUpdateNotification object:nil];
    
}

- (FCButton *)restoreButton{
    if (nil == _restoreButton){
        _restoreButton = [[FCButton alloc] init];
        [_restoreButton addTarget:self action:@selector(restoreAction:) forControlEvents:UIControlEventTouchUpInside];
        [_restoreButton setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"ContentFilterRestore", @"")
                                                                attributes:@{
            NSForegroundColorAttributeName : UIColor.whiteColor,
            NSFontAttributeName : FCStyle.bodyBold
        }] forState:UIControlStateNormal];
        _restoreButton.backgroundColor = UIColor.redColor;
        _restoreButton.layer.cornerRadius = 10;
        _restoreButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_restoreButton];
        
        [NSLayoutConstraint activateConstraints:@[
            [_restoreButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-15],
            [_restoreButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:15],
            [_restoreButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-15],
            [_restoreButton.heightAnchor constraintEqualToConstant:45]
        ]];
    }
    
    return _restoreButton;
}


- (void)restoreAction:(id)sender{
    FCButton *button = (FCButton *)sender;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"AdBlock", @"")
                                                                   message:NSLocalizedString(@"ContentFilterRestoreMessage", @"")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"")
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
        self.contentFilter.downloadUrl = self.contentFilter.defaultUrl;
        self.contentFilter.title = self.contentFilter.defaultTitle;
        NSString *restoreDateString = @"2023-05-20 00:00:00";
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *restoreDate = [dateFormatter dateFromString:restoreDateString];
        self.contentFilter.updateTime = restoreDate;
        [[DataManager shareManager] updateContentFilterUpdateTime:restoreDate uuid:self.contentFilter.uuid];
        [[DataManager shareManager] updateContentFilterDownloadUrl:self.contentFilter.defaultUrl uuid:self.contentFilter.uuid];
        [[DataManager shareManager] updateContentFilterTitle:self.contentFilter.defaultTitle uuid:self.contentFilter.uuid];
        [button startLoading];
        [self.navigationController.slideController startLoading];
        [self.contentFilter restoreRulesWithCompletion:^(NSError *error){
            [button stopLoading];
            self.titleElement.inputEntity.text = self.contentFilter.title;
            self.linkElement.inputEntity.text = self.contentFilter.downloadUrl;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.title = self.contentFilter.title;
                [self.navigationController.slideController stopLoading];
                AdBlockDetailViewController *cer = (AdBlockDetailViewController *)self.navigationController.slideController.baseCer;
                [cer refreshRules];
                
                [self.tableView reloadData];
                UIImage *image =  [UIImage systemImageNamed:@"checkmark.circle.fill"
                                          withConfiguration:[UIImageSymbolConfiguration configurationWithFont:FCStyle.sfIcon]];
                image = [image imageWithTintColor:FCStyle.fcBlack
                                    renderingMode:UIImageRenderingModeAlwaysOriginal];
                [FCShared.toastCenter show:image
                                 mainTitle:self.contentFilter.title
                            secondaryTitle:NSLocalizedString(@"SaveDone", @"")];
                [[NSNotificationCenter defaultCenter] postNotificationName:ContentFilterDidUpdateNotification object:nil];
            });
        }];
        
    }];
    [alert addAction:confirm];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"")
         style:UIAlertActionStyleCancel
         handler:^(UIAlertAction * _Nonnull action) {
     }];
     [alert addAction:cancel];
    [self.navigationController.slideController.baseCer presentViewController:alert animated:YES completion:nil];
}

- (CGSize)mainViewSize{
    return CGSizeMake(MIN(FCApp.keyWindow.frame.size.width - 30, 360), 390);
}

@end
