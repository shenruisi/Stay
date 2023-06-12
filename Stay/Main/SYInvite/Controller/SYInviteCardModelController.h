//
//  SYInviteCardModelController.h
//  Stay
//
//  Created by zly on 2023/6/1.
//

#import "ModalViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SYInviteCardModelController : ModalViewController

@property (nonatomic, strong) NSArray *imageList;
@property (nonatomic, strong) NSString *color;
@property (nonatomic, strong) NSString *dateString;
@property (nonatomic, strong) NSString *defaultImage;
@property (nonatomic, strong) NSString *defaultName;
@end

NS_ASSUME_NONNULL_END
