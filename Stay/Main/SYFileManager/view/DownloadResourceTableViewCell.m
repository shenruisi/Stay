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
#import "DataManager.h"
#import <objc/runtime.h>

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
    
    if(_downloadResource.status == 2) {
        UIButton *savePhotoBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 154, 25)];
        [savePhotoBtn setImage:[ImageHelper sfNamed:@"square.and.arrow.down" font:FCStyle.body color:FCStyle.accent] forState:UIControlStateNormal];
        [savePhotoBtn setTitle:NSLocalizedString(@"SAVETOPHOTOS", @"") forState:UIControlStateNormal];
        [savePhotoBtn setTitleColor:FCStyle.accent forState:UIControlStateNormal];
        savePhotoBtn.titleLabel.font = FCStyle.footnoteBold;
        savePhotoBtn.top = top;
        savePhotoBtn.left = 12;
        savePhotoBtn.backgroundColor = FCStyle.background;
        savePhotoBtn.layer.cornerRadius = 8;
        [savePhotoBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 8)];
        [savePhotoBtn addTarget:self.controller action:@selector(saveToPhoto:) forControlEvents:UIControlEventTouchUpInside];
        objc_setAssociatedObject(savePhotoBtn , @"resource", _downloadResource, OBJC_ASSOCIATION_COPY_NONATOMIC);

        [self.contentView addSubview:savePhotoBtn];

        
        UIButton *saveFileBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 154, 25)];
        [saveFileBtn setImage:[ImageHelper sfNamed:@"square.and.arrow.down" font:FCStyle.body color:FCStyle.accent] forState:UIControlStateNormal];
        [saveFileBtn setTitle:NSLocalizedString(@"SAVETOFILES", @"") forState:UIControlStateNormal];
        [saveFileBtn setTitleColor:FCStyle.accent forState:UIControlStateNormal];
        saveFileBtn.titleLabel.font = FCStyle.footnoteBold;
        saveFileBtn.centerY = savePhotoBtn.centerY;
        saveFileBtn.left = savePhotoBtn.right + 9;
        saveFileBtn.backgroundColor = FCStyle.background;
        saveFileBtn.layer.cornerRadius = 8;
        [saveFileBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 8)];
        objc_setAssociatedObject(saveFileBtn , @"resource", _downloadResource, OBJC_ASSOCIATION_COPY_NONATOMIC);

        [saveFileBtn addTarget:self.controller action:@selector(saveToFile:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:saveFileBtn];
        
        UIButton *runBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 25)];
        runBtn.titleLabel.font = FCStyle.footnoteBold;
       
        [self.contentView addSubview:runBtn];
        objc_setAssociatedObject(runBtn , @"resource", self.downloadResource, OBJC_ASSOCIATION_COPY_NONATOMIC);

        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,  0,  self.contentView.width - 11, 0.5)];
        line.backgroundColor = FCStyle.fcSeparator;
        line.top =  saveFileBtn.bottom + 6;
        line.left = 12;
        [self.contentView addSubview:line];
        self.contentView.backgroundColor = [UIColor clearColor];
    } else {
        self.contentView.backgroundColor =  [FCStyle.accent colorWithAlphaComponent:0.1];

        _downloadRateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 16)];
        UIButton *stop =  [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        objc_setAssociatedObject(stop , @"resource", _downloadResource, OBJC_ASSOCIATION_COPY_NONATOMIC);

        _downloadRateLabel.font = FCStyle.footnoteBold;
        _downloadRateLabel.top = top;
        _downloadRateLabel.left = 12;
        _downloadRateLabel.textColor = FCStyle.accent;
        [self.contentView addSubview:_downloadRateLabel];
    
        if(_downloadResource.status == 0) {
            _downloadRateLabel.text = [NSString stringWithFormat:@"%@:%.1f%%",NSLocalizedString(@"Downloading",""),_downloadResource.downloadProcess];
            
            
            UILabel *stopLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 52, 18)];
            stopLabel.tintColor = FCStyle.accent;
            stopLabel.text = NSLocalizedString(@"STOP","");
            stopLabel.font = FCStyle.footnoteBold;
            stopLabel.bottom = imageView.bottom;
            stopLabel.textColor = FCStyle.accent;
            [stopLabel sizeToFit];
            stopLabel.right = self.contentView.width - 10;
            [self.contentView addSubview:stopLabel];
        
            
            [stop setImage:[ImageHelper sfNamed:@"pause.circle.fill" font:FCStyle.body color:FCStyle.accent] forState:UIControlStateNormal];
            stop.bottom = stopLabel.top - 2;
            stop.right =  self.contentView.width - 26;
            [stop addTarget:self.controller action:@selector(stopDownload:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:stop];
            
            stopLabel.centerX = stop.centerX;
        
        } else if (_downloadResource.status == 1) {
            
            UILabel *continueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 52, 18)];
            continueLabel.tintColor = FCStyle.accent;
            continueLabel.text = NSLocalizedString(@"CONTINUE","");
            continueLabel.font = FCStyle.footnoteBold;
            continueLabel.bottom = imageView.bottom;
            continueLabel.textColor = FCStyle.accent;
            [continueLabel sizeToFit];
            continueLabel.right = self.contentView.width - 10;
            [self.contentView addSubview:continueLabel];
        
            
            [stop setImage:[ImageHelper sfNamed:@"play.circle.fill" font:FCStyle.body color:FCStyle.accent] forState:UIControlStateNormal];
            stop.bottom = continueLabel.top - 2;
            stop.right =  self.contentView.width - 26;
            [stop addTarget:self.controller action:@selector(continueDownload:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:stop];
            _downloadRateLabel.text = [NSString stringWithFormat:@"%@:%.1f%%",NSLocalizedString(@"StopDownload",""),_downloadResource.downloadProcess];
            continueLabel.centerX = stop.centerX;

        } else if (_downloadResource.status == 3) {
            UILabel *retryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 52, 18)];
            retryLabel.tintColor = FCStyle.accent;
            retryLabel.text = NSLocalizedString(@"RETRY","");
            retryLabel.font = FCStyle.footnoteBold;
            retryLabel.bottom = imageView.bottom;
            retryLabel.textColor = FCStyle.accent;
            [retryLabel sizeToFit];
            retryLabel.right = self.contentView.width - 10;
            [self.contentView addSubview:retryLabel];
        
            [stop setImage:[ImageHelper sfNamed:@"goforward" font:FCStyle.body color:FCStyle.accent] forState:UIControlStateNormal];
            
            [stop addTarget:self.controller action:@selector(retryDownload:) forControlEvents:UIControlEventTouchUpInside];

            stop.bottom = retryLabel.top - 2;
            stop.right =  self.contentView.width - 26;
            [self.contentView addSubview:stop];
            
            retryLabel.centerX = stop.centerX;

            _downloadRateLabel.text = [NSString stringWithFormat:@"%@:%.1f%%",NSLocalizedString(@"DownloadFailed",""),_downloadResource.downloadProcess];
        }
        
        
        _progress = [[SYProgress alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 2) BgViewBgColor:FCStyle.borderColor BgViewBorderColor:FCStyle.borderColor ProgressViewColor:FCStyle.accent];

        _progress.top = _downloadRateLabel.bottom + 5;
        _progress.progress = _downloadResource.downloadProcess / 100;
        [self.contentView addSubview:_progress];
    }
    
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

    if(hours == 0) {
        return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];

    } else {
        return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
    }
    
}


@end
