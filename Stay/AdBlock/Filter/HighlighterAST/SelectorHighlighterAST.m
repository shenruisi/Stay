//
//  SelectorHighlighterAST.m
//  Stay
//
//  Created by ris on 2023/4/6.
//

#import "SelectorHighlighterAST.h"

@implementation SelectorHighlighterAST

- (void)construct:(NSArray *)args{
    [super construct:args];
    
    if (self.parser.curToken.type == FilterTokenTypeSelectorElementHiding){
        [self.attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"##" attributes:@{
            NSFontAttributeName : FCStyle.caption,
            NSForegroundColorAttributeName : FCStyle.filterCosmeticColor
        }]];
    }
    else if (self.parser.curToken.type == FilterTokenTypeSelectorElementHidingException){
        [self.attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"#@#" attributes:@{
            NSFontAttributeName : FCStyle.caption,
            NSForegroundColorAttributeName : FCStyle.filterCosmeticColor
        }]];
    }
    else if (self.parser.curToken.type == FilterTokenTypeSelectorElementHidingEmulation){
        [self.attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"#?#" attributes:@{
            NSFontAttributeName : FCStyle.caption,
            NSForegroundColorAttributeName : FCStyle.filterCosmeticColor
        }]];
    }
    else if (self.parser.curToken.type == FilterTokenTypeSelectorElementSnippetFilter){
        [self.attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"#$#" attributes:@{
            NSFontAttributeName : FCStyle.caption,
            NSForegroundColorAttributeName : FCStyle.filterCosmeticColor
        }]];
    }
    
    NSInteger length = self.attributedString.length;
    [self.attributedString appendAttributedString:[NSAttributedString captionText:[self.parser.curToken toString]]];
    [self.attributedString addAttributes:@{
        NSForegroundColorAttributeName : FCStyle.filterSelectorColor
    } range:NSMakeRange(length, self.attributedString.length - length)];
}

@end
