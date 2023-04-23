//
//  BlockerAST.h
//  Stay
//
//  Created by ris on 2023/4/7.
//

#import <Foundation/Foundation.h>
#import "FilterTokenParser.h"
#import "ContentBlockerRule.h"
NS_ASSUME_NONNULL_BEGIN

@interface BlockerAST : NSObject

@property (nonatomic, strong) FilterTokenParser *parser;
@property (nonatomic, strong) ContentBlockerRule *contentBlockerRule;
@property (nonatomic, assign) BOOL unsupported;

- (instancetype)initWithParser:(FilterTokenParser *)parser
                          args:(nullable NSArray *)args;
- (void)construct:(nullable NSArray *)args;
@end

NS_ASSUME_NONNULL_END
