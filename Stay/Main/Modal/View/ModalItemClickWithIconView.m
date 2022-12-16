//
//  ModalItemClickWithIconView.m
//  FastClip-iOS
//
//  Created by ris on 2022/12/8.
//

#import "ModalItemClickWithIconView.h"
#import "FCLayoutImageView.h"
#import "FCStyle.h"
#import "UIView+Layout.h"

@interface ModalItemClickWithIconView()

@property (nonatomic, strong) FCLayoutImageView *iconImageView;
@end

@implementation ModalItemClickWithIconView

- (void)estimateDisplay{
    [super estimateDisplay];
    [self iconImageView];
}

- (void)fillData:(ModalItemElement *)element{
    [super fillData:element];
    UIImage *image =  [UIImage systemImageNamed:element.iconEntity.sfSymbolName
                              withConfiguration:[UIImageSymbolConfiguration configurationWithFont:FCStyle.cellIcon]];
    image = [image imageWithTintColor:element.highlight ? UIColor.redColor : FCStyle.fcBlack
                        renderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.iconImageView setImage:image];
}

- (FCLayoutImageView *)iconImageView{
    if (nil == _iconImageView){
        _iconImageView = [[FCLayoutImageView alloc] init];
        _iconImageView.contentMode = UIViewContentModeRight;
        __weak ModalItemClickWithIconView *weakSelf = self;
        _iconImageView.fcLayout = ^(UIView * _Nonnull itself, UIView * _Nonnull superView) {
            [itself setFrame:CGRectMake(superView.width - weakSelf.element.spacing3 - FCStyle.cellIcon.lineHeight,
                                        (superView.height - FCStyle.cellIcon.lineHeight) / 2,
                                        FCStyle.cellIcon.lineHeight,
                                        FCStyle.cellIcon.lineHeight)];
        };
        [self.contentView addSubview:_iconImageView];
    }
    return _iconImageView;
}

@end
