//
//  FCLinkButton.m
//  Stay
//
//  Created by ris on 2023/6/13.
//

#import "FCLinkButton.h"

@interface FCLinkButton()

@property (nonatomic, strong) UIView *line;

@end

@implementation FCLinkButton

- (instancetype)init{
    if (self = [super init]){
        self.backgroundColor = UIColor.clearColor;
        [self line];
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(tapGesture:)];
        
        [self addGestureRecognizer:gesture];
    }
    
    return self;
}

- (UIView *)line{
    if (nil == _line){
        _line = [[UIView alloc] init];
        _line.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_line];
        
        [NSLayoutConstraint activateConstraints:@[
            [_line.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [_line.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [_line.heightAnchor constraintEqualToConstant:1],
            [_line.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-1]
        ]];
    }
    
    return _line;
}

- (void)setAttributedTitle:(NSAttributedString *)attributedTitle{
    _attributedTitle = attributedTitle;
    self.attributedText = _attributedTitle;
    _line.backgroundColor = [_attributedTitle attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:nil];
}

- (void)tapGesture:(UIGestureRecognizer *)gesture{
    if (self.action){
        self.action();
    }
}

@end
