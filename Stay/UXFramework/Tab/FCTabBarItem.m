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

- (instancetype)initWithDescriptor:(NSDictionary *)descriptor{
    if (self = [super init]){
        self.selectImage = descriptor[@"select"][@"image"];
        self.deselectImage = descriptor[@"deselect"][@"image"];
        self.offsetY = [descriptor[@"offsetY"] floatValue];
    }
    
    return self;
}

@end
