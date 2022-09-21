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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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

    if(dic.active == 0) {
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
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 234, 17)];
    headerLabel.font = FCStyle.body;
    headerLabel.textColor = dic.active == 0 ? [FCStyle.fcBlack colorWithAlphaComponent:0.7] : FCStyle.fcBlack;
    headerLabel.text = dic.name;
    [self.contentView addSubview:headerLabel];
    
    UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 234, 17)];
    subLabel.font = FCStyle.footnote;
    subLabel.textColor = dic.active == 0 ? [FCStyle.fcSecondaryBlack colorWithAlphaComponent:0.7] : FCStyle.fcSecondaryBlack;
    subLabel.text = dic.desc;
    subLabel.top = headerLabel.bottom + 5;
    [self.contentView addSubview:subLabel];
    headerLabel.left = subLabel.left = left;
    subLabel.top = headerLabel.bottom + 5;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0,  self.contentView.width - 20, 1)];
    line.backgroundColor = FCStyle.fcSeparator;
    line.top =  99;
    line.left = 20;
    [self.contentView addSubview:line];
    NSString *uuid = dic.uuid;
    ScriptEntity *entity = [ScriptMananger shareManager].scriptDic[uuid];
    
    if(entity != nil && entity.needUpdate && !dic.updateSwitch){
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 60, 25);
        btn.right = self.contentView.width - 19;
        btn.top = 20;
        [btn setTitle:NSLocalizedString(@"settings.update","update") forState:UIControlStateNormal];
        [btn setTitleColor:FCStyle.accent forState:UIControlStateNormal];
        btn.titleLabel.font = FCStyle.footnoteBold;
        btn.layer.cornerRadius = 12.5;
        btn.backgroundColor = FCStyle.background;
        
        [btn addTarget:self.controller action:@selector(updateScript:) forControlEvents:UIControlEventTouchUpInside];
        
        objc_setAssociatedObject (btn , @"script", entity.updateScript.description, OBJC_ASSOCIATION_COPY_NONATOMIC);
        objc_setAssociatedObject (btn , @"scriptContent", entity.updateScript.content, OBJC_ASSOCIATION_COPY_NONATOMIC);
        objc_setAssociatedObject (btn , @"downloadUrl", entity.script.downloadUrl, OBJC_ASSOCIATION_COPY_NONATOMIC);
        [self.contentView addSubview:btn];
    } else {
        headerLabel.width = self.contentView.width - headerLabel.left - 10;
        subLabel.width =  self.contentView.width - subLabel.left - 10;
    }
    
    UIImage *simage =  [UIImage systemImageNamed:@"s.circle.fill"
                                 withConfiguration:[UIImageSymbolConfiguration configurationWithFont:[UIFont systemFontOfSize:15]]];
    simage = [simage imageWithTintColor:dic.active == 0 ?FCStyle.grayNoteColor:FCStyle.accent renderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIImageView *sImageView = [[UIImageView alloc] initWithImage:simage];
    sImageView.frame = CGRectMake(0, 0, 15, 15);
    sImageView.top = imageBox.bottom + 10;
    sImageView.left = 20;
    [self.contentView addSubview:sImageView];
    
    UILabel *actLabel = [[UILabel alloc]init];
    actLabel.font = FCStyle.footnoteBold;
    actLabel.textColor = dic.active == 0 ? [FCStyle.grayNoteColor colorWithAlphaComponent:0.7] : FCStyle.accent;
    actLabel.text = dic.active == 0 ? NSLocalizedString(@"Stopped", @"") : NSLocalizedString(@"Activated", @"");
    [actLabel sizeToFit];
    actLabel.centerY = sImageView.centerY;
    actLabel.left = sImageView.right + 5;
    [self.contentView addSubview:actLabel];
    
    UIImage *image =  [UIImage systemImageNamed:@"v.circle.fill"
                                 withConfiguration:[UIImageSymbolConfiguration configurationWithFont:[UIFont systemFontOfSize:15]]];
    image = [image imageWithTintColor:FCStyle.grayNoteColor renderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIImageView *versionImageView = [[UIImageView alloc] initWithImage:image];
    versionImageView.frame = CGRectMake(0, 0, 15, 15);
    versionImageView.centerY = sImageView.centerY;
    versionImageView.left = actLabel.right + 12;
    [self.contentView addSubview:versionImageView];

    UILabel *version = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 15)];
    version.font = FCStyle.footnoteBold;
    version.text = dic.version;
    version.textColor = dic.active == 0 ? [FCStyle.grayNoteColor colorWithAlphaComponent:0.7] : FCStyle.grayNoteColor;
    version.centerY = sImageView.centerY;
    version.left = versionImageView.right + 5;
    [self.contentView addSubview:version];
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
@end
