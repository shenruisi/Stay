//
//  InviteProgressView.h
//  Stay
//
//  Created by zly on 2023/5/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface InviteProgressView : UIView
@property (nonatomic, strong) NSArray *titleArray;

- (void)updateProgress:(CGFloat)progress;


@end

NS_ASSUME_NONNULL_END
