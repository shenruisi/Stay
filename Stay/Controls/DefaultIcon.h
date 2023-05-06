//
//  DefaultIcon.h
//  Stay
//
//  Created by ris on 2023/5/6.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DefaultIcon : NSObject

+ (UIImage *)iconWithTitle:(NSString *)title size:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
