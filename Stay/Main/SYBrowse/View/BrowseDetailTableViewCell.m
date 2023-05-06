//
//  BrowseDetailTableViewCell.m
//  Stay
//
//  Created by zly on 2022/9/14.
//

#import "BrowseDetailTableViewCell.h"
#import "ScriptMananger.h"
#import "FCStyle.h"
#import "ScriptEntity.h"
#import "UIImageView+WebCache.h"
#import <objc/runtime.h>
#import "ImageHelper.h"
#import "SYNoDownLoadDetailViewController.h"
#import "API.h"
#import "QuickAccess.h"
#import "DeviceHelper.h"
#import "DefaultIcon.h"
@implementation BrowseDetailTableViewCell


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){

    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
}

- (void)setEntity:(NSDictionary *)entity{
    for (UIView *subView in self.contentView.subviews) {
        [subView removeFromSuperview];
    }
    [self createCellView:entity];
}

- (void )createCellView:(NSDictionary *)dic{
    UIView *imageBox = [[UIView alloc] initWithFrame:CGRectMake(15, 12, 48, 48)];
    imageBox.layer.cornerRadius = 8;
    imageBox.layer.borderWidth = 1;
    imageBox.clipsToBounds = YES;
    imageBox.layer.borderColor = FCStyle.borderColor.CGColor;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 26, 26)];
    [imageView sd_setImageWithURL:[NSURL URLWithString: dic[@"icon_url"]]];
//    [imageView sd_setImageWithURL:[NSURL URLWithString: @"https://res.stayfork.app/scripts/8E61538B6D32E64E6F38BF2AB4416C73/icon.png"]];
    imageView.contentMode =  UIViewContentModeScaleAspectFit;

    imageView.clipsToBounds = YES;
    imageView.centerX = 24;
    imageView.centerY = 24;
    [imageBox addSubview:imageView];
    [self.contentView addSubview:imageBox];
//    view.backgroundColor = FCStyle.background;
    
    NSString *icon = dic[@"icon_url"];
    CGFloat left = 15;
    left = imageBox.right + 10;

  
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0,  self.contentView.width - 15, 0.5)];
    line.backgroundColor = FCStyle.fcSeparator;
    line.top =  138;
    line.left = 15;
    [self.contentView addSubview:line];
    
    NSString *name = @"name";
    NSString *desc = @"desc";
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 234, 18)];
    headerLabel.font = FCStyle.bodyBold;
    headerLabel.textColor = FCStyle.fcBlack;
    headerLabel.text = dic[name];
    [self.contentView addSubview:headerLabel];
    
    UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 234, 13)];
    subLabel.font = FCStyle.footnote;
    subLabel.textColor = FCStyle.fcSecondaryBlack;
    subLabel.text = dic[desc];
    subLabel.top = headerLabel.bottom + 5;
    [self.contentView addSubview:subLabel];
    headerLabel.left = subLabel.left = left;
    subLabel.top = headerLabel.bottom + 5;
    
    
    headerLabel.width = self.contentView.width - headerLabel.left - 100;
    subLabel.width =  self.contentView.width - subLabel.left - 100;
    
    
    NSDictionary *locate = dic[@"locales"];
    if(locate != NULL  && locate.count > 0) {
        NSDictionary *localLanguage = locate[[UserScript localeCode]];
        if (localLanguage != nil && localLanguage.count > 0) {
            headerLabel.text = localLanguage[name];
            subLabel.text = localLanguage[@"description"];
        }
    }
    
    if(icon.length <= 0){
        [imageView setImage:[DefaultIcon iconWithTitle:headerLabel.text size:CGSizeMake(48, 48)]];
    }
    
    NSString *uuid = dic[@"uuid"];
    
    ScriptEntity *entity = [ScriptMananger shareManager].scriptDic[uuid];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 67, 25);
//    btn.backgroundColor = FCStyle.background;
    btn.layer.cornerRadius = 10;
    btn.layer.borderWidth = 1;
    btn.layer.borderColor = FCStyle.accent.CGColor;
    
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.contentView addSubview:indicatorView];
    
    if(entity != nil) {
        [btn setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Detail", @"")
                                                                attributes:@{
            NSForegroundColorAttributeName : FCStyle.accent,
            NSFontAttributeName : FCStyle.footnoteBold
        }] forState:UIControlStateNormal];
        
        [btn sizeToFit];
        btn.width = btn.width + 20;
        if(btn.width < 67) {
            btn.width = 67;
        }
        btn.height = 25;
        [btn addTarget:self.controller action:@selector(queryDetail:) forControlEvents:UIControlEventTouchUpInside];
        objc_setAssociatedObject (btn , @"uuid", uuid, OBJC_ASSOCIATION_COPY_NONATOMIC);
    } else {
        
        NSString *btnName = NSLocalizedString(@"Get", @"");
        
        if (self.selectedUrl != nil && self.selectedUrl.length > 0 && [self.selectedUrl isEqualToString:dic[@"hosting_url"]]) {
            btnName = NSLocalizedString(@"Downloading", @"");
            btn.hidden = true;
            indicatorView.hidden = false;
            [indicatorView startAnimating];
        } else {
            btn.hidden = false;
            indicatorView.hidden = true;
        }
        
        [btn setAttributedTitle:[[NSAttributedString alloc] initWithString:btnName
                                                                attributes:@{
            NSForegroundColorAttributeName : FCStyle.accent,
            NSFontAttributeName : FCStyle.footnoteBold
        }] forState:UIControlStateNormal];
        objc_setAssociatedObject (btn , @"downloadUrl", dic[@"hosting_url"], OBJC_ASSOCIATION_COPY_NONATOMIC);
        objc_setAssociatedObject (btn , @"name", dic[@"name"], OBJC_ASSOCIATION_COPY_NONATOMIC);
        objc_setAssociatedObject (btn , @"platforms", dic[@"platforms"], OBJC_ASSOCIATION_COPY_NONATOMIC);
        objc_setAssociatedObject (btn , @"iconUrl", dic[@"icon_url"], OBJC_ASSOCIATION_COPY_NONATOMIC);

        [btn sizeToFit];
        btn.width = btn.width + 20;
        if(btn.width < 67) {
            btn.width = 67;
        }
        btn.height = 25;
        NSArray *plafroms = dic[@"platforms"];
        if (plafroms != NULL && ![plafroms containsObject:[[API shared] queryDeviceType]] ) {
            [btn addTarget:self.controller action:@selector(notSupport:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [btn addTarget:self.controller action:@selector(getDetail:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    btn.top = headerLabel.top;
    btn.right = self.contentView.width - 15;
    btn.layer.cornerRadius = 12.5;
    [self.contentView addSubview:btn];
    indicatorView.center = btn.center;
    
    
    
    UILabel *installLabel = [[UILabel alloc] init];
    NSNumber *install = dic[@"installs"];
    NSString *installs = [install stringValue];
    installLabel.text = installs;
    installLabel.textColor = FCStyle.fcSecondaryBlack;
    installLabel.font = FCStyle.footnote;
    [installLabel sizeToFit];
    installLabel.centerX = btn.centerX;
    installLabel.top = btn.bottom + 5;
    [self.contentView addSubview:installLabel];
    
    CGFloat top = imageBox.bottom + 10;
    NSArray *platforms = dic[@"platforms"];
    if(platforms != nil && platforms.count > 0) {
        top = top + 19;
        CGFloat imageLeft = 16;
        for(int i = 0; i < platforms.count; i++) {
        
            NSString *name = platforms[i];
            if ([name isEqualToString:@"mac"]) {
                name = @"laptopcomputer";
            }
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[ImageHelper sfNamed:name font:FCStyle.body color:FCStyle.grayNoteColor]];
            imageView.size = imageView.image.size;
            imageView.bottom = top;
            imageView.left = imageLeft;
            imageLeft += 5 + imageView.width;
            [self.contentView addSubview:imageView];
        }
        
        bool stayOnly = [dic[@"stay_only"] boolValue];
        if(stayOnly) {
            UIView *splitline = [[UIView alloc] initWithFrame:CGRectMake(0, 12, 1, 17)];
            splitline.backgroundColor = FCStyle.fcSeparator;
            splitline.bottom = top;
            [self.contentView addSubview:splitline];
            splitline.left = imageLeft + 10;
            UILabel *onlyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 19)];
            onlyLabel.text = @"Only on";
            onlyLabel.font = FCStyle.footnoteBold;
            onlyLabel.textColor =  FCStyle.grayNoteColor;
            onlyLabel.bottom = top;
            onlyLabel.left = splitline.right + 12;
            [self.contentView addSubview:onlyLabel];
            UIImageView *bzImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bz"]]; ;
            bzImageView.size = CGSizeMake(20, 20);
            bzImageView.bottom = top;
            bzImageView.left = onlyLabel.right + 2;
            [self.contentView addSubview:bzImageView];
        }
        
        
        top += 10;
    }
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(noDownloadDetail:)];
    if(entity != nil) {
        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self.controller action:@selector(queryDetail:)];
        objc_setAssociatedObject (tapGesture , @"uuid", uuid, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    [tapGesture setName:uuid];
    [self.contentView addGestureRecognizer:tapGesture];
    
    NSArray *tags = dic[@"tags"];
    
    UIScrollView *tagScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, top, self.contentView.width ,25)];
//    tagScrollView.clipsToBounds = YES;
    tagScrollView.showsVerticalScrollIndicator = false;
    tagScrollView.showsHorizontalScrollIndicator = false;
    if(tags != nil && tags.count > 0) {
        CGFloat tagLeft = 16;
        for (int i = 0; i < tags.count; i++) {
            UILabel *tag = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 25)];
            tag.text = tags[i];
            tag.backgroundColor = [FCStyle.accent colorWithAlphaComponent:0.1];
            tag.font = FCStyle.footnote;
            tag.layer.cornerRadius = 8;
            tag.layer.borderColor = FCStyle.accent.CGColor;
            tag.layer.borderWidth = 1;
            tag.textAlignment = NSTextAlignmentCenter;
            [tag sizeToFit];
            tag.width += 40;
            tag.height = 25;
            tag.left = tagLeft;
            tag.clipsToBounds = YES;
            tag.top = 0;
            tagLeft = tag.right + 5;
            [tagScrollView addSubview:tag];
        }
        
        tagScrollView.contentSize = CGSizeMake(tagLeft, 25);
    }
    [self.contentView addSubview:tagScrollView];
    
}


-(void)noDownloadDetail:(UITapGestureRecognizer *)tap {
    NSString* uuid = tap.name;
    SYNoDownLoadDetailViewController *cer = [[SYNoDownLoadDetailViewController alloc] init];
    cer.uuid = uuid;
    if ((FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type])
            && [QuickAccess splitController].viewControllers.count >= 2){
             [[QuickAccess secondaryController] pushViewController:cer];
    }
    else{
        [self.navigationController pushViewController:cer animated:true];
    }
    
}




@end
