//
//  NavigationBarIconView.m
//  Stay
//
//  Created by ris on 2022/10/20.
//

#import "NavigationBarIconView.h"
#import "ImageHelper.h"
#import "FCStyle.h"

@implementation NavigationBarIconView

+ (instancetype)ofSFName:(NSString *)sfName{
#ifdef Mac
    NavigationBarIconView *imageView = [[NavigationBarIconView alloc] initWithFrame:CGRectMake(0, 0, 25, 18)];
#else
    NavigationBarIconView *imageView = [[NavigationBarIconView alloc] initWithFrame:CGRectMake(0, 0, 30, 22)];
#endif
    imageView.contentMode = UIViewContentModeCenter;
    [imageView setImage: [ImageHelper sfNamed:sfName
                                         font:FCStyle.sfNavigationBar
                                        color:FCStyle.fcMacIcon]];
    return imageView;
}

@end
