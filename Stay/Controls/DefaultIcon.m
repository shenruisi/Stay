//
//  DefaultIcon.m
//  Stay
//
//  Created by ris on 2023/5/6.
//

#import "DefaultIcon.h"
#import "FCStyle.h"

@implementation DefaultIcon

+ (UIImage *)iconWithTitle:(NSString *)title size:(CGSize)size{
    NSString *firstChar = [self getFirstChar:title];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = label.bounds;
    NSArray<UIColor *> *colors = FCStyle.accentGradient;
    gradientLayer.colors = @[(id)colors[0].CGColor, (id)colors[1].CGColor];
//    [label.layer insertSublayer:gradientLayer atIndex:0];
    label.font = [UIFont boldSystemFontOfSize:size.width/2.5];
    label.textColor = FCStyle.fcSecondaryBlack;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = firstChar;
    
    UIView *view = [[UIView alloc] initWithFrame:label.frame];
    [view.layer insertSublayer:gradientLayer atIndex:0];
    [view addSubview:label];
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (NSString *)getFirstChar:(NSString *)title{
    NSCharacterSet *symbolSet = [NSCharacterSet symbolCharacterSet];
    for (int i = 0; i < title.length; i++){
        NSString *oneChar = [title substringWithRange:NSMakeRange(i, 1)];
        BOOL isCharSymbol = [symbolSet characterIsMember:[oneChar characterAtIndex:0]];
        if (!isCharSymbol){
            return oneChar;
        }
    }
    
    return nil;
}

@end
