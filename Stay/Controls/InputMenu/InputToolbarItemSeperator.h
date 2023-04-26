//
//  InputToolbarItemSeperator.h
//  Stay
//
//  Created by ris on 2023/4/26.
//

#import "InputToolbarItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface InputToolbarItemSeperator : UIView

@property (nonatomic, strong) InputToolbarItemElement *element;
@property (nonatomic, assign) BOOL fillSuperView;

- (instancetype)initWithElement:(InputToolbarItemElement *)element;

@end


NS_ASSUME_NONNULL_END
