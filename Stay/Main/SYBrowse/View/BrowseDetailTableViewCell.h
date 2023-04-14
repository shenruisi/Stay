//
//  BrowseDetailTableViewCell.h
//  Stay
//
//  Created by zly on 2022/9/14.
//

#import <UIKit/UIKit.h>
#import "FCTableViewCell.h"
NS_ASSUME_NONNULL_BEGIN

@interface BrowseDetailTableViewCell<ElementType> : FCTableViewCell<ElementType>

@property (nonatomic, strong) NSDictionary *entity;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) UIViewController *controller;
@property (nonatomic, strong) NSString *selectedUrl;

@end

NS_ASSUME_NONNULL_END
