//
//  InputToolbarItem.m
//  Stay
//
//  Created by ris on 2023/4/26.
//

#import "InputToolbarItem.h"
#import "ImageHelper.h"
#import "FCStyle.h"
#import "UIColor+Convert.h"

@implementation InputToolbarItemElement

- (instancetype)init{
    if (self = [super init]){
        self.enabled = YES;
        self.useSFSymbol = YES;
        self.imageFont = FCStyle.cellIcon;
        self.radius = 6;
    }
    
    return self;
}

- (BOOL)titleMode{
    return self.title.length > 0;
}

@end

@interface InputToolbarItem()

@property (nonatomic, strong) UIImageView *itemImageView;
@property (nonatomic, strong) UILabel *itemLabelView;
@property (nonatomic, strong) UIView *highlightedView;
@property (nonatomic, strong) UIView *hoverView;
@end

@implementation InputToolbarItem

- (instancetype)initWithElement:(InputToolbarItemElement *)element{
    if (self = [super init]){
        self.backgroundColor = [UIColor clearColor];
        self.fillSuperView = YES;
        self.element = element;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self configureHover];
        [self configureTap];
    }
    
    return self;
}

- (void)configureHover{
    UIHoverGestureRecognizer *hoverRecognizer = [[UIHoverGestureRecognizer alloc] initWithTarget:self action:@selector(hovering:)];
    [self addGestureRecognizer:hoverRecognizer];
}

- (void)configureTap{
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(tap:)];
    [self addGestureRecognizer:gesture];
}

- (void)didMoveToSuperview{
    [super didMoveToSuperview];
    if (self && self.superview && self.fillSuperView){
        [NSLayoutConstraint activateConstraints:@[
            [self.leadingAnchor constraintEqualToAnchor:self.superview.leadingAnchor],
            [self.trailingAnchor constraintEqualToAnchor:self.superview.trailingAnchor],
            [self.topAnchor constraintEqualToAnchor:self.superview.topAnchor],
            [self.bottomAnchor constraintEqualToAnchor:self.superview.bottomAnchor]
        ]];
    }
    [self highlightedView];
    [self hoverView];
    if (self.element.titleMode){
        [self itemLabelView];
    }
    else{
        [self itemImageView];
    }
   
   
}

- (void)reload{
    self.hoverView.hidden = YES;
    self.highlightedView.hidden = !self.element.selected;
    if (self.element.useSFSymbol){
        [self.itemImageView setImage:[ImageHelper sfNamed:self.element.imageName
                                                 font:self.element.imageFont
                                            color:self.element.enabled ? (self.element.selected ? FCStyle.accent : FCStyle.fcBlack) :  FCStyle.fcSeparator]];
    }
    else{
        UIImage *image = [UIImage imageNamed:self.element.imageName];
        [self.itemImageView setImage:[image imageWithTintColor:self.element.enabled ? (self.element.selected ? FCStyle.accent : FCStyle.fcBlack) :  FCStyle.fcSeparator]];
    }
}
    
- (void)tap:(UITapGestureRecognizer *)recognizer{
    if (self.element.action){
        self.element.action(self);
    }
}
    
- (void)hovering:(UIHoverGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan){
        if (self.element.selected){
            self.hoverView.hidden = YES;
        }
        else{
            self.hoverView.hidden = NO;
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded){
        self.hoverView.hidden = YES;
    }
}

- (UIView *)highlightedView{
    if (nil == _highlightedView){
        _highlightedView = [[UIView alloc] init];
        _highlightedView.translatesAutoresizingMaskIntoConstraints = NO;
        _highlightedView.backgroundColor = [[FCStyle.accent colorWithAlphaComponent:0.1] rgba2rgb:FCStyle.secondaryBackground];
        _highlightedView.layer.cornerRadius = self.element.radius;
        _highlightedView.hidden = !self.element.selected;
        [self addSubview:_highlightedView];
        
        [NSLayoutConstraint activateConstraints:@[
            [_highlightedView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [_highlightedView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [_highlightedView.topAnchor constraintEqualToAnchor:self.topAnchor],
            [_highlightedView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        ]];
    }
    
    return _highlightedView;
}


- (UIView *)hoverView{
    if (nil == _hoverView){
        _hoverView = [[UIView alloc] init];
        _hoverView.translatesAutoresizingMaskIntoConstraints = NO;
        _hoverView.backgroundColor = FCStyle.fcHover;
        _hoverView.layer.cornerRadius = self.element.radius;
        _hoverView.hidden = YES;
        [self addSubview:_hoverView];
        
        [NSLayoutConstraint activateConstraints:@[
            [_hoverView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [_hoverView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [_hoverView.topAnchor constraintEqualToAnchor:self.topAnchor],
            [_hoverView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        ]];
    }
    
    return _hoverView;
}

- (UIImageView *)itemImageView{
    if (nil == _itemImageView){
        _itemImageView = [[UIImageView alloc] init];
        _itemImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _itemImageView.contentMode =  UIViewContentModeCenter;
        _itemImageView.userInteractionEnabled = NO;
        [self addSubview:_itemImageView];
        
        [NSLayoutConstraint activateConstraints:@[
            [_itemImageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [_itemImageView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [_itemImageView.topAnchor constraintEqualToAnchor:self.topAnchor],
            [_itemImageView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        ]];
    }
    
    if (self.element.useSFSymbol){
        [_itemImageView setImage:[ImageHelper sfNamed:self.element.imageName
                                                 font:self.element.imageFont
                                            color:self.element.enabled ? (self.element.selected ? FCStyle.accent : FCStyle.fcBlack) :  FCStyle.fcSeparator]];
    }
    else{
        UIImage *image = [UIImage imageNamed:self.element.imageName];
        [_itemImageView setImage:[image imageWithTintColor:self.element.enabled ? (self.element.selected ? FCStyle.accent : FCStyle.fcBlack) :  FCStyle.fcSeparator]];
    }
    
    return _itemImageView;
}

- (UILabel *)itemLabelView{
    if (nil == _itemLabelView){
        _itemLabelView = [[UILabel alloc] init];
        _itemLabelView.font = self.element.titleFont;
        _itemLabelView.textColor = self.element.selected ? FCStyle.accent : self.element.titleColor;
        _itemLabelView.translatesAutoresizingMaskIntoConstraints = NO;
        _itemLabelView.contentMode =  UIViewContentModeCenter;
        _itemLabelView.textAlignment = NSTextAlignmentCenter;
        _itemLabelView.userInteractionEnabled = NO;
        [self addSubview:_itemLabelView];
        
        [NSLayoutConstraint activateConstraints:@[
            [_itemLabelView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [_itemLabelView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [_itemLabelView.topAnchor constraintEqualToAnchor:self.topAnchor],
            [_itemLabelView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        ]];
        
        [_itemLabelView setText:self.element.title];
    }
    
    return _itemLabelView;
}



@end
