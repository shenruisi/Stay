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
        [self configGestureRecognizer];
    }
    
    return self;
}

- (void)configGestureRecognizer{
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognizer:)];
    [self.fcContentView addGestureRecognizer:recognizer];
}

- (void)tapRecognizer:(UITapGestureRecognizer *)recognizer{
    CGPoint location = [recognizer locationInView:self.fcContentView];
    if (recognizer.numberOfTouches == 1){
//        self.tapEffectView.alpha = 1;
//        [self.tapEffectView setFrame:CGRectMake(location.x, location.y, 0, 0)];
//        self.tapEffectView.layer.anchorPoint = CGPointMake(0.5, 0.5);
//        self.tapEffectView.layer.cornerRadius = 0;
//        CGFloat radius =  MAX((self.size.width - location.x),location.x);
//        [UIView animateWithDuration:0.3
//                         animations:^{
//            [self.tapEffectView setFrame:CGRectMake(location.x - radius, location.y - radius, radius * 2, radius * 2)];
//            self.tapEffectView.layer.cornerRadius = radius;
//        } completion:^(BOOL finished) {
//            self.tapEffectView.alpha = 0;
//        }];
        
//        for (UIView *subview in self.fcContentView.subviews) {
//            subview.layer.mask = nil; // 将子视图的mask属性设置为nil
//            subview.backgroundColor = [UIColor clearColor];
//        }
//        UIView *maskView = [[UIView alloc] initWithFrame:self.fcContentView.bounds];
//        maskView.backgroundColor = UIColor.grayColor;
//        UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 100, 100)];
//        self.maskLayer.path = path.CGPath;
//        self.fcContentView.layer.mask = self.maskLayer;
        
//        UIView *containerView = [self.fcContentView.containerView duplicate];
//        for ()
//        [self.fcContentView addSubview:containerView];
        
        [self tap];
    }
    else if (recognizer.numberOfTouches == 2){
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.fcContentView.bounds];
        self.maskLayer.path = path.CGPath;
        self.fcContentView.layer.mask = self.maskLayer;
    }
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

- (CAShapeLayer *)maskLayer{
    if (nil == _maskLayer){
        _maskLayer = [[CAShapeLayer alloc] init];
//        _maskLayer.fillColor = [UIColor blueColor].CGColor;
//        _maskLayer
    }
    
    return _maskLayer;
}

- (void)tap{
    if (self.action){
        self.action(self.element);
    }
}

+ (UIEdgeInsets)contentInset{
    return UIEdgeInsetsMake(10, 10, 0, 10);
}

+ (NSString *)identifier{
    return @"FCTableViewCell";
}

@end
