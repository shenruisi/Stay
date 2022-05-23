//
//  FCBlockView.m
//  FastClip-iOS
//
//  Created by ris on 2022/2/8.
//

#import "FCBlockView.h"

@implementation FCBlockView

- (instancetype)init{
    if (self = [super init]){
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
    }
    
    return self;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.delegate && [self.delegate respondsToSelector:@selector(touched)]){
        [self.delegate touched];
    }
}

@end
