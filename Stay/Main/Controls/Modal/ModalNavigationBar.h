//
//  ModalNavigationBar.h
//  FastClip-iOS
//
//  Created by ris on 2022/2/7.
//

#import "FCView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ModalNavigationBarDelegate <NSObject>
- (void)navigationBarDidClickCancelButton;
@end

@interface ModalNavigationBar : FCView

@property (nonatomic, strong) NSString *title;
@property (readonly) CGFloat height;
@property (nonatomic, assign) BOOL showCancel;
@property (nonatomic, weak) id<ModalNavigationBarDelegate> delegate;
- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
