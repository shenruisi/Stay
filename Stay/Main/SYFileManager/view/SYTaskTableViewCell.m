//
//  SYTaskTableViewCell.m
//  Stay
//
//  Created by zly on 2023/4/18.
//

#import "SYTaskTableViewCell.h"
#import "FCStyle.h"
#import "UIImageView+WebCache.h"
#import <objc/runtime.h>
#import "ImageHelper.h"
#import "FCShared.h"
#import "ColorHelper.h"
#import "DeviceHelper.h"

@interface SmoothProcessView : FCView

@property (nonatomic, strong) UIColor *progressTintColor;
@property (nonatomic, strong) UIColor *trackTintColor;

@property (nonatomic, strong) UIView *movingView;
@property (nonatomic, assign) CGFloat progress;
@end

@implementation SmoothProcessView

- (instancetype)init{
    if (self = [super init]){
        [self movingView];
    }
    
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self.movingView setFrame:CGRectMake(0, 0, self.width * self.progress, self.height)];
}

- (void)setProgress:(CGFloat)progress{
    if (progress <= _progress) return;
    CGFloat lastProgress = _progress;
    _progress = progress;
    [self.movingView setFrame:CGRectMake(0, 0, self.width * lastProgress, self.height)];
    [UIView animateWithDuration:0.5 animations:^{
        [self.movingView setFrame:CGRectMake(0, 0, self.width * progress, self.height)];
    }];
}

- (UIView *)movingView{
    if (nil == _movingView){
        _movingView = [[UIView alloc] init];
        [self addSubview:_movingView];
    }
    
    return _movingView;
}

- (void)setTrackTintColor:(UIColor *)trackTintColor{
    self.backgroundColor = trackTintColor;
}

- (void)setProgressTintColor:(UIColor *)progressTintColor{
    self.movingView.backgroundColor = progressTintColor;
}

@end

@interface SYTaskTableViewCell()

@property (nonatomic, strong) NSMutableArray *speedArray;
@property (nonatomic, strong) SmoothProcessView *progressView;

@end
@implementation SYTaskTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self progressView];
        [self avatorView];
        [self hostLabel];
        [self titleLabel];
        [self stopBtn];
        [self stopLabel];
        [self saveToLabel];
        [self docImageView];
        [self docNameLabel];
        [self downloadRateLabel];
        [self downloadSpeedLabel];
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
    objc_setAssociatedObject(self.stopBtn , @"resource", _downloadResource, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if(self.downloadResource.downloadProcess > 0) {
        self.progress = _downloadResource.downloadProcess / 100;
    }
    
    
    [_stopBtn removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    
    
    if(_downloadResource.status == 0) {
        _downloadSpeedLabel.hidden = NO;
        _downloadRateLabel.text = [NSString stringWithFormat:@"%@:%.1f%%",NSLocalizedString(@"Downloading",""),_downloadResource.downloadProcess];
        [_stopBtn setImage:[ImageHelper sfNamed:@"pause.circle.fill" font:FCStyle.body color:FCStyle.accent] forState:UIControlStateNormal];
        [_stopBtn addTarget:self.controller action:@selector(stopDownload:) forControlEvents:UIControlEventTouchUpInside];
        _stopLabel.text = NSLocalizedString(@"STOP","");
        [NSLayoutConstraint deactivateConstraints:self.speedArray];
        [self.speedArray removeAllObjects];
        [self.speedArray addObject:[_downloadRateLabel.rightAnchor constraintEqualToAnchor:self.downloadSpeedLabel.leftAnchor constant:-5]];
        [NSLayoutConstraint activateConstraints:self.speedArray];
    } else if(_downloadResource.status == 1) {
        [_stopBtn setImage:[ImageHelper sfNamed:@"play.circle.fill" font:FCStyle.body color:FCStyle.accent] forState:UIControlStateNormal];
        [_stopBtn addTarget:self.controller action:@selector(continueDownload:) forControlEvents:UIControlEventTouchUpInside];
        _stopLabel.text = NSLocalizedString(@"CONTINUE","");
        _downloadRateLabel.text = [NSString stringWithFormat:@"%@:%.1f%%",NSLocalizedString(@"StopDownload",""),_downloadResource.downloadProcess];
        
        
        [NSLayoutConstraint deactivateConstraints:self.speedArray];
        [self.speedArray removeAllObjects];
        [self.speedArray addObject:[_downloadRateLabel.trailingAnchor constraintEqualToAnchor:self.fcContentView.trailingAnchor constant:-10]];
        [NSLayoutConstraint activateConstraints:self.speedArray];
    } else if(_downloadResource.status == 3) {
        [_stopBtn setImage:[ImageHelper sfNamed:@"goforward" font:FCStyle.body color:FCStyle.accent] forState:UIControlStateNormal];
        [_stopBtn addTarget:self.controller action:@selector(retryDownload:) forControlEvents:UIControlEventTouchUpInside];
        _stopLabel.text = NSLocalizedString(@"RETRY","");
        _downloadRateLabel.text = [NSString stringWithFormat:@"%@:%.1f%%",NSLocalizedString(@"DownloadFailed",""),_downloadResource.downloadProcess];
        [NSLayoutConstraint deactivateConstraints:self.speedArray];
        [self.speedArray removeAllObjects];
        [self.speedArray addObject:[_downloadRateLabel.trailingAnchor constraintEqualToAnchor:self.fcContentView.trailingAnchor constant:-10]];
        [NSLayoutConstraint activateConstraints:self.speedArray];
    } else if(_downloadResource.status == 4) {
        [_stopBtn setImage:[ImageHelper sfNamed:@"pause.circle.fill" font:FCStyle.body color:FCStyle.accent] forState:UIControlStateNormal];
        [_stopBtn addTarget:self.controller action:@selector(stopDownload:) forControlEvents:UIControlEventTouchUpInside];
        _downloadRateLabel.text = NSLocalizedString(@"Transcoding","");
        [NSLayoutConstraint deactivateConstraints:self.speedArray];
        [self.speedArray removeAllObjects];
        [self.speedArray addObject:[_downloadRateLabel.rightAnchor constraintEqualToAnchor:self.downloadSpeedLabel.leftAnchor constant:-5]];
        [NSLayoutConstraint activateConstraints:self.speedArray];
    }  else if (_downloadResource.status == 5) {
        [_stopBtn setImage:[ImageHelper sfNamed:@"goforward" font:FCStyle.body color:FCStyle.accent] forState:UIControlStateNormal];
        [_stopBtn addTarget:self.controller action:@selector(retryDownload:) forControlEvents:UIControlEventTouchUpInside];
        _stopLabel.text = NSLocalizedString(@"RETRY","");
        _downloadRateLabel.text = NSLocalizedString(@"TranscodingFailed","");
        [NSLayoutConstraint deactivateConstraints:self.speedArray];
        [self.speedArray removeAllObjects];
        [self.speedArray addObject:[_downloadRateLabel.trailingAnchor constraintEqualToAnchor:self.fcContentView.trailingAnchor constant:-10]];
        [NSLayoutConstraint activateConstraints:self.speedArray];
        
    } else if (_downloadResource.status == 6){
        [_stopBtn setImage:[ImageHelper sfNamed:@"goforward" font:FCStyle.body color:FCStyle.accent] forState:UIControlStateNormal];
        [_stopBtn addTarget:self.controller action:@selector(retryDownload:) forControlEvents:UIControlEventTouchUpInside];
        _stopLabel.text = NSLocalizedString(@"RETRY","");
        _downloadRateLabel.text = NSLocalizedString(@"NOSPACEFAILED","");
        [NSLayoutConstraint deactivateConstraints:self.speedArray];
        [self.speedArray removeAllObjects];
        [self.speedArray addObject:[_downloadRateLabel.trailingAnchor constraintEqualToAnchor:self.fcContentView.trailingAnchor constant:-10]];
        [NSLayoutConstraint activateConstraints:self.speedArray];
    }
    
    
    if ([self.downloadResource.firstPath isEqualToString:FILEUUID]) {
        [_docImageView setImage:[ImageHelper sfNamed:@"folder.fill" font:[UIFont systemFontOfSize:16] color: RGB(146, 209, 243)]];
        NSArray *componets = [self.downloadResource.allPath pathComponents];
        _docNameLabel.text = [componets objectAtIndex:(componets.count - 2)];
    } else  {
        FCTab *fCTab = [[FCShared tabManager] tabOfUUID:self.downloadResource.firstPath];
        [_docImageView setImage:[ImageHelper sfNamed:@"folder" font:[UIFont systemFontOfSize:16] color: [ColorHelper colorFromHex:fCTab.config.hexColor]]];
        _docNameLabel.text = fCTab.config.name;
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


- (UIButton *)stopBtn {
    if(_stopBtn == nil) {
        _stopBtn = [[UIButton alloc] init];
        _stopBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [self.fcContentView addSubview:_stopBtn];

        [NSLayoutConstraint activateConstraints:@[
            [_stopBtn.trailingAnchor constraintEqualToAnchor:self.fcContentView.trailingAnchor constant:-24.5],
            [_stopBtn.topAnchor constraintEqualToAnchor:self.fcContentView.topAnchor constant:44],
            [_stopBtn.widthAnchor constraintEqualToConstant:24],
            [_stopBtn.heightAnchor constraintEqualToConstant:24],
        ]];
    }
    return _stopBtn;
}

- (UILabel *)stopLabel {
    if(_stopLabel == nil) {
        _stopLabel = [[UILabel alloc] init];
        _stopLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _stopLabel.tintColor = FCStyle.accent;
        _stopLabel.font = FCStyle.footnoteBold;
        _stopLabel.textColor = FCStyle.accent;
        [self.fcContentView addSubview:_stopLabel];

        [NSLayoutConstraint activateConstraints:@[
            [_stopLabel.centerXAnchor constraintEqualToAnchor:self.stopBtn.centerXAnchor],
            [_stopLabel.topAnchor constraintEqualToAnchor:self.stopBtn.bottomAnchor constant:5],
            [_stopLabel.heightAnchor constraintEqualToConstant:18],
        ]];
        
    }
    return _stopLabel;
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
//            [_titleLabel.heightAnchor constraintEqualToConstant:15],
            [_titleLabel.leftAnchor constraintEqualToAnchor:self.avatorView.rightAnchor constant:10],
            [_titleLabel.rightAnchor constraintEqualToAnchor:self.stopBtn.leftAnchor constant:-11],
            [_titleLabel.topAnchor constraintEqualToAnchor:self.hostLabel.bottomAnchor constant:9],
        ]];
    }
    
    return _titleLabel;
}

- (UILabel *)saveToLabel {
    if(_saveToLabel == nil) {
        _saveToLabel = [[UILabel alloc] init];
        _saveToLabel.text = NSLocalizedString(@"SaveTo","");
        _saveToLabel.textColor = FCStyle.titleGrayColor;
        _saveToLabel.font = FCStyle.footnote;
        _saveToLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.fcContentView addSubview:_saveToLabel];
        [NSLayoutConstraint activateConstraints:@[
            [_saveToLabel.leadingAnchor constraintEqualToAnchor:self.fcContentView.leadingAnchor constant:10],
            [_saveToLabel.bottomAnchor constraintEqualToAnchor:self.fcContentView.bottomAnchor constant:-9],
        ]];

    }
    
    return _saveToLabel;
}

- (UIImageView *)docImageView {
    if(_docImageView == nil) {
        _docImageView = [[UIImageView alloc] init];
        _docImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _docImageView.contentMode = UIViewContentModeBottom;
        [self.fcContentView addSubview:_docImageView];
        [NSLayoutConstraint activateConstraints:@[
            [_docImageView.leftAnchor constraintEqualToAnchor:self.saveToLabel.rightAnchor constant:6],
            [_docImageView.centerYAnchor constraintEqualToAnchor:self.saveToLabel.centerYAnchor],
            [_docImageView.widthAnchor constraintEqualToConstant:22],
            [_docImageView.heightAnchor constraintEqualToConstant:16],
        ]];

    }
    
    return _docImageView;
}

- (UILabel *)docNameLabel {
    if(_docNameLabel == nil) {
        _docNameLabel = [[UILabel alloc] init];
        _docNameLabel.textColor = FCStyle.fcBlack;
        _docNameLabel.font = FCStyle.footnote;
        _docNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.fcContentView addSubview:_docNameLabel];
        [NSLayoutConstraint activateConstraints:@[
            [_docNameLabel.leftAnchor constraintEqualToAnchor:self.docImageView.rightAnchor constant:4],
            [_docNameLabel.centerYAnchor constraintEqualToAnchor:self.saveToLabel.centerYAnchor],
        ]];
    
    }
    return _docNameLabel;
}

- (UILabel *)downloadRateLabel {
    if(_downloadRateLabel == nil) {
        _downloadRateLabel = [[UILabel alloc] init];
        _downloadRateLabel.font = FCStyle.footnoteBold;
        _downloadRateLabel.textColor = FCStyle.accent;
        _downloadRateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.fcContentView addSubview:_downloadRateLabel];
        
        [self.speedArray addObject:[_downloadRateLabel.rightAnchor constraintEqualToAnchor:self.downloadSpeedLabel.leftAnchor constant:-5]];
        
        [NSLayoutConstraint activateConstraints:@[
            [_downloadRateLabel.centerYAnchor constraintEqualToAnchor:self.saveToLabel.centerYAnchor],
        ]];
        
        [NSLayoutConstraint activateConstraints:self.speedArray];
        
    }
    return _downloadRateLabel;
}

- (UILabel *)downloadSpeedLabel {
    if(_downloadSpeedLabel == nil) {
        _downloadSpeedLabel = [[UILabel alloc] init];
        
        _downloadSpeedLabel.font = FCStyle.footnote;
        _downloadSpeedLabel.textColor = FCStyle.titleGrayColor;
        _downloadSpeedLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.fcContentView addSubview:_downloadSpeedLabel];
        [NSLayoutConstraint activateConstraints:@[
            [_downloadSpeedLabel.trailingAnchor constraintEqualToAnchor:self.fcContentView.trailingAnchor constant:-10],
            [_downloadSpeedLabel.centerYAnchor constraintEqualToAnchor:self.saveToLabel.centerYAnchor],
        ]];
        
    }
    return _downloadSpeedLabel;
}

- (SmoothProcessView *)progressView {
    if(_progressView == nil) {
        _progressView = [[SmoothProcessView alloc] init];
        _progressView.progressTintColor = [FCStyle.accent colorWithAlphaComponent:0.1];
        _progressView.trackTintColor= [UIColor clearColor];
        _progressView.translatesAutoresizingMaskIntoConstraints = NO;
        _progressView.layer.cornerRadius = 10;
        _progressView.clipsToBounds = YES;
        [self.fcContentView addSubview:_progressView];
        [NSLayoutConstraint activateConstraints:@[
            [_progressView.leadingAnchor constraintEqualToAnchor:self.fcContentView.leadingAnchor],
            [_progressView.topAnchor constraintEqualToAnchor:self.fcContentView.topAnchor],
            [_progressView.heightAnchor constraintEqualToConstant:140],
            [_progressView.widthAnchor constraintEqualToAnchor:self.fcContentView.widthAnchor],

        ]];
    }
    return _progressView;
}

- (NSMutableArray *)speedArray {
    if(_speedArray == nil) {
        _speedArray = [NSMutableArray array];
    }
    
    return _speedArray;
    
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    self.progressView.progress = progress;
}
@end
