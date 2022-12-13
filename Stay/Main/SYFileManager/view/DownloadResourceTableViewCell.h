//
//  DownloadResourceTableViewCell.h
//  Stay
//
//  Created by zly on 2022/12/5.
//

#import <UIKit/UIKit.h>
#import "DownloadResource.h"
NS_ASSUME_NONNULL_BEGIN

@interface DownloadResourceTableViewCell : UITableViewCell

@property(nonatomic,strong)DownloadResource *downloadResource;

@property(nonatomic,strong)UIViewController *controller;



@end

NS_ASSUME_NONNULL_END
