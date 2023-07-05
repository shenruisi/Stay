//
//  FCLinkButton.h
//  Stay
//
//  Created by ris on 2023/6/13.
//

#import "FCTapView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FCLinkButton : UILabel

@property (nonatomic, strong) NSAttributedString *attributedTitle;
@property (nonatomic, copy) void(^action)(void);

@end

NS_ASSUME_NONNULL_END
