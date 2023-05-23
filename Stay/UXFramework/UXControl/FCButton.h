//
//  FCButton.h
//  Stay
//
//  Created by ris on 2023/4/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FCButton : UIButton

@property (nonatomic, strong) UIColor *loadingBackgroundColor;
@property (nonatomic, strong) UIColor *loadingTitleColor;
@property (nonatomic, strong) UIColor *loadingBorderColor;
@property (nonatomic, strong) UIColor *loadingViewColor;
- (void)startLoading;
- (void)stopLoading;
@end

NS_ASSUME_NONNULL_END
