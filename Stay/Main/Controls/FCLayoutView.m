//
//  FCLayoutView.m
//  FastClip-iOS
//
//  Created by ris on 2022/2/7.
//

#import "FCLayoutView.h"
#import "FCLayoutImageView.h"
#import "FCLayoutLabel.h"
#import "UIView+Layout.h"
#import "FCLayoutSwitch.h"
#import "FCLayoutTextField.h"

@interface FCLayoutView()

@end

@implementation FCLayoutView


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
    for (UIView *view in self.subviews){
        if ([view isKindOfClass:[FCLayoutView class]]){
            FCLayoutView *fcView = (FCLayoutView *)view;
            if (fcView.fcLayout){
                fcView.fcLayout(fcView, self);
            }
        }
        else if ([view isKindOfClass:[FCLayoutImageView class]]){
            FCLayoutImageView *fcImageView = (FCLayoutImageView *)view;
            if (fcImageView.fcLayout){
                fcImageView.fcLayout(fcImageView, self);
            }
        }
        else if ([view isKindOfClass:[FCLayoutLabel class]]){
            FCLayoutLabel *fcLabel = (FCLayoutLabel *)view;
            if (fcLabel.fcLayout){
                fcLabel.fcLayout(fcLabel, self);
            }
        }
        else if ([view isKindOfClass:[FCLayoutSwitch class]]){
            FCLayoutSwitch *fcSwitch = (FCLayoutSwitch *)view;
            if (fcSwitch.fcLayout){
                fcSwitch.fcLayout(fcSwitch, self);
            }
        }
        else if ([view isKindOfClass:[FCLayoutTextField class]]){
            FCLayoutTextField *fcTextField = (FCLayoutTextField *)view;
            if (fcTextField.fcLayout){
                fcTextField.fcLayout(fcTextField, self);
            }
        }
    }
}


@end
