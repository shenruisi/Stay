//
//  BrowseDetailTableViewCell.h
//  Stay
//
//  Created by zly on 2022/9/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BrowseDetailTableViewCell : UITableViewCell

@property (nonatomic, strong) NSDictionary *entity;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) UIViewController *controller;

@end

NS_ASSUME_NONNULL_END
