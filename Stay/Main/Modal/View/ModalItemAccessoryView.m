//
//  ModalItemAccessoryView.m
//  Stay
//
//  Created by ris on 2022/12/16.
//

#import "ModalItemAccessoryView.h"
#import "FCLayoutImageView.h"
#import "FCStyle.h"

@interface ModalItemAccessoryView()

@property (nonatomic, strong) FCLayoutImageView *imageView;
@end

@implementation ModalItemAccessoryView

- (void)estimateDisplay{
    [super estimateDisplay];
    [self imageView];
}

- (void)fillData:(ModalItemElement *)element{
    [super fillData:element];
    UIImage *image =  [UIImage systemImageNamed:@"chevron.right"
                              withConfiguration:[UIImageSymbolConfiguration configurationWithFont:FCStyle.sfSecondaryIcon]];
    image = [image imageWithTintColor:FCStyle.fcSecondaryBlack
                        renderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.imageView setImage:image];
}

- (FCLayoutImageView *)imageView{
    if (nil == _imageView){
        _imageView = [[FCLayoutImageView alloc] init];
        _imageView.contentMode = UIViewContentModeRight;
        __weak ModalItemAccessoryView *weakSelf = self;
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
