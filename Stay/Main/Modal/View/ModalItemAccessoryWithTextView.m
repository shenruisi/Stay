//
//  ModalItemAccessoryWithTextView.m
//  FastClip-iOS
//
//  Created by ris on 2022/12/8.
//

#import "ModalItemAccessoryWithTextView.h"
#import "FCLayoutImageView.h"
#import "FCLayoutLabel.h"
#import "UIView+Layout.h"
#import "FCStyle.h"

@interface ModalItemAccessoryWithTextView()

@property (nonatomic, strong) FCLayoutLabel *label;
@property (nonatomic, strong) FCLayoutImageView *imageView;
@end

@implementation ModalItemAccessoryWithTextView

- (void)estimateDisplay{
    [super estimateDisplay];
    [self label];
    [self imageView];
}

- (void)fillData:(ModalItemElement *)element{
    [super fillData:element];
    [self.label setText:element.accessoryEntity.text];
    UIImage *image =  [UIImage systemImageNamed:@"chevron.right"
                              withConfiguration:[UIImageSymbolConfiguration configurationWithFont:FCStyle.sfSecondaryIcon]];
    image = [image imageWithTintColor:FCStyle.fcSecondaryBlack
                        renderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.imageView setImage:image];
}

- (FCLayoutLabel *)label{
    if (nil == _label){
        _label = [[FCLayoutLabel alloc] init];
        _label.font = FCStyle.body;
        _label.textColor = FCStyle.fcSecondaryBlack;
        _label.textAlignment = NSTextAlignmentRight;
        __weak ModalItemAccessoryWithTextView *weakSelf = self;
        _label.fcLayout = ^(UIView * _Nonnull itself, UIView * _Nonnull superView) {
            [itself setFrame:CGRectMake(superView.width - weakSelf.element.spacing3 - FCStyle.sfSecondaryIcon.lineHeight - 100 - 5,
                                        (superView.height - FCStyle.body.lineHeight) / 2,
                                        100,
                                        FCStyle.body.lineHeight)];
        };
        [self.contentView addSubview:_label];
    }
    
    return _label;
}

- (FCLayoutImageView *)imageView{
    if (nil == _imageView){
        _imageView = [[FCLayoutImageView alloc] init];
        _imageView.contentMode = UIViewContentModeRight;
        __weak ModalItemAccessoryWithTextView *weakSelf = self;
        _imageView.fcLayout = ^(UIView * _Nonnull itself, UIView * _Nonnull superView) {
            [itself setFrame:CGRectMake(superView.width - weakSelf.element.spacing3 - FCStyle.sfSecondaryIcon.lineHeight,
                                        (superView.height - FCStyle.sfSecondaryIcon.lineHeight) / 2,
                                        FCStyle.sfSecondaryIcon.lineHeight,
                                        FCStyle.sfSecondaryIcon.lineHeight)];
        };
        [self.contentView addSubview:_imageView];
    }
    return _imageView;
}

@end
