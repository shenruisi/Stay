//
//  SYSelectBarModalViewController.h
//  Stay
//
//  Created by zly on 2022/6/10.
//

#import "ModalViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SYSelectBarModalViewController : ModalViewController

@property(nonatomic, strong) UIView *shareUrlBtn;
@property(nonatomic, strong) UIView *shareContentBtn;

@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *url;

@end

NS_ASSUME_NONNULL_END
