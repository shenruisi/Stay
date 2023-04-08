//
//  ContentFilterHighlighter.h
//  Stay
//
//  Created by ris on 2023/4/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContentFilterHighlighter : NSObject

+ (NSMutableAttributedString *)rule:(NSString *)rule;
@end

NS_ASSUME_NONNULL_END
