//
//  HighlighterAST.h
//  Stay
//
//  Created by ris on 2023/4/5.
//

#import <Foundation/Foundation.h>
#import "FilterTokenParser.h"
#import "FCStyle.h"
#import "NSAttributedString+Style.h"
NS_ASSUME_NONNULL_BEGIN

@interface HighlighterAST : NSObject

@property (nonatomic, strong) NSMutableAttributedString *attributedString;
@property (nonatomic, strong) FilterTokenParser *parser;

- (instancetype)initWithParser:(FilterTokenParser *)parser
                          args:(nullable NSArray *)args;
- (void)construct:(nullable NSArray *)args;
@end

NS_ASSUME_NONNULL_END
