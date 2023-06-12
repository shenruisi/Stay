//
//  SYInviteViewController.m
//  Stay
//
//  Created by zly on 2023/5/26.
//

#import "SYInviteViewController.h"
#import "InviteProgressView.h"
#import "FCStyle.h"
#import "API.h"
#import "DeviceHelper.h"
#import "InviteDetail.h"
#import "SYInviteCardController.h"
#import "UserScript.h"
#import "FCImageView.h"
#import "UIImageView+WebCache.h"
#import "ImageHelper.h"
#import "FCStore.h"

@interface ShareLinkView:UIView
@property (nonatomic, strong) NSString *linkStr;
@property (nonatomic, assign) NSUInteger visitcount;
@property (nonatomic, strong) UIViewController *cer;

@end


@implementation ShareLinkView


- (void)setUpUI {
    UILabel *linkView = [[UILabel alloc] initWithFrame:CGRectMake(18, 12, self.width - 36, 61)];
    linkView.layer.cornerRadius = 10;
    linkView.layer.masksToBounds = YES;
    linkView.backgroundColor = FCStyle.secondaryPopup;
    linkView.text = _linkStr;
    linkView.font = FCStyle.body;
    linkView.textColor = FCStyle.fcBlack;
    linkView.textAlignment = NSTextAlignmentCenter;
    [self addSubview:linkView];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(18, 0, 30, 19)];
    [imgView setImage:[ImageHelper sfNamed:@"eye" font:FCStyle.body color:FCStyle.subtitleColor]];
    imgView.top = linkView.bottom + 11;
    [self addSubview:imgView];

    UILabel *visitLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 16)];
    visitLabel.text = [NSString stringWithFormat:@"%ld %@",_visitcount,NSLocalizedString(@"Viewed",@"")];
    visitLabel.font = FCStyle.footnoteBold;
    visitLabel.textColor = FCStyle.subtitleColor;
    visitLabel.centerY = imgView.centerY;
    visitLabel.left = imgView.right + 4;
    [self addSubview:visitLabel];

    
    UIButton *shareBtn =  [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 161, 35)];
    [shareBtn setImage:[ImageHelper sfNamed:@"doc.on.doc" font:FCStyle.body color:FCStyle.accent] forState:UIControlStateNormal];
    [shareBtn setTitle:NSLocalizedString(@"CopLink", @"") forState:UIControlStateNormal];
    [shareBtn setTitleColor:FCStyle.accent forState:UIControlStateNormal];
    shareBtn.titleLabel.font = FCStyle.footnoteBold;
//        [_savePhotoBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 8)];
    shareBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 8);
    shareBtn.layer.cornerRadius = 10;
    shareBtn.layer.borderWidth = 1;
    shareBtn.layer.borderColor = FCStyle.accent.CGColor;
    [shareBtn addTarget:_cer action:@selector(shareLink:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:shareBtn];
    shareBtn.top = visitLabel.bottom + 19;
    shareBtn.centerX = self.width / 2;
    
}


- (void)shareLink:(UIButton *)sender{
    
}
@end

@interface InviteImageView:UIView
@property (nonatomic, strong) UIView *inviteView;
@property (nonatomic, strong) FCImageView *iconImageView;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) InviteDetail *detail;
@property (nonatomic, strong) UILabel *useLabel;
@property (nonatomic, strong) UILabel *stayLabel;
@property (nonatomic, strong) UIImageView *sigImageView;
@property (nonatomic, strong) UILabel *extensionLabel;
@property (nonatomic, strong) UIImageView *qrCodeImageView;
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UIButton *addBtn;
@end

@implementation InviteImageView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}
- (void)setupUI {
    
    self.iconImageView = nil;
    self.nameLabel = nil;
    self.useLabel = nil;
    self.stayLabel = nil;
    self.sigImageView = nil;
    self.extensionLabel = nil;
    self.qrCodeImageView = nil;
    [self backView];
    [self inviteView];
    [self gradientLayer];
    [self iconImageView];
    [self nameLabel];
    [self useLabel];
    [self stayLabel];
    [self sigImageView];
    [self extensionLabel];
    [self qrCodeImageView];
    [self tipsLabel];
    [self addBtn];
}

- (UIView *)backView {
    if(_backView == nil) {
        _backView = [[UIView alloc] initWithFrame:CGRectMake(26, 19,  self.width - 26 * 2, 387)];
        [self addSubview:_backView];
    }
    return _backView;
}

- (UIView *)inviteView {
    if(_inviteView == nil) {
        _inviteView = [[UIView alloc] initWithFrame:CGRectMake(50, 33, self.width - 26 * 2 - 100, 330)];
        _inviteView.backgroundColor = FCStyle.fcWhite;
        _inviteView.layer.cornerRadius = 10;
        _inviteView.clipsToBounds = YES;
        [self.backView addSubview:_inviteView];
    }
    return _inviteView;
}

- (CAGradientLayer *)gradientLayer{
    if (nil == _gradientLayer){
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.frame = [self backView].bounds;
        NSArray<UIColor *> *colors = FCStyle.accentGradient;
        _gradientLayer.colors = @[(id)colors[0].CGColor, (id)colors[1].CGColor];
        [self.backView.layer insertSublayer:_gradientLayer atIndex:0];
    }
    
    return _gradientLayer;
}

- (FCImageView *)iconImageView {
    if(nil == _iconImageView) {
        _iconImageView = [[FCImageView alloc] initWithFrame:CGRectMake(14, 14, self.width - 26 * 2 - 100 - 28, (self.width - 26 * 2 - 100 - 28) / 1.25)];
        if(self.detail.cover.length > 1) {
            [_iconImageView sd_setImageWithURL:self.detail.cover];
        } else {
            [_iconImageView setImage:[UIImage imageNamed:@"rainbow"]];
        }
        
        _iconImageView.layer.cornerRadius = 10;
        _iconImageView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
        _iconImageView.clipsToBounds = YES;
        [self.inviteView addSubview:_iconImageView];
    }
    return _iconImageView;
}

- (UILabel *)nameLabel {
    if(_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, 200, 28)];
        if(self.detail.color.length > 0 ) {
            _nameLabel.textColor =  UIColorFromRGB(self.detail.color );
        } else {
            _nameLabel.textColor = FCStyle.accent;
        }
        _nameLabel.font = [UIFont boldSystemFontOfSize:24];
        _nameLabel.text = self.detail.name;
        _nameLabel.top = self.iconImageView.bottom + 12;
        [self.inviteView addSubview:_nameLabel];

    }
    return _nameLabel;
}

- (UILabel *)useLabel {
    if(nil == _useLabel) {
        _useLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, 300, 22)];
        _useLabel.font = FCStyle.footnote;
        if(self.detail.color.length > 0 ) {
            _useLabel.textColor =  UIColorFromRGB(self.detail.color);
        } else {
            _useLabel.textColor = FCStyle.accent;
        }
        _useLabel.text = NSLocalizedString(@"Iuse",@"");
        [_useLabel sizeToFit];
        _useLabel.top = self.nameLabel.bottom + 9;
        [self.inviteView addSubview:_useLabel];
    }
    return _useLabel;
}

- (UILabel *)stayLabel {
    if(nil == _stayLabel){
        _stayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 44, 22)];
        if(self.detail.color.length > 0) {
            _stayLabel.backgroundColor =  UIColorFromRGB(self.detail.color);
        } else {
            _stayLabel.backgroundColor = FCStyle.accent;
        }
        _stayLabel.textColor = FCStyle.fcWhite;
        _stayLabel.font = FCStyle.footnote;
        _stayLabel.text = NSLocalizedString(@"Stay",@"");
        _stayLabel.layer.cornerRadius = 10;
        _stayLabel.clipsToBounds = YES;
        _stayLabel.textAlignment = NSTextAlignmentCenter;
        [self.inviteView addSubview:_stayLabel];
        _stayLabel.left = self.useLabel.right + 5;
        _stayLabel.centerY = self.useLabel.centerY;
    }
    return _stayLabel;
}

- (UIImageView *)sigImageView {
    if(nil == _sigImageView) {
        _sigImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 19)];
        [_sigImageView setImage:[ImageHelper sfNamed:@"arrow.turn.right.down" font:FCStyle.body color:self.detail.color.length > 0?UIColorFromRGB(self.detail.color):FCStyle.accent]];
        [self.inviteView addSubview:_sigImageView];
        _sigImageView.top = self.stayLabel.bottom;
        _sigImageView.left = self.stayLabel.right - 7;

    }
    return _sigImageView;
}

- (UILabel *)extensionLabel {
    if(nil == _extensionLabel) {
        _extensionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 19)];
        _extensionLabel.font = FCStyle.footnoteBold;
        if(self.detail.color.length > 0) {
            _extensionLabel.textColor =  UIColorFromRGB(self.detail.color);
        } else {
            _extensionLabel.textColor = FCStyle.accent;
        }
        _extensionLabel.text = NSLocalizedString(@"ASafariExtension",@"");
        [_extensionLabel sizeToFit];
        [self.inviteView addSubview:_extensionLabel];
        _extensionLabel.top = self.sigImageView.bottom;
        _extensionLabel.left = self.stayLabel.left;
    }
    return _extensionLabel;
}

- (UIImageView *)qrCodeImageView {
    if(nil == _qrCodeImageView) {
        _qrCodeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(14, 0, 40, 40)];
        [self.inviteView addSubview:_qrCodeImageView];
        _qrCodeImageView.top = self.extensionLabel.bottom + 30;
        if(self.detail.link.length > 0) {
            [self generatingTwoDimensionalCode];
        }
    }
    return _qrCodeImageView;
}

- (UILabel *)tipsLabel {
    if(nil == _tipsLabel) {
        _tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 141, 33)];
        Boolean isPro = [[FCStore shared] getPlan:NO] == FCPlan.None?FALSE:TRUE;
        _tipsLabel.font = FCStyle.footnote;
        _tipsLabel.textColor = FCStyle.subtitleColor;
        if(isPro){
            _tipsLabel.height = 16;
            _tipsLabel.text = NSLocalizedString(@"inviteTipsPro",@"");
        } else {
            _tipsLabel.text = NSLocalizedString(@"inviteTips",@"");
            _tipsLabel.numberOfLines = 2;
        }
        
        [self.inviteView addSubview:_tipsLabel];
        
        _tipsLabel.bottom = self.qrCodeImageView.bottom;
        _tipsLabel.left = self.qrCodeImageView.right + 5;
    }
    return _tipsLabel;
}

- (UIButton *)addBtn {
    if(nil == _addBtn) {
        _addBtn =  [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 161, 35)];
        [_addBtn setImage:[ImageHelper sfNamed:@"square.and.arrow.up" font:FCStyle.body color:FCStyle.accent] forState:UIControlStateNormal];
        [_addBtn setTitle:NSLocalizedString(@"ShareCard", @"") forState:UIControlStateNormal];
        [_addBtn setTitleColor:FCStyle.accent forState:UIControlStateNormal];
        _addBtn.titleLabel.font = FCStyle.footnoteBold;
        _addBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 8);
        _addBtn.layer.cornerRadius = 10;
        _addBtn.layer.borderWidth = 1;
        _addBtn.layer.borderColor = FCStyle.accent.CGColor;
        [_addBtn addTarget:self action:@selector(shareImage:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_addBtn];
        _addBtn.top = self.backView.bottom + 22;
        _addBtn.centerX = self.backView.centerX;
    }
    return _addBtn;
}

- (void)shareImage:(UIButton *)sender{
    
}

 -(void)generatingTwoDimensionalCode {

     // 创建过滤器
     CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];

     // 过滤器恢复默认
     [filter setDefaults];

     // 给过滤器添加数据
     NSString *string = self.detail.link;
     NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];

     [filter setValue:data forKeyPath:@"inputMessage"];

     // 获取二维码过滤器生成的二维码
     CIImage *image = [filter outputImage];// 此时的 image 是模糊的

     // 高清处理：将获取到的二维码添加到 imageview
     self.qrCodeImageView.image =[self createNonInterpolatedUIImageFormCIImage:image withSize:40];// withSize 大于等于视图显示的尺寸
}

- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {

     CGRect extent = CGRectIntegral(image.extent);
     CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));

     // 创建 bitmap
     size_t width = CGRectGetWidth(extent) * scale;
     size_t height = CGRectGetHeight(extent) * scale;
     CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
     CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
     CIContext *context = [CIContext contextWithOptions:nil];
     CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
     CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
     CGContextScaleCTM(bitmapRef, scale, scale);
     CGContextDrawImage(bitmapRef, extent, bitmapImage);
     // 保存 bitmap 到图片
     CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
     CGContextRelease(bitmapRef);
     CGImageRelease(bitmapImage);
     return [UIImage imageWithCGImage:scaledImage];
}


@end

@interface InviteRulesView:UIView

@end

@implementation InviteRulesView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 13, 100, 21)];
    titleLab.text = NSLocalizedString(@"InviteRule",@"InviteFriend");
    titleLab.font = FCStyle.headlineBold;
    titleLab.textColor = FCStyle.fcBlack;
    titleLab.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLab];
    titleLab.centerX = self.width / 2;
    
    UILabel *descLab = [[UILabel alloc] initWithFrame:CGRectMake(11, 0, 322, 100)];
    descLab.text = NSLocalizedString(@"InviteRuleDesc",@"InviteFriend");
    descLab.font = FCStyle.footnote;
    descLab.numberOfLines = 0;
    descLab.textColor = FCStyle.subtitleColor;
    descLab.textAlignment = NSTextAlignmentCenter;
    [descLab sizeToFit];
    [self addSubview:descLab];
    
    descLab.top = titleLab.bottom + 12;
    descLab.centerX = self.width / 2;
    
    self.height = descLab.bottom + 27;
}

@end


@interface HowToInviteView:UIView

@end

@implementation HowToInviteView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 13, 100, 21)];
    titleLab.text = NSLocalizedString(@"HowToInvite",@"");
    titleLab.font = FCStyle.headlineBold;
    titleLab.textColor = FCStyle.fcBlack;
    titleLab.textAlignment = NSTextAlignmentLeft;
    [titleLab sizeToFit];
    [self addSubview:titleLab];
//    titleLab.centerX = self.width / 2;
    
    UILabel *descLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 322, 100)];
    descLab.text = NSLocalizedString(@"HowToInviteDesc",@"InviteFriend");
    descLab.font = FCStyle.footnote;
    descLab.numberOfLines = 0;
    descLab.textColor = FCStyle.subtitleColor;
    descLab.textAlignment = NSTextAlignmentLeft;
    [descLab sizeToFit];
    [self addSubview:descLab];
    
    descLab.top = titleLab.bottom + 12;
    self.height = descLab.bottom + 15;
    
    
    
}

@end


@interface SYInviteViewController () <
UITableViewDelegate,
UITableViewDataSource
>
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) InviteProgressView *inviteView;
@property (nonatomic, strong) UILabel *pointLabel;
@property (nonatomic, strong) UILabel *inviteLabel;
@property (nonatomic, strong) InviteRulesView *inviteRulesView;
@property (nonatomic, strong) HowToInviteView *howToInviteView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *inviteBtn;
@property (nonatomic, assign) Boolean *started;
@property (nonatomic, strong) SYInviteCardController *inviteCardController;
@property (nonatomic, strong) InviteImageView *inviteImageView;
@property (nonatomic, strong) InviteDetail *detail;
@end

@implementation SYInviteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.hidesBottomBarWhenPushed = true;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    self.title = NSLocalizedString(@"InviteFriend",@"InviteFriend");
    [self tableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveInviteSuccess:)
                                                 name:@"app.stay.notification.SaveInviteSuccess"
                                               object:nil];
    
    [[API shared]  queryPath:@"/invite-task/detail"
                        pro:NO
                   deviceId:DeviceHelper.uuid
                        biz:nil
                 completion:^(NSInteger statusCode, NSError * _Nonnull error, NSDictionary * _Nonnull server, NSDictionary * _Nonnull biz) {
        NSLog(@"%@",biz);
        
        if(biz != NULL) {
            InviteDetail *inviteDetail = [InviteDetail ofDictionary:biz];
            if(inviteDetail.inviteCode.length > 0) {
                self.started = true;
            }
            dispatch_async(dispatch_get_main_queue(), ^{

                self.inviteView.titleArray = inviteDetail.process;
                _detail = inviteDetail;
                [self.tableView reloadData];
                [self.inviteView updateProgress:0.5];
            });
        }
    }];
    
   
}

- (void)saveInviteSuccess:(NSNotification *)sender{
    [[API shared]  queryPath:@"/invite-task/detail"
                        pro:NO
                   deviceId:DeviceHelper.uuid
                        biz:nil
                 completion:^(NSInteger statusCode, NSError * _Nonnull error, NSDictionary * _Nonnull server, NSDictionary * _Nonnull biz) {
        NSLog(@"%@",biz);
        
        if(biz != NULL) {
            InviteDetail *inviteDetail = [InviteDetail ofDictionary:biz];
            if(inviteDetail.inviteCode.length > 0) {
                self.started = true;
            }
            dispatch_async(dispatch_get_main_queue(), ^{

                self.inviteView.titleArray = inviteDetail.process;
                _detail = inviteDetail;
                [self.tableView reloadData];
                [self.inviteView updateProgress:0.5];
            });
        }
    }];
}


- (void)inviteCreate:(UIButton *)sender {
    if(_detail != NULL) {
        if (! [[UserScript localeCodeLanguageCodeOnly] isEqualToString:@"zh"]) {
            self.inviteCardController.dateStr = _detail.sinceEn;
        } else {
            self.inviteCardController.dateStr = _detail.sinceCn;
        }
        self.inviteCardController.imageList = _detail.candidateCovers;
        self.inviteCardController.color = _detail.color;
        self.inviteCardController.defaultImage = _detail.cover;
        self.inviteCardController.defaultName = _detail.name;
    }
    if (!self.inviteCardController.isShown){
        [self.inviteCardController show];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                       reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:self.iconImageView];
        [cell.contentView addSubview:self.pointLabel];
        self.pointLabel.top = self.iconImageView.bottom + 24;
        [cell.contentView addSubview:self.inviteView];
        self.inviteView.top = self.pointLabel.bottom + 11;
        [cell.contentView addSubview:self.inviteLabel];
        self.inviteLabel.top = self.inviteView.bottom + 21;
        [cell.contentView addSubview:self.inviteRulesView];
        self.inviteRulesView.top = self.inviteView.bottom + 21;

 
        [cell.contentView addSubview:self.howToInviteView];
        self.howToInviteView.top = self.inviteRulesView.bottom + 15;
        
        [cell.contentView addSubview:self.inviteBtn];
         
        if(_started) {
            [cell.contentView addSubview:self.inviteImageView];
            self.inviteImageView.detail = _detail;
            [self.inviteImageView setupUI];
            self.inviteImageView.top = self.howToInviteView.bottom + 13;
            ShareLinkView *linkView = [[ShareLinkView alloc] initWithFrame:CGRectMake(19, 0, self.view.width - 38, 167)];
            linkView.backgroundColor = FCStyle.fcWhite;
            linkView.layer.cornerRadius = 10;
            linkView.layer.masksToBounds = YES;
            linkView.visitcount = _detail.visitedCount;
            linkView.linkStr = _detail.link;
            linkView.cer = self;
            [linkView setUpUI];
            [cell.contentView addSubview:linkView];

            linkView.top = self.inviteImageView.bottom + 26;
            [self.inviteBtn setTitle:NSLocalizedString(@"EditInfo", @"") forState:UIControlStateNormal];
            self.inviteBtn.top = linkView.bottom + 32;
            
        } else {
            self.inviteBtn.top = self.howToInviteView.bottom + 23;
        }
        return cell;
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(_started) {
        return 1375;
    } else {
        return 647;
    }
}


- (UIImageView *)iconImageView {
    if(_iconImageView == nil) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 25, 100, 100)];
        _iconImageView.centerX = self.view.centerX;
        [_iconImageView setImage:[UIImage imageNamed:@"InviteBigIcon"]];
    }
    return _iconImageView;
}


- (InviteProgressView *)inviteView {
    if(_inviteView == nil) {
        _inviteView = [[InviteProgressView alloc] initWithFrame:CGRectMake(21, 0, 348, 69)];
        _inviteView.backgroundColor = FCStyle.fcWhite;
        _inviteView.layer.cornerRadius = 10;
    }
    
    return _inviteView;
}

- (UILabel *)pointLabel {
    if(_pointLabel == nil) {
        _pointLabel = [[UILabel alloc] initWithFrame:CGRectMake(19, 149, 120, 18)];
        _pointLabel.font = FCStyle.subHeadlineBold;
        _pointLabel.textColor = FCStyle.subtitleColor;
        _pointLabel.text = NSLocalizedString(@"PointProgress", @"");
        _pointLabel.top = self.iconImageView.bottom + 24;
    }
    return _pointLabel;
}

- (UILabel *)inviteLabel {
    if(_inviteLabel == nil) {
        _inviteLabel = [[UILabel alloc] initWithFrame:CGRectMake(19, 0, 240, 18)];
        _inviteLabel.font = FCStyle.subHeadlineBold;
        _inviteLabel.textColor = FCStyle.subtitleColor;
        _inviteLabel.text = NSLocalizedString(@"InviteToGetPoint", @"");
        _inviteLabel.top = self.inviteView.bottom + 21;
    }
    return _inviteLabel;
}

- (InviteRulesView *)inviteRulesView {
    if(_inviteRulesView == nil) {
        _inviteRulesView = [[InviteRulesView alloc] initWithFrame:CGRectMake(19, 0, self.view.width - 38, 300)];
        _inviteRulesView.layer.cornerRadius = 10;
        _inviteRulesView.backgroundColor = FCStyle.fcWhite;
    }
    return _inviteRulesView;
}

- (HowToInviteView *)howToInviteView {
    if(_howToInviteView == nil) {
        _howToInviteView = [[HowToInviteView alloc] initWithFrame:CGRectMake(19, 0, self.view.width - 38, 70)];
        _howToInviteView.layer.cornerRadius = 10;
        _howToInviteView.backgroundColor = FCStyle.fcWhite;
    }
    return _howToInviteView;
}

- (UIButton *)inviteBtn {
    if(_inviteBtn == nil) {
        _inviteBtn = [[UIButton alloc] initWithFrame:CGRectMake(19, 0, self.view.width - 38, 45)];
        [_inviteBtn setTitle:@"Start Gifting" forState:UIControlStateNormal];
        [_inviteBtn setTitleColor:FCStyle.accent forState:UIControlStateNormal];
        [_inviteBtn addTarget:self action:@selector(inviteCreate:) forControlEvents:UIControlEventTouchUpInside];
        _inviteBtn.font = FCStyle.bodyBold;
        _inviteBtn.layer.borderColor = FCStyle.accent.CGColor;
        _inviteBtn.layer.borderWidth = 1;
        _inviteBtn.layer.cornerRadius = 10;
    }
    return _inviteBtn;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        if (@available(iOS 15.0, *)){
           _tableView.sectionHeaderTopPadding = 0;
        }
        _tableView.sectionFooterHeight = 0;
        [self.view addSubview:_tableView];
                
        [NSLayoutConstraint activateConstraints:@[
            [_tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
            [_tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
            [_tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
            [_tableView.heightAnchor constraintEqualToConstant:self.view.height]
        ]];
        
    }
    return _tableView;
}


- (SYInviteCardController *)inviteCardController {
    if(_inviteCardController == nil) {
        _inviteCardController = [[SYInviteCardController alloc] init];
        
    }
    return _inviteCardController;
}

- (InviteImageView *)inviteImageView {
    if(nil == _inviteImageView) {
        _inviteImageView = [[InviteImageView alloc] initWithFrame:CGRectMake(19, 0, self.view.width - 38, 474)];
        _inviteImageView.backgroundColor = FCStyle.fcWhite;
        _inviteImageView.layer.cornerRadius = 10;
        _inviteImageView.layer.masksToBounds = YES;
    }
    return _inviteImageView;
}

- (void)shareLink:(UIButton *)sender {
    //分享的url
    NSArray *activityItems = @[_detail.link];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];

    [self.navigationController presentViewController:activityVC animated:YES completion:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:@"app.stay.notification.SaveInviteSuccess"
                                                      object:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
