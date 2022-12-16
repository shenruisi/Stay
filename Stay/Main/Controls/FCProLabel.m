//
//  FCProLabel.m
//  FastClip-iOS
//
//  Created by ris on 2022/12/14.
//

#import "FCProLabel.h"
#import "FCStyle.h"
#import "FCStore.h"

@interface FCProLabel()

@end

@implementation FCProLabel

- (instancetype)init{
    if (self = [super init]){
        self.font = FCStyle.footnoteBold;
        self.text = @"Pro";
        self.textColor = FCStyle.fcGolden;
        self.layer.borderColor = FCStyle.borderGolden.CGColor;
        self.layer.borderWidth = 1;
        self.backgroundColor = FCStyle.backgroundGolden;
        self.layer.cornerRadius = 9;
        self.layer.masksToBounds = YES;
        self.textAlignment = NSTextAlignmentCenter;
    }
    
    return self;
}

@end
