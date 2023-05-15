//
//  FCTapView.m
//  Stay
//
//  Created by ris on 2023/5/15.
//

#import "FCTapView.h"

@implementation FCTapView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(tapAction)];
        [self addGestureRecognizer:gesture];
    }
    
    return self;
}

- (instancetype)init{
    if (self = [super init]){
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(tapAction)];
        [self addGestureRecognizer:gesture];
    }
    
    return self;
}


- (void)tapAction{
    if (self.action){
        self.action();
    }
}


@end
