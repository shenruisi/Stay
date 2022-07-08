//
//  SYTextInputModelViewController.h
//  Stay
//
//  Created by zly on 2022/7/6.
//

#import "ModalViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SYTextInputModelViewController : ModalViewController

@property(nonatomic, strong) UITextView *inputView;
@property(nonatomic, strong) UIButton *confirmBtn;
@property(nonatomic, strong) NSString *notificationName;


- (void)updateNotificationName:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
