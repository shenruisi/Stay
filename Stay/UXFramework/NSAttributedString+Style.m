//
//  NSAttributedString+Style.m
//  Stay
//
//  Created by ris on 2023/4/5.
//

#import "NSAttributedString+Style.h"
#import "FCStyle.h"
#import "UIFont+Convert.h"

@implementation NSAttributedString(Style)

+ (NSMutableAttributedString *)bodyText:(NSString *)text{
    return [[NSMutableAttributedString alloc] initWithString:text attributes:@{
        NSFontAttributeName : [FCStyle.body toHelvetica:0],
        NSForegroundColorAttributeName : FCStyle.fcBlack
    }];
}

+ (NSMutableAttributedString *)captionText:(NSString *)text{
    return [[NSMutableAttributedString alloc] initWithString:text attributes:@{
        NSFontAttributeName : [FCStyle.caption toHelvetica:0],
        NSForegroundColorAttributeName : FCStyle.fcBlack
    }];
}


@end
