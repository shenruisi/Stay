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
#import "SYProgress.h"

@implementation SYVideoCellTableViewCell

- (void)setDownloadResource:(DownloadResource *)downloadResource {
    _downloadResource = downloadResource;
}

- (void)createCell:(BOOL)isCurrent {
    int contentWidth = UIScreen.mainScreen.bounds.size.width;
    
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
        
        watchProcess.progress = _downloadResource.watchProcess * 1.0 / _downloadResource.videoDuration;
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
        time.width = time.width + 10;

        time.right = 155;
        time.layer.cornerRadius = 7;
        time.layer.masksToBounds = TRUE;
        [imageView addSubview:time];
    }
    
    [self.contentView addSubview:imageView];
    UILabel *hostLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, contentWidth - 160 - 12 - 15 - 12, 15)];
    hostLabel.font = FCStyle.footnote;
    hostLabel.text = _downloadResource.host;
    hostLabel.textColor = isCurrent ? FCStyle.accent : FCStyle.titleGrayColor;
    hostLabel.left = imageView.right + 15;
    hostLabel.top = imageView.top;
    [self.contentView addSubview:hostLabel];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, contentWidth - 160 - 12 - 15 - 12, 44)];
    titleLabel.numberOfLines = 3;
    titleLabel.font = FCStyle.body;
    titleLabel.text = _downloadResource.title;
    titleLabel.textColor = isCurrent ? FCStyle.accent : FCStyle.fcBlack;
    [titleLabel sizeToFit];
    titleLabel.top = hostLabel.bottom + 2;
    titleLabel.left = imageView.right + 15;
    [self.contentView addSubview:titleLabel];
    
    if (isCurrent) {
        UILabel *nowLabel = [[UILabel alloc] initWithFrame:CGRectMake(imageView.right + 15, imageView.bottom - 15, contentWidth - 160 - 12 - 15 - 12, 15)];
        nowLabel.font = FCStyle.footnoteBold;
        nowLabel.text = NSLocalizedString(@"NowPlaying", @"");
        nowLabel.textColor = FCStyle.accent;
        [self.contentView addSubview:nowLabel];
    }

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0,  contentWidth - 11, 0.5)];
    line.backgroundColor = FCStyle.fcSeparator;
    line.top =  imageView.bottom + 6;
    line.left = 12;
    [self.contentView addSubview:line];
}


- (void)reloadCell:(BOOL)isCurrent {
    for (UIView *subView in self.contentView.subviews) {
        [subView removeFromSuperview];
    }
    [self createCell:isCurrent];
}

- (NSString *)timeFormatted:(NSInteger)totalSeconds
{

    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;

    if(hours == 0) {
        return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];

    } else {
        return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
    }
    
}

@end
