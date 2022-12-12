//
//  DownloadResourceTableViewCell.m
//  Stay
//
//  Created by zly on 2022/12/5.
//

#import "DownloadResourceTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "FCStyle.h"
#import "DownloadManager.h"
#import "ImageHelper.h"
#import "SYProgress.h"
@implementation DownloadResourceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setDownloadResource:(DownloadResource *)downloadResource {
    for (UIView *subView in self.contentView.subviews) {
        [subView removeFromSuperview];
    }
    _downloadResource = downloadResource;
    [self createCell];
}

- (void)createCell {
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 8, 60, 60)];
    imageView.layer.cornerRadius = 10;
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.layer.borderColor = FCStyle.borderColor.CGColor;
    imageView.layer.borderWidth = 0.5;
    if(_downloadResource.icon != nil) {
        [imageView sd_setImageWithURL:[NSURL URLWithString:_downloadResource.icon] placeholderImage:[UIImage imageNamed:@"videoDefault"]];
    } else {
        [imageView setImage:[UIImage imageNamed:@"videoDefault"]];
    }
    
    if(_downloadResource.videoDuration >= 0) {
        
    }
    
    [self.contentView addSubview:imageView];
    UILabel *hostLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width - 60 - 12 - 15 -12 - 50, 15)];
    hostLabel.font = FCStyle.footnote;
    hostLabel.text = _downloadResource.host;
    hostLabel.textColor = FCStyle.titleGrayColor;
    hostLabel.left = imageView.right + 15;
    hostLabel.top = imageView.top;
    [self.contentView addSubview:hostLabel];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width - 60 - 12 - 15 -12 - 50, 44)];
    titleLabel.numberOfLines = 2;
    titleLabel.font = FCStyle.body;
    titleLabel.text = _downloadResource.title;
    [titleLabel sizeToFit];
    titleLabel.top = hostLabel.bottom + 2;
    titleLabel.left = imageView.right + 5;
    [self.contentView addSubview:titleLabel];
    
    CGFloat top = imageView.bottom + 7;
    
    
    UIButton *runBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 25)];
    runBtn.titleLabel.textColor = FCStyle.accent;
    runBtn.titleLabel.font = FCStyle.footnoteBold;
    
    if(_downloadResource.status == 2) {
        UIButton *savePhotoBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 154, 25)];
        [savePhotoBtn setImage:[ImageHelper sfNamed:@"square.and.arrow.down" font:FCStyle.body color:FCStyle.accent] forState:UIControlStateNormal];
        [savePhotoBtn setTitle:NSLocalizedString(@"SAVETOPHOTOS", @"") forState:UIControlStateNormal];
        [savePhotoBtn setTitleColor:FCStyle.accent forState:UIControlStateNormal];
        savePhotoBtn.titleLabel.font = FCStyle.footnoteBold;
        savePhotoBtn.top = top;
        savePhotoBtn.left = 12;
        savePhotoBtn.backgroundColor = FCStyle.secondaryPopup;
        savePhotoBtn.layer.cornerRadius = 8;
        [savePhotoBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 8)];

        [self.contentView addSubview:savePhotoBtn];

        
        UIButton *saveFileBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 154, 25)];
        [saveFileBtn setImage:[ImageHelper sfNamed:@"square.and.arrow.down" font:FCStyle.body color:FCStyle.accent] forState:UIControlStateNormal];
        [saveFileBtn setTitle:NSLocalizedString(@"SAVETOFILES", @"") forState:UIControlStateNormal];
        [saveFileBtn setTitleColor:FCStyle.accent forState:UIControlStateNormal];
        saveFileBtn.titleLabel.font = FCStyle.footnoteBold;
        saveFileBtn.centerY = savePhotoBtn.centerY;
        saveFileBtn.left = savePhotoBtn.right + 9;
        saveFileBtn.backgroundColor = FCStyle.secondaryPopup;
        saveFileBtn.layer.cornerRadius = 8;
        [saveFileBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 8)];

        [self.contentView addSubview:saveFileBtn];
        runBtn.titleLabel.text = NSLocalizedString(@"PLAY", @"");
        
        
    } else {
        UILabel *downloadRateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 128, 16)];
    
        downloadRateLabel.font = FCStyle.footnoteBold;
        downloadRateLabel.top = top;
        downloadRateLabel.left = 12;
        downloadRateLabel.textColor = FCStyle.accent;
        [self.contentView addSubview:downloadRateLabel];
    
        if(_downloadResource.status == 0) {
            downloadRateLabel.text = [NSString stringWithFormat:@"%@%.2f%%",NSLocalizedString(@"Downloading",""),_downloadResource.downloadProcess];
        } else if (_downloadResource.status == 1) {
            downloadRateLabel.text = [NSString stringWithFormat:@"%@%.2f%%",NSLocalizedString(@"StopDownload",""),_downloadResource.downloadProcess];
        } else if (_downloadResource.status == 3) {
            downloadRateLabel.text = [NSString stringWithFormat:@"%@%.2f%%",NSLocalizedString(@"DownloadFailed",""),_downloadResource.downloadProcess];
        }
        
        
        SYProgress *progress = [[SYProgress alloc] initWithFrame:CGRectMake(12, 0, self.contentView.width - 24, 2) BgViewBgColor:FCStyle.progressBgColor BgViewBorderColor:FCStyle.progressBgColor ProgressViewColor:FCStyle.accent];

        progress.top = downloadRateLabel.bottom + 5;
        progress.progress = _downloadResource.downloadProcess;
        [self.contentView addSubview:progress];
    }
    
    
    
    
    
}

@end
