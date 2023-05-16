//
//  AddressHighlighterAST.m
//  Stay
//
//  Created by ris on 2023/4/6.
//

#import "AddressHighlighterAST.h"

@implementation AddressHighlighterAST

- (void)construct:(NSArray *)args{
    [super construct:args];
    
    [self.attributedString appendAttributedString:[NSAttributedString captionText:[self.parser.curToken toString]]];

    
    [self.attributedString addAttributes:@{
        NSForegroundColorAttributeName : FCStyle.filterAddressColor
    } range:NSMakeRange(0, self.attributedString.length)];
}

@end
