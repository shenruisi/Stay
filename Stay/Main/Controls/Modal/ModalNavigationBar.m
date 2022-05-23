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
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self.titleLabel setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [self.cancelButton setFrame:CGRectMake(frame.size.width - 15 - 22, (frame.size.height - 22)/2, 22, 22)];
}

- (UILabel *)titleLabel{
    if (nil == _titleLabel){
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = FCStyle.headline;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = FCStyle.fcBlack;
        [self addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

- (UIButton *)cancelButton{
    if (nil == _cancelButton){
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectZero];
        UIImage *image = [UIImage systemImageNamed:@"multiply.circle.fill" withConfiguration:[UIImageSymbolConfiguration configurationWithFont:[UIFont systemFontOfSize:22]]];
        
        [_cancelButton setImage:[image imageWithTintColor:FCStyle.fcSecondaryBlack renderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
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

- (CGFloat)height{
    return 44;
}

@end
