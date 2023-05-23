//
//  SYDownloadedViewCell.m
//  Stay
//
//  Created by zly on 2023/4/24.
//

#import "SYDownloadedViewCell.h"
#import "FCStyle.h"
#import "UIImageView+WebCache.h"
#import <objc/runtime.h>
#import "ImageHelper.h"
#import "FCShared.h"
#import "ColorHelper.h"
#import "DeviceHelper.h"

@implementation SYDownloadedViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self progressView];
        [self avatorView];
        [self hostLabel];
        [self titleLabel];
        [self savePhotoBtn];
        [self saveFileBtn];
        [self timeLab];
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

- (void)setDownloadResource:(DownloadResource *)downloadResource {
    _downloadResource = downloadResource;
    if(_downloadResource.icon != nil) {
        [self.avatorView setImage:[UIImage imageNamed:@"videoDefault"]];
        NSString *path_document = NSHomeDirectory();
        [_avatorView sd_setImageWithURL:([_downloadResource.icon hasPrefix:@"http"] ? [NSURL URLWithString:_downloadResource.icon] : [NSURL fileURLWithPath:[path_document stringByAppendingString:_downloadResource.icon]])  completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        }];
    } else {
        [_avatorView setImage:[UIImage imageNamed:@"videoDefault"]];
    }
    _hostLabel.text =  _downloadResource.host;
    _titleLabel.text = _downloadResource.title;
    if(self.downloadResource.downloadProcess > 0) {
        self.progress = _downloadResource.downloadProcess / 100;
    }
    if(self.downloadResource.protect) {
        _saveFileBtn.enabled = false;
        _savePhotoBtn.enabled = false;
        [_savePhotoBtn setImage:[ImageHelper sfNamed:@"square.and.arrow.down" font:FCStyle.body color:FCStyle.fcSeparator] forState:UIControlStateNormal];
        [_savePhotoBtn setTitleColor:FCStyle.fcSeparator forState:UIControlStateNormal];
        [_saveFileBtn setImage:[ImageHelper sfNamed:@"square.and.arrow.down" font:FCStyle.body color:FCStyle.fcSeparator] forState:UIControlStateNormal];
        [_saveFileBtn setTitleColor:FCStyle.fcSeparator forState:UIControlStateNormal];
        _savePhotoBtn.layer.borderColor = FCStyle.fcSeparator.CGColor;
        _saveFileBtn.layer.borderColor = FCStyle.fcSeparator.CGColor;
    } else {
        _saveFileBtn.enabled = true;
        _savePhotoBtn.enabled = true;
        [_savePhotoBtn setImage:[ImageHelper sfNamed:@"square.and.arrow.down" font:FCStyle.body color:FCStyle.accent] forState:UIControlStateNormal];
        [_savePhotoBtn setTitleColor:FCStyle.accent forState:UIControlStateNormal];
        [_saveFileBtn setImage:[ImageHelper sfNamed:@"square.and.arrow.down" font:FCStyle.body color:FCStyle.accent] forState:UIControlStateNormal];
        [_saveFileBtn setTitleColor:FCStyle.accent forState:UIControlStateNormal];
        _savePhotoBtn.layer.borderColor = FCStyle.accent.CGColor;
        _saveFileBtn.layer.borderColor = FCStyle.accent.CGColor;
    }
 

    objc_setAssociatedObject(_savePhotoBtn , @"resource", _downloadResource, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(_saveFileBtn , @"resource", _downloadResource, OBJC_ASSOCIATION_COPY_NONATOMIC);

    if(_downloadResource.videoDuration > 0) {
        _timeLab.hidden = NO;
        _progressView.hidden = NO;
        _progressView.progress = _downloadResource.watchProcess * 1.0 / _downloadResource.videoDuration;
        _timeLab.text = [self timeFormatted:_downloadResource.videoDuration];
    } else {
        _progressView.hidden = YES;
        _timeLab.hidden = YES;
    }
    
}

- (UIImageView *)avatorView {
    if(_avatorView == nil) {
        _avatorView = [[UIImageView alloc] init];
        _avatorView.layer.cornerRadius = 5;
        _avatorView.clipsToBounds = YES;
        _avatorView.contentMode = UIViewContentModeScaleAspectFit;
        _avatorView.layer.borderColor = FCStyle.borderColor.CGColor;
        _avatorView.layer.borderWidth = 0.5;
        _avatorView.backgroundColor = FCStyle.background;
        _avatorView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.fcContentView addSubview:_avatorView];

        [NSLayoutConstraint activateConstraints:@[
         
            [_avatorView.leadingAnchor constraintEqualToAnchor:self.fcContentView.leadingAnchor constant:10],
            [_avatorView.topAnchor constraintEqualToAnchor:self.fcContentView.topAnchor constant:9],
            [_avatorView.widthAnchor constraintEqualToConstant:160],
            [_avatorView.heightAnchor constraintEqualToConstant:90],
        ]];
        
        
    }
    
    return _avatorView;
}

- (UILabel *)hostLabel {
    if(_hostLabel == nil) {
        _hostLabel= [[UILabel alloc] init];
        _hostLabel.font = FCStyle.footnote;
        _hostLabel.textColor = FCStyle.titleGrayColor;
        _hostLabel.translatesAutoresizingMaskIntoConstraints = NO;

        [self.fcContentView addSubview:_hostLabel];
        [NSLayoutConstraint activateConstraints:@[
            [_hostLabel.heightAnchor constraintEqualToConstant:15],
            [_hostLabel.leftAnchor constraintEqualToAnchor:self.avatorView.rightAnchor constant:10],
            [_hostLabel.trailingAnchor constraintEqualToAnchor:self.fcContentView.trailingAnchor constant:-20],
            [_hostLabel.topAnchor constraintEqualToAnchor:self.fcContentView.topAnchor constant:9],
        ]];

    }
    return _hostLabel;
}


- (UILabel *)titleLabel {
    if(_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 2;
        _titleLabel.font = FCStyle.body;
        _titleLabel.text = _downloadResource.title;
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.fcContentView addSubview:_titleLabel];
        [NSLayoutConstraint activateConstraints:@[
            [_titleLabel.leftAnchor constraintEqualToAnchor:self.avatorView.rightAnchor constant:10],
            [_titleLabel.topAnchor constraintEqualToAnchor:self.hostLabel.bottomAnchor constant:9],
            [_titleLabel.trailingAnchor constraintEqualToAnchor:self.fcContentView.trailingAnchor constant: - 10]
        ]];
    }
    
    return _titleLabel;
}

- (UIProgressView *)progressView {
    if(_progressView == nil) {
        _progressView = [[UIProgressView alloc] init];
        _progressView.progressTintColor = FCStyle.accent;
        _progressView.progressViewStyle= UIProgressViewStyleBar;
        _progressView.trackTintColor= FCStyle.fcShadowLine;
        _progressView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.fcContentView addSubview:_progressView];
        [NSLayoutConstraint activateConstraints:@[
            [_progressView.leadingAnchor constraintEqualToAnchor:self.fcContentView.leadingAnchor],
            [_progressView.widthAnchor constraintEqualToAnchor:self.fcContentView.widthAnchor],
        ]];
        
      #ifdef FC_MAC
        [NSLayoutConstraint activateConstraints:@[
            [_progressView.leadingAnchor constraintEqualToAnchor:self.fcContentView.leadingAnchor],
            [_progressView.topAnchor constraintEqualToAnchor:self.avatorView.bottomAnchor constant:1],
            [_progressView.heightAnchor constraintEqualToConstant:2],
            [_progressView.widthAnchor constraintEqualToAnchor:self.fcContentView.widthAnchor],
        ]];
    #else
        [NSLayoutConstraint activateConstraints:@[
            [_progressView.leadingAnchor constraintEqualToAnchor:self.fcContentView.leadingAnchor],
            [_progressView.topAnchor constraintEqualToAnchor:self.avatorView.bottomAnchor constant:9],
            [_progressView.heightAnchor constraintEqualToConstant:2],
            [_progressView.widthAnchor constraintEqualToAnchor:self.fcContentView.widthAnchor],
        ]];
    #endif
    }
    return _progressView;
}


- (UIButton *)savePhotoBtn {
    if(_savePhotoBtn == nil) {
        _savePhotoBtn = [[UIButton alloc] init];
        [_savePhotoBtn setImage:[ImageHelper sfNamed:@"square.and.arrow.down" font:FCStyle.body color:FCStyle.accent] forState:UIControlStateNormal];
        [_savePhotoBtn setTitle:NSLocalizedString(@"SAVETOPHOTOS", @"") forState:UIControlStateNormal];
        [_savePhotoBtn setTitleColor:FCStyle.accent forState:UIControlStateNormal];
        _savePhotoBtn.titleLabel.font = FCStyle.footnoteBold;
//        [_savePhotoBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 8)];
//        _savePhotoBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, -8);
        _savePhotoBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 8);
        [_savePhotoBtn addTarget:self.controller action:@selector(saveToPhoto:) forControlEvents:UIControlEventTouchUpInside];
        _savePhotoBtn.translatesAutoresizingMaskIntoConstraints = NO;
        _savePhotoBtn.layer.borderColor = FCStyle.accent.CGColor;
        _savePhotoBtn.layer.borderWidth = 1;
        _savePhotoBtn.layer.cornerRadius = 8;
        [self.fcContentView addSubview:_savePhotoBtn];
        [NSLayoutConstraint activateConstraints:@[
            [_savePhotoBtn.topAnchor constraintEqualToAnchor:self.progressView.bottomAnchor constant:7],
            [_savePhotoBtn.heightAnchor constraintEqualToConstant:25],
            [_savePhotoBtn.widthAnchor constraintEqualToConstant:155],
            [_savePhotoBtn.leadingAnchor constraintEqualToAnchor:self.fcContentView.leadingAnchor constant:10],
        ]];
        
        
        if(FCDeviceTypeMac == DeviceHelper.type) {
            _savePhotoBtn.hidden = true;
        }
    }
    return _savePhotoBtn;
}

- (UIButton *)saveFileBtn {
    if(_saveFileBtn == nil) {
        _saveFileBtn = [[UIButton alloc] init];
        [_saveFileBtn setImage:[ImageHelper sfNamed:@"square.and.arrow.down" font:FCStyle.body color:FCStyle.accent] forState:UIControlStateNormal];
        [_saveFileBtn setTitle:NSLocalizedString(@"SAVETOFILES", @"") forState:UIControlStateNormal];
        [_saveFileBtn setTitleColor:FCStyle.accent forState:UIControlStateNormal];
        _saveFileBtn.titleLabel.font = FCStyle.footnoteBold;
        _saveFileBtn.layer.borderColor = FCStyle.accent.CGColor;
        _saveFileBtn.layer.borderWidth = 1;
        _saveFileBtn.layer.cornerRadius = 8;
        [_saveFileBtn addTarget:self.controller action:@selector(saveToFile:) forControlEvents:UIControlEventTouchUpInside];

//        [_savePhotoBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 8)];
        _saveFileBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 8);
        _saveFileBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [self.fcContentView addSubview:_saveFileBtn];
        if(FCDeviceTypeMac == DeviceHelper.type) {
            [NSLayoutConstraint activateConstraints:@[
                [_saveFileBtn.bottomAnchor constraintEqualToAnchor:self.fcContentView.bottomAnchor constant:-8],
                [_saveFileBtn.heightAnchor constraintEqualToConstant:25],
                [_saveFileBtn.leadingAnchor constraintEqualToAnchor:self.fcContentView.leadingAnchor constant:10],
                [_saveFileBtn.widthAnchor constraintEqualToConstant:147],

            ]];
        } else {
            [NSLayoutConstraint activateConstraints:@[
                [_saveFileBtn.bottomAnchor constraintEqualToAnchor:self.fcContentView.bottomAnchor constant:-8],
                [_saveFileBtn.heightAnchor constraintEqualToConstant:25],
                [_saveFileBtn.leftAnchor constraintEqualToAnchor:self.savePhotoBtn.rightAnchor constant:11],
                [_saveFileBtn.widthAnchor constraintEqualToConstant:147],

            ]];
        }
    }
    return _saveFileBtn;
}

- (UILabel *)timeLab {
    if(_timeLab == nil) {
        _timeLab = [[UILabel alloc] init];
        _timeLab.font = FCStyle.footnote;
        _timeLab.textColor = [UIColor whiteColor];
        _timeLab.backgroundColor = RGBA(0, 0, 0, 0.8);
        _timeLab.textAlignment = NSTextAlignmentCenter;
        _timeLab.layer.cornerRadius = 7;
        _timeLab.layer.masksToBounds = TRUE;
        _timeLab.translatesAutoresizingMaskIntoConstraints = NO;
        [self.fcContentView addSubview:_timeLab];

        [NSLayoutConstraint activateConstraints:@[
            [_timeLab.bottomAnchor constraintEqualToAnchor:self.avatorView.bottomAnchor constant:-5],
            [_timeLab.rightAnchor constraintEqualToAnchor:self.avatorView.rightAnchor constant:-5],
            [_timeLab.heightAnchor constraintEqualToConstant:15],
        ]];
    }
    return _timeLab;
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    self.progressView.progress = progress;
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
