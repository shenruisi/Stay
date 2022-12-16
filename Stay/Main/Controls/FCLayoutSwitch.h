//
//  FCLayoutSwitch.h
//  FastClip-iOS
//
//  Created by ris on 2022/12/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FCLayoutSwitch : UISwitch

@property (nonatomic,assign) BOOL layoutSelfWhenLayoutSubviews;
@property (nonatomic,copy) void(^fcLayout)(UIView *itself,UIView *superView);
@end

NS_ASSUME_NONNULL_END
