//
//  FCStyle.m
//  FastClip-iOS
//
//  Created by King on 22/2/2022.
//

#import "FCStyle.h"

@implementation FCStyle

+ (UIColor *)accent {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *themeColor = [userDefaults objectForKey:@"themeColor"];

    if(themeColor == nil ) {
        return  [UIColor colorNamed: @"AccentClassicColor"];
    } else {
        return [FCStyle colorWithHexString:themeColor alpha:1];
    }
    
}

+ (NSString *)appearance{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *type = [userDefaults objectForKey:@"themeType"];
    if (type.length == 0) return @"System";
    else return type;
}
    
//    if([@"System" isEqual:type]) {
//        [[UIApplication sharedApplication].keyWindow setOverrideUserInterfaceStyle:UIUserInterfaceStyleUnspecified];
//    } else if([@"Dark" isEqual:type]){
//        [[UIApplication sharedApplication].keyWindow setOverrideUserInterfaceStyle:UIUserInterfaceStyleDark];
//    }else if([@"Light" isEqual:type]){
//        [[UIApplication sharedApplication].keyWindow setOverrideUserInterfaceStyle:UIUserInterfaceStyleLight];
//    }

+ (UIColor *)accentHighlight {
    return [UIColor colorNamed: @"SecondaryAccentClassicColor"];
}

+ (UIColor *)accentHover {
    return [UIColor colorNamed: @"TertiaryAccentClassicColor"];
}

+ (UIColor *)accentSelected {
    return [UIColor colorNamed: @"SelectedAccentClassicColor"];
}

+ (UIColor *)background {
    return [UIColor colorNamed: @"BackgroundColor"];
}

+ (UIColor *)secondaryBackground {
    return [UIColor colorNamed: @"SecondaryBackgroundColor"];
}

+ (UIColor *)tertiaryBackground {
    return [UIColor colorNamed: @"TertiaryBackgroundColor"];
}

+ (UIColor *)popup {
    return [UIColor colorNamed: @"PopupColor"];
}

+ (UIColor *)secondaryPopup {
    return [UIColor colorNamed: @"SecondaryPopupColor"];
}

+ (UIColor *)fcSeparator {
    return [UIColor colorNamed: @"FCSeparatorColor"];
}

+ (UIColor *)fcPlaceHolder {
    return UIColor.placeholderTextColor;
}

+ (UIColor *)fcBlack {
    return [UIColor colorNamed: @"FCBlackColor"];
}

+ (UIColor *)fcSecondaryBlack {
    return [UIColor colorNamed: @"FCSecondaryBlackColor"];
}

+ (UIColor *)fcWhite {
    return [UIColor colorNamed: @"FCWhiteColor"];
}

+ (UIColor *)fcShadowLine {
    return [UIColor colorNamed: @"FCShadowLineColor"];
}

+ (UIColor *)fcBlue {
    return [UIColor colorNamed:@"FCBlueColor"];
}

+ (UIColor *)fcGolden {
    return [UIColor colorNamed:@"FCGoldenColor"];
}

+ (UIColor *)backgroundGolden {
    return [UIColor colorNamed:@"BackgroundGoldenColor"];
}

+ (UIColor *)borderGolden {
    return [UIColor colorNamed:@"BorderGoldenColor"];
}

+ (UIFont *)title1{
#ifdef iOS
    return [UIFont systemFontOfSize:28];
#else
    return [UIFont systemFontOfSize:26];
#endif
}

+ (UIFont *)title1Bold{
#ifdef iOS
    return [UIFont boldSystemFontOfSize:28];
#else
    return [UIFont boldSystemFontOfSize:26];
#endif
}

+ (UIFont *)title3{
#ifdef iOS
    return [UIFont systemFontOfSize:20];
#else
    return [UIFont systemFontOfSize:18];
#endif
}

+ (UIFont *)title3Bold{
#ifdef iOS
    return [UIFont boldSystemFontOfSize:20];
#else
    return [UIFont boldSystemFontOfSize:18];
#endif
}

+ (UIFont *)headline {
#ifdef iOS
    return [UIFont systemFontOfSize:17];
#else
    return [UIFont systemFontOfSize:15];
#endif
}

+ (UIFont *)headlineBold {
#ifdef iOS
    return [UIFont boldSystemFontOfSize:17];
#else
    return [UIFont boldSystemFontOfSize:15];
#endif
}

+ (UIFont *)subHeadline {
#ifdef iOS
    return [UIFont systemFontOfSize:15];
#else
    return [UIFont systemFontOfSize:13];
#endif
}

+ (UIFont *)subHeadlineBold {
#ifdef iOS
    return [UIFont boldSystemFontOfSize:15];
#else
    return [UIFont boldSystemFontOfSize:13];
#endif
}

+ (UIFont *)body {
#ifdef iOS
    return [UIFont systemFontOfSize:16];
#else
    return [UIFont systemFontOfSize:14];
#endif
}

+ (UIFont *)bodyBold {
#ifdef iOS
    return [UIFont boldSystemFontOfSize:16];
#else
    return [UIFont boldSystemFontOfSize:14];
#endif
}

+ (UIFont *)footnote {
#ifdef iOS
    return [UIFont systemFontOfSize:13];
#else
    return [UIFont systemFontOfSize:11];
#endif
}

+ (UIFont *)footnoteBold {
#ifdef iOS
    return [UIFont boldSystemFontOfSize:13];
#else
    return [UIFont boldSystemFontOfSize:11];
#endif
}

+ (UIFont *)sfFootnote {
#ifdef iOS
    return [UIFont systemFontOfSize:13];
#else
    return [UIFont systemFontOfSize:18];
#endif
}

+ (UIFont *)sfActbar {
#ifdef iOS
    return [UIFont systemFontOfSize:17];
#else
    return [UIFont systemFontOfSize:18];
#endif
}

+ (UIColor *)colorWithHexString:(NSString *)string alpha:(CGFloat) alpha
{
    if ([string hasPrefix:@"#"])
        string = [string substringFromIndex:1];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.length = 2;
    
    range.location = 0;
    NSString *rString = [string substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [string substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [string substringWithRange:range];
    
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r/255.0f) green:((float)g/255.0f) blue:((float)b/255.0f) alpha:alpha];
}

@end
