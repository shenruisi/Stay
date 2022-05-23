//
//  FCStyle.m
//  FastClip-iOS
//
//  Created by King on 22/2/2022.
//

#import "FCStyle.h"

@implementation FCStyle

+ (UIColor *)accent {
    return  [UIColor colorNamed: @"AccentClassicColor"];
}

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

+ (UIFont *)title3{
    return [UIFont systemFontOfSize:20];
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

@end
