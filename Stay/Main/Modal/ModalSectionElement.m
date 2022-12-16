//
//  ModalSectionElement.m
//  FastClip-iOS
//
//  Created by ris on 2022/12/8.
//

#import "ModalSectionElement.h"

@implementation ModalSectionElement

+ (instancetype)ofTitle:(nullable NSString *)title{
    ModalSectionElement *element = [[ModalSectionElement alloc] init];
    element.title = title;
    return element;
}

- (instancetype)init{
    if (self = [super init]){
        self.spacing1 = 5;
        self.spacing2 = 10;
        self.spacing3 = 15;
        self.spacing4 = 20;
    }
    
    return self;
}


- (CGFloat)height{
    NSInteger length = self.title.length;
    return self.title.length == 0 ? 10 : 45;
}

@end
