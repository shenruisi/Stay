//
//  HomeDetailCell.h
//  Stay
//
//  Created by zly on 2022/9/14.
//

#import <UIKit/UIKit.h>
#import "Tampermonkey.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeDetailCell : UITableViewCell

@property(nonatomic, strong) UserScript *scrpit;
@property(nonatomic, strong) UIViewController *controller;

@end

NS_ASSUME_NONNULL_END
