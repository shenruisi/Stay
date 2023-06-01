//
//  FCImageView.h
//  Stay
//
//  Created by ris on 2023/5/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FCImageView : UIImageView

@property (nonatomic, assign) CGFloat progress;
- (void)clearProcess;
@end

NS_ASSUME_NONNULL_END
