//
//  SYVideoCellTableViewCell.m
//  Stay
//
//  Created by zly on 2022/12/28.
//

#import "SYVideoCellTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "FCStyle.h"
#import "DownloadManager.h"
#import "ImageHelper.h"
#import "DataManager.h"
#import <objc/runtime.h>
#import "SYProgress.h"

@implementation SYVideoCellTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)createCell {
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 8, 160, 90)];
    imageView.layer.cornerRadius = 5;
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.layer.borderColor = FCStyle.borderColor.CGColor;
    imageView.layer.borderWidth = 0.5;
    imageView.backgroundColor = FCStyle.background;
    if(_downloadResource.icon != nil) {
        UIImageView *plImg = [[UIImageView alloc] initWithFrame:CGRectMake(18, 0, 44, 36)];
        [plImg setImage:[UIImage imageNamed:@"videoDefault"]];
        plImg.centerX = 80;
        plImg.centerY = 45;
        plImg.contentMode = UIViewContentModeScaleAspectFit;
        [imageView addSubview:plImg];
    
        [imageView sd_setImageWithURL:([_downloadResource.icon hasPrefix:@"http"] ? [NSURL URLWithString:_downloadResource.icon] : [NSURL fileURLWithPath:_downloadResource.icon])  completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if(error == nil) {
                plImg.hidden = true;
            }
        }];
    } else {

        UIImageView *plImg = [[UIImageView alloc] initWithFrame:CGRectMake(18, 0, 44, 36)];
        [plImg setImage:[UIImage imageNamed:@"videoDefault"]];
        plImg.contentMode = UIViewContentModeScaleAspectFit;
        plImg.centerX = 80;
        [imageView addSubview:plImg];
        UILabel *youtubeLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 15)];
        youtubeLab.text = @"youtube";
        youtubeLab.font = FCStyle.footnote;
        youtubeLab.centerX = plImg.centerX;
        youtubeLab.top = plImg.bottom + 8;
        [imageView addSubview:youtubeLab];
    }
    
    if(_downloadResource.videoDuration > 0) {
        SYProgress *watchProcess = [[SYProgress alloc] initWithFrame:CGRectMake(0, 0, 160, 2) BgViewBgColor:FCStyle.borderColor BgViewBorderColor:FCStyle.borderColor ProgressViewColor:FCStyle.accent];
        
        watchProcess.progress = _downloadResource.watchProcess / _downloadResource.videoDuration;
        watchProcess.bottom = 90;
        [imageView addSubview:watchProcess];
        
        UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 15)];
        time.font = FCStyle.footnote;
        time.textColor = [UIColor whiteColor];
        time.backgroundColor = RGBA(0, 0, 0, 0.8);
        time.text = [self timeFormatted:_downloadResource.videoDuration];
        time.textAlignment = NSTextAlignmentCenter;
        time.bottom = 82;
        [time sizeToFit];
        time.width = time.width + 20;

        time.right = 155;
        time.layer.cornerRadius = 7;
        time.layer.masksToBounds = TRUE;
        [imageView addSubview:time];
    }
    
    [self.contentView addSubview:imageView];
    UILabel *hostLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width - 160 - 12 - 15 -12 - 50, 15)];
    if(_downloadResource.status == 2) {
        hostLabel.width =  self.contentView.width - 160 - 15 - 12 - 12;
    }
    hostLabel.font = FCStyle.footnote;
    hostLabel.text = _downloadResource.host;
    hostLabel.textColor = FCStyle.titleGrayColor;
    hostLabel.left = imageView.right + 15;
    hostLabel.top = imageView.top;
    [self.contentView addSubview:hostLabel];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width - 160 - 12 - 15 -12 - 50, 44)];
    if(_downloadResource.status == 2) {
        titleLabel.width =  self.contentView.width - 160 - 15 - 12 - 12;
    }
    titleLabel.numberOfLines = 3;
    titleLabel.font = FCStyle.body;
    titleLabel.text = _downloadResource.title;
    [titleLabel sizeToFit];
    titleLabel.top = hostLabel.bottom + 2;
    titleLabel.left = imageView.right + 15;
    [self.contentView addSubview:titleLabel];
    
    CGFloat top = imageView.bottom + 7;
    
    objc_setAssociatedObject(runBtn , @"resource", self.downloadResource, OBJC_ASSOCIATION_COPY_NONATOMIC);
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0,  self.contentView.width - 11, 0.5)];
    line.backgroundColor = FCStyle.fcSeparator;
    line.top =  saveFileBtn.bottom + 6;
    line.left = 12;
    [self.contentView addSubview:line];

}


- (void)reloadCell {
    for (UIView *subView in self.contentView.subviews) {
        [subView removeFromSuperview];
    }
    [self createCell];
}

- (NSString *)timeFormatted:(NSInteger)totalSeconds
{

    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;

    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}

@end
