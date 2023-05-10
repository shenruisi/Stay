//
//  DownloadFileTableViewCell.m
//  Stay
//
//  Created by zly on 2022/12/5.
//

#import "DownloadFileTableViewCell.h"
#import "ImageHelper.h"
#import "FCStyle.h"
#import "ColorHelper.h"
#import "DataManager.h"
@implementation DownloadFileTableViewCell
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}


- (void)setFctab:(FCTab *)fctab {
    for (UIView *subView in self.contentView.subviews) {
        [subView removeFromSuperview];
    }
    
    _fctab = fctab;
    [self createFileCell:fctab];
}

- (void)createFileCell:(FCTab *)fCTab {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 21, 27, 20)];
    [imageView setImage:[ImageHelper sfNamed:@"folder" font:[UIFont systemFontOfSize:22] color: [ColorHelper colorFromHex:fCTab.config.hexColor]]];
    imageView.contentMode = UIViewContentModeBottom;
    [self.contentView addSubview:imageView];

    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width - 100, 18)];
    name.text = fCTab.config.name;
    name.font = FCStyle.body;
    [name sizeToFit];
    name.top = 13;
    name.left = imageView.right + 10;
    [self.contentView addSubview:name];
    
    
    UIImageView *rightIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 8, 15)];
    [rightIcon setImage:[ImageHelper sfNamed:@"chevron.right" font:[UIFont systemFontOfSize:15] color: FCStyle.grayNoteColor]];
    rightIcon.centerY = imageView.centerY;
    rightIcon.right = self.contentView.width - 20;
    rightIcon.contentMode = UIViewContentModeBottom;
    [self.contentView addSubview:rightIcon];
    
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0,  self.contentView.width - 10, 0.5)];
    line.backgroundColor = FCStyle.fcSeparator;
    line.bottom =  imageView.bottom + 21;
    line.left = 10;
    [self.contentView addSubview:line];
    
    NSArray *list =  [[DataManager shareManager] selectDownloadComplete:fCTab.uuid];
    UILabel *itemsLab =  [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 18)];
    itemsLab.font = FCStyle.footnote;
    itemsLab.textColor = FCStyle.subtitleColor;
    
    if(list != NULL && list.count > 0) {
        itemsLab.text = [NSString stringWithFormat:@"%ld %@",list.count,NSLocalizedString(@"items","")];
    } else {
        itemsLab.text = [NSString stringWithFormat:@"0 %@",NSLocalizedString(@"items","")];
    }
    itemsLab.top = name.bottom;
    itemsLab.left = imageView.right + 10;
    [self.contentView addSubview:itemsLab];
    
}

@end
