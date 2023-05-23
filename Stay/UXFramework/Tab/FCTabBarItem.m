//
//  FCTabBarItem.m
//  Stay
//
//  Created by ris on 2023/3/14.
//

#import "FCTabBarItem.h"

#import "FCTabBarItem.h"

@interface FCTabBarItem()

@property (nonatomic, strong) UIImage *selectImage;
@property (nonatomic, strong) UIImage *deselectImage;
@property (nonatomic, assign) CGFloat offsetY;
@end

@implementation FCTabBarItem

+ (instancetype)ofDescriptor:(NSDictionary *)descriptor{
    FCTabBarItem *item = [[FCTabBarItem alloc] init];
    item.selectImage = descriptor[@"select"][@"image"];
    item.deselectImage = descriptor[@"deselect"][@"image"];
    item.offsetY = [descriptor[@"offsetY"] floatValue];
    return item;
}

@end
