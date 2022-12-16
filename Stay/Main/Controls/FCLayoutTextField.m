//
//  FCLayoutTextField.m
//  FastClip-iOS
//
//  Created by ris on 2022/12/12.
//

#import "FCLayoutTextField.h"

@implementation FCLayoutTextField

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    if (self.fcLayout){
        self.fcLayout(self, newSuperview);
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (self.fcLayout && self.layoutSelfWhenLayoutSubviews){
        self.fcLayout(self, self.superview);
    }
}

@end
