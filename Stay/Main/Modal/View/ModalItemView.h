//
//  ModalItemView.h
//  FastClip-iOS
//
//  Created by ris on 2022/12/7.
//

#import <UIKit/UIKit.h>
#import "FCLayoutView.h"
#import "ModalItemElement.h"

NS_ASSUME_NONNULL_BEGIN

@interface ModalItemContent : FCLayoutView

- (void)appendBackgroundView;
@end

@interface ModalItemContentShadowRound : ModalItemContent
@end

@interface ModalItemView : FCLayoutView

@property (nonatomic, strong) ModalItemElement *element;
@property (nonatomic, readonly) CGFloat itemCornerRadius;
@property (nonatomic, strong) ModalItemContent *contentView;

@property (nonatomic, weak) UITableViewCell *cell;

- (instancetype)initWithElement:(ModalItemElement *)element;
- (void)fillData:(ModalItemElement *)element;
- (void)estimateDisplay;

- (void)attachGesture;
@end

NS_ASSUME_NONNULL_END
