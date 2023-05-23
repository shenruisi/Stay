//
//  HomeDetailCell.m
//  Stay
//
//  Created by zly on 2022/9/14.
//

#import "HomeDetailCell.h"
#import "Tampermonkey.h"
#import "ScriptMananger.h"
#import "FCStyle.h"
#import "ScriptEntity.h"
#import "UIImageView+WebCache.h"
#import <objc/runtime.h>
#import "ImageHelper.h"
#import "QuickAccess.h"
#import "DefaultIcon.h"

@interface HomeDetailCell()

@property (nonatomic, strong) UIView *imageBox;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) UILabel *subLabel;
@property (nonatomic, strong) UIButton *updateBtn;
@property (nonatomic, strong) UIView *sImageView;
@property (nonatomic, strong) UILabel *actLabel;
@property (nonatomic, strong) UIView *splitView;
@property (nonatomic, strong) UIImageView *versionImageView;
@property (nonatomic, strong) UILabel *versionLabel;
@property (nonatomic, strong) UILabel *updateTime;
@property (nonatomic, strong) NSMutableArray *viewConstraints;

@property (nonatomic, strong) NSMutableArray *titleConstraints;
@property (nonatomic, strong) NSMutableArray *subTitleConstraints;
@property (nonatomic, strong) NSMutableArray *updateBtnConstraints;
@property (nonatomic, strong) NSMutableArray *imageViewConstraints;


@end

@implementation HomeDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

//- (void)updateConfigurationUsingState:(UICellConfigurationState *)state {
//    self.backgroundConfiguration = [UIBackgroundConfiguration clearConfiguration];
//}


- (void)setScrpit:(UserScript *)scrpit {
    _scrpit = scrpit;
    if(scrpit != nil) {
        [self createCellView:scrpit];
    }
    
}

- (void)doubleTap:(CGPoint)location{
    [super doubleTap:location];
    
    UIView *containerView = [self.fcContentView.containerView duplicate];
    containerView.backgroundColor  = FCStyle.popup;
    [self.contentView addSubview:containerView];
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [containerView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:[FCTableViewCell contentInset].left],
        [containerView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-[FCTableViewCell contentInset].right],
        [containerView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:[FCTableViewCell contentInset].top],
        [containerView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-[FCTableViewCell contentInset].bottom]
    ]];
    
    UIView *imageBoxTmp = [[UIView alloc] init];
    imageBoxTmp.layer.cornerRadius = 10;
    imageBoxTmp.layer.borderWidth = 1;
    imageBoxTmp.layer.borderColor = FCStyle.borderColor.CGColor;
    imageBoxTmp.translatesAutoresizingMaskIntoConstraints = NO;
    imageBoxTmp.clipsToBounds = YES;;
    [containerView addSubview:imageBoxTmp];
    
    UIImageView *image = [[UIImageView alloc] init];
    image.contentMode =  UIViewContentModeScaleAspectFit;
    image.clipsToBounds = YES;
    image.translatesAutoresizingMaskIntoConstraints = NO;
    [imageBoxTmp addSubview:image];
    [NSLayoutConstraint activateConstraints:@[
        [image.centerXAnchor constraintEqualToAnchor:imageBoxTmp.centerXAnchor],
        [image.centerYAnchor constraintEqualToAnchor:imageBoxTmp.centerYAnchor],
    ]];
    
    UserScript *dic = self.scrpit;
    
    if(dic.icon.length > 0) {
        [image sd_setImageWithURL:[NSURL URLWithString: dic.icon]];
        [NSLayoutConstraint activateConstraints:@[
            [image.heightAnchor constraintEqualToConstant:26],
            [image.widthAnchor constraintEqualToConstant:26]
        ]];
      
    } else {
        [image setImage:[DefaultIcon iconWithTitle:dic.name size:CGSizeMake(48, 48)]];
        [NSLayoutConstraint activateConstraints:@[
            [image.heightAnchor constraintEqualToConstant:48],
            [image.widthAnchor constraintEqualToConstant:48]
        ]];
    }
    
    if(dic.active == 0) {
        image.image = [self makeGrayImage:image.image];
    }

    [NSLayoutConstraint activateConstraints:@[
        [imageBoxTmp.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor constant:15],
        [imageBoxTmp.topAnchor constraintEqualToAnchor:containerView.topAnchor constant:12],
        [imageBoxTmp.heightAnchor constraintEqualToConstant:48],
        [imageBoxTmp.widthAnchor constraintEqualToConstant:48]

    ]];

    
    UILabel *nameLabel = (UILabel *)[self.headerLabel duplicate];
    nameLabel.textColor =  dic.active == 1?[FCStyle.fcBlack colorWithAlphaComponent:0.5] : FCStyle.fcBlack;
    nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:nameLabel];
    [NSLayoutConstraint activateConstraints:@[
        [nameLabel.leftAnchor constraintEqualToAnchor:imageBoxTmp.rightAnchor constant:10],
        [nameLabel.topAnchor constraintEqualToAnchor:containerView.topAnchor constant:15]
    ]];
    
    UILabel *subTitleLabel = (UILabel *)[self.subLabel duplicate];
    subTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    subTitleLabel.textColor =  dic.active == 1 ?  [FCStyle.fcSecondaryBlack colorWithAlphaComponent:0.5] : FCStyle.fcSecondaryBlack;
    [containerView addSubview:subTitleLabel];
    [NSLayoutConstraint activateConstraints:@[
        [subTitleLabel.topAnchor constraintEqualToAnchor:nameLabel.bottomAnchor constant:5],
        [subTitleLabel.leftAnchor constraintEqualToAnchor:imageBoxTmp.rightAnchor constant:10],
    ]];
    
    UIView *tmpSplitView = [[UIView alloc] init];
    tmpSplitView.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:tmpSplitView];
    tmpSplitView.layer.cornerRadius = 4;
    [NSLayoutConstraint activateConstraints:@[
        [tmpSplitView.widthAnchor constraintEqualToConstant:8],
        [tmpSplitView.heightAnchor constraintEqualToConstant:8],
        [tmpSplitView.bottomAnchor constraintEqualToAnchor:containerView.bottomAnchor constant:-10],
        [tmpSplitView.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor constant:15],

    ]];
    [tmpSplitView setBackgroundColor:dic.active == 1 ?[FCStyle.grayNoteColor colorWithAlphaComponent:0.5]:FCStyle.accent];

    UILabel *statusView =  [[UILabel alloc] init];
    statusView.translatesAutoresizingMaskIntoConstraints = NO;
    statusView.font = FCStyle.footnoteBold;
    [containerView addSubview:statusView];

    statusView.textColor = dic.active == 1 ? [FCStyle.grayNoteColor colorWithAlphaComponent:0.5] : FCStyle.accent;
    statusView.text = dic.active == 1 ? NSLocalizedString(@"Stopped", @"") : NSLocalizedString(@"Activated", @"");
    

    UIView *splitLine = [[UIView alloc] init];
    splitLine.translatesAutoresizingMaskIntoConstraints = NO;
    splitLine.backgroundColor = FCStyle.fcSeparator;
    [containerView addSubview:splitLine];
    [NSLayoutConstraint activateConstraints:@[
        [splitLine.widthAnchor constraintEqualToConstant:1],
        [splitLine.heightAnchor constraintEqualToConstant:13],
    ]];
    
    

    [NSLayoutConstraint activateConstraints:@[
        [statusView.centerYAnchor constraintEqualToAnchor:tmpSplitView.centerYAnchor],
        [statusView.leftAnchor constraintEqualToAnchor:tmpSplitView.rightAnchor constant:5],
        [splitLine.centerYAnchor constraintEqualToAnchor:tmpSplitView.centerYAnchor],
        [splitLine.leftAnchor constraintEqualToAnchor:statusView.rightAnchor constant:3],

    ]];
    
    
    UIImageView *tmpVersionImageView = [[UIImageView alloc] init];
    tmpVersionImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:tmpVersionImageView];
    [NSLayoutConstraint activateConstraints:@[
        [tmpVersionImageView.widthAnchor constraintEqualToConstant:15],
        [tmpVersionImageView.heightAnchor constraintEqualToConstant:15],
    ]];
    
    
    UIImage *tmpImage =  [UIImage systemImageNamed:@"v.circle.fill"
                                 withConfiguration:[UIImageSymbolConfiguration configurationWithFont:[UIFont systemFontOfSize:15]]];
    tmpImage = [tmpImage imageWithTintColor: dic.active == 1 ? [FCStyle.grayNoteColor colorWithAlphaComponent:0.5] : FCStyle.grayNoteColor renderingMode:UIImageRenderingModeAlwaysOriginal];
    [tmpVersionImageView setImage:tmpImage];
    
    
    
    
    
    UILabel *tmpVersionLabel = [[UILabel alloc] init];
    tmpVersionLabel.font = FCStyle.footnoteBold;
    tmpVersionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:tmpVersionLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [tmpVersionImageView.centerYAnchor constraintEqualToAnchor:splitLine.centerYAnchor],
        [tmpVersionImageView.leftAnchor constraintEqualToAnchor:splitLine.rightAnchor constant:3],
    ]];
    


    tmpVersionLabel.text = dic.version;
    tmpVersionLabel.textColor = dic.active == 1 ? [FCStyle.grayNoteColor colorWithAlphaComponent:0.5] : FCStyle.grayNoteColor;
    [NSLayoutConstraint activateConstraints:@[
        [tmpVersionLabel.centerYAnchor constraintEqualToAnchor:splitLine.centerYAnchor],
        [tmpVersionLabel.leftAnchor constraintEqualToAnchor:tmpVersionImageView.rightAnchor constant:5],
    ]];
    
    
    UIButton *tmpUpdateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [tmpUpdateBtn setTitle:NSLocalizedString(@"settings.update","update") forState:UIControlStateNormal];
    [tmpUpdateBtn setTitleColor: FCStyle.accent forState:UIControlStateNormal];
    tmpUpdateBtn.titleLabel.font = FCStyle.footnoteBold;
    tmpUpdateBtn.layer.cornerRadius = 10;
    tmpUpdateBtn.layer.borderWidth = 1;
    tmpUpdateBtn.layer.borderColor = FCStyle.accent.CGColor;
    tmpUpdateBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:tmpUpdateBtn];
    
    
    NSString *uuid = dic.uuid;
    ScriptEntity *entity = [ScriptMananger shareManager].scriptDic[uuid];
    if(entity != nil && entity.needUpdate && !dic.updateSwitch && entity.updateScript != NULL && entity.updateScript.content != NULL){
        tmpUpdateBtn.hidden = false;
        CGRect rect = [tmpUpdateBtn.titleLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, FCStyle.body.pointSize)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName : FCStyle.footnoteBold}
                                               context:nil];
        
        
        [NSLayoutConstraint activateConstraints:@[[tmpUpdateBtn.heightAnchor constraintEqualToConstant:25],
                                                           [tmpUpdateBtn.widthAnchor constraintEqualToConstant:rect.size.width + 20],
                                                           [tmpUpdateBtn.topAnchor constraintEqualToAnchor:containerView.topAnchor constant:15],
                                                    [tmpUpdateBtn.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor constant:-11],]];


        [NSLayoutConstraint activateConstraints:@[
            [nameLabel.rightAnchor constraintEqualToAnchor:tmpUpdateBtn.leftAnchor constant:-11],
        ]];
        [NSLayoutConstraint activateConstraints:@[
            [subTitleLabel.widthAnchor constraintEqualToAnchor:nameLabel.widthAnchor]

        ]];
    
        
    } else {
        tmpUpdateBtn.hidden = true;
        
        [NSLayoutConstraint activateConstraints:@[
            [nameLabel.widthAnchor constraintEqualToAnchor:containerView.widthAnchor constant:-90],
        ]];
        [NSLayoutConstraint activateConstraints:@[
            [subTitleLabel.widthAnchor constraintEqualToAnchor:containerView.widthAnchor constant:-90],
        ]];
        
        
    }
    
    
    UIView *maskView = [[UIView alloc] init];
    maskView.backgroundColor = UIColor.blackColor;
    maskView.layer.cornerRadius = 0;
    containerView.maskView = maskView;
    CGFloat radius =  MAX((self.size.width - location.x),location.x);
    [maskView setFrame:CGRectMake(location.x, location.y, 0, 0)];
    [UIView animateWithDuration:0.5
                     animations:^{
        [maskView setFrame:CGRectMake(location.x - radius, location.y - radius, radius * 2, radius * 2)];
        maskView.layer.cornerRadius = radius;
    } completion:^(BOOL finished) {
        containerView.maskView = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeScriptStatus" object:self.scrpit];
        [containerView removeFromSuperview];
        
    }];
}


- (void )createCellView:(UserScript *)dic{
    
    
    [NSLayoutConstraint deactivateConstraints:self.titleConstraints];
    [NSLayoutConstraint deactivateConstraints:self.subTitleConstraints];
    [NSLayoutConstraint deactivateConstraints:self.updateBtnConstraints];
    [NSLayoutConstraint deactivateConstraints:self.imageViewConstraints];

    [self.updateBtnConstraints removeAllObjects];
    [self.titleConstraints removeAllObjects];
    [self.subTitleConstraints removeAllObjects];
    [self.imageViewConstraints removeAllObjects];
    
    self.iconImageView.image = nil;
    
    if(dic.icon.length > 0) {
        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString: dic.icon]];
        
        [self.imageViewConstraints addObjectsFromArray:@[[_iconImageView.heightAnchor constraintEqualToConstant:26],
                                                         [_iconImageView.widthAnchor constraintEqualToConstant:26]]];
        
    } else {
        [self.iconImageView setImage:[DefaultIcon iconWithTitle:dic.name size:CGSizeMake(48, 48)]];
        [self.imageViewConstraints addObjectsFromArray:@[[_iconImageView.heightAnchor constraintEqualToConstant:48],
                                                         [_iconImageView.widthAnchor constraintEqualToConstant:48]]];
    }
    
    
    
    
    if(dic.active == 0) {
        self.iconImageView.image = [self makeGrayImage:self.iconImageView.image];
    }
    
    [self.titleConstraints addObjectsFromArray:@[
                [self.headerLabel.topAnchor constraintEqualToAnchor:self.fcContentView.topAnchor constant:15],
                [self.headerLabel.leftAnchor constraintEqualToAnchor:self.imageBox.rightAnchor constant:10],
    ]];
    
    [self.subTitleConstraints addObjectsFromArray:@[
        [self.subLabel.topAnchor constraintEqualToAnchor:self.headerLabel.bottomAnchor constant:5],
        [self.subLabel.leftAnchor constraintEqualToAnchor:self.imageBox.rightAnchor constant:10],
    ]];
    

    
    self.headerLabel.textColor = dic.active == 0 ? [FCStyle.fcBlack colorWithAlphaComponent:0.5] : FCStyle.fcBlack;
    self.headerLabel.text = dic.name;
    self.subLabel.text = dic.desc;
    self.subLabel.textColor = dic.active == 0 ? [FCStyle.fcSecondaryBlack colorWithAlphaComponent:0.5] : FCStyle.fcSecondaryBlack;

    

    NSString *uuid = dic.uuid;
    ScriptEntity *entity = [ScriptMananger shareManager].scriptDic[uuid];
    if(entity != nil && entity.needUpdate && !dic.updateSwitch && entity.updateScript != NULL && entity.updateScript.content != NULL){
        self.updateBtn.hidden = false;

        objc_setAssociatedObject (self.updateBtn , @"script", entity.updateScript.description, OBJC_ASSOCIATION_COPY_NONATOMIC);
        objc_setAssociatedObject (self.updateBtn , @"scriptContent", entity.updateScript.content, OBJC_ASSOCIATION_COPY_NONATOMIC);
        objc_setAssociatedObject (self.updateBtn , @"downloadUrl", entity.script.downloadUrl, OBJC_ASSOCIATION_COPY_NONATOMIC);
        
        CGRect rect = [self.updateBtn.titleLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, FCStyle.body.pointSize)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName : FCStyle.footnoteBold}
                                               context:nil];
        
        
        [self.updateBtnConstraints addObjectsFromArray:@[[self.updateBtn.heightAnchor constraintEqualToConstant:25],
                                                           [self.updateBtn.widthAnchor constraintEqualToConstant:rect.size.width + 20],
                                                           [self.updateBtn.topAnchor constraintEqualToAnchor:self.fcContentView.topAnchor constant:15],
                                                    [self.updateBtn.trailingAnchor constraintEqualToAnchor:self.fcContentView.trailingAnchor constant:-11],]];


                [NSLayoutConstraint activateConstraints:self.updateBtnConstraints];
        [self.titleConstraints addObjectsFromArray:@[
            [self.headerLabel.rightAnchor constraintEqualToAnchor:self.updateBtn.leftAnchor constant:-11],
        ]];
        [self.subTitleConstraints addObjectsFromArray:@[
            [self.subLabel.widthAnchor constraintEqualToAnchor:self.headerLabel.widthAnchor]

        ]];
    
        
    } else {
        self.updateBtn.hidden = true;
        
        [self.titleConstraints addObjectsFromArray:@[
            [self.headerLabel.widthAnchor constraintEqualToAnchor:self.fcContentView.widthAnchor constant:-90],
        ]];
        [self.subTitleConstraints addObjectsFromArray:@[
            [self.subLabel.widthAnchor constraintEqualToAnchor:self.fcContentView.widthAnchor constant:-90],

        ]];
        
        
    }
    

    [NSLayoutConstraint activateConstraints:self.titleConstraints];
    [NSLayoutConstraint activateConstraints:self.subTitleConstraints];
    [NSLayoutConstraint activateConstraints:self.imageViewConstraints];

    
    [self.sImageView setBackgroundColor:dic.active == 0 ?[FCStyle.grayNoteColor colorWithAlphaComponent:0.5]:FCStyle.accent];
    
    
    
    self.actLabel.textColor = dic.active == 0 ? [FCStyle.grayNoteColor colorWithAlphaComponent:0.5] : FCStyle.accent;
    self.actLabel.text = dic.active == 0 ? NSLocalizedString(@"Stopped", @"") : NSLocalizedString(@"Activated", @"");
    
    [NSLayoutConstraint activateConstraints:@[
        [self.actLabel.centerYAnchor constraintEqualToAnchor:self.sImageView.centerYAnchor],
        [self.actLabel.leftAnchor constraintEqualToAnchor:self.sImageView.rightAnchor constant:5],
        [self.splitView.centerYAnchor constraintEqualToAnchor:self.sImageView.centerYAnchor],
        [self.splitView.leftAnchor constraintEqualToAnchor:self.actLabel.rightAnchor constant:3],

    ]];
    
    
    
    
    UIImage *image =  [UIImage systemImageNamed:@"v.circle.fill"
                                 withConfiguration:[UIImageSymbolConfiguration configurationWithFont:[UIFont systemFontOfSize:15]]];
    image = [image imageWithTintColor: dic.active == 0 ? [FCStyle.grayNoteColor colorWithAlphaComponent:0.5] : FCStyle.grayNoteColor renderingMode:UIImageRenderingModeAlwaysOriginal];

    [self.versionImageView setImage:image];
    [NSLayoutConstraint activateConstraints:@[
        [self.versionImageView.centerYAnchor constraintEqualToAnchor:self.splitView.centerYAnchor],
        [self.versionImageView.leftAnchor constraintEqualToAnchor:self.splitView.rightAnchor constant:3],
    ]];
    


    self.versionLabel.text = dic.version;
    self.versionLabel.textColor = dic.active == 0 ? [FCStyle.grayNoteColor colorWithAlphaComponent:0.5] : FCStyle.grayNoteColor;
    [NSLayoutConstraint activateConstraints:@[
        [self.versionLabel.centerYAnchor constraintEqualToAnchor:self.splitView.centerYAnchor],
        [self.versionLabel.leftAnchor constraintEqualToAnchor:self.versionImageView.rightAnchor constant:5],
    ]];
    
//
    if(dic.updateScriptTime != nil && dic.updateScriptTime.length > 0) {
        self.updateTime.hidden = false;
        self.updateTime.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"UpdateOn", @""),[self timeWithTimeIntervalString: dic.updateScriptTime]];
        self.updateTime.textColor = dic.active == 0 ? [FCStyle.fcSecondaryBlack colorWithAlphaComponent:0.5] : FCStyle.fcSecondaryBlack;
        [NSLayoutConstraint activateConstraints:@[
            [self.updateTime.centerYAnchor constraintEqualToAnchor:self.splitView.centerYAnchor],
            [self.updateTime.trailingAnchor constraintEqualToAnchor:self.fcContentView.trailingAnchor constant:-11],
        ]];
    } else {
        self.updateTime.hidden = true;
    }

}

- (UIImage*)makeGrayImage:(UIImage*)image {
    //修改饱和度为0
    CIImage *beginImage = [CIImage imageWithCGImage:image.CGImage];
    CIFilter * filter = [CIFilter filterWithName:@"CIColorControls"];
    [filter setValue:beginImage forKey:kCIInputImageKey];
    //饱和度 0---2 默认为1
    [filter setValue:0 forKey:@"inputSaturation"];

    // 得到过滤后的图片
    CIImage *outputImage = [filter outputImage];
    // 转换图片, 创建基于GPU的CIContext对象
    CIContext *context = [CIContext contextWithOptions: nil];
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *newImg = [UIImage imageWithCGImage:cgimg];
    // 释放C对象
    CGImageRelease(cgimg);
    return newImg;
}


- (NSString *)timeWithTimeIntervalString:(NSString *)timeString
{
    
    if(timeString == NULL || [timeString doubleValue] < 20) {
        timeString = [self getNowDate];
    }
  // 格式化时间
  NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
  formatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
  [formatter setDateStyle:NSDateFormatterMediumStyle];
  [formatter setTimeStyle:NSDateFormatterShortStyle];
  [formatter setDateFormat:@"yyyy.MM.dd"];
  
  // 毫秒值转化为秒
  NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeString doubleValue]/ 1000.0];
  NSString* dateString = [formatter stringFromDate:date];
  return dateString;
}

- (NSString *)getNowDate {
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[date timeIntervalSince1970]*1000; // *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeString = [NSString stringWithFormat:@"%.0f", a];
    return timeString;
}

- (UIView *)imageBox {
    if(_imageBox == nil) {
        _imageBox = [[UIView alloc] init];
        _imageBox.layer.cornerRadius = 10;
        _imageBox.layer.borderWidth = 1;
        _imageBox.layer.borderColor = FCStyle.borderColor.CGColor;
        _imageBox.translatesAutoresizingMaskIntoConstraints = NO;
        _imageBox.clipsToBounds = YES;
        [self.fcContentView addSubview:_imageBox];
        [NSLayoutConstraint activateConstraints:@[
            [_imageBox.leadingAnchor constraintEqualToAnchor:self.fcContentView.leadingAnchor constant:15],
            [_imageBox.topAnchor constraintEqualToAnchor:self.fcContentView.topAnchor constant:12],
            [_imageBox.heightAnchor constraintEqualToConstant:48],
            [_imageBox.widthAnchor constraintEqualToConstant:48]

        ]];
    }
    return _imageBox;
}

- (UIImageView *)iconImageView {
    if(_iconImageView == nil) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.contentMode =  UIViewContentModeScaleAspectFit;
        _iconImageView.clipsToBounds = YES;
        _iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.imageBox addSubview:self.iconImageView];
        [NSLayoutConstraint activateConstraints:@[
            [_iconImageView.centerXAnchor constraintEqualToAnchor:self.imageBox.centerXAnchor],
            [_iconImageView.centerYAnchor constraintEqualToAnchor:self.imageBox.centerYAnchor],
        ]];
        
 
    }
    
    return _iconImageView;
}

- (UILabel *)headerLabel {
    if(_headerLabel == nil) {
        _headerLabel = [[UILabel alloc] init];
        _headerLabel.font = FCStyle.body;
        _headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.fcContentView addSubview:_headerLabel];
    }
    return _headerLabel;
}

- (UILabel *)subLabel {
    if(_subLabel == nil) {
        _subLabel = [[UILabel alloc] init];
        _subLabel.font = FCStyle.footnote;
        _subLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.fcContentView addSubview:_subLabel];
    }
    return _subLabel;
}

- (UIButton *)updateBtn {
    if(_updateBtn == nil) {
        _updateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_updateBtn setTitle:NSLocalizedString(@"settings.update","update") forState:UIControlStateNormal];
        [_updateBtn setTitleColor:FCStyle.accent forState:UIControlStateNormal];
        _updateBtn.titleLabel.font = FCStyle.footnoteBold;
        _updateBtn.layer.cornerRadius = 10;
        _updateBtn.layer.borderWidth = 1;
        _updateBtn.layer.borderColor = FCStyle.accent.CGColor;
        [_updateBtn addTarget:self.controller action:@selector(updateScript:) forControlEvents:UIControlEventTouchUpInside];
        _updateBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [self.fcContentView addSubview:_updateBtn];
        
    }
    return _updateBtn;
}

- (UIView *)sImageView {
    if(_sImageView == nil) {
        
        _sImageView = [[UIView alloc] init];
        _sImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.fcContentView addSubview:_sImageView];
        _sImageView.layer.cornerRadius = 4;
        [NSLayoutConstraint activateConstraints:@[
            [_sImageView.widthAnchor constraintEqualToConstant:8],
            [_sImageView.heightAnchor constraintEqualToConstant:8],
            [_sImageView.bottomAnchor constraintEqualToAnchor:self.fcContentView.bottomAnchor constant:-10],
            [_sImageView.leadingAnchor constraintEqualToAnchor:self.fcContentView.leadingAnchor constant:15],

        ]];
    }
    return _sImageView;
}

- (UILabel *)actLabel {
    if(_actLabel == nil) {
        _actLabel = [[UILabel alloc] init];
        _actLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _actLabel.font = FCStyle.footnoteBold;
        [self.fcContentView addSubview:_actLabel];
    }
    return _actLabel;
}

- (UIView *)splitView {
    if(_splitView == nil) {
        _splitView = [[UIView alloc] init];
        _splitView.translatesAutoresizingMaskIntoConstraints = NO;
        _splitView.backgroundColor = FCStyle.fcSeparator;
        [self.fcContentView addSubview:_splitView];
        [NSLayoutConstraint activateConstraints:@[
            [_splitView.widthAnchor constraintEqualToConstant:1],
            [_splitView.heightAnchor constraintEqualToConstant:13],
        ]];
    }
    return _splitView;
}

- (UIImageView *)versionImageView {
    if(_versionImageView == nil) {
        _versionImageView = [[UIImageView alloc] init];
        _versionImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.fcContentView addSubview:_versionImageView];
        [NSLayoutConstraint activateConstraints:@[
            [_versionImageView.widthAnchor constraintEqualToConstant:15],
            [_versionImageView.heightAnchor constraintEqualToConstant:15],
        ]];
    }
    return _versionImageView;
}

- (UILabel *)versionLabel {
    if(_versionLabel == nil) {
        _versionLabel = [[UILabel alloc] init];
        _versionLabel.font = FCStyle.footnoteBold;
        _versionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.fcContentView addSubview:_versionLabel];

    }
    return _versionLabel;
}

- (UILabel *)updateTime {
    if(_updateTime == nil) {
        _updateTime = [[UILabel alloc] init];
        _updateTime.font = FCStyle.footnote;
        _updateTime.translatesAutoresizingMaskIntoConstraints = NO;
        [self.fcContentView addSubview:_updateTime];
    }
    return _updateTime;
}

- (NSMutableArray *)viewConstraints {
    if(_viewConstraints == nil) {
        _viewConstraints = [NSMutableArray array];
    }
    return _viewConstraints;
}

- (NSMutableArray *)titleConstraints {
    if(_titleConstraints == nil) {
        _titleConstraints = [NSMutableArray array];
    }
    return _titleConstraints;
}

- (NSMutableArray *)subTitleConstraints {
    if(_subTitleConstraints == nil) {
        _subTitleConstraints = [NSMutableArray array];
    }
    return _subTitleConstraints;
}
- (NSMutableArray *)updateBtnConstraints {
    if(_updateBtnConstraints == nil) {
        _updateBtnConstraints = [NSMutableArray array];
    }
    return _updateBtnConstraints;
}

- (NSMutableArray *)imageViewConstraints {
    if(_imageViewConstraints == nil) {
        _imageViewConstraints = [NSMutableArray array];
    }
    return _imageViewConstraints;
}

@end
