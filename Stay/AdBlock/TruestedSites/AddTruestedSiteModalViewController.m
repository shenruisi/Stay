//
//  AddTruestedSiteModalViewController.m
//  Stay
//
//  Created by ris on 2023/5/15.
//

#import "AddTruestedSiteModalViewController.h"
#import "FCApp.h"
#import "ModalItemView.h"
#import "FCButton.h"
#import "ModalSectionView.h"
#import "ModalItemViewFactory.h"
#import "FCStyle.h"
#import "ContentFilterManager.h"

NSNotificationName const _Nonnull TruestedSiteDidAddNotification = @"app.notification.TruestedSiteDidAddNotification";

@interface AddTruestedSiteModalViewController()<
 UITableViewDelegate,
 UITableViewDataSource
>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSDictionary *> *dataSource;
@property (nonatomic, strong) ModalItemElement *domainElement;
@property (nonatomic, strong) FCButton *addButton;
@end

@implementation AddTruestedSiteModalViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.hideNavigationBar = NO;
    self.navigationBar.showCancel = YES;
    self.title = NSLocalizedString(@"NewSite", @"");
    [self tableView];
    [self addButton];
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
                @"sectionElement" : [ModalSectionElement ofTitle:NSLocalizedString(@"Domain", @"")],
                @"itemElements" : @[self.domainElement]
            },
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
        [[_tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-25] setActive:YES];
    }
    
    return _tableView;
}

- (FCButton *)addButton{
    if (nil == _addButton){
        _addButton = [[FCButton alloc] init];
        [_addButton addTarget:self action:@selector(addAction:) forControlEvents:UIControlEventTouchUpInside];
        [_addButton setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Add", @"")
                                                                attributes:@{
            NSForegroundColorAttributeName : FCStyle.fcSeparator,
            NSFontAttributeName : FCStyle.bodyBold
        }] forState:UIControlStateNormal];
        _addButton.loadingBackgroundColor = UIColor.clearColor;
        _addButton.loadingTitleColor = FCStyle.fcSeparator;
        _addButton.loadingBorderColor = FCStyle.fcSeparator;
        _addButton.loadingViewColor = FCStyle.fcSecondaryBlack;
        _addButton.backgroundColor = UIColor.clearColor;
        _addButton.layer.cornerRadius = 10;
        _addButton.layer.borderColor = FCStyle.fcSeparator.CGColor;
        _addButton.layer.borderWidth = 1;
        _addButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_addButton];
        
        [NSLayoutConstraint activateConstraints:@[
            [_addButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-15],
            [_addButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:15],
            [_addButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-15],
            [_addButton.heightAnchor constraintEqualToConstant:45]
        ]];
    }
    
    return _addButton;
}


- (ModalItemElement *)domainElement{
    if (nil == _domainElement){
        _domainElement = [[ModalItemElement alloc] init];
        ModalItemDataEntityGeneral *general = [[ModalItemDataEntityGeneral alloc] init];
        ModalItemDataEntityInput *input = [[ModalItemDataEntityInput alloc] init];
        input.placeholder = NSLocalizedString(@"Domain", @"");
        input.autocorrectionType = UITextAutocorrectionTypeNo;
        input.autocapitalizationType = UITextAutocapitalizationTypeNone;
        input.spellCheckingType = UITextSpellCheckingTypeNo;
        _domainElement.generalEntity = general;
        _domainElement.inputEntity = input;
        __weak AddTruestedSiteModalViewController *weakSelf = self;
        _domainElement.inputEntity.textChanged = ^(NSString * _Nonnull text) {
            if (text.length > 0){
                [weakSelf.addButton setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Add", @"")
                                                                        attributes:@{
                    NSForegroundColorAttributeName : FCStyle.accent,
                    NSFontAttributeName : FCStyle.bodyBold
                }] forState:UIControlStateNormal];
                weakSelf.addButton.layer.cornerRadius = 10;
                weakSelf.addButton.layer.borderColor = FCStyle.accent.CGColor;
                weakSelf.addButton.layer.borderWidth = 1;
            }
            else{
                [weakSelf.addButton setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Add", @"")
                                                                        attributes:@{
                    NSForegroundColorAttributeName : FCStyle.fcSeparator,
                    NSFontAttributeName : FCStyle.bodyBold
                }] forState:UIControlStateNormal];
                weakSelf.addButton.layer.cornerRadius = 10;
                weakSelf.addButton.layer.borderColor = FCStyle.fcSeparator.CGColor;
                weakSelf.addButton.layer.borderWidth = 1;
            }
        };
        _domainElement.renderMode = ModalItemElementRenderModeSingle;
        _domainElement.type = ModalItemElementTypeInput;
    }
    
    return _domainElement;
}

- (void)addAction:(id)sender{
    NSString *text = self.domainElement.inputEntity.textField.text;
    if (0 == text.length){
        return;
    }
    
    NSRegularExpression *domainRegex = [NSRegularExpression regularExpressionWithPattern:@"([a-zA-Z0-9\\-]*\\.?[a-zA-Z0-9\\-]+\\.[a-zA-Z]{2,})" options:0 error:nil];
    NSArray<NSTextCheckingResult *> *results = [domainRegex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    if (results.count == 1){
        NSInteger n = results[0].numberOfRanges;
        if (n > 0){
            NSRange range = [results[0] rangeAtIndex:0];
            if (NSMaxRange(range) == text.length){
                
                if ([[ContentFilterManager shared] existTruestSiteWithDomain:text]){
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle: NSLocalizedString(@"AdBlock", @"")
                                                                                   message:NSLocalizedString(@"DomainExistError", @"")
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *confirm = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"")
                                                                      style:UIAlertActionStyleDefault
                                                                    handler:^(UIAlertAction * _Nonnull action) {
                    }];
                    [alert addAction:confirm];
                    [self.navigationController.slideController.baseCer presentViewController:alert animated:YES completion:nil];
                    return;
                }
                
                [[ContentFilterManager shared] addTruestSiteWithDomain:text error:nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:TruestedSiteDidAddNotification object:nil];
                [self.navigationController.slideController dismiss];
                return;
            }
        }
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: NSLocalizedString(@"AdBlock", @"")
                                                                   message:NSLocalizedString(@"DomainFormatError", @"")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"")
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
        }];
    [alert addAction:confirm];
    [self.navigationController.slideController.baseCer presentViewController:alert animated:YES completion:nil];
}

- (CGSize)mainViewSize{
    return CGSizeMake(MIN(FCApp.keyWindow.frame.size.width - 30, 360), 260);
}

@end
