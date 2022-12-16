//
//  FCLayoutLabel.m
//  FastClip-iOS
//
//  Created by ris on 2022/12/2.
//

#import "FCLayoutLabel.h"
#import "FCLayoutView.h"
#import "FCLayoutImageView.h"
#import "UIView+Layout.h"
#import "FCLayoutSwitch.h"

@implementation FCLayoutLabel

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

