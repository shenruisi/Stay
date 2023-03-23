//
//  FCRoundedShadowView2.m
//  Stay
//
//  Created by ris on 2023/3/23.
//

#import "FCRoundedShadowView2.h"
#import "FCStyle.h"

@interface FCRoundedShadowView2()


@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) CACornerMask cornerMask;
@end

@implementation FCRoundedShadowView2

- (instancetype)initWithRadius:(CGFloat)radius
                    borderWith:(CGFloat)borderWith
                    cornerMask:(CACornerMask)cornerMask{
    if (self = [super init]){
        self.radius = radius;
        self.borderWidth = borderWith;
        self.cornerMask = cornerMask;
        self.layer.backgroundColor = [UIColor clearColor].CGColor;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 1);
        self.layer.shadowOpacity = 0.05;
        self.layer.shadowRadius = 7;
        [self containerView];
    }
    
    return self;
}


- (FCView *)containerView{
    if (nil == _containerView){
        _containerView = [[FCView alloc] init];
        _containerView.translatesAutoresizingMaskIntoConstraints = NO;
        _containerView.backgroundColor = FCStyle.popup;
        _containerView.layer.maskedCorners = self.cornerMask;
        _containerView.layer.cornerRadius = self.radius;
        _containerView.layer.borderColor = FCStyle.fcSeparator.CGColor;
        _containerView.layer.borderWidth = self.borderWidth;
        _containerView.clipsToBounds = YES;
        [self addSubview:_containerView];
        
        [NSLayoutConstraint activateConstraints:@[
            [_containerView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [_containerView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [_containerView.topAnchor constraintEqualToAnchor:self.topAnchor],
            [_containerView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
        ]];
    }
    
    return _containerView;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    self.containerView.layer.borderColor = FCStyle.fcSeparator.CGColor;
}

@end
