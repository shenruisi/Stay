//
//  SYTaskTableViewCell.h
//  Stay
//
//  Created by zly on 2023/4/18.
//

#import "FCTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface SYTaskTableViewCell<ElementType> : FCTableViewCell<ElementType>
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *hostLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *docNameLabel;
@property (nonatomic, strong) UILabel *fileNameLabel;
@property (nonatomic,strong) UILabel *downloadRateLabel;
//@property (nonatomic,strong) SYProgress *progress;
@property (nonatomic,strong) UILabel *downloadSpeedLabel;
@end

NS_ASSUME_NONNULL_END
