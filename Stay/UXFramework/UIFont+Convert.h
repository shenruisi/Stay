//
//  UIFont+Convert.h
//  Stay
//
//  Created by ris on 2023/4/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIFont(Convert)
- (UIFont *)toFontName:(NSString *)fontName traits:(UIFontDescriptorSymbolicTraits)traits;
- (UIFont *)toHelvetica:(UIFontDescriptorSymbolicTraits)traits;
@end

NS_ASSUME_NONNULL_END
