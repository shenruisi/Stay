//
//  SYDownloadedViewCell.h
//  Stay
//
//  Created by zly on 2023/4/24.
//

#import "FCTableViewCell.h"
#import "DownloadResource.h"

NS_ASSUME_NONNULL_BEGIN

@interface SYDownloadedViewCell : FCTableViewCell
@property (nonatomic, strong) UIImageView *avatorView;
@property (nonatomic, strong) UILabel *hostLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *savePhotoBtn;
@property (nonatomic, strong) UIButton *saveFileBtn;
@property (nonatomic, strong) DownloadResource *downloadResource;
@property (nonatomic, strong) UIViewController *controller;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, strong) UILabel *timeLab;
@property (nonatomic, strong) UILabel *qualityLabel;

@end

NS_ASSUME_NONNULL_END
