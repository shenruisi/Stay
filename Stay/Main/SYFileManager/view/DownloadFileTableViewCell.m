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
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 13, 27, 20)];
    [imageView setImage:[ImageHelper sfNamed:@"folder" font:[UIFont systemFontOfSize:20] color: [ColorHelper colorFromHex:fCTab.config.hexColor]]];
    imageView.contentMode = UIViewContentModeBottom;
    imageView.centerY = 25;
    [self.contentView addSubview:imageView];

    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width - 100, 18)];
    name.text = fCTab.config.name;
    name.font = FCStyle.body;
    [name sizeToFit];
    name.centerY = imageView.centerY;
    name.left = imageView.right + 7;
    [self.contentView addSubview:name];
    
    
    UIImageView *rightIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 8, 15)];
    [rightIcon setImage:[ImageHelper sfNamed:@"chevron.right" font:[UIFont systemFontOfSize:15] color: FCStyle.grayNoteColor]];
    rightIcon.centerY = imageView.centerY;
    rightIcon.right = self.contentView.width - 20;
    rightIcon.contentMode = UIViewContentModeBottom;
    [self.contentView addSubview:rightIcon];
    
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0,  self.contentView.width - 10, 0.5)];
    line.backgroundColor = FCStyle.fcSeparator;
    line.top =  imageView.bottom + 13;
    line.left = 10;
    [self.contentView addSubview:line];
    
}

@end
