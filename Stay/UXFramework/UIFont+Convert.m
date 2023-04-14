//
//  UIFont+Convert.m
//  Stay
//
//  Created by ris on 2023/4/5.
//

#import "UIFont+Convert.h"

@implementation UIFont(Convert)

- (UIFont *)toHelvetica:(UIFontDescriptorSymbolicTraits)traits{
     return [self toFontName:@"Helvetica" traits:traits];
    
}

- (UIFont *)toFontName:(NSString *)fontName traits:(UIFontDescriptorSymbolicTraits)traits{
    BOOL isBold = (traits & UIFontDescriptorTraitBold) != 0;
    BOOL isItalic = (traits & UIFontDescriptorTraitItalic) != 0;
    NSMutableString *trait = [[NSMutableString alloc] init];
    if (isBold){[trait appendString:@"Bold"];}
    if (isItalic){[trait appendString:@"Oblique"];}
    if (trait.length > 0){
        return [UIFont fontWithName:[NSString stringWithFormat:@"%@-%@",fontName,trait] size:self.pointSize];
    }
    else{
        return [UIFont fontWithName:fontName size:self.pointSize];
    }
}


@end
