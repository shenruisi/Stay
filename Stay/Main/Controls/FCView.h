//
//  FCView.h
//  FastClip-iOS
//
//  Created by ris on 2022/2/7.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIView+Duplicate.h"

NS_ASSUME_NONNULL_BEGIN

@interface FCView : UIView

@property (nonatomic, assign) BOOL active;

- (UIView *)fcDuplicate;
@end

NS_ASSUME_NONNULL_END
