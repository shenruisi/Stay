//
//  SYParseDownloadModalViewController.m
//  Stay
//
//  Created by Jin on 2023/2/10.
//

#import "SYParseDownloadModalViewController.h"
#import "FCApp.h"
#import "FCStyle.h"
#import "FCShared.h"
#import "ImageHelper.h"
#import "ColorHelper.h"
#import "UIImageView+WebCache.h"
#import "NSString+Urlencode.h"
#import "UIColor+Convert.h"
#import "VideoParser.h"
#import "DownloadResource.h"
#import "DataManager.h"
#import "DownloadManager.h"
#import "MyAdditions.h"
#import "SYDownloadModalViewController.h"
#import "SYDownloadFolderChooseModalViewController.h"
#import "SYDownloadResourceManagerController.h"
#import "DeviceHelper.h"
#import "QuickAccess.h"
#import "FCStore.h"
#import "SYInviteTaskController.h"

@interface _DownloadTableViewCell : UITableViewCell<
  UITextViewDelegate
>

@property (nonatomic, strong) UIImageView *checkImg;
@property (nonatomic, strong) UIStackView *rightView;;
@property (nonatomic, strong) UIImageView *coverImg;
@property (nonatomic, strong) UILabel *hostLabel;
@property (nonatomic, strong) UITextView *titleText;
@property (nonatomic, strong) UIView *qualityView;;
@property (nonatomic, strong) UILabel *linkLabel;
@property (nonatomic, strong) UIControl *folderView;
@property (nonatomic, strong) UIImageView *folderImg;
@property (nonatomic, strong) UILabel *folderLabel;

@property (nonatomic, strong) NSMutableDictionary *entity;

@end

@implementation _DownloadTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = FCStyle.popup;
        
        UIStackView *stackV = self.rightView;
        
        UIView *topView = [[UIView alloc] init];
        [stackV addArrangedSubview:topView];
        [topView addSubview:self.coverImg];
        [topView addSubview:self.hostLabel];
        [topView addSubview:self.titleText];
        [stackV setCustomSpacing:12 afterView:topView];
        [stackV addArrangedSubview:self.qualityView];
        [stackV setCustomSpacing:12 afterView:self.qualityView];
        UILabel *downloadLabel = [[UILabel alloc] init];
        downloadLabel.font = FCStyle.subHeadlineBold;
        downloadLabel.textColor = FCStyle.fcSecondaryBlack;
        downloadLabel.text = NSLocalizedString(@"DownloadLink", @"");
        [stackV addArrangedSubview:downloadLabel];
        [stackV setCustomSpacing:6 afterView:downloadLabel];
        UIButton *copyBtn = [[UIButton alloc] init];
        [copyBtn setTitle:NSLocalizedString(@"Copy", @"") forState:UIControlStateNormal];
        [copyBtn setTitleColor:FCStyle.accent forState:UIControlStateNormal];
        copyBtn.titleLabel.font = FCStyle.footnote;
        [copyBtn addTarget:self action:@selector(copyAction:) forControlEvents:UIControlEventTouchUpInside];
        copyBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [stackV addSubview:copyBtn];
        UIView *linkView = [[UIView alloc] init];
        linkView.layer.cornerRadius = 10;
        linkView.clipsToBounds = YES;
        linkView.backgroundColor = FCStyle.secondaryPopup;
        [stackV addArrangedSubview:linkView];
        [stackV setCustomSpacing:12 afterView:linkView];
        [linkView addSubview:self.linkLabel];
        UILabel *saveLabel = [[UILabel alloc] init];
        saveLabel.font = FCStyle.subHeadlineBold;
        saveLabel.textColor = FCStyle.fcSecondaryBlack;
        saveLabel.text = NSLocalizedString(@"SaveTo", @"");
        [stackV addArrangedSubview:saveLabel];
        [stackV setCustomSpacing:10 afterView:saveLabel];
        [stackV addArrangedSubview:self.folderView];
        [self.folderImg setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [self.folderView addSubview:self.folderImg];
        [self.folderView addSubview:self.folderLabel];
        UIImageView *arrowImg = [[UIImageView alloc] initWithImage:[ImageHelper sfNamed:@"chevron.right" font:[UIFont systemFontOfSize:13] color:FCStyle.fcSecondaryBlack]];
        [arrowImg setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        arrowImg.translatesAutoresizingMaskIntoConstraints = NO;
        [self.folderView addSubview:arrowImg];
        
        UIView *line = [[UIView alloc] init];
        line.backgroundColor = FCStyle.fcSeparator;
        line.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:line];
        
        [NSLayoutConstraint activateConstraints:@[
            [self.checkImg.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:9],
            [self.checkImg.widthAnchor constraintEqualToConstant:23],
            [self.checkImg.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
            [stackV.leadingAnchor constraintEqualToAnchor:self.checkImg.trailingAnchor constant:8],
            [stackV.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-15],
            [stackV.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:20],
            [topView.widthAnchor constraintEqualToAnchor:stackV.widthAnchor],
            [topView.heightAnchor constraintEqualToConstant:81],
            [self.coverImg.leadingAnchor constraintEqualToAnchor:topView.leadingAnchor],
            [self.coverImg.widthAnchor constraintEqualToConstant:144],
            [self.coverImg.topAnchor constraintEqualToAnchor:topView.topAnchor],
            [self.coverImg.heightAnchor constraintEqualToConstant:81],
            [self.hostLabel.leadingAnchor constraintEqualToAnchor:self.coverImg.trailingAnchor constant:9],
            [self.hostLabel.trailingAnchor constraintEqualToAnchor:topView.trailingAnchor],
            [self.hostLabel.topAnchor constraintEqualToAnchor:topView.topAnchor],
            [self.titleText.leadingAnchor constraintEqualToAnchor:self.coverImg.trailingAnchor constant:8],
            [self.titleText.trailingAnchor constraintEqualToAnchor:topView.trailingAnchor],
            [self.titleText.topAnchor constraintEqualToAnchor:self.hostLabel.bottomAnchor constant:3],
            [self.titleText.bottomAnchor constraintEqualToAnchor:topView.bottomAnchor],
            [self.qualityView.widthAnchor constraintEqualToAnchor:stackV.widthAnchor],
            [self.qualityView.heightAnchor constraintEqualToConstant:25],
            [copyBtn.trailingAnchor constraintEqualToAnchor:stackV.trailingAnchor constant:-6],
            [copyBtn.topAnchor constraintEqualToAnchor:downloadLabel.topAnchor constant:-5],
            [linkView.widthAnchor constraintEqualToAnchor:stackV.widthAnchor],
            [linkView.heightAnchor constraintEqualToConstant:45],
            [self.linkLabel.leadingAnchor constraintEqualToAnchor:linkView.leadingAnchor constant:11],
            [self.linkLabel.trailingAnchor constraintEqualToAnchor:linkView.trailingAnchor],
            [self.linkLabel.centerYAnchor constraintEqualToAnchor:linkView.centerYAnchor],
            [self.folderView.widthAnchor constraintEqualToAnchor:stackV.widthAnchor],
            [self.folderView.heightAnchor constraintEqualToConstant:45],
            [self.folderImg.leadingAnchor constraintEqualToAnchor:self.folderView.leadingAnchor constant:10],
            [self.folderImg.centerYAnchor constraintEqualToAnchor:self.folderView.centerYAnchor],
            [self.folderLabel.leadingAnchor constraintEqualToAnchor:self.folderImg.trailingAnchor constant:8],
            [self.folderLabel.trailingAnchor constraintEqualToAnchor:arrowImg.leadingAnchor constant:-8],
            [self.folderLabel.centerYAnchor constraintEqualToAnchor:self.folderView.centerYAnchor],
            [arrowImg.trailingAnchor constraintEqualToAnchor:self.folderView.trailingAnchor constant:-14],
            [arrowImg.centerYAnchor constraintEqualToAnchor:self.folderView.centerYAnchor],
            [line.leadingAnchor constraintEqualToAnchor:stackV.leadingAnchor],
            [line.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
            [line.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],
            [line.heightAnchor constraintEqualToConstant:0.5],
        ]];
    }
    
    return self;
}

- (void)setEntity:(NSMutableDictionary *)entity{
    _entity = entity;
    
    self.checkImg.image = entity[@"isSelected"] ? [ImageHelper sfNamed:@"checkmark.circle.fill" font:[UIFont systemFontOfSize:20] color:FCStyle.accent] : [ImageHelper sfNamed:@"circle" font:[UIFont systemFontOfSize:20] color:FCStyle.fcNavigationLineColor];
    NSString *poster = entity[@"poster"];
    if (poster.length > 0) {
        [self.coverImg sd_setImageWithURL:[NSURL URLWithString:poster] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if(error == nil) {
                self.coverImg.contentMode = UIViewContentModeScaleAspectFit;
            }
        }];
    }
    self.hostLabel.text = entity[@"hostUrl"];
    self.titleText.text = entity[@"title"];
    NSArray *qualityList = entity[@"qualityList"];
    if (qualityList.count > 0) {
        [self.qualityView setHidden:NO];
        NSString *selectedQuality = entity[@"selectedQuality"];
        NSString *selectedDownloadUrl = entity[@"selectedDownloadUrl"];
        [self buildQualityView:qualityList selectedQuality:selectedQuality];
        self.linkLabel.text = selectedDownloadUrl.length > 0 ? selectedDownloadUrl : entity[@"downloadUrl"];
    } else {
        [self.qualityView setHidden:YES];
        self.linkLabel.text = entity[@"downloadUrl"];
    }
    FCTab *tab = [[FCShared tabManager] tabOfUUID:entity[@"uuid"]];
    if(tab == nil) {
        NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"MY_PHONE_STORAGE"];
        self.folderImg.image = [ImageHelper sfNamed:@"folder.fill" font:[UIFont systemFontOfSize:20] color: RGB(146, 209, 243)];
        self.folderLabel.text = entity[@"pathName"] == nil?dic[@"fileName"]:entity[@"pathName"];

    } else {
        self.folderImg.image = [ImageHelper sfNamed:@"folder" font:[UIFont systemFontOfSize:20] color:[ColorHelper colorFromHex:tab.config.hexColor]];
        self.folderLabel.text = tab.config.name;
    }
}

- (void)buildQualityView:(NSArray *)qualityList selectedQuality:(NSString *)selectedQuality {
    for (UIView *subView in self.qualityView.subviews) {
        [subView removeFromSuperview];
    }
    
    CGFloat maxWidth = MIN(FCApp.keyWindow.frame.size.width - 30, 360) - 40 - 15 + 15;
    CGFloat curWidth = 0, top = 0, itemWidth;
    for (int i = 0; i < qualityList.count; i++) {
        NSDictionary *dic = qualityList[i];
        NSString *qualityLabel = dic[@"qualityLabel"];
        UIButton *btn = [[UIButton alloc] init];
        btn.layer.cornerRadius = 8;
        btn.clipsToBounds = YES;
        btn.layer.borderWidth = 0.5;
        if ([qualityLabel isEqualToString:selectedQuality]) {
            btn.backgroundColor = [[FCStyle.accent colorWithAlphaComponent:0.1] rgba2rgb:FCStyle.secondaryBackground];
            btn.layer.borderColor = UIColor.clearColor.CGColor;
        } else {
            btn.backgroundColor = FCStyle.secondaryPopup;
            btn.layer.borderColor = FCStyle.fcNavigationLineColor.CGColor;
        }
        [btn setTitle:qualityLabel forState:UIControlStateNormal];
        [btn setTitleColor:FCStyle.fcBlack forState:UIControlStateNormal];
        btn.titleLabel.font = FCStyle.footnote;
        btn.tag = i;
        [btn addTarget:self action:@selector(qualityAction:) forControlEvents:UIControlEventTouchUpInside];
        btn.translatesAutoresizingMaskIntoConstraints = NO;
        [self.qualityView addSubview:btn];
        itemWidth = qualityLabel.length * 8 + 15 + 15;
        curWidth += itemWidth;
        if (curWidth > maxWidth) {
            top += 30;
            curWidth = itemWidth;
        }
        [NSLayoutConstraint activateConstraints:@[
            [btn.leadingAnchor constraintEqualToAnchor:self.qualityView.leadingAnchor constant:curWidth - itemWidth],
            [btn.widthAnchor constraintEqualToConstant:itemWidth - 15],
            [btn.topAnchor constraintEqualToAnchor:self.qualityView.topAnchor constant:top],
            [btn.heightAnchor constraintEqualToConstant:25],
        ]];
    }
    
    [self.qualityView removeFromSuperview];
    for (NSLayoutConstraint *constraint in self.qualityView.constraints) {
        if ([constraint.firstAnchor isEqual:self.qualityView.heightAnchor]) {
            [self.qualityView removeConstraint:constraint];
        }
    }
    [self.rightView insertArrangedSubview:self.qualityView atIndex:1];
    [self.rightView setCustomSpacing:12 afterView:self.qualityView];
    [[self.qualityView.heightAnchor constraintEqualToConstant:25 + top] setActive:YES];
}

- (void)copyAction:(UIView *)sender {
    UIPasteboard.generalPasteboard.string = self.linkLabel.text;
    [FCShared.toastCenter show:[ImageHelper sfNamed:@"checkmark.circle.fill" font:FCStyle.sfIcon color:FCStyle.fcBlack] mainTitle:NSLocalizedString(@"DownloadLink", @"") secondaryTitle:NSLocalizedString(@"Copied", @"")];
}

- (void)qualityAction:(UIView *)sender {
    NSArray *qualityList = _entity[@"qualityList"];
    NSString *selectedQuality = _entity[@"selectedQuality"];
    NSDictionary *dic = qualityList[sender.tag];
    if (![dic[@"qualityLabel"] isEqualToString:selectedQuality]) {
        _entity[@"selectedQuality"] = dic[@"qualityLabel"];
        _entity[@"selectedDownloadUrl"] = dic[@"downloadUrl"];
        _entity[@"selectedAudioUrl"] = dic[@"audioUrl"];
        _entity[@"selectedProtect"] = dic[@"protect"];
        [self buildQualityView:qualityList selectedQuality:dic[@"qualityLabel"]];
        self.linkLabel.text =  dic[@"downloadUrl"];
    }
}

- (void)textViewDidChange:(UITextView *)textView{
    _entity[@"title"] = textView.text;
}

- (UIImageView *)checkImg {
    if (nil == _checkImg) {
        _checkImg = [[UIImageView alloc] initWithImage:[ImageHelper sfNamed:@"circle" font:[UIFont systemFontOfSize:20] color:FCStyle.fcNavigationLineColor]];
        _checkImg.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_checkImg];
    }
    
    return _checkImg;
}

- (UIStackView *)rightView {
    if (nil == _rightView) {
        _rightView = [[UIStackView alloc] init];
        _rightView.axis = UILayoutConstraintAxisVertical;
        _rightView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_rightView];
    }
    
    return _rightView;
}

- (UIImageView *)coverImg {
    if (nil == _coverImg) {
        _coverImg = [[UIImageView alloc] init];
        _coverImg.layer.cornerRadius = 5;
        _coverImg.clipsToBounds = YES;
        _coverImg.contentMode = UIViewContentModeCenter;
        _coverImg.backgroundColor = FCStyle.background;
        _coverImg.image = [UIImage imageNamed:@"videoDefault"];
        _coverImg.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    return _coverImg;
}

- (UILabel *)hostLabel {
    if (nil == _hostLabel) {
        _hostLabel = [[UILabel alloc] init];
        _hostLabel.font = FCStyle.footnote;
        _hostLabel.textColor = FCStyle.fcSecondaryBlack;
        _hostLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    return _hostLabel;
}

- (UITextView *)titleText {
    if (nil == _titleText) {
        _titleText = [[UITextView alloc] init];
        _titleText.font = FCStyle.body;
        _titleText.textColor = FCStyle.fcBlack;
        _titleText.layer.cornerRadius = 10;
        _titleText.clipsToBounds = YES;
        _titleText.backgroundColor = FCStyle.secondaryPopup;
        _titleText.textContainerInset = UIEdgeInsetsMake(4, 0, 4, 0);
        _titleText.delegate = self;
        _titleText.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    return _titleText;
}

- (UIView *)qualityView {
    if (nil == _qualityView) {
        _qualityView = [[UIView alloc] init];
        _qualityView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    return _qualityView;
}

- (UILabel *)linkLabel {
    if (nil == _linkLabel) {
        _linkLabel = [[UILabel alloc] init];
        _linkLabel.font = FCStyle.body;
        _linkLabel.textColor = FCStyle.fcBlack;
        _linkLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    return _linkLabel;
}

- (UIControl *)folderView {
    if (nil == _folderView) {
        _folderView = [[UIControl alloc] init];
        _folderView.layer.cornerRadius = 10;
        _folderView.clipsToBounds = YES;
        _folderView.backgroundColor = FCStyle.secondaryPopup;
    }
    
    return _folderView;
}

- (UIImageView *)folderImg {
    if (nil == _folderImg) {
        _folderImg = [[UIImageView alloc] initWithImage:[ImageHelper sfNamed:@"folder" font:[UIFont systemFontOfSize:20] color:FCStyle.accent]];
        _folderImg.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    return _folderImg;
}

- (UILabel *)folderLabel {
    if (nil == _folderLabel) {
        _folderLabel = [[UILabel alloc] init];
        _folderLabel.font = FCStyle.body;
        _folderLabel.textColor = FCStyle.fcBlack;
        _folderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    return _folderLabel;
}

@end

@interface SYParseDownloadModalViewController()<
 UITableViewDelegate,
 UITableViewDataSource
> {
    NSInteger _curCount;
}

@property (nonatomic, strong) NSMutableArray<NSMutableDictionary *> *dataSource;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *emptyView;
@property (nonatomic, strong) UIButton *startButton;
@end

@implementation SYParseDownloadModalViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationBar.hidden = NO;
    self.navigationBar.showCancel = YES;
    self.title = NSLocalizedString(@"ToBeDownload", @"");
    [self tableView];
    [self emptyView];
    [self startButton];
}

- (void)viewWillAppear{
    [super viewWillAppear];

    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    _DownloadTableViewCell *cell = nil;
    NSMutableDictionary *entity = self.dataSource[indexPath.row];
    cell = [[_DownloadTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [cell setEntity:entity];
    [cell.folderView addTarget:self action:@selector(folderAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.folderView.tag = indexPath.row;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *qualityList = self.dataSource[indexPath.row][@"qualityList"];
    CGFloat height = 290;
    if (qualityList.count > 0) {
        CGFloat maxWidth = self.view.width - 40 - 15 + 15;
        CGFloat curWidth = 0, curHeight = 30, itemWidth;
        for (NSDictionary *qulity in qualityList) {
            NSString *qualityLabel = qulity[@"qualityLabel"];
            itemWidth = qualityLabel.length * 8 + 15 + 15;
            curWidth += itemWidth;
            if (curWidth > maxWidth) {
                curHeight += 30;
                curWidth = itemWidth;
            }
        }
        height += curHeight;
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableDictionary *entity = self.dataSource[indexPath.row];
    if (entity[@"isSelected"]) {
        [entity removeObjectForKey:@"isSelected"];
        _curCount--;
    } else {
        entity[@"isSelected"] = @(YES);
        _curCount++;
    }
    [tableView reloadData];
    BOOL isEnable = _curCount > 0;
    [self.startButton setEnabled:isEnable];
    self.startButton.layer.borderColor = isEnable ? FCStyle.accent.CGColor : FCStyle.borderColor.CGColor;
    Boolean isPro = [[FCStore shared] getPlan:NO] == FCPlan.None?FALSE:TRUE;

    [self.startButton setAttributedTitle:[[NSAttributedString alloc] initWithString:isPro?NSLocalizedString(@"StartDownload", @""): [NSString stringWithFormat:NSLocalizedString(@"ConsumePoint", @""), @([SharedStorageManager shared].userDefaultsExRO.downloadConsumePoints).description]
                                                                                     attributes:@{
                                NSForegroundColorAttributeName : isEnable ? FCStyle.accent : [UIColor systemGray3Color],
                                 NSFontAttributeName : FCStyle.bodyBold}]
                                            forState:UIControlStateNormal];
}

- (NSMutableArray<NSMutableDictionary *> *)dataSource{
    if (nil == _dataSource){
        _dataSource = [NSMutableArray array];
    }
    
    return _dataSource;
}

- (void)setData:(NSArray<NSDictionary *> *)data {
    if (data.count == 0) {
        _curCount = 0;
        [self.dataSource removeAllObjects];
        [self.emptyView setHidden:NO];
        [self.startButton setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Quit", @"")
                                                                                 attributes:@{
                             NSForegroundColorAttributeName : FCStyle.accent,
                             NSFontAttributeName : FCStyle.bodyBold}]
                                        forState:UIControlStateNormal];
        [self.startButton setEnabled:YES];
        self.startButton.backgroundColor = UIColor.clearColor;
        self.startButton.layer.borderColor = FCStyle.accent.CGColor;
        self.startButton.layer.borderWidth = 1;
        [self.tableView setHidden:YES];
        [self.tableView reloadData];
    } else {
        for (NSDictionary *dic in data) {
            BOOL founded = NO;
            for (NSMutableDictionary *mutDic in self.dataSource) {
                if ([dic[@"videoUuid"] isEqualToString:mutDic[@"videoUuid"]]) {
                    NSString *selectedQuality = mutDic[@"selectedQuality"];
                    NSArray *qualityList = dic[@"qualityList"];
                    if (selectedQuality.length == 0 && qualityList.count > 0) {
                        mutDic[@"qualityList"] = qualityList;
                        NSString *downloadUrl = dic[@"downloadUrl"];
                        NSString *selectedDownloadUrl;
                        NSString *selectedAudioUrl;
                        Boolean selectedProtect = FALSE;
                        for (NSDictionary *qulity in qualityList) {
                            if ([downloadUrl isEqualToString:qulity[@"downloadUrl"]]) {
                                selectedQuality = qulity[@"qualityLabel"];
                                selectedDownloadUrl = qulity[@"downloadUrl"];
                                selectedAudioUrl = qulity[@"audioUrl"];
                                selectedProtect = [qulity[@"protect"] boolValue];
                                break;
                            }
                        }
                        if (selectedQuality.length == 0) {
                            selectedQuality = qualityList[0][@"qualityLabel"];
                            selectedDownloadUrl = qualityList[0][@"downloadUrl"];
                            selectedAudioUrl = qualityList[0][@"audioUrl"];
                            selectedProtect = [qualityList[0][@"protect"] boolValue];
                        }
                        mutDic[@"selectedQuality"] = selectedQuality;
                        mutDic[@"selectedDownloadUrl"] = selectedDownloadUrl;
                        mutDic[@"selectedAudioUrl"] = selectedAudioUrl;
                        mutDic[@"selectedProtect"] = @(selectedProtect);
                    }
                    
                    founded = YES;
                    break;
                }
            }
            if (!founded) {
                NSMutableDictionary *item = [NSMutableDictionary dictionaryWithDictionary:dic];
                NSArray *qualityList = item[@"qualityList"];
                if (qualityList.count > 0) {
                    NSString *downloadUrl = item[@"downloadUrl"];
                    NSString *selectedQuality;
                    NSString *selectedDownloadUrl;
                    NSString *selectedAudioUrl;
                    Boolean selectedProtect = FALSE;
                    for (NSDictionary *qulity in qualityList) {
                        if ([downloadUrl isEqualToString:qulity[@"downloadUrl"]]) {
                            selectedQuality = qulity[@"qualityLabel"];
                            selectedDownloadUrl = qulity[@"downloadUrl"];
                            selectedAudioUrl = qulity[@"audioUrl"];
                            selectedProtect = [qulity[@"protect"] boolValue];
                            break;
                        }
                    }
                    if (selectedQuality.length == 0) {
                        selectedQuality = qualityList[0][@"qualityLabel"];
                        selectedDownloadUrl = qualityList[0][@"downloadUrl"];
                        selectedAudioUrl = qualityList[0][@"audioUrl"];
                        selectedProtect = [qualityList[0][@"protect"] boolValue];
                    }
                    item[@"selectedQuality"] = selectedQuality;
                    item[@"selectedDownloadUrl"] = selectedDownloadUrl;
                    item[@"selectedAudioUrl"] = selectedAudioUrl;
                    item[@"selectedProtect"] = @(selectedProtect);
                }
                if (item[@"uuid"] == nil) {
                    NSString *selectedUUID = SharedStorageManager.shared.userDefaults.lastFolderUUID;
                    if (selectedUUID.length == 0) {
                        selectedUUID = ((FCTab *)[[FCShared.tabManager tabs] objectAtIndex:0]).uuid;
                    }
                    item[@"uuid"] = selectedUUID;
                }
                if (self.dataSource.count == 0) {
                    item[@"isSelected"] = @(YES);
                    _curCount = 1;
                }
                [self.dataSource addObject:item];
            }
        }
        [self.emptyView setHidden:YES];
        Boolean isPro = [[FCStore shared] getPlan:NO] == FCPlan.None?FALSE:TRUE;
        [self.startButton setAttributedTitle:[[NSAttributedString alloc] initWithString:isPro?NSLocalizedString(@"StartDownload", @""):[NSString stringWithFormat:NSLocalizedString(@"ConsumePoint", @""), @([SharedStorageManager shared].userDefaultsExRO.downloadConsumePoints).description]
                                                                                 attributes:@{
                             NSForegroundColorAttributeName : FCStyle.accent,
                             NSFontAttributeName : FCStyle.bodyBold}]
                                        forState:UIControlStateNormal];
        [self.tableView setHidden:NO];
        [self.tableView reloadData];
    }
}

- (void)folderAction:(UIView *)sender{
    SYDownloadFolderChooseModalViewController *cer = [[SYDownloadFolderChooseModalViewController alloc] init];
    cer.dic = self.dataSource[sender.tag];
    cer.nav = self.nav;
    [self.navigationController pushModalViewController:cer];
}

- (UIButton *)startButton{
    if (nil == _startButton){
        _startButton = [[UIButton alloc] initWithFrame:CGRectMake(15, self.view.height - 10 - 45, self.view.frame.size.width - 30, 45)];
        [_startButton setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Quit", @"")
                                                                                 attributes:@{
                             NSForegroundColorAttributeName : FCStyle.accent,
                             NSFontAttributeName : FCStyle.bodyBold}]
                                        forState:UIControlStateNormal];
        [_startButton addTarget:self
                                 action:@selector(startAction:)
                       forControlEvents:UIControlEventTouchUpInside];
        _startButton.backgroundColor = UIColor.clearColor;
        _startButton.layer.borderColor = FCStyle.accent.CGColor;
        _startButton.layer.borderWidth = 1;
        _startButton.layer.cornerRadius = 10;
        _startButton.layer.masksToBounds = YES;
        [self.view addSubview:_startButton];
    }
    
    return _startButton;
}

- (void)startAction:(id)sender{
    if (self.dataSource.count == 0) {
        [self.navigationController.slideController dismiss];
    } else {
        Boolean isPro = [[FCStore shared] getPlan:NO] == FCPlan.None?FALSE:TRUE;

        if(!isPro) {
            float point = [SharedStorageManager shared].userDefaultsExRO.availablePoints;
            float downloadNeedPoint = [SharedStorageManager shared].userDefaultsExRO.downloadConsumePoints;
            
            if(point >= downloadNeedPoint) {
                [DeviceHelper consumePoints:downloadNeedPoint];
            } else {
                SYInviteTaskController *cer = [[SYInviteTaskController alloc] init];
                cer.nav = self.nav;
                cer.needBack = true;
                [self.navigationController pushModalViewController:cer];
                return;
            }
        }
        
        
        int count = 0;
        int oldCount = 0;
        FCTab *tab;
        for (NSMutableDictionary *item in self.dataSource) {
            if (item[@"isSelected"]) {
                DownloadResource *resource = [[DownloadResource alloc] init];
                NSString *downLoadUrl = [item[@"selectedDownloadUrl"] ? item[@"selectedDownloadUrl"] : item[@"downloadUrl"] safeEncode];
                resource.title = item[@"title"];
                resource.downloadUrl = downLoadUrl;
                resource.icon = item[@"poster"];
                resource.host = item[@"hostUrl"];
                resource.audioUrl = item[@"selectedAudioUrl"] ? item[@"selectedAudioUrl"] : item[@"audioUrl"];
                resource.protect = [item[@"selectedProtect"] ? item[@"selectedProtect"] : item[@"protect"] isEqual:@(1)]?YES:NO;
                if(resource.host == nil) {
                    resource.host = [NSURL URLWithString:downLoadUrl].host;
                }
                resource.firstPath = item[@"uuid"];
                if (nil == tab) {
                    tab = [FCShared.tabManager tabOfUUID:item[@"uuid"]];
                }
                
                resource.downloadUuid = [downLoadUrl md5];
                DownloadResource *oldResource =  [[DataManager shareManager] selectDownloadResourceByDownLoadUUid:resource.downloadUuid];
                if(!(oldResource != nil && oldResource.downloadUrl != nil)) {
                    FCTab *tab = [[FCShared tabManager] tabOfUUID:resource.firstPath];
                    Request *request = [[Request alloc] init];
                    request.url = downLoadUrl;
                    if(tab == nil) {
                        NSMutableDictionary *entity = self.dataSource[0];

                        NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"MY_PHONE_STORAGE"];
                        request.fileDir = entity[@"allPath"] == NULL?dic[@"url"]:entity[@"allPath"] ;
                        request.key = FILEUUID;
                        SharedStorageManager.shared.userDefaults.lastFolderUUID = FILEUUID;
                    } else {
                        request.fileDir = tab.path;
                        request.key = tab.uuid;
                        SharedStorageManager.shared.userDefaults.lastFolderUUID = tab.uuid;
                    }
                    request.fileType = @"video";
                    request.audioUrl = resource.audioUrl;
                    request.fileName = resource.title.length > 0 ? resource.title : downLoadUrl.lastPathComponent;
                    if (![request.fileName hasSuffix:@".mp4"] && ![request.fileName hasSuffix:@".m3u8"]) {
                        request.fileName = [request.fileName stringByAppendingString:@".mp4"];
                    }
                
                    
                    Task *task = [[DownloadManager shared] enqueue:request];
                    
                    resource.status = 0;
                    resource.watchProcess = 0;
                    resource.downloadProcess = 0;
                    resource.videoDuration = 0;
                    resource.allPath = task.filePath;
                    resource.sort = 0;
                    
                    [[DataManager shareManager] addDownloadResource:resource];
                    count++;
                } else {
                    oldCount++;
                }
            }
        }
        
        if (count == 0) {
            UIAlertController *onlyOneAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(oldCount > 0 ? @"urlIsDownloaded" : @"SelectVideos", @"")
                                                                           message:@""
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *onlyOneConfirm = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"")
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * _Nonnull action) {
            
                
            }];
            [onlyOneAlert addAction:onlyOneConfirm];
            [self.nav presentViewController:onlyOneAlert animated:YES completion:nil];

            return;
        } else {

          
            [self.nav popToRootViewControllerAnimated:true];
#ifdef FC_MAC
        if ([QuickAccess primaryController] != nil){
            [QuickAccess primaryController].selectedIndex = 2;
        }
#else
    if (FCDeviceTypeIPhone == [DeviceHelper type]){
        if([UIApplication sharedApplication].keyWindow.rootViewController != nil) {
            [((FCTabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController).fcTabBar selectIndex:3];
        }
    }
#endif

            
            double delayInSeconds = 0.5; // 延迟时间
            dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(startTime, dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"changeDownloading" object:nil];
            });

            
            [self.navigationController.slideController dismiss];
        }
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

- (UIView *)emptyView {
    if (nil == _emptyView) {
        _emptyView = [[UIView alloc] init];
        _emptyView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_emptyView];
        UILabel *tipLabel = [[UILabel alloc] init];
        tipLabel.font = FCStyle.body;
        tipLabel.textColor = FCStyle.fcBlack;
        tipLabel.text = NSLocalizedString(@"ParseWeb", @"");
        tipLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_emptyView addSubview:tipLabel];
        
        [NSLayoutConstraint activateConstraints:@[
            [_emptyView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
            [_emptyView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
            [_emptyView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
            [_emptyView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-10-10-45],
            [tipLabel.centerXAnchor constraintEqualToAnchor:_emptyView.centerXAnchor],
            [tipLabel.centerYAnchor constraintEqualToAnchor:_emptyView.centerYAnchor],
        ]];
    }
    
    return _emptyView;
}

- (void)clear{
}

- (CGSize)mainViewSize{
    return CGSizeMake(MIN(FCApp.keyWindow.frame.size.width - 30, 360), 447);
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
