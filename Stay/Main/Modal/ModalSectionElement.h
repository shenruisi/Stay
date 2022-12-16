//
//  ModalSectionElement.h
//  FastClip-iOS
//
//  Created by ris on 2022/12/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ModalSectionElement : NSObject

@property (nonatomic, strong) NSString *title;

@property (nonatomic, assign) NSInteger spacing1;
@property (nonatomic, assign) NSInteger spacing2;
@property (nonatomic, assign) NSInteger spacing3;
@property (nonatomic, assign) NSInteger spacing4;

+ (instancetype)ofTitle:(nullable NSString *)title;
- (CGFloat)height;
@end

NS_ASSUME_NONNULL_END
