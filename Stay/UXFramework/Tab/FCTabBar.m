//
//  FCTabBar.m
//  Stay
//
//  Created by ris on 2023/3/14.
//

#import "FCTabBar.h"
#import "FCStyle.h"

@interface _BorderedButton : UIButton

@property (nonatomic, strong) UIView *borderedView;
@end

@implementation _BorderedButton

- (UIView *)borderedView{
    return nil;
}
@end

@interface FCTabBar()

@property (nonatomic, assign) FCTabBarStyle style;
@property (nonatomic, strong) UIView *line;
@property (nonatomic, assign) CGFloat opaqueHeight;
@property (nonatomic, strong) NSMutableArray<_BorderedButton *> *buttons;
@property (nonatomic, strong) UISegmentedControl *segmentControl;
@property (nonatomic, assign) BOOL tabBarHidden;
@end

@implementation FCTabBar


- (instancetype)initWithStyle:(FCTabBarStyle)style{
    if (self = [super init]){
        self.style = style;
        self.backgroundColor = UIColor.clearColor;
        if (self.style == FCTabBarStyleSegment){
            [self segmentControl];
        }
        
        [self line];
    }
    
    return self;
}

- (void)addItem:(FCTabBarItem *)item{
    if (self.style == FCTabBarStyleNormal){
        _BorderedButton *button = [[_BorderedButton alloc] init];
        [button setImage:item.selectImage forState:UIControlStateSelected];
        [button setImage:item.deselectImage forState:UIControlStateNormal];
        button.imageView.contentMode = UIViewContentModeCenter;
#ifdef FC_MAC
        button.imageEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15);
#else
        CGFloat safeBottom = self.superview.safeAreaInsets.bottom;
        button.imageEdgeInsets = UIEdgeInsetsMake((safeBottom == 0 ? 0 : 15) + item.offsetY, 10, 0, 10);
#endif
       
        
        [button addTarget:self action:@selector(didClick:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = self.buttons.count;
        
        UIHoverGestureRecognizer *hoverRecognizer = [[UIHoverGestureRecognizer alloc] initWithTarget:self action:@selector(hovering:)];
        [button addGestureRecognizer:hoverRecognizer];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [button addGestureRecognizer:longPress];

        
        UIView *borderedView = [[UIView alloc] init];
        borderedView.backgroundColor = FCStyle.fcSeparator;
#ifdef FC_IOS
        borderedView.layer.cornerRadius = 15;
#else
        borderedView.layer.cornerRadius = 12;
#endif
        borderedView.hidden = YES;
        [self addSubview:borderedView];
        button.borderedView = borderedView;
        
        [self.buttons addObject:button];
        [self addSubview:button];
        item.button = button;
    }
    else if (self.style == FCTabBarStyleSegment){
        [self.segmentControl insertSegmentWithImage:item.selectImage atIndex:self.segmentControl.numberOfSegments animated:NO];
    }
    
}

- (void)hovering:(UIHoverGestureRecognizer *)recognizer{
    _BorderedButton *button = (_BorderedButton *)recognizer.view;
    if (recognizer.state == UIGestureRecognizerStateBegan){
        button.borderedView.hidden = NO;
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded){
        if (!button.selected){
            button.borderedView.hidden = YES;
        }
    }
}

- (void)longPress:(UIHoverGestureRecognizer *)recognizer{
//    _BorderedButton *button = (_BorderedButton *)recognizer.view;
//    if (recognizer.state == UIGestureRecognizerStateBegan){
//        button.borderedView.hidden = NO;
//    }
//    else if (recognizer.state == UIGestureRecognizerStateEnded){
//        if (!button.selected){
//            button.borderedView.hidden = YES;
//        }
//
//    }
}

- (void)layout{
    if (self.style == FCTabBarStyleNormal){
        CGFloat safeBottom = 0;
#ifdef FC_IOS
        safeBottom = self.superview.safeAreaInsets.bottom;
#endif
        [self setFrame:CGRectMake(self.superview.safeAreaInsets.left, self.superview.frame.size.height -  (self.tabBarHidden ? 0 :self.height) - (self.tabBarHidden ? -safeBottom : safeBottom), self.superview.frame.size.width - self.superview.safeAreaInsets.left, self.height + safeBottom)];
        [self.line setFrame:CGRectMake(0, 0, self.bounds.size.width, 0.5)];
        NSInteger buttonWidth = self.bounds.size.width / self.buttons.count;
        
        NSInteger borderedWidth = 40;
        NSInteger borderedHeight = 25;
        NSInteger top = 12;
        
#ifdef FC_IOS
        borderedWidth = 50;
        borderedHeight = 30;
        top = 9;
#endif
        CGFloat left = 0;
        for (_BorderedButton *button in self.buttons){
            [button setFrame:CGRectMake(left, 0, buttonWidth, self.height)];
            button.borderedView.frame = CGRectMake(left + ((buttonWidth - borderedWidth)) / 2, top, borderedWidth,borderedHeight);
            left += buttonWidth;
        }
    }
}

- (void)didClick:(id)sender{
    _BorderedButton *button = (_BorderedButton *)sender;
    [self selectIndex:button.tag];
}

- (void)selectIndex:(NSInteger)index{
    _BorderedButton *selectButton = self.buttons[index];
    for (_BorderedButton *button in self.buttons){
        BOOL selected = button.tag == index;
        if (selected){
            button.transform = CGAffineTransformMakeScale(0.9, 0.9);
            
            [UIView animateWithDuration:0.3
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                button.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
            }
                             completion:^(BOOL finished) {
            }];
        }
        
        button.selected = selected;
        button.borderedView.hidden = !selected;
        button.borderedView.backgroundColor = selected ? [FCStyle.accent colorWithAlphaComponent:0.1] : FCStyle.fcSeparator;
        
    }
    if ([self.delegate respondsToSelector:@selector(tabBar:didSelectIndex:)]){
        [self.delegate tabBar:self didSelectIndex:selectButton.tag];
    }
}

- (NSMutableArray *)buttons{
    if (nil == _buttons){
        _buttons = [[NSMutableArray alloc] init];
    }
    
    return _buttons;
}

- (UISegmentedControl *)segmentControl{
    if (nil == _segmentControl){
        _segmentControl = [[UISegmentedControl alloc] init];
        [self addSubview:_segmentControl];
    }
    
    return _segmentControl;
}

- (UIView *)line{
    if (nil == _line){
        _line = [[UIView alloc] init];
        _line.backgroundColor = FCStyle.fcSeparator;
        [self addSubview:_line];
    }
    
    return _line;
}

- (BOOL)isShown{
    return !self.tabBarHidden;
}

- (void)show{
    if (self.tabBarHidden){
        self.tabBarHidden = NO;
        [UIView animateWithDuration:0.3
                         animations:^{
            [self layout];
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)dismiss{
    if (!self.tabBarHidden){
        self.tabBarHidden = YES;
        [UIView animateWithDuration:0.3
                         animations:^{
            [self layout];
        } completion:^(BOOL finished) {
            
        }];
    }
}

@end
