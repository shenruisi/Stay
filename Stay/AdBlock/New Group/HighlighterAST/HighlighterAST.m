//
//  HighlighterAST.m
//  Stay
//
//  Created by ris on 2023/4/5.
//

#import "HighlighterAST.h"

@implementation HighlighterAST

- (instancetype)initWithParser:(FilterTokenParser *)parser args:(NSArray *)args{
    if (self = [super init]){
        self.parser = parser;
        [self construct:args];
    }
    
    return self;
}


- (void)construct:(nullable NSArray *)args{}

- (NSMutableAttributedString *)attributedString{
    if (nil == _attributedString){
        _attributedString = [[NSMutableAttributedString alloc] init];
    }
    
    return _attributedString;
}
@end
