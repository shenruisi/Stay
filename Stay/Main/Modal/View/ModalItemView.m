//
//  ModalItemView.m
//  FastClip-iOS
//
//  Created by ris on 2022/12/7.
//

#import "ModalItemView.h"
#import "UIView+Layout.h"
#import "FCStyle.h"
#import "FCLayoutLabel.h"
#import "FCProLabel.h"
#import "FCStore.h"
#import "FCRoundedShadowView2.h"

@interface ModalItemContent()

@property (nonatomic, strong) FCLayoutLabel *titleLabel;
@property (nonatomic, strong) FCLayoutLabel *subtitleLabel;
@property (nonatomic, strong) FCProLabel *proLabel;
@end

@implementation ModalItemContent
- (instancetype)init{
    if (self = [super init]){
        self.backgroundColor = FCStyle.secondaryPopup;
        [self appendBackgroundView];
        [self titleLabel];
        [self subtitleLabel];
        [self proLabel];
    }
    
    return self;
}

- (void)appendBackgroundView{}

- (FCLayoutLabel *)titleLabel{
    if (nil == _titleLabel){
        _titleLabel = [[FCLayoutLabel alloc] init];
        _titleLabel.font = FCStyle.body;
        [self addSubview:_titleLabel];
        
    }
    
    return _titleLabel;
}

- (FCLayoutLabel *)subtitleLabel{
    if (nil == _subtitleLabel){
        _subtitleLabel = [[FCLayoutLabel alloc] init];
        _subtitleLabel.font = FCStyle.footnote;
        _subtitleLabel.textColor = FCStyle.fcSecondaryBlack;
        [self addSubview:_subtitleLabel];
    }
    
    return _subtitleLabel;
}

- (FCProLabel *)proLabel{
    if (nil == _proLabel){
        _proLabel = [[FCProLabel alloc] init];
        _proLabel.hidden = FCPlan.None != [[FCStore shared] getPlan:NO];
        [self addSubview:_proLabel];
    }
    
    return _proLabel;
}

@end

@interface ModalItemContentShadowRound()

@property (nonatomic, strong) FCRoundedShadowView2 *backgroundView;
@end

@implementation ModalItemContentShadowRound

- (void)appendBackgroundView{
    [self backgroundView];
}

- (FCRoundedShadowView2 *)backgroundView{
    if (nil == _backgroundView){
        _backgroundView = [[FCRoundedShadowView2 alloc] initWithRadius:10
                                                           borderWith:1
                                                           cornerMask:kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner];
        
        _backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_backgroundView];
        
        [NSLayoutConstraint activateConstraints:@[
            [_backgroundView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [_backgroundView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [_backgroundView.topAnchor constraintEqualToAnchor:self.topAnchor],
            [_backgroundView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
        ]];
    }
    
    return _backgroundView;
}



@end


@interface ModalItemView()

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) FCLayoutView *separatorView;
@property (nonatomic, strong) FCLayoutLabel *tipsLabel;
@end

@implementation ModalItemView

- (instancetype)initWithElement:(ModalItemElement *)element{
    if (self = [super init]){
        self.layoutSelfWhenLayoutSubviews = YES;
        self.element = element;
        self.backgroundColor = FCStyle.popup;
        self.fcLayout = ^(UIView * _Nonnull itself, UIView * _Nonnull superView) {
            [itself setFrame:CGRectMake(0, 0, superView.width, superView.height)];
        };
    }
    
    return self;
}

- (void)didMoveToSuperview{
    [super didMoveToSuperview];
    if (self && self.superview){
        [self estimateDisplay];
    }
}

- (void)estimateDisplay{
    [self contentView];
    [self separatorView];
    
    if (self.element.generalEntity.tips.length > 0){
        [self tipsLabel];
    }
    
    if (ModalItemElementRenderModeSingle == self.element.renderMode){
        self.contentView.layer.cornerRadius = self.itemCornerRadius;
        self.contentView.layer.maskedCorners =
        kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
        self.separatorView.hidden = YES;
    }
    else if (ModalItemElementRenderModeTop == self.element.renderMode){
        self.contentView.layer.cornerRadius = self.itemCornerRadius;
        self.contentView.layer.maskedCorners =
        kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
        self.separatorView.hidden = NO;
    }
    else if (ModalItemElementRenderModeMiddle == self.element.renderMode){
        self.contentView.layer.cornerRadius = 0;
        self.separatorView.hidden = NO;
    }
    else if (ModalItemElementRenderModeBottom == self.element.renderMode){
        self.contentView.layer.cornerRadius = self.itemCornerRadius;
        self.contentView.layer.maskedCorners =
        kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
        self.separatorView.hidden = YES;
    }
    
    [self _fillData:self.element];
}

- (void)_fillData:(ModalItemElement *)element{
    [self fillData:element];
}

- (void)fillData:(ModalItemElement *)element{
    if (element.generalEntity.titleFont){
        self.contentView.titleLabel.font = element.generalEntity.titleFont;
    }
    
    self.contentView.titleLabel.textColor = element.enable ? FCStyle.fcBlack : FCStyle.fcSeparator;
    
    [self.contentView.titleLabel setText:element.generalEntity.title];
    if (element.generalEntity.subtitle.length > 0){
        [self.contentView.subtitleLabel setText:element.generalEntity.subtitle];
    }
    if (element.generalEntity.tips.length > 0){
        [self.tipsLabel setText:self.element.generalEntity.tips];
    }
}

- (ModalItemContent *)contentView{
    if (nil == _contentView){
        if (self.element.shadowRound){
            _contentView = [[ModalItemContentShadowRound alloc] init];
        }
        else{
            _contentView = [[ModalItemContent alloc] init];
        }
        
        _contentView.layoutSelfWhenLayoutSubviews = YES;
        __weak ModalItemView *weakSelf = self;
        _contentView.fcLayout = ^(UIView * _Nonnull itself, UIView * _Nonnull superView) {
            CGFloat height = [weakSelf.element.latestContentUserInfo[@"tipsHeight"] floatValue];
            [itself setFrame:CGRectMake(weakSelf.element.spacing3,
                                        0,
                                        superView.width - 2 * weakSelf.element.spacing3,
                                        weakSelf.element.latestContentHeight - height)];
        };
        _contentView.titleLabel.fcLayout = ^(UIView * _Nonnull itself, UIView * _Nonnull superView) {
            CGFloat width = [weakSelf.element.latestContentUserInfo[@"titleWidth"] floatValue];
            [itself setFrame:CGRectMake(weakSelf.element.spacing3,
                                        (superView.height - FCStyle.body.lineHeight)/2,
                                        width,
                                        FCStyle.body.lineHeight)];
        };
        
        _contentView.titleLabel.textColor = self.element.highlight ? UIColor.redColor : FCStyle.fcBlack;
        
        _contentView.subtitleLabel.fcLayout = ^(UIView * _Nonnull itself, UIView * _Nonnull superView) {
            CGFloat titleWidth = [weakSelf.element.latestContentUserInfo[@"titleWidth"] floatValue];
            CGFloat subtitleWidth = [weakSelf.element.latestContentUserInfo[@"subtitleWidth"] floatValue];
            [itself setFrame:CGRectMake(weakSelf.element.spacing3 + titleWidth + weakSelf.element.spacing1,
                                        (superView.height - FCStyle.footnote.lineHeight)/2,
                                        subtitleWidth,
                                        FCStyle.footnote.lineHeight)];
        };
        
        _contentView.proLabel.fcLayout = ^(UIView * _Nonnull itself, UIView * _Nonnull superView) {
            CGFloat titleWidth = [weakSelf.element.latestContentUserInfo[@"titleWidth"] floatValue];
            [itself setFrame:CGRectMake(weakSelf.element.spacing3 + titleWidth + weakSelf.element.spacing1,
                                        (superView.height - 18)/2,
                                        35,
                                        18)];
        };
        
        if (!self.element.pro){
            [_contentView.proLabel removeFromSuperview];
        }
        
        [self addSubview:_contentView];
    }
    
    return _contentView;
}

- (FCLayoutLabel *)tipsLabel{
    if (nil == _tipsLabel){
        _tipsLabel = [[FCLayoutLabel alloc] init];
        _tipsLabel.font = FCStyle.footnote;
        _tipsLabel.textColor = FCStyle.fcSecondaryBlack;
        _tipsLabel.numberOfLines = 3;
        __weak ModalItemView *weakSelf = self;
        _tipsLabel.fcLayout = ^(UIView * _Nonnull itself, UIView * _Nonnull superView) {
            CGFloat height = [weakSelf.element.latestContentUserInfo[@"tipsHeight"] floatValue];
            [itself setFrame:CGRectMake(weakSelf.element.spacing3,
                                        superView.height - height,
                                        superView.width - 2 * weakSelf.element.spacing3,
                                        height)];
        };
        [self addSubview:_tipsLabel];
    }
    
    return _tipsLabel;
}

- (FCLayoutView *)separatorView{
    if (nil == _separatorView){
        _separatorView = [[FCLayoutView alloc] init];
        __weak ModalItemView *weakSelf = self;
        _separatorView.fcLayout = ^(UIView * _Nonnull itself, UIView * _Nonnull superView) {
            [itself setFrame:CGRectMake(2 * weakSelf.element.spacing3,
                                        weakSelf.bottom - 1,
                                        superView.width - 2 * weakSelf.element.spacing3 - weakSelf.element.spacing3,
                                        0.5)];
        };
        _separatorView.backgroundColor = FCStyle.fcSeparator;
        [self addSubview:_separatorView];
    }

    return _separatorView;
}



- (UITapGestureRecognizer *)tapGestureRecognizer{
    if (nil == _tapGestureRecognizer){
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandlder:)];
        
    }
    return _tapGestureRecognizer;
}

- (void)tapGestureHandlder:(UITapGestureRecognizer *)tapGestureRecognizer{
    if (self.element.action){
        self.element.action(self.element);
    }
}

- (void)attachGesture{
    if (self.element.tapEnabled){
        [self.cell addGestureRecognizer:self.tapGestureRecognizer];
    }
}

- (void)clear{
    [self.contentView.titleLabel setText:@""];
}

- (CGFloat)itemCornerRadius{
    return 10;
}

@end
