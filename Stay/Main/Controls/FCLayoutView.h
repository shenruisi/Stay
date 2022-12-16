//
//  FCLayoutView.h
//  FastClip-iOS
//
//  Created by ris on 2022/2/7.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FCLayoutView : UIView

@property (nonatomic, assign) BOOL layoutSelfWhenLayoutSubviews;
@property (nonatomic,copy) void(^fcLayout)(UIView *itself,UIView *superView);
@end

NS_ASSUME_NONNULL_END
