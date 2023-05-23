//
//  FCRoundedShadowView.m
//  FastClip-iOS
//
//  Created by ris on 2022/2/9.
//

#import "FCRoundedShadowView.h"
#import "FCStyle.h"

@interface FCRoundedShadowView()

@property (nonatomic, strong) FCView *containerView;
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) CACornerMask cornerMask;
@end

@implementation FCRoundedShadowView

- (instancetype)initWithRadius:(CGFloat)radius{
    if (self = [super init]){
        self.radius = radius;
        self.cornerMask = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
        self.layer.backgroundColor = [UIColor clearColor].CGColor;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 1.0);
        self.layer.shadowOpacity = 0.2;
        self.layer.shadowRadius = MAX(10,self.radius);
        
        [self containerView];
        self.containerView.layer.cornerRadius = MAX(10,self.radius);
    }
    
    return self;
}

- (instancetype)initWithRadius:(CGFloat)radius
                    borderWith:(CGFloat)borderWith
                    cornerMask:(CACornerMask)cornerMask{
    if (self = [super init]){
        self.radius = radius;
        self.borderWidth = borderWith;
        self.cornerMask = cornerMask;
        self.layer.backgroundColor = [UIColor clearColor].CGColor;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 1.0);
        self.layer.shadowOpacity = 0.1;
        self.layer.shadowRadius = MAX(10,self.radius);
        [self containerView];
        self.containerView.layer.cornerRadius = MAX(10,self.radius);
    }
    
    return self;
}

- (instancetype)initWithNoShadowRadius:(CGFloat)radius
                            borderWith:(CGFloat)borderWith
                            cornerMask:(CACornerMask)cornerMask{
    if (self = [super init]){
        self.radius = radius;
        self.borderWidth = borderWith;
        self.cornerMask = cornerMask;
        [self containerView];
        self.containerView.layer.cornerRadius = MAX(10,self.radius);
    }
    
    return self;
}


- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    if (_containerView){
        [self.containerView setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    }
    
}

- (FCView *)containerView{
    if (nil == _containerView){
        _containerView = [[FCView alloc] init];
        _containerView.backgroundColor = FCStyle.popup;
        _containerView.layer.maskedCorners = self.cornerMask;
        _containerView.layer.cornerRadius = MAX(10,self.radius);
        _containerView.layer.borderColor = FCStyle.fcSeparator.CGColor;
        _containerView.layer.borderWidth = self.borderWidth;
        _containerView.clipsToBounds = YES;
        [self addSubview:_containerView];
    }
    
    return _containerView;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    self.containerView.layer.borderColor = FCStyle.fcSeparator.CGColor;
}

@end
