//
//  FCTopToastModalViewController.h
//  Stay
//
//  Created by ris on 2022/11/25.
//

#import "ModalViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FCTopToastModalViewController : ModalViewController

@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) NSString *mainTitle;
@property (nonatomic, strong) NSString *secondaryTitle;

- (void)reload;
@end


NS_ASSUME_NONNULL_END
