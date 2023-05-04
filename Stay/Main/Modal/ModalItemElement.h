//
//  ModalItemElement.h
//  FastClip-iOS
//
//  Created by ris on 2022/12/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef enum {
    ModalItemElementTypeUndefined = 0,
    ModalItemElementTypeClick = 100,
    ModalItemElementTypeClickWithIcon = 101,
    ModalItemElementTypeAccessory = 200,
    ModalItemElementTypeAccessoryWithText = 201,
    ModalItemElementTypeSwitch = 300,
    ModalItemElementTypeSplit = 400,
    ModalItemElementTypeInput = 500,
}ModalItemElementType;

typedef enum {
    ModalItemElementRenderModeSingle = 0,
    ModalItemElementRenderModeTop,
    ModalItemElementRenderModeMiddle,
    ModalItemElementRenderModeBottom
}ModalItemElementRenderMode;

@interface ModalItemDataEntityGeneral : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, strong) UIFont *subtitleFont;
@property (nonatomic, strong) NSString *tips;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) UIFont *accessoryFont;
@end

@interface ModalItemDataEntityIcon : NSObject

@property (nonatomic, strong) NSString *sfSymbolName;
@end

@interface ModalItemDataEntitySwitch : NSObject

@property (nonatomic, assign) BOOL on;
@end

@interface ModalItemDataEntityAccessory : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign) BOOL animation;
@property (nonatomic, assign) BOOL checkmark;
@end

@interface ModalItemDataEntitySplit : NSObject

@property (nonatomic, strong) NSString *text1;
@property (nonatomic, strong) NSString *text2;
@property (nonatomic, assign) NSInteger clickIndex;
@end

@interface ModalItemDataEntityInput : NSObject

@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign) UIKeyboardType keyboardType;
@property (nonatomic, weak) UITextField *textField;
@property (nonatomic, copy) void(^textChanged)(NSString *text);
@end

@interface ModalItemElement : NSObject

@property (nonatomic, strong) ModalItemDataEntityGeneral *generalEntity;
@property (nonatomic, strong) ModalItemDataEntityIcon *iconEntity;
@property (nonatomic, strong) ModalItemDataEntitySwitch *switchEntity;
@property (nonatomic, strong) ModalItemDataEntityAccessory *accessoryEntity;
@property (nonatomic, strong) ModalItemDataEntitySplit *splitEntity;
@property (nonatomic, strong) ModalItemDataEntityInput *inputEntity;
@property (nonatomic, assign) ModalItemElementType type;
//Default is YES
@property (nonatomic, assign) BOOL tapEnabled;
@property (nonatomic, assign) BOOL highlight;
@property (nonatomic, assign) BOOL enable;
@property (nonatomic, assign) BOOL pro;

@property (nonatomic, assign) NSInteger spacing1;
@property (nonatomic, assign) NSInteger spacing2;
@property (nonatomic, assign) NSInteger spacing3;
@property (nonatomic, assign) NSInteger spacing4;

@property (nonatomic, assign) CGFloat latestContentHeight;
@property (nonatomic, assign) CGFloat viewWidth;

@property (nonatomic, strong) NSDictionary<NSString *,id> *latestContentUserInfo;

@property (nonatomic, assign) ModalItemElementRenderMode renderMode;

@property (nonatomic, copy) void(^action)(ModalItemElement *element);

@property (nonatomic, assign) BOOL shadowRound;

- (CGFloat)contentHeightWithWidth:(CGFloat)width;
- (void)clear;
@end


NS_ASSUME_NONNULL_END
