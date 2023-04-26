//
//  InputToolbarItem.h
//  Stay
//
//  Created by ris on 2023/4/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class InputToolbarItemElement;
@interface InputToolbarItem : UIView

@property (nonatomic, strong) InputToolbarItemElement *element;
@property (nonatomic, assign) BOOL fillSuperView;

- (instancetype)initWithElement:(InputToolbarItemElement *)element;
- (void)reload;
@end


@interface InputToolbarItemElement : NSObject

@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) BOOL useSFSymbol;
@property (nonatomic, assign) CGFloat imageDeltaY;
@property (nonatomic, assign) BOOL isSeperator;
@property (nonatomic, strong) UIFont *imageFont;
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, copy) void(^action)(InputToolbarItem *item);

@property (readonly) BOOL titleMode;
@end

NS_ASSUME_NONNULL_END
