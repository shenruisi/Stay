//
//  SYTaskTableViewCell.h
//  Stay
//
//  Created by zly on 2023/4/18.
//

#import "FCTableViewCell.h"
#import "DownloadResource.h"
#import "SYProgress.h"
NS_ASSUME_NONNULL_BEGIN

@interface SYTaskTableViewCell<ElementType> : FCTableViewCell<ElementType>
@property (nonatomic, strong) UIImageView *avatorView;
@property (nonatomic, strong) UILabel *hostLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *docNameLabel;
@property (nonatomic, strong) UILabel *fileNameLabel;
@property (nonatomic, strong) UILabel *downloadRateLabel;
@property (nonatomic, strong) UILabel *downloadSpeedLabel;
@property (nonatomic, strong) DownloadResource *downloadResource;
@property (nonatomic, strong) UIViewController *controller;
@property (nonatomic, strong) UIButton *stopBtn;
@property (nonatomic, strong) UILabel *stopLabel;
@property (nonatomic, strong) UILabel *saveToLabel;
@property (nonatomic, strong) UIImageView *docImageView;
//@property (nonatomic, strong) SYProgress *progress;

@property (nonatomic ,assign) CGFloat progress;

@end

NS_ASSUME_NONNULL_END
