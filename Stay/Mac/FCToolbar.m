//
//  FCToolbar.m
//  FastClip-Mac
//
//  Created by ris on 2022/3/8.
//

#import "FCToolbar.h"

@interface FCToolbar()

@end

@implementation FCToolbar

- (instancetype)initWithIdentifier:(NSToolbarIdentifier)identifier{
    if (self = [super initWithIdentifier:identifier]){
    }
    
    return self;
}

- (CGFloat)height{
    return 50.0;
}

@end
