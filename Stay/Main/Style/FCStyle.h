//
//  FCStyle.h
//  FastClip-iOS
//
//  Created by King on 22/2/2022.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FCStyle : NSObject

@property(class, nonatomic, readonly) UIColor *accent;
@property(class, nonatomic, readonly) UIColor *lightAccent;
@property(class, nonatomic, readonly) NSArray<UIColor *> *accentGradient;
@property(class, nonatomic, readonly) UIColor *accentHighlight;
@property(class, nonatomic, readonly) UIColor *accentHover;
@property(class, nonatomic, readonly) UIColor *accentSelected;
@property(class, nonatomic, readonly) UIColor *background;
@property(class, nonatomic, readonly) UIColor *secondaryBackground;
@property(class, nonatomic, readonly) UIColor *tertiaryBackground;
@property(class, nonatomic, readonly) UIColor *popup;
@property(class, nonatomic, readonly) UIColor *secondaryPopup;
@property(class, nonatomic, readonly) UIColor *fcSeparator;
@property(class, nonatomic, readonly) UIColor *fcPlaceHolder;
@property(class, nonatomic, readonly) UIColor *fcBlack;
@property(class, nonatomic, readonly) UIColor *fcSecondaryBlack;
@property(class, nonatomic, readonly) UIColor *fcThirdBlack;
@property(class, nonatomic, readonly) UIColor *fcWhite;
@property(class, nonatomic, readonly) UIColor *fcBlue;
@property(class, nonatomic, readonly) UIColor *fcGolden;
@property(class, nonatomic, readonly) UIColor *backgroundGolden;
@property(class, nonatomic, readonly) UIColor *borderGolden;
@property(class, nonatomic, readonly) UIColor *borderColor;
@property(class, nonatomic, readonly) UIColor *grayNoteColor;
@property(class, nonatomic, readonly) UIColor *fcMacIcon;
@property(class, nonatomic, readonly) UIColor *fcNavigationLineColor;
@property(class, nonatomic, readonly) UIColor *titleGrayColor;
@property(class, nonatomic, readonly) UIColor *progressBgColor;
@property(class, nonatomic, readonly) UIColor *subtitleColor;

@property(class, nonatomic, readonly) UIColor *filterCommentColor;
@property(class, nonatomic, readonly) UIColor *filterExceptionColor;
@property(class, nonatomic, readonly) UIColor *filterAddressColor;
@property(class, nonatomic, readonly) UIColor *filterSeparatorColor;
@property(class, nonatomic, readonly) UIColor *filterModifierColor;
@property(class, nonatomic, readonly) UIColor *filterOptionColor;
@property(class, nonatomic, readonly) UIColor *filterCosmeticColor;
@property(class, nonatomic, readonly) UIColor *filterSelectorColor;

@property(class, nonatomic, readonly) UIFont *headline;
@property(class, nonatomic, readonly) UIFont *headlineBold;
@property(class, nonatomic, readonly) UIFont *subHeadline;
@property(class, nonatomic, readonly) UIFont *subHeadlineBold;
@property(class, nonatomic, readonly) UIFont *body;
@property(class, nonatomic, readonly) UIFont *bodyBold;
@property(class, nonatomic, readonly) UIFont *caption;
@property(class, nonatomic, readonly) UIFont *footnote;
@property(class, nonatomic, readonly) UIFont *footnoteBold;
@property(class, nonatomic, readonly) UIFont *title1;
@property(class, nonatomic, readonly) UIFont *title1Bold;
@property(class, nonatomic, readonly) UIFont *title3;
@property(class, nonatomic, readonly) UIFont *title3Bold;

@property(class, nonatomic, readonly) UIColor *fcShadowLine;
@property(class, nonatomic, readonly) UIFont *sfFootnote;
@property(class, nonatomic, readonly) UIFont *sfActbar;
@property(class, nonatomic, readonly) UIFont *sfNavigationBar;
@property(class, nonatomic, readonly) UIFont *sfSecondaryIcon;
@property(class, nonatomic, readonly) UIFont *cellIcon;
@property(class, nonatomic, readonly) UIFont *sfIcon;

@property(class, nonatomic, readonly) UIFont *sfSymbolL1;
@property(class, nonatomic, readonly) UIFont *sfSymbolL1Bold;
@property(class, nonatomic, readonly) UIFont *sfSymbolL1d5;
@property(class, nonatomic, readonly) UIFont *sfSymbolL1d5Bold;
@property(class, nonatomic, readonly) UIFont *sfSymbolL2;
@property(class, nonatomic, readonly) UIFont *sfSymbolL2Bold;
@property(class, nonatomic, readonly) UIFont *sfSymbolL3;
@property(class, nonatomic, readonly) UIFont *sfSymbolL3Bold;



+ (UIColor *)colorWithHexString:(NSString *)string alpha:(CGFloat) alpha;
+ (NSString *)appearance;
@end

NS_ASSUME_NONNULL_END
