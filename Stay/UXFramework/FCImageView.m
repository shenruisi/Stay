//
//  FCImageView.m
//  Stay
//
//  Created by ris on 2023/5/31.
//

#import "FCImageView.h"
#import "FCStyle.h"
#import "UIColor+Convert.h"

@interface FCImageView(){
    CGFloat _lastProcess;
}

@property (nonatomic, strong) UIView *progressMovingView;
@property (nonatomic, strong) UIView *progressBackgroundView;
@property (nonatomic, strong) NSLayoutConstraint *progressMovingWidthConstraint;
@end

@implementation FCImageView

- (void)setProgress:(CGFloat)progress{
    _progress = progress;
    [self progressBackgroundView];
    [self progressMovingView];
    self.progressMovingWidthConstraint.constant = self.progressBackgroundView.width * progress;
}

- (void)clearProcess{
    if (_progressBackgroundView){
        [self.progressBackgroundView removeFromSuperview];
        self.progressBackgroundView = nil;
    }
    
    if (_progressMovingView){
        [self.progressMovingView removeFromSuperview];
        self.progressMovingView = nil;
    }
   
}

- (UIView *)progressBackgroundView{
    if (nil == _progressBackgroundView){
        _progressBackgroundView = [[UIView alloc] init];
        _progressBackgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        _progressBackgroundView.layer.cornerRadius = 3;
        _progressBackgroundView.backgroundColor = FCStyle.background;
        [self addSubview:_progressBackgroundView];
        
        [NSLayoutConstraint activateConstraints:@[
            [_progressBackgroundView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [_progressBackgroundView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
            [_progressBackgroundView.heightAnchor constraintEqualToConstant:6],
            [_progressBackgroundView.widthAnchor constraintEqualToConstant:90]
        ]];
    }
    
    return _progressBackgroundView;
}

- (UIView *)progressMovingView{
    if (nil == _progressMovingView){
        _progressMovingView = [[UIView alloc] init];
        _progressMovingView.translatesAutoresizingMaskIntoConstraints = NO;
        _progressMovingView.layer.cornerRadius = 3;
        _progressMovingView.backgroundColor = [[FCStyle.accent colorWithAlphaComponent:0.1] rgba2rgb:FCStyle.background];
        [self addSubview:_progressMovingView];
        self.progressMovingWidthConstraint = [_progressMovingView.widthAnchor constraintEqualToConstant:0];
        [NSLayoutConstraint activateConstraints:@[
            [_progressMovingView.leadingAnchor constraintEqualToAnchor:self.progressBackgroundView.leadingAnchor],
            [_progressMovingView.topAnchor constraintEqualToAnchor:self.progressBackgroundView.topAnchor],
            [_progressMovingView.heightAnchor constraintEqualToConstant:6],
            self.progressMovingWidthConstraint
        ]];
    }
    
    return _progressMovingView;
}

@end
