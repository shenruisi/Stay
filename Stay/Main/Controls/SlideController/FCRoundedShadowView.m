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
@end

@implementation FCRoundedShadowView

- (instancetype)initWithRadius:(CGFloat)radius{
    if (self = [super init]){
        self.radius = radius;
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

- (instancetype)init{
    if (self = [super init]){
        [self containerView];
        self.containerView.layer.cornerRadius = 0;
        self.containerView.layer.borderWidth = 0;
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self.containerView setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
}

- (FCView *)containerView{
    if (nil == _containerView){
        _containerView = [[FCView alloc] init];
        _containerView.backgroundColor = FCStyle.popup;
        _containerView.layer.cornerRadius = MAX(10,self.radius);
        _containerView.layer.borderColor = FCStyle.fcSeparator.CGColor;
        _containerView.layer.borderWidth = 1;
        _containerView.clipsToBounds = YES;
        [self addSubview:_containerView];
    }
    
    return _containerView;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    self.containerView.layer.borderColor = FCStyle.fcSeparator.CGColor;
}

@end
