//
//  NSAttributedString+Style.h
//  Stay
//
//  Created by ris on 2023/4/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSAttributedString(Style)

+ (NSMutableAttributedString *)bodyText:(NSString *)text;
+ (NSMutableAttributedString *)captionText:(NSString *)text;
@end

NS_ASSUME_NONNULL_END
