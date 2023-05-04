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
    UIFont *font = element.generalEntity.accessoryFont ? element.generalEntity.accessoryFont : FCStyle.sfSecondaryIcon;
    UIImage *image;
    if (element.accessoryEntity.checkmark){
        image =  [UIImage systemImageNamed:@"checkmark.circle.fill"
                                  withConfiguration:[UIImageSymbolConfiguration configurationWithFont: font]];
        image = [image imageWithTintColor:element.enable ? FCStyle.accent : FCStyle.fcSeparator
                            renderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    else{
        image =  [UIImage systemImageNamed:@"chevron.right"
                                  withConfiguration:[UIImageSymbolConfiguration configurationWithFont: font]];
        image = [image imageWithTintColor:element.enable ? FCStyle.fcSecondaryBlack : FCStyle.fcSeparator
                            renderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    
    [self.imageView setImage:image];
    
    
}


- (FCLayoutImageView *)imageView{
    if (nil == _imageView){
        _imageView = [[FCLayoutImageView alloc] init];
        _imageView.contentMode = UIViewContentModeRight;
        __weak ModalItemAccessoryView *weakSelf = self;
        UIFont *font = self.element.generalEntity.accessoryFont ? self.element.generalEntity.accessoryFont : FCStyle.sfSecondaryIcon;
        _imageView.fcLayout = ^(UIView * _Nonnull itself, UIView * _Nonnull superView) {
            [itself setFrame:CGRectMake(superView.width - weakSelf.element.spacing3 - font.lineHeight,
                                        (superView.height - font.lineHeight) / 2,
                                        FCStyle.sfSecondaryIcon.lineHeight,
                                        FCStyle.sfSecondaryIcon.lineHeight)];
            
            if (weakSelf.element.accessoryEntity.animation){
                [weakSelf.imageView.layer removeAllAnimations];
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
                animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(itself.center.x, itself.center.y)];
                animation.toValue = [NSValue valueWithCGPoint:CGPointMake(itself.center.x + 5, itself.center.y)];
                animation.autoreverses = YES;
                animation.repeatCount = HUGE_VALF;
                animation.duration = 1;
                [weakSelf.imageView.layer addAnimation:animation forKey:@"wave"];
            }
            else{
                [weakSelf.imageView.layer removeAllAnimations];
            }
        };
        [self.contentView addSubview:_imageView];
    }
    return _imageView;
}

@end
