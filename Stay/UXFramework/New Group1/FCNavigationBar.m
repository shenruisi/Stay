//
//  FCNavigationBar.m
//  Stay
//
//  Created by ris on 2023/3/14.
//

#import "FCNavigationBar.h"

@interface FCNavigationBar()

@end

@implementation FCNavigationBar

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
//    CGRect frame = self.frame;
//    frame.size = [self sizeThatFits:self.bounds.size];
//    self.frame = frame;
}

//- (CGSize)sizeThatFits:(CGSize)size{
//    UIEdgeInsets safeAreaInsets = self.superview.safeAreaInsets;
//    CGSize newSize = CGSizeMake(self.superview.bounds.size.width, 64);
//    return newSize;
//}

@end
