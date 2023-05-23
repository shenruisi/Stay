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
#import "NSString+Urlencode.h"
#import "ModalItemView.h"
#import "ModalItemViewFactory.h"
#import "ModalSectionView.h"
#import "FCStyle.h"
#import "VideoParser.h"
#import "SYDownloadModalViewController.h"
#import "SYParseDownloadModalViewController.h"

@interface SYParseModalViewController()<
 UITableViewDelegate,
 UITableViewDataSource
>

@property (nonatomic, strong) NSArray<NSDictionary *> *dataSource;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<ModalItemElement *> *linkElements;
@property (nonatomic, strong) UIButton *parseButton;
@property (nonatomic, strong) SYParseDownloadModalViewController *parseDownloadController;
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
                NSForegroundColorAttributeName : FCStyle.accent,
                             NSFontAttributeName : FCStyle.bodyBold}]
                                        forState:UIControlStateNormal];
        [_parseButton addTarget:self
                                 action:@selector(parseAction:)
                       forControlEvents:UIControlEventTouchUpInside];
        _parseButton.backgroundColor = UIColor.clearColor;
        _parseButton.layer.borderColor = FCStyle.accent.CGColor;
        _parseButton.layer.borderWidth = 1;
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
    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:@"\\s*https?://[^，]+\\s*" options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *result = [regExp firstMatchInString:link options:0 range:NSMakeRange(0, [link length])];
    if (result != nil) {
        NSString *targetUrl = [[link substringWithRange:[result rangeAtIndex:0]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSURL *linkURL = [NSURL URLWithString:[targetUrl safeEncode]];
        if (linkURL != nil && ([linkURL.lastPathComponent hasSuffix:@".mp4"]
                               || [linkURL.lastPathComponent hasSuffix:@".m3u8"]
                               || [linkURL.host containsString:@"googlevideo.com"])) {
            SYDownloadModalViewController *cer = [[SYDownloadModalViewController alloc] init];
            cer.dic = [NSMutableDictionary dictionaryWithDictionary:self.dic];
            cer.dic[@"downloadUrl"] = targetUrl;
            if(cer.dic[@"title"] == nil) {
                cer.dic[@"title"] = [linkURL.lastPathComponent stringByDeletingPathExtension];
            }
            cer.nav = self.nav;
            [self.navigationController pushModalViewController:cer];
        } else {
            self.linkElements[0].inputEntity.text = targetUrl;
            [self.tableView reloadData];
            
            self.parseDownloadController.nav = self.nav;
            [self.navigationController pushModalViewController:self.parseDownloadController];
            [self.parseDownloadController setData:[NSArray array]];
            
            [[VideoParser shared] parse:[targetUrl safeEncode] completionBlock:^(NSArray<NSDictionary *> * _Nonnull videoItems) {
                [self.parseDownloadController setData:videoItems];
            }];
        }
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

- (SYParseDownloadModalViewController *)parseDownloadController {
    if (nil == _parseDownloadController) {
        _parseDownloadController = [[SYParseDownloadModalViewController alloc] init];
    }
    
    return _parseDownloadController;
}

- (void)clear{
}

- (CGSize)mainViewSize{
    return CGSizeMake(MIN(FCApp.keyWindow.frame.size.width - 30, 360), 220);
}

@end
