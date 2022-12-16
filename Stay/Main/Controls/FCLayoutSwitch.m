//
//  FCLayoutSwitch.m
//  FastClip-iOS
//
//  Created by ris on 2022/12/8.
//

#import "FCLayoutSwitch.h"
#import "FCLayoutView.h"
#import "FCLayoutLabel.h"
#import "UIView+Layout.h"
#import "FCLayoutImageView.h"

@implementation FCLayoutSwitch

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
