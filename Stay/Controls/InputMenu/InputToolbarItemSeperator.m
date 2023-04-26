//
//  InputToolbarItemSeperator.m
//  Stay
//
//  Created by ris on 2023/4/26.
//

#import "InputToolbarItemSeperator.h"
#import "FCStyle.h"

@interface InputToolbarItemSeperator()

@property (nonatomic, strong) UIView *line;
@end

@implementation InputToolbarItemSeperator

- (instancetype)initWithElement:(InputToolbarItemElement *)element{
    if (self = [super init]){
        self.fillSuperView = YES;
        self.element = element;
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    return self;
}

- (void)didMoveToSuperview{
    [super didMoveToSuperview];
    if (self && self.superview && self.fillSuperView){
        [NSLayoutConstraint activateConstraints:@[
            [self.leadingAnchor constraintEqualToAnchor:self.superview.leadingAnchor],
            [self.trailingAnchor constraintEqualToAnchor:self.superview.trailingAnchor],
            [self.topAnchor constraintEqualToAnchor:self.superview.topAnchor],
            [self.bottomAnchor constraintEqualToAnchor:self.superview.bottomAnchor]
        ]];
    }
    
    [self line];
}


- (UIView *)line{
    if (nil == _line){
        _line = [[UIView alloc] init];
        _line.translatesAutoresizingMaskIntoConstraints = NO;
        _line.backgroundColor = FCStyle.fcSeparator;
        [self addSubview:_line];
        
        [NSLayoutConstraint activateConstraints:@[
            [_line.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [_line.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [_line.topAnchor constraintEqualToAnchor:self.topAnchor],
            [_line.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        ]];
    }
    
    return _line;
}
@end
