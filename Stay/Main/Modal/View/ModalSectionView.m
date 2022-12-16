//
//  ModalSectionView.m
//  FastClip-iOS
//
//  Created by ris on 2022/12/8.
//

#import "ModalSectionView.h"
#import "FCStyle.h"
#import "FCLayoutLabel.h"
#import "UIView+Layout.h"

@interface ModalSectionContent()

@property (nonatomic, strong) FCLayoutLabel *titleLabel;
@end

@implementation ModalSectionContent

- (instancetype)init{
    if (self = [super init]){
        self.backgroundColor = FCStyle.popup;
        [self titleLabel];
    }
    
    return self;
}


- (FCLayoutLabel *)titleLabel{
    if (nil == _titleLabel){
        _titleLabel = [[FCLayoutLabel alloc] init];
        _titleLabel.font = FCStyle.subHeadlineBold;
        _titleLabel.textColor = FCStyle.fcSecondaryBlack;
        [self addSubview:_titleLabel];
        
    }
    
    return _titleLabel;
}
@end

@interface ModalSectionView()
@end

@implementation ModalSectionView

- (instancetype)initWithElement:(ModalSectionElement *)element{
    if (self = [super init]){
        self.layoutSelfWhenLayoutSubviews = YES;
        self.element = element;
        self.backgroundColor = FCStyle.popup;
        self.fcLayout = ^(UIView * _Nonnull itself, UIView * _Nonnull superView) {
            [itself setFrame:CGRectMake(0, itself.top, superView.width, [element height])];
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
    [self fillData:self.element];
}

- (void)fillData:(ModalSectionElement *)element{
    [self.contentView.titleLabel setText:element.title];
}

- (ModalSectionContent *)contentView{
    if (nil == _contentView){
        _contentView = [[ModalSectionContent alloc] init];
        _contentView.layoutSelfWhenLayoutSubviews = YES;
        __weak ModalSectionView *weakSelf = self;
        _contentView.fcLayout = ^(UIView * _Nonnull itself, UIView * _Nonnull superView) {
            [itself setFrame:CGRectMake(weakSelf.element.spacing3,
                                        0,
                                        superView.width - 2 * weakSelf.element.spacing3,
                                        [weakSelf.element height])];
        };
        _contentView.titleLabel.fcLayout = ^(UIView * _Nonnull itself, UIView * _Nonnull superView) {
            [itself setFrame:CGRectMake(0,
                                        (superView.height - FCStyle.subHeadlineBold.lineHeight)/2,
                                        superView.width,
                                        weakSelf.element.title.length == 0 ? 0 : FCStyle.subHeadlineBold.lineHeight)];
        };
        [self addSubview:_contentView];
    }
    
    return _contentView;
}

+ (CGFloat)fixedHeight{
    return 45.0f;
}

@end
