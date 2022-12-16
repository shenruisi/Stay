//
//  UIView+Layout.m
//  FastClip-iOS
//
//  Created by ris on 2022/11/30.
//

#import "UIView+Layout.h"

@implementation UIView(Layout)

- (CGFloat)width{
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width{
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              width,
                              self.frame.size.height)];
}

- (CGFloat)height{
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height{
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              self.frame.size.width,
                              height)];
}

- (CGFloat)bottom{
    return self.frame.origin.y + self.frame.size.height;
}

- (CGFloat)right{
    return self.frame.origin.x + self.frame.size.width;
}

- (CGFloat)left{
    return self.frame.origin.x;
}

- (CGFloat)top{
    return self.frame.origin.y;
}

@end
