//
//  ModalNavigationBar.m
//  FastClip-iOS
//
//  Created by ris on 2022/2/7.
//

#import "ModalNavigationBar.h"
#import "FCStyle.h"

@interface ModalNavigationBar()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIView *lineView;
@end

@implementation ModalNavigationBar

- (instancetype)init{
    if (self = [super initWithFrame:CGRectMake(0, 0, 0, self.height)]){
        self.backgroundColor = FCStyle.popup;
        [self titleLabel];
        
    }
    
    return self;
}

- (void)setTitle:(NSString *)title{
    _title = title;
    self.titleLabel.text = _title;
    CGRect rect = [_title boundingRectWithSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName : FCStyle.headlineBold}
                                                     context:nil];
    [self.lineView setFrame:CGRectMake(15, self.frame.size.height - 8, rect.size.width + 30, 0.5)];
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self.titleLabel setFrame:CGRectMake(15, 0, frame.size.width, frame.size.height)];
    [self.cancelButton setFrame:CGRectMake(frame.size.width - 15 - 20, (frame.size.height - 20)/2, 20, 20)];
}

- (UILabel *)titleLabel{
    if (nil == _titleLabel){
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = FCStyle.headlineBold;
        _titleLabel.textColor = FCStyle.fcBlack;
        [self addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

- (UIView *)lineView{
    if (nil == _lineView){
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = FCStyle.fcSeparator;
        [self addSubview:_lineView];
    }
    
    return _lineView;
}

- (UIButton *)cancelButton{
    if (nil == _cancelButton){
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectZero];
        UIImage *image = [UIImage systemImageNamed:@"multiply.circle.fill" withConfiguration:[UIImageSymbolConfiguration configurationWithFont:[UIFont systemFontOfSize:20]]];
        _cancelButton.imageView.contentMode = UIViewContentModeCenter;
        [_cancelButton setImage:[image imageWithTintColor:FCStyle.fcBlack renderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cancelButton];
        _cancelButton.hidden = YES;
        
    }
    
    return _cancelButton;
}

- (void)cancelAction:(id)sender{
    if ([self.delegate respondsToSelector:@selector(navigationBarDidClickCancelButton)]){
        [self.delegate navigationBarDidClickCancelButton];
    }
}
    
- (void)setShowCancel:(BOOL)showCancel{
    self.cancelButton.hidden = !showCancel;
}

- (void)setRightItems:(NSArray<UIView *> *)rightItems{
    for (UIView *view in _rightItems){
        [view removeFromSuperview];
    }
    _rightItems = rightItems;
    [self layoutRightItems];
}

- (void)layoutRightItems{
    CGFloat spacing = 10.0f;
    CGFloat viewWidths = 0;
    for (UIView *view in _rightItems){
        viewWidths += view.frame.size.width;
    }
    
    CGFloat left = self.frame.size.width - (viewWidths + spacing * _rightItems.count) - 15 - (self.cancelButton.hidden ? 0 : 22);
    for (UIView *view in _rightItems){
        [view setFrame:CGRectMake(left,
                                  (self.frame.size.height - view.frame.size.height) / 2,
                                  view.frame.size.width,
                                  view.frame.size.height)];
        left += spacing + view.frame.size.width;
        [self addSubview:view];
    }
}

- (void)hideRightItems{
    for (UIView *view in self.rightItems){
        view.hidden = YES;
    }
}

- (void)showRightItems{
    for (UIView *view in self.rightItems){
        view.hidden = NO;
    }
}

- (CGFloat)height{
    return 44;
}

@end
