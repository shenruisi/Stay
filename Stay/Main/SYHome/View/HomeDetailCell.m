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
@interface HomeDetailCell()

@property (nonatomic, strong) UIView *imageBox;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) UILabel *subLabel;
@property (nonatomic, strong) UIButton *updateBtn;
@property (nonatomic, strong) UIImageView *sImageView;
@property (nonatomic, strong) UILabel *actLabel;
@property (nonatomic, strong) UIView *splitView;
@property (nonatomic, strong) UIImageView *versionImageView;
@property (nonatomic, strong) UILabel *versionLabel;
@property (nonatomic, strong) UILabel *updateTime;
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

- (void )createCellView:(UserScript *)dic{
    

//    [imageView sd_setImageWithURL:[NSURL URLWithString: dic[@"icon_url"]]];
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString: dic.icon]];
    if(dic.active == 0 && dic.icon != NULL && dic.icon.length > 0) {
        self.iconImageView.image = [self makeGrayImage:self.iconImageView.image];
    }

    if (dic.icon != NULL && dic.icon.length > 0) {
        self.imageBox.hidden = false;
        [NSLayoutConstraint activateConstraints:@[
            [self.headerLabel.topAnchor constraintEqualToAnchor:self.fcContentView.topAnchor constant:15],
            [self.headerLabel.leftAnchor constraintEqualToAnchor:self.imageBox.rightAnchor constant:10],

            [self.subLabel.topAnchor constraintEqualToAnchor:self.headerLabel.bottomAnchor constant:5],
            [self.subLabel.leftAnchor constraintEqualToAnchor:self.imageBox.rightAnchor constant:10],
        ]];
        
        
    } else {
        self.imageBox.hidden = true;
        [NSLayoutConstraint activateConstraints:@[
            [self.headerLabel.topAnchor constraintEqualToAnchor:self.fcContentView.topAnchor constant:15],
            [self.headerLabel.leadingAnchor constraintEqualToAnchor:self.fcContentView.leadingAnchor constant:20],

            [self.subLabel.topAnchor constraintEqualToAnchor:self.headerLabel.bottomAnchor constant:5],
            [self.subLabel.leadingAnchor constraintEqualToAnchor:self.fcContentView.leadingAnchor constant:20],
        ]];
    }
    
    self.headerLabel.textColor = dic.active == 0 ? [FCStyle.fcBlack colorWithAlphaComponent:0.5] : FCStyle.fcBlack;
    self.headerLabel.text = dic.name;
    self.subLabel.text = dic.desc;
    self.subLabel.textColor = dic.active == 0 ? [FCStyle.fcSecondaryBlack colorWithAlphaComponent:0.5] : FCStyle.fcSecondaryBlack;

    

    NSString *uuid = dic.uuid;
    ScriptEntity *entity = [ScriptMananger shareManager].scriptDic[uuid];
    if(entity != nil && entity.needUpdate && !dic.updateSwitch && entity.updateScript != NULL && entity.updateScript.content != NULL){

        objc_setAssociatedObject (self.updateBtn , @"script", entity.updateScript.description, OBJC_ASSOCIATION_COPY_NONATOMIC);
        objc_setAssociatedObject (self.updateBtn , @"scriptContent", entity.updateScript.content, OBJC_ASSOCIATION_COPY_NONATOMIC);
        objc_setAssociatedObject (self.updateBtn , @"downloadUrl", entity.script.downloadUrl, OBJC_ASSOCIATION_COPY_NONATOMIC);
//
        
        
        CGRect rect = [self.updateBtn.titleLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, FCStyle.body.pointSize)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName : FCStyle.footnoteBold}
                                               context:nil];
            
        CGRect titleRect = [self.headerLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, FCStyle.body.pointSize)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName : FCStyle.body}
                                               context:nil];
            
        
        
        [NSLayoutConstraint activateConstraints:@[
            [self.updateBtn.heightAnchor constraintEqualToConstant:25],
            [self.updateBtn.widthAnchor constraintEqualToConstant:rect.size.width + 10],
            [self.updateBtn.topAnchor constraintEqualToAnchor:self.fcContentView.topAnchor constant:15],
            [self.updateBtn.trailingAnchor constraintEqualToAnchor:self.fcContentView.trailingAnchor constant:-11],
            [self.headerLabel.rightAnchor constraintEqualToAnchor:self.updateBtn.leftAnchor constant:-11],
            [self.subLabel.widthAnchor constraintEqualToAnchor:self.headerLabel.widthAnchor]
         ]];
    
        
    } else {
        if (dic.icon != NULL && dic.icon.length > 0) {
            [NSLayoutConstraint activateConstraints:@[
                [self.headerLabel.widthAnchor constraintEqualToAnchor:self.fcContentView.widthAnchor constant:-90],
                [self.subLabel.widthAnchor constraintEqualToAnchor:self.fcContentView.widthAnchor constant:-90],
            ]];
        } else {
            [NSLayoutConstraint activateConstraints:@[
                [self.headerLabel.widthAnchor constraintEqualToAnchor:self.fcContentView.widthAnchor constant:-40],
                [self.subLabel.widthAnchor constraintEqualToAnchor:self.fcContentView.widthAnchor constant:-40],
            ]];
        }
    }
    


    
    
    UIImage *simage =  [UIImage systemImageNamed:@"s.circle.fill"
                                 withConfiguration:[UIImageSymbolConfiguration configurationWithFont:[UIFont systemFontOfSize:15]]];
    simage = [simage imageWithTintColor:dic.active == 0 ?[FCStyle.grayNoteColor colorWithAlphaComponent:0.5]:FCStyle.accent renderingMode:UIImageRenderingModeAlwaysOriginal];
    
    
    [self.sImageView setImage:simage];
    
    
    
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
        [self.fcContentView addSubview:_imageBox];
        [NSLayoutConstraint activateConstraints:@[
            [_imageBox.leadingAnchor constraintEqualToAnchor:self.fcContentView.leadingAnchor constant:20],
            [_imageBox.topAnchor constraintEqualToAnchor:self.fcContentView.topAnchor constant:12],
            [_imageBox.heightAnchor constraintEqualToConstant:48],
            [_imageBox.widthAnchor constraintEqualToConstant:48]

        ]];
    }
    return _imageBox;
}

- (UIImageView *)iconImageView {
    if(_iconImageView == nil) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 26, 26)];
        _iconImageView.contentMode =  UIViewContentModeScaleAspectFit;
        _iconImageView.clipsToBounds = YES;
        _iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.imageBox addSubview:self.iconImageView];
        [NSLayoutConstraint activateConstraints:@[
            [_iconImageView.centerXAnchor constraintEqualToAnchor:self.imageBox.centerXAnchor],
            [_iconImageView.centerYAnchor constraintEqualToAnchor:self.imageBox.centerYAnchor]
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

- (UIImageView *)sImageView {
    if(_sImageView == nil) {
        
        _sImageView = [[UIImageView alloc] init];
        _sImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.fcContentView addSubview:_sImageView];
        [NSLayoutConstraint activateConstraints:@[
            [_sImageView.widthAnchor constraintEqualToConstant:15],
            [_sImageView.heightAnchor constraintEqualToConstant:15],
            [_sImageView.bottomAnchor constraintEqualToAnchor:self.fcContentView.bottomAnchor constant:-10],
            [_sImageView.leadingAnchor constraintEqualToAnchor:self.fcContentView.leadingAnchor constant:20],

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

@end
