//
//  FCNavigationBar.m
//  Stay
//
//  Created by ris on 2023/3/14.
//

#import "FCNavigationBar.h"
#import "FCStyle.h"
#import "FCViewController.h"
#import "FCNavigationController.h"
#import "ImageHelper.h"
#import "FCRoundedShadowView2.h"

static NSInteger FCNavigationTabItemLeft = 1;
static NSInteger FCNavigationTabItemRight = 100;
static NSInteger TabItemExtendLength = 10;



@interface _TabButton : UIButton
@property (nonatomic, strong) FCTabButtonItem *item;
@end

@implementation _TabButton

- (void)setItem:(FCTabButtonItem *)item{
    _item = item;
    
    if (item.title.length > 0){
        [self setAttributedTitle:[[NSAttributedString alloc] initWithString:_item.title
                                                                 attributes:@{
            NSForegroundColorAttributeName : FCStyle.fcBlack,
            NSFontAttributeName : FCStyle.body
        }] forState:UIControlStateNormal];
        
        [self setAttributedTitle:[[NSAttributedString alloc] initWithString:_item.title
                                                                 attributes:@{
            NSForegroundColorAttributeName : FCStyle.accent,
            NSFontAttributeName : FCStyle.body
        }] forState:UIControlStateSelected];
    }
    
    if (item.image){
        [self setImage:item.image forState:UIControlStateNormal];
    }
}

@end

@interface FCTabButtonItem()

@property (nonatomic, weak) _TabButton *button;
@end

@implementation FCTabButtonItem
@end

@interface FCNavigationTabItem()

@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) UIView *activatedLine;
@property (nonatomic, strong) _TabButton *selectedButton;
@property (nonatomic, strong) NSLayoutConstraint *activatedLineCenterConstraint;
@property (nonatomic, strong) NSLayoutConstraint *activatedLineWidthConstraint;
@end

@implementation FCNavigationTabItem

- (instancetype)init{
    if (self = [super init]){
        self.backgroundColor = [UIColor clearColor];
        [self line];
        [self activatedLine];
    }
    
    return self;
}

- (void)activeItem:(FCTabButtonItem *)targetItem{
    for (UIView *view in self.subviews){
        if (view.tag == FCNavigationTabItemLeft){
            _TabButton *button = (_TabButton *)view;
            if (button.item == targetItem){
                [self leftTabButtonItemDidClick:button];
            }
        }
    }
}

- (void)setLeftTabButtonItems:(NSArray<FCTabButtonItem *> *)leftTabButtonItems{
    for (UIView *view in self.subviews){
        if (view.tag == FCNavigationTabItemLeft){
            [view removeFromSuperview];
        }
    }

    _leftTabButtonItems = leftTabButtonItems;
    
    _TabButton *prevButton;
    for (NSUInteger i = 0; i < _leftTabButtonItems.count; i++){
        FCTabButtonItem *item = [_leftTabButtonItems objectAtIndex:i];
        CGRect rect = [item.title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, FCStyle.body.pointSize)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName : FCStyle.body}
                                               context:nil];
        _TabButton *button = [[_TabButton alloc] init];
        button.item = item;
        item.button = button;
    
        button.translatesAutoresizingMaskIntoConstraints = NO;
        button.tag = FCNavigationTabItemLeft;
        [button addTarget:self
                   action:@selector(leftTabButtonItemDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        if (!prevButton){
            [NSLayoutConstraint activateConstraints:@[
                [button.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:15],
                [button.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-12],
                [button.heightAnchor constraintEqualToConstant:rect.size.height],
                [button.widthAnchor constraintEqualToConstant:rect.size.width + TabItemExtendLength]
            ]];
        }
        else{
            [NSLayoutConstraint activateConstraints:@[
                [button.leadingAnchor constraintEqualToAnchor:prevButton.trailingAnchor constant:10],
                [button.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-12],
                [button.heightAnchor constraintEqualToConstant:rect.size.height],
                [button.widthAnchor constraintEqualToConstant:rect.size.width + TabItemExtendLength]
            ]];
        }
        
        if (i == 0){
            button.selected = YES;
            self.selectedButton = button;
            self.activatedLineCenterConstraint = [self.activatedLine.centerXAnchor constraintEqualToAnchor:button.centerXAnchor];
            [self.activatedLineCenterConstraint setActive:YES];
            self.activatedLineWidthConstraint = [self.activatedLine.widthAnchor constraintEqualToConstant:MIN(40,rect.size.width)];
            [self.activatedLineWidthConstraint setActive:YES];
            
        }
        
        prevButton = button;
    }
    
    [self layoutIfNeeded];
   
}

- (void)leftTabButtonItemDidClick:(_TabButton *)button{
    FCViewController *cer;
    if ([[self navigationBar].delegate isKindOfClass:[FCNavigationController class]]){
        cer = (FCViewController *)((FCNavigationController *)[self navigationBar].delegate).topViewController;
    }
    
    if (self.selectedButton == button){
        [cer tabItemDidClick:button.item refresh:YES];
        return;
    }
    
    self.selectedButton.selected = NO;
    [UIView animateWithDuration:0.1 animations:^{
        self.activatedLineWidthConstraint.constant = 0;
        [self layoutIfNeeded];
    
    } completion:^(BOOL finished) {
        [self.activatedLineCenterConstraint setActive:NO];
        self.activatedLineCenterConstraint =  [self.activatedLine.centerXAnchor constraintEqualToAnchor:button.centerXAnchor];
        [self.activatedLineCenterConstraint setActive:YES];
        button.selected = YES;
        [self layoutIfNeeded];
        [cer tabItemDidClick:button.item refresh:NO];
        
        [UIView animateWithDuration:0.1 animations:^{
            self.activatedLineWidthConstraint.constant = MIN(40, button.frame.size.width - TabItemExtendLength);
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
    }];
    self.selectedButton = button;
}

- (void)setRightTabButtonItems:(NSArray<FCTabButtonItem *> *)rightTabButtonItems{
    for (UIView *view in self.subviews){
        if (view.tag == FCNavigationTabItemRight){
            [view removeFromSuperview];
        }
    }
    
    _rightTabButtonItems = rightTabButtonItems;
    
    _TabButton *prevButton;
    for (NSInteger i = _rightTabButtonItems.count - 1; i >= 0; i--){
        FCTabButtonItem *item = [_rightTabButtonItems objectAtIndex:i];
        CGRect rect = CGRectMake(0, 0, 23, 23);
        _TabButton *button = [[_TabButton alloc] init];
        button.item = item;
        item.button = button;
    
        button.translatesAutoresizingMaskIntoConstraints = NO;
        button.tag = FCNavigationTabItemRight;
        [button addTarget:self
                   action:@selector(rightTabButtonItemDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        if (!prevButton){
            [NSLayoutConstraint activateConstraints:@[
                [button.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-15],
                [button.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-12],
                [button.heightAnchor constraintEqualToConstant:rect.size.height],
                [button.widthAnchor constraintEqualToConstant:rect.size.width + TabItemExtendLength]
            ]];
        }
        else{
            [NSLayoutConstraint activateConstraints:@[
                [button.leadingAnchor constraintEqualToAnchor:prevButton.trailingAnchor constant:-10],
                [button.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-12],
                [button.heightAnchor constraintEqualToConstant:rect.size.height],
                [button.widthAnchor constraintEqualToConstant:rect.size.width + TabItemExtendLength]
            ]];
        }
    
        prevButton = button;
    }
    
    [self layoutIfNeeded];
    
}

- (void)rightTabButtonItemDidClick:(_TabButton *)button{
    FCNavigationBar *searchBar = (FCNavigationBar *)self.superview;
    [searchBar rightItemClick:button.item];
//    FCViewController *cer;
//    if ([[self navigationBar].delegate isKindOfClass:[FCNavigationController class]]){
//        cer = (FCViewController *)((FCNavigationController *)[self navigationBar].delegate).topViewController;
//    }
//
//    [cer searchTabItemDidClick];
}

- (UIView *)line{
    if (nil == _line){
        _line = [[UIView alloc] init];
        _line.translatesAutoresizingMaskIntoConstraints = NO;
        _line.backgroundColor = FCStyle.fcSeparator;
        [self addSubview:_line];
        
        [NSLayoutConstraint activateConstraints:@[
            [_line.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [_line.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [_line.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
            [_line.heightAnchor constraintEqualToConstant:0.5]
        ]];
    }
    
    return _line;
}

- (UIView *)activatedLine{
    if (nil == _activatedLine){
        _activatedLine = [[UIView alloc] init];
        _activatedLine.translatesAutoresizingMaskIntoConstraints = NO;
        _activatedLine.layer.cornerRadius = 2;
        _activatedLine.backgroundColor = FCStyle.accent;
        [self addSubview:_activatedLine];
        
        [NSLayoutConstraint activateConstraints:@[
            [_activatedLine.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
            [_activatedLine.heightAnchor constraintEqualToConstant:2]
        ]];
    }
    
    return _activatedLine;
}

- (FCNavigationBar *)navigationBar{
    return (FCNavigationBar *)self.superview;
}


@end

@interface FCSearchBar : UIView

@property (nonatomic, strong) FCRoundedShadowView2 *textFieldContainer;
//@property (nonatomic, strong) NSArray<NSLayoutConstraint *> *textFieldContainerConstraints;
@end

@implementation FCSearchBar

- (instancetype)init{
    if (self = [super init]){
        [self textFieldContainer];
//        self.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}

- (FCRoundedShadowView2 *)textFieldContainer{
    if (nil == _textFieldContainer){
        _textFieldContainer = [[FCRoundedShadowView2 alloc] initWithRadius:10
                                                                borderWith:1
                                                                cornerMask:kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner];
        _textFieldContainer.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_textFieldContainer];
//        self.textFieldContainerConstraints = @[
//            _textFieldContainer.le
//        ];
//        [NSLayoutConstraint deactivateConstraints:<#(nonnull NSArray<NSLayoutConstraint *> *)#>]
        [NSLayoutConstraint activateConstraints:@[
            [_textFieldContainer.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [_textFieldContainer.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [_textFieldContainer.topAnchor constraintEqualToAnchor:self.topAnchor constant:0],
            [_textFieldContainer.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-5],
        ]];
    }
    
    return _textFieldContainer;
}

@end

@interface FCNavigationBar()

@property (nonatomic, strong) FCTabButtonItem *searchTabItem;
@property (nonatomic, strong) FCSearchBar *searchBar;
@property (nonatomic, strong) NSLayoutConstraint *searchBarWidth;
@property (nonatomic, strong) NSArray<NSLayoutConstraint *> *searchBarConstraints;
@end

@implementation FCNavigationBar

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
//        self.backgroundColor = [UIColor clearColor];
//        UINavigationBarAppearance *navigationBarAppearance = [[UINavigationBarAppearance alloc] init];
//        [navigationBarAppearance setShadowColor:FCStyle.fcSeparator];
//        [self setStandardAppearance:navigationBarAppearance];
    }
    
    return self;
}


- (void)layoutSubviews{
    [super layoutSubviews];
   
}

- (void)rightItemClick:(FCTabButtonItem *)item{
    if (item == self.searchTabItem){
        if (self.searchBar){
            [self.searchBar removeFromSuperview];
        }
        self.searchBar = [[FCSearchBar alloc] init];
        [self.navigationTabItem addSubview:self.searchBar];
        [self.navigationTabItem sendSubviewToBack:self.searchBar];
        [self.searchBar setFrame:CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.navigationTabItem.size.height)];
        self.searchBar.alpha = 0;
        
        [UIView animateWithDuration:3 animations:^{
            [self.searchBar setFrame:CGRectMake(self.navigationTabItem.size.width - 60, 0, self.searchBar.size.width, self.searchBar.size.height)];
            self.searchBar.alpha = 1;
        } completion:^(BOOL finished) {

        }];
    }
}

- (FCTabButtonItem *)searchTabItem{
    if (nil == _searchTabItem){
        _searchTabItem = [[FCTabButtonItem alloc] init];
        _searchTabItem.image = [ImageHelper sfNamed:@"magnifyingglass" font:FCStyle.headline color:FCStyle.fcBlack];
    }
    
    return _searchTabItem;
}


- (void)setEnableTabItemSearch:(BOOL)enableTabItemSearch{
    _enableTabItemSearch = enableTabItemSearch;
    if (_enableTabItemSearch){
        [self.navigationTabItem setRightTabButtonItems:@[self.searchTabItem]];
    }
    else{
        [self.navigationTabItem setRightTabButtonItems:@[]];
    }
}

- (void)setEnableTabItem:(BOOL)enableTabItem{
    _enableTabItem = enableTabItem;
    if (_enableTabItem){
        self.prefersLargeTitles = YES;
        [self navigationTabItem];
    }
    else{
        self.prefersLargeTitles = NO;
    }
    self.navigationTabItem.hidden = !enableTabItem;
}

- (FCNavigationTabItem *)navigationTabItem{
    if (nil == _navigationTabItem){
        _navigationTabItem = [[FCNavigationTabItem alloc] init];
        _navigationTabItem.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_navigationTabItem];
        
        [NSLayoutConstraint activateConstraints:@[
            [_navigationTabItem.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [_navigationTabItem.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [_navigationTabItem.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
            [_navigationTabItem.heightAnchor constraintEqualToConstant:44]
        ]];
    }
    
    return _navigationTabItem;
}

- (void)showSearchWithOffset:(CGFloat)offset{
    CGFloat move =  MIN(50,offset/1.8);
    self.searchBar.alpha = move/50;
    [self.searchBar setFrame:CGRectMake(self.frame.size.width - move, 0, self.frame.size.width, self.navigationTabItem.size.height)];
    [self.searchTabItem.button setImage: [ImageHelper sfNamed:@"magnifyingglass" font:FCStyle.headline color: move == 50 ? FCStyle.accent : FCStyle.fcBlack] forState:UIControlStateNormal];
}

- (FCSearchBar *)searchBar{
    if (nil == _searchBar){
        _searchBar = [[FCSearchBar alloc] init];
        [self.navigationTabItem addSubview:self.searchBar];
        [self.navigationTabItem sendSubviewToBack:self.searchBar];
    }
    
    return _searchBar;
}


- (void)setFrame:(CGRect)frame{
    if (_enableTabItem){
        CGRect newFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, MAX(88,frame.size.height));
    //    NSLog(@"navigation bar %@",NSStringFromCGRect(self.frame));
        [super setFrame:newFrame];
    }
    else{
        [super setFrame:frame];
    }
  
}

@end
