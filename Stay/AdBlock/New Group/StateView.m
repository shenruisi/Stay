//
//  StateView.m
//  Stay
//
//  Created by ris on 2023/3/24.
//

#import "StateView.h"
#import "FCStyle.h"

@interface StateView()

@property (nonatomic, strong) UIView *circleView;
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation StateView

- (instancetype)init{
    if (self = [super init]){
        [self circleView];
        [self titleLabel];
    }
    
    return self;
}



- (UIView *)fcDuplicate{
    UIView *copied = [super fcDuplicate];
    UIView *circleView = [self.circleView duplicate];
    circleView.translatesAutoresizingMaskIntoConstraints = NO;
    [copied addSubview:circleView];

    [NSLayoutConstraint activateConstraints:@[
        [circleView.leadingAnchor constraintEqualToAnchor:copied.leadingAnchor],
        [circleView.centerYAnchor constraintEqualToAnchor:copied.centerYAnchor],
        [circleView.widthAnchor constraintEqualToConstant:8],
        [circleView.heightAnchor constraintEqualToConstant:8]
    ]];

    UILabel *titleLabel = (UILabel *)[self.titleLabel duplicate];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [copied addSubview:titleLabel];

    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.leadingAnchor constraintEqualToAnchor:circleView.leadingAnchor constant:15],
        [titleLabel.centerYAnchor constraintEqualToAnchor:copied.centerYAnchor],
        [titleLabel.widthAnchor constraintEqualToConstant:150],
        [titleLabel.heightAnchor constraintEqualToConstant:FCStyle.footnoteBold.pointSize]
    ]];
    
    return copied;
}


- (void)setActive:(BOOL)active{
    [super setActive:active];
    self.titleLabel.text = active ? NSLocalizedString(@"Activated", @"") :  NSLocalizedString(@"Stopped", @"");
}

- (UIView *)circleView{
    if (nil == _circleView){
        _circleView = [[UIView alloc] init];
        _circleView.translatesAutoresizingMaskIntoConstraints = NO;
        _circleView.backgroundColor = FCStyle.accent;
        _circleView.layer.cornerRadius = 4;
        [self addSubview:_circleView];
        
        [NSLayoutConstraint activateConstraints:@[
            [_circleView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [_circleView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
            [_circleView.widthAnchor constraintEqualToConstant:8],
            [_circleView.heightAnchor constraintEqualToConstant:8]
        ]];
    }
    
    return _circleView;;
}

- (UILabel *)titleLabel{
    if (nil == _titleLabel){
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.textColor = FCStyle.accent;
        _titleLabel.font = FCStyle.footnoteBold;
        [self addSubview:_titleLabel];
        
        [NSLayoutConstraint activateConstraints:@[
            [_titleLabel.leadingAnchor constraintEqualToAnchor:self.circleView.leadingAnchor constant:15],
            [_titleLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
            [_titleLabel.widthAnchor constraintEqualToConstant:150],
            [_titleLabel.heightAnchor constraintEqualToConstant:FCStyle.footnoteBold.pointSize]
        ]];
    }
    
    return _titleLabel;
}

@end
