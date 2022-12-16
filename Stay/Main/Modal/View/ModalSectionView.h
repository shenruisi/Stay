//
//  ModalSectionView.h
//  FastClip-iOS
//
//  Created by ris on 2022/12/8.
//

#import "FCLayoutView.h"
#import "ModalSectionElement.h"

NS_ASSUME_NONNULL_BEGIN

@interface ModalSectionContent : FCLayoutView
@end


@interface ModalSectionView : FCLayoutView

@property (nonatomic, strong) ModalSectionElement *element;
@property (nonatomic, strong) ModalSectionContent *contentView;
@property (class, nonatomic, readonly) CGFloat fixedHeight;

- (instancetype)initWithElement:(ModalSectionElement *)element;
- (void)fillData:(ModalSectionElement *)element;
- (void)estimateDisplay;
@end

NS_ASSUME_NONNULL_END
