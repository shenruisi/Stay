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
    imageBox.layer.borderColor = FCStyle.borderColor.CGColor;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 26, 26)];
    [imageView sd_setImageWithURL:[NSURL URLWithString: dic[@"icon_url"]]];
//    [imageView sd_setImageWithURL:[NSURL URLWithString: @"https://res.stayfork.app/scripts/8E61538B6D32E64E6F38BF2AB4416C73/icon.png"]];

    imageView.clipsToBounds = YES;
    imageView.centerX = 24;
    imageView.centerY = 24;
    [imageBox addSubview:imageView];
    [self.contentView addSubview:imageBox];
//    view.backgroundColor = FCStyle.background;
    
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 234, 16)];
    headerLabel.font = FCStyle.body;
    headerLabel.textColor = FCStyle.fcBlack;
    headerLabel.text = dic[@"name"];
    [self.contentView addSubview:headerLabel];
    
    UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 234, 13)];
    subLabel.font = FCStyle.footnote;
    subLabel.textColor = FCStyle.fcSecondaryBlack;
    subLabel.text = dic[@"desc"];
    subLabel.top = headerLabel.bottom + 5;
    [self.contentView addSubview:subLabel];
    headerLabel.left = subLabel.left = imageBox.right + 10;
    subLabel.top = headerLabel.bottom + 5;
//
//    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0,  self.contentView.width - 20, 1)];
//    line.backgroundColor = FCStyle.fcSeparator;
//    line.top =  127;
//    line.left = 20;
//    [self.contentView addSubview:line];
    
    NSString *uuid = dic[@"uuid"];
    
    ScriptEntity *entity = [ScriptMananger shareManager].scriptDic[uuid];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 67, 25);
    btn.backgroundColor = FCStyle.background;
    if(entity != nil) {
        [btn setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Detail", @"")
                                                                attributes:@{
            NSForegroundColorAttributeName : FCStyle.accent,
            NSFontAttributeName : FCStyle.footnoteBold
        }] forState:UIControlStateNormal];
        [btn addTarget:self.controller action:@selector(queryDetail:) forControlEvents:UIControlEventTouchUpInside];
        objc_setAssociatedObject (btn , @"uuid", uuid, OBJC_ASSOCIATION_COPY_NONATOMIC);
    } else {
        [btn setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Get", @"")
                                                                attributes:@{
            NSForegroundColorAttributeName : FCStyle.accent,
            NSFontAttributeName : FCStyle.footnoteBold
        }] forState:UIControlStateNormal];
        [btn addTarget:self.controller action:@selector(getDetail:) forControlEvents:UIControlEventTouchUpInside];
        objc_setAssociatedObject (btn , @"downloadUrl", dic[@"hosting_url"], OBJC_ASSOCIATION_COPY_NONATOMIC);
        objc_setAssociatedObject (btn , @"name", dic[@"name"], OBJC_ASSOCIATION_COPY_NONATOMIC);

    }
    
    btn.top = headerLabel.top;
    btn.right = self.contentView.width - 15;
    btn.layer.cornerRadius = 12.5;
    [self.contentView addSubview:btn];
    
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
        
        top += 10;
    }
    
    
    NSArray *tags = dic[@"tags"];
    
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
            tag.top = top;
            tag.left = tagLeft;
            tag.clipsToBounds = YES;
            [self.contentView addSubview:tag];
            tagLeft = tag.right + 5;
        }
    }
    
}





@end
