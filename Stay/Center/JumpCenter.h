//
//  JumpCenter.h
//  Stay
//
//  Created by ris on 2023/5/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JumpCenter : NSObject

+ (void)jumpWithUrl:(NSString *)urlStr baseCer:(UIViewController *)baseCer;
@end

NS_ASSUME_NONNULL_END
