//
//  FCTapView.h
//  Stay
//
//  Created by ris on 2023/5/15.
//

#import "FCView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FCTapView : FCView

@property (nonatomic, copy) void(^action)(void);
@end

NS_ASSUME_NONNULL_END
