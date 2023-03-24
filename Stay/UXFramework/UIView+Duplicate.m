//
//  UIView+Duplicate.m
//  Stay
//
//  Created by ris on 2023/3/24.
//

#import "UIView+Duplicate.h"

@implementation UIView(Duplicate)

- (UIView *)duplicate{
    NSData * tempArchive = [NSKeyedArchiver archivedDataWithRootObject:self];
    UIView *copied = [NSKeyedUnarchiver unarchiveObjectWithData:tempArchive];
    [[copied subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    copied.layer.maskedCorners = self.layer.maskedCorners;
    copied.layer.cornerRadius = self.layer.cornerRadius;
    copied.layer.borderColor = self.layer.borderColor;
    copied.layer.borderWidth = self.layer.borderWidth;
    return copied;
}
@end
