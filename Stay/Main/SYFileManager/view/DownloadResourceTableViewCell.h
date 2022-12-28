//
//  DownloadResourceTableViewCell.h
//  Stay
//
//  Created by zly on 2022/12/5.
//

#import <UIKit/UIKit.h>
#import "DownloadResource.h"
#import "SYProgress.h"

NS_ASSUME_NONNULL_BEGIN

@interface DownloadResourceTableViewCell : UITableViewCell

@property(nonatomic,strong)DownloadResource *downloadResource;

@property(nonatomic,strong)UIViewController *controller;

@property(nonatomic,strong)UILabel *downloadRateLabel;

@property(nonatomic,strong)SYProgress *progress;

@property(nonatomic,strong)UILabel *downloadSpeedLabel;


- (void)reloadCell;
@end

NS_ASSUME_NONNULL_END
