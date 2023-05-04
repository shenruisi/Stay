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
    
    if (element.accessoryEntity.animation){
        
    }
    else{
        
    }
}


- (FCLayoutImageView *)imageView{
    if (nil == _imageView){
        _imageView = [[FCLayoutImageView alloc] init];
        _imageView.contentMode = UIViewContentModeRight;
        __weak ModalItemAccessoryView *weakSelf = self;
        UIFont *font = self.element.generalEntity.accessoryFont ? self.element.generalEntity.accessoryFont : FCStyle.sfSecondaryIcon;
        _imageView.fcLayout = ^(UIView * _Nonnull itself, UIView * _Nonnull superView) {
            [itself setFrame:CGRectMake(superView.width - weakSelf.element.spacing3 - FCStyle.sfSecondaryIcon.lineHeight,
                                        (superView.height - font.lineHeight) / 2,
                                        FCStyle.sfSecondaryIcon.lineHeight,
                                        FCStyle.sfSecondaryIcon.lineHeight)];
        };
        [self.contentView addSubview:_imageView];
    }
    return _imageView;
}

@end
