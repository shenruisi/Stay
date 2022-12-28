//
//  SYVideoCellTableViewCell.h
//  Stay
//
//  Created by zly on 2022/12/28.
//

#import <UIKit/UIKit.h>
#import "DownloadResource.h"

NS_ASSUME_NONNULL_BEGIN

@interface SYVideoCellTableViewCell : UITableViewCell

@property(nonatomic,strong)DownloadResource *downloadResource;

@property(nonatomic,strong)UIViewController *controller;


- (void)reloadCell;
@end

NS_ASSUME_NONNULL_END
