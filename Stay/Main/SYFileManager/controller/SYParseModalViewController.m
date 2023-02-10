//
//  SYParseModalViewController.m
//  Stay
//
//  Created by King on 8/2/2023.
//

#import "SYParseModalViewController.h"
#import "FCApp.h"
#import "ModalItemElement.h"
#import "UIView+Layout.h"
#import "ModalItemView.h"
#import "ModalItemViewFactory.h"
#import "ModalSectionView.h"
#import "FCStyle.h"
#import "VideoParser.h"

@interface SYParseModalViewController()<
 UITableViewDelegate,
 UITableViewDataSource
>

@property (nonatomic, strong) NSArray<NSDictionary *> *dataSource;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<ModalItemElement *> *linkElements;
@property (nonatomic, strong) UIButton *parseButton;
@end

@implementation SYParseModalViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationBar.hidden = NO;
    self.navigationBar.showCancel = YES;
    self.title = NSLocalizedString(@"ToBeDownload", @"");
    [self tableView];
    [self parseButton];
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
        }
        linkElement.generalEntity = generalEntity;
        linkElement.inputEntity = inputEntity;
        linkElement.type = ModalItemElementTypeInput;
        linkElement.renderMode = ModalItemElementRenderModeSingle;
        linkElement.action = ^(ModalItemElement * _Nonnull element) {
        };
        [ret addObject:linkElement];
        _linkElements = ret;
    }
    
    return _linkElements;
}

- (UIButton *)parseButton{
    if (nil == _parseButton){
        _parseButton = [[UIButton alloc] initWithFrame:CGRectMake(15, self.view.height - 10 - 45, self.view.frame.size.width - 30, 45)];
        [_parseButton setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Parse", @"")
                                                                                 attributes:@{
                             NSForegroundColorAttributeName : UIColor.whiteColor,
                             NSFontAttributeName : FCStyle.bodyBold}]
                                        forState:UIControlStateNormal];
        [_parseButton addTarget:self
                                 action:@selector(parseAction:)
                       forControlEvents:UIControlEventTouchUpInside];
        _parseButton.backgroundColor = FCStyle.accent;
        _parseButton.layer.cornerRadius = 10;
        _parseButton.layer.masksToBounds = YES;
        [self.view addSubview:_parseButton];
    }
    
    return _parseButton;
}

- (void)parseAction:(id)sender{
    if(self.linkElements[0].inputEntity.text == nil || self.linkElements[0].inputEntity.text.length == 0 ) {
        UIAlertController *onlyOneAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"urlNotEmpty", @"")
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *onlyOneConfirm = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"")
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
        
            
        }];
        [onlyOneAlert addAction:onlyOneConfirm];
        [self.nav presentViewController:onlyOneAlert animated:YES completion:nil];

        return;
    }
    
    
    
    NSString *link = self.linkElements[0].inputEntity.text;
    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:@"\\s*https?://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]\\s*" options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *result = [regExp firstMatchInString:link options:0 range:NSMakeRange(0, [link length])];
    if (result != nil) {
        [self.parseButton setEnabled:NO];
        [self.parseButton setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Parsing", @"")
                                                                                 attributes:@{
                             NSForegroundColorAttributeName : UIColor.whiteColor,
                             NSFontAttributeName : FCStyle.bodyBold}]
                                        forState:UIControlStateNormal];
        NSString *targetUrl = [[link substringWithRange:[result rangeAtIndex:0]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.linkElements[0].inputEntity.text = targetUrl;
        [self.tableView reloadData];
        
        [[VideoParser shared] parse:targetUrl completionBlock:^(NSArray<NSDictionary *> * _Nonnull videoItems) {
            NSLog(@"videoItems %@",videoItems);
        }];
    } else {
        UIAlertController *onlyOneAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ParseFailed", @"")
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *onlyOneConfirm = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"")
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
        
            
        }];
        [onlyOneAlert addAction:onlyOneConfirm];
        [self.nav presentViewController:onlyOneAlert animated:YES completion:nil];

        return;
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
    return CGSizeMake(MIN(FCApp.keyWindow.frame.size.width - 30, 360), 220);
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
