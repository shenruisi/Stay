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

@implementation HomeDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){

    }
    
    return self;
}

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
#ifdef FC_MAC
    self.contentView.backgroundColor = selected ? FCStyle.accentHighlight :  FCStyle.secondaryBackground;
#else
    UIViewController *rootController = [QuickAccess rootController];
    if ([rootController isKindOfClass:[UISplitViewController class]]){
        UISplitViewController *splitViewController = (UISplitViewController *)rootController;
        if (nil == splitViewController || splitViewController.viewControllers.count < 2){
            self.contentView.backgroundColor = FCStyle.secondaryBackground;
        }
        else{
            self.contentView.backgroundColor = selected ? FCStyle.accentHighlight :  FCStyle.secondaryBackground;
        }
    }
    else{
        self.contentView.backgroundColor = FCStyle.secondaryBackground;
    }
#endif
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
#ifdef FC_MAC
    self.contentView.backgroundColor = selected ? FCStyle.accentHighlight :  FCStyle.secondaryBackground;
#else
    UIViewController *rootController = [QuickAccess rootController];
    if ([rootController isKindOfClass:[UISplitViewController class]]){
        UISplitViewController *splitViewController = (UISplitViewController *)rootController;
        if (nil == splitViewController || splitViewController.viewControllers.count < 2){
            self.contentView.backgroundColor = FCStyle.secondaryBackground;
        }
        else{
            self.contentView.backgroundColor = selected ? FCStyle.accentHighlight :  FCStyle.secondaryBackground;
        }
    }
    else{
        self.contentView.backgroundColor = FCStyle.secondaryBackground;
    }
#endif
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
}

- (void)updateConfigurationUsingState:(UICellConfigurationState *)state {
    self.backgroundConfiguration = [UIBackgroundConfiguration clearConfiguration];
}


- (void)setScrpit:(UserScript *)scrpit {
    for (UIView *subView in self.contentView.subviews) {
        [subView removeFromSuperview];
    }
    _scrpit = scrpit;
    [self createCellView:scrpit];
    
}

- (void )createCellView:(UserScript *)dic{
    UIView *imageBox = [[UIView alloc] initWithFrame:CGRectMake(20, 12, 48, 48)];
    imageBox.layer.cornerRadius = 10;
    imageBox.layer.borderWidth = 1;
    imageBox.layer.borderColor = FCStyle.borderColor.CGColor;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 26, 26)];
//    [imageView sd_setImageWithURL:[NSURL URLWithString: dic[@"icon_url"]]];
    [imageView sd_setImageWithURL:[NSURL URLWithString: dic.icon]];
    imageView.contentMode =  UIViewContentModeScaleAspectFit;

    if(dic.active == 0 && dic.icon != NULL && dic.icon.length > 0) {
        imageView.image = [self makeGrayImage:imageView.image];
    }

    imageView.clipsToBounds = YES;
    imageView.centerX = 24;
    imageView.centerY = 24;
    [imageBox addSubview:imageView];
    [self.contentView addSubview:imageBox];
    CGFloat left = 20;
    if (dic.icon != NULL && dic.icon.length > 0) {
        left = imageBox.right + 10;
    } else {
        imageBox.hidden = true;
    }
//    view.backgroundColor = FCStyle.background;
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 234, 19)];
    headerLabel.font = FCStyle.bodyBold;
    headerLabel.textColor = dic.active == 0 ? [FCStyle.fcBlack colorWithAlphaComponent:0.5] : FCStyle.fcBlack;
    headerLabel.text = dic.name;
    [self.contentView addSubview:headerLabel];
    
    UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 234, 17)];
    subLabel.font = FCStyle.footnote;
    subLabel.textColor = dic.active == 0 ? [FCStyle.fcSecondaryBlack colorWithAlphaComponent:0.5] : FCStyle.fcSecondaryBlack;
    subLabel.text = dic.desc;
    subLabel.top = headerLabel.bottom + 5;
    [self.contentView addSubview:subLabel];
    headerLabel.left = subLabel.left = left;
    subLabel.top = headerLabel.bottom + 5;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0,  self.contentView.width - 20, 0.5)];
    line.backgroundColor = FCStyle.fcSeparator;
    line.top =  99.5;
    line.left = 20;
    [self.contentView addSubview:line];
    NSString *uuid = dic.uuid;
    ScriptEntity *entity = [ScriptMananger shareManager].scriptDic[uuid];
    
    
    CGFloat rightWidth = 0;
    
    if(entity != nil && entity.needUpdate && !dic.updateSwitch){
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 60, 25);
  
        [btn setTitle:NSLocalizedString(@"settings.update","update") forState:UIControlStateNormal];
        [btn setTitleColor:FCStyle.accent forState:UIControlStateNormal];
        btn.titleLabel.font = FCStyle.footnoteBold;
        btn.layer.cornerRadius = 12.5;
        btn.backgroundColor = FCStyle.background;
        
        [btn addTarget:self.controller action:@selector(updateScript:) forControlEvents:UIControlEventTouchUpInside];
        
        
        objc_setAssociatedObject (btn , @"script", entity.updateScript.description, OBJC_ASSOCIATION_COPY_NONATOMIC);
        objc_setAssociatedObject (btn , @"scriptContent", entity.updateScript.content, OBJC_ASSOCIATION_COPY_NONATOMIC);
        objc_setAssociatedObject (btn , @"downloadUrl", entity.script.downloadUrl, OBJC_ASSOCIATION_COPY_NONATOMIC);
        [btn sizeToFit];
        btn.width = btn.width + 20;
        if(btn.width < 60) {
            btn.width = 60;
        }
        btn.right = self.contentView.width - 19;
        btn.top = 20;
        [self.contentView addSubview:btn];
        
        rightWidth = btn.width;
    }
    
    
    headerLabel.width = self.contentView.width - headerLabel.left - 30 - rightWidth;
    subLabel.width =  self.contentView.width - subLabel.left - 30 - rightWidth;
    
    
    UIImage *simage =  [UIImage systemImageNamed:@"s.circle.fill"
                                 withConfiguration:[UIImageSymbolConfiguration configurationWithFont:[UIFont systemFontOfSize:15]]];
    simage = [simage imageWithTintColor:dic.active == 0 ?[FCStyle.grayNoteColor colorWithAlphaComponent:0.5]:FCStyle.accent renderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIImageView *sImageView = [[UIImageView alloc] initWithImage:simage];
    sImageView.frame = CGRectMake(0, 0, 15, 15);
    sImageView.top = imageBox.bottom + 10;
    sImageView.left = 20;
    [self.contentView addSubview:sImageView];
    
    UILabel *actLabel = [[UILabel alloc]init];
    actLabel.font = FCStyle.footnoteBold;
    actLabel.textColor = dic.active == 0 ? [FCStyle.grayNoteColor colorWithAlphaComponent:0.5] : FCStyle.accent;
    actLabel.text = dic.active == 0 ? NSLocalizedString(@"Stopped", @"") : NSLocalizedString(@"Activated", @"");
    [actLabel sizeToFit];
    actLabel.centerY = sImageView.centerY;
    actLabel.left = sImageView.right + 5;
    [self.contentView addSubview:actLabel];
    
    UIImage *image =  [UIImage systemImageNamed:@"v.circle.fill"
                                 withConfiguration:[UIImageSymbolConfiguration configurationWithFont:[UIFont systemFontOfSize:15]]];
    image = [image imageWithTintColor: dic.active == 0 ? [FCStyle.grayNoteColor colorWithAlphaComponent:0.5] : FCStyle.grayNoteColor renderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIImageView *versionImageView = [[UIImageView alloc] initWithImage:image];
    versionImageView.frame = CGRectMake(0, 0, 15, 15);
    versionImageView.centerY = sImageView.centerY;
    versionImageView.left = actLabel.right + 12;
    [self.contentView addSubview:versionImageView];

    UILabel *version = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 15)];
    version.font = FCStyle.footnoteBold;
    version.text = dic.version;
    version.textColor = dic.active == 0 ? [FCStyle.grayNoteColor colorWithAlphaComponent:0.5] : FCStyle.grayNoteColor;
    [version sizeToFit];
    version.centerY = sImageView.centerY;
    version.left = versionImageView.right + 5;
    [self.contentView addSubview:version];
    
    
    if(dic.updateScriptTime != nil && dic.updateScriptTime.length > 0) {
        UILabel *updateTime = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 15)];
        updateTime.font = FCStyle.footnote;
        updateTime.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"UpdateOn", @""),[self timeWithTimeIntervalString: dic.updateScriptTime]];
        updateTime.textColor = dic.active == 0 ? [FCStyle.fcSecondaryBlack colorWithAlphaComponent:0.5] : FCStyle.fcSecondaryBlack;
        [updateTime sizeToFit];
        updateTime.centerY = version.centerY;
        updateTime.right = self.contentView.width - 20;

//        updateTime.left = version.right + 5;
        [self.contentView addSubview:updateTime];
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


@end
