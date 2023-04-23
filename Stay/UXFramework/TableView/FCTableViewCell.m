//
//  FCTableViewCell.m
//  Stay
//
//  Created by ris on 2023/3/23.
//

#import "FCTableViewCell.h"
#import "FCStyle.h"
#import "UIView+Duplicate.h"

@interface FCTableViewCell()

@property (nonatomic, strong) FCRoundedShadowView2 *fcContentView;
@property (nonatomic, strong) UIView *tapEffectView;
@property (nonatomic, strong) CAShapeLayer *maskLayer;
@end

@implementation FCTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self fcContentView];
        [self tapEffectView];
        self.backgroundColor = [UIColor clearColor];
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        [self configGestureRecognizer];
    }
    
    return self;
}

- (void)configGestureRecognizer{
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognizer:)];
    tapRecognizer.numberOfTapsRequired = 1;
    [self.fcContentView addGestureRecognizer:tapRecognizer];
    
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapRecognizer:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    [self.fcContentView addGestureRecognizer:doubleTapRecognizer];
    
    [tapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
}

- (void)tapRecognizer:(UITapGestureRecognizer *)recognizer{
    CGPoint location = [recognizer locationInView:self.fcContentView];
    [self _effect:location];
    [self tap:location];
}

- (void)doubleTapRecognizer:(UITapGestureRecognizer *)recognizer{
    CGPoint location = [recognizer locationInView:self.fcContentView];
    [self _effect:location];
    [self doubleTap:location];
}


- (void)_effect:(CGPoint)location{
    self.tapEffectView.alpha = 1;
    [self.tapEffectView setFrame:CGRectMake(location.x, location.y, 0, 0)];
    self.tapEffectView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    self.tapEffectView.layer.cornerRadius = 0;
    CGFloat radius =  MAX((self.size.width - location.x),location.x);
    [UIView animateWithDuration:0.3
                     animations:^{
        [self.tapEffectView setFrame:CGRectMake(location.x - radius, location.y - radius, radius * 2, radius * 2)];
        self.tapEffectView.layer.cornerRadius = radius;
    } completion:^(BOOL finished) {
        self.tapEffectView.alpha = 0;
    }];
}

- (void)setElement:(id)element{
    _element = element;
    [self buildWithElement:element];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (FCRoundedShadowView2 *)fcContentView{
    if (nil == _fcContentView){
        _fcContentView = [[FCRoundedShadowView2 alloc] initWithRadius:10
                                                           borderWith:1
                                                           cornerMask:kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner];
        
        _fcContentView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_fcContentView];
        
        [NSLayoutConstraint activateConstraints:@[
            [_fcContentView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:[FCTableViewCell contentInset].left],
            [_fcContentView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-[FCTableViewCell contentInset].right],
            [_fcContentView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:[FCTableViewCell contentInset].top],
            [_fcContentView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-[FCTableViewCell contentInset].bottom]
        ]];
    }
    
    return _fcContentView;
}

- (UIView *)tapEffectView{
    if (nil == _tapEffectView){
        _tapEffectView = [[UIView alloc] init];
        _tapEffectView.backgroundColor = [FCStyle.fcBlack colorWithAlphaComponent:0.02];
        [self.fcContentView.containerView addSubview:_tapEffectView];
    }
    
    return _tapEffectView;
}


- (void)tap:(CGPoint)location{
    if (self.tapAction){
        self.tapAction(self.element);
    }
}

- (void)doubleTap:(CGPoint)location{
    if (self.doubleTapAction){
        self.doubleTapAction(self.element);
    }
}

- (void)buildWithElement:(id)element{}

+ (UIEdgeInsets)contentInset{
    return UIEdgeInsetsMake(10, 10, 0, 10);
}

+ (NSString *)identifier{
    return @"FCTableViewCell";
}

@end
