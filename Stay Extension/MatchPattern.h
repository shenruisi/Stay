//
//  MatchPattern.h
//  Stay Extension
//
//  Created by ris on 2022/5/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MatchPattern : NSObject

- (instancetype)initWithPattern:(NSString *)pattern;
- (BOOL)doMatch:(NSString *)urlString;
@end

NS_ASSUME_NONNULL_END
