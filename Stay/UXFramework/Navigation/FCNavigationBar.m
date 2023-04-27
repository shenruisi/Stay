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
#import "FCBlockView.h"
#import "FCTabBarController.h"


static NSInteger FCNavigationTabItemLeft = 1;
static NSInteger FCNavigationTabItemRight = 100;
static NSInteger TabItemExtendLength = 10;
static CGFloat OneStageMovingLength = 50;


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

- (void)alphaSubItems:(CGFloat)alpha{
    self.activatedLine.alpha = alpha;
    
    for (UIView *view in self.subviews){
        if (view.tag == FCNavigationTabItemLeft
            || view.tag == FCNavigationTabItemRight){
            view.alpha = alpha;
        }
    }
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

@protocol FCSearchBarDelegate <NSObject>
- (void)searchBarDidClickCancel;
@end

@protocol FCSearchBarDelegate;
@interface FCSearchBar()

@property (nonatomic, strong) FCRoundedShadowView2 *textFieldContainer;
@property (nonatomic, strong) NSLayoutConstraint *textFieldContainerLeading;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, weak) id<FCSearchBarDelegate> delegate;
@property (nonatomic, strong) UIImageView *leftAccessory;
@end

@implementation FCSearchBar

- (instancetype)init{
    if (self = [super init]){
        [self textFieldContainer];
        [self cancelButton];
        [self leftAccessory];
        [self textField];
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
        self.textFieldContainerLeading = [_textFieldContainer.leadingAnchor constraintEqualToAnchor:self.leadingAnchor];
        [NSLayoutConstraint activateConstraints:@[
            self.textFieldContainerLeading,
            [_textFieldContainer.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-70],
            [_textFieldContainer.topAnchor constraintEqualToAnchor:self.topAnchor constant:0],
            [_textFieldContainer.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-5],
        ]];
    }
    
    return _textFieldContainer;
}

- (UIImageView *)leftAccessory{
    if (nil == _leftAccessory){
        _leftAccessory = [[UIImageView alloc] init];
        _leftAccessory.hidden = YES;
        _leftAccessory.image = [ImageHelper sfNamed:@"magnifyingglass" font:FCStyle.headline color:FCStyle.accent];
        CGSize size = _leftAccessory.image.size;
        _leftAccessory.translatesAutoresizingMaskIntoConstraints = NO;
        [self.textFieldContainer addSubview:_leftAccessory];
        [NSLayoutConstraint activateConstraints:@[
            [_leftAccessory.leadingAnchor constraintEqualToAnchor:self.textFieldContainer.leadingAnchor constant:7.9],
            [_leftAccessory.widthAnchor constraintEqualToConstant:size.width],
            [_leftAccessory.topAnchor constraintEqualToAnchor:self.textFieldContainer.topAnchor constant:10]
        ]];
    }
    
    return _leftAccessory;
}

- (UITextField *)textField{
    if (nil == _textField){
        _textField = [[UITextField alloc] init];
        _textField.translatesAutoresizingMaskIntoConstraints = NO;
        [self.textFieldContainer addSubview:_textField];
        [NSLayoutConstraint activateConstraints:@[
            [_textField.leadingAnchor constraintEqualToAnchor:self.leftAccessory.trailingAnchor constant:5],
            [_textField.trailingAnchor constraintEqualToAnchor:self.textFieldContainer.trailingAnchor constant:-5],
            [_textField.topAnchor constraintEqualToAnchor:self.textFieldContainer.topAnchor],
            [_textField.bottomAnchor constraintEqualToAnchor:self.textFieldContainer.bottomAnchor]
        ]];
        
    }
    
    return _textField;
}

- (UIButton *)cancelButton{
    if (nil == _cancelButton){
        _cancelButton = [[UIButton alloc] init];
        [_cancelButton setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"cancel", @"")
                                                                attributes:@{
            NSForegroundColorAttributeName : FCStyle.accent,
            NSFontAttributeName : FCStyle.body
        }] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
        _cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_cancelButton];
        
        [NSLayoutConstraint activateConstraints:@[
            [_cancelButton.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-10],
            [_cancelButton.widthAnchor constraintEqualToConstant:70],
            [_cancelButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        ]];
    }
    
    return _cancelButton;
}

- (void)cancelAction:(id)sender{
    [self.delegate searchBarDidClickCancel];
}

@end



@interface FCNavigationBar()<
 FCBlockViewDelegate,
 FCSearchBarDelegate,
 UITextFieldDelegate
>

@property (nonatomic, strong) FCTabButtonItem *searchTabItem;
@property (nonatomic, strong) FCBlockView *searchBlockView;
@property (nonatomic, strong) NSArray<NSLayoutConstraint *> *bindViewConstraints;
@property (nonatomic, assign) BOOL searchBarShouldAppear;
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
        [self.searchBar setFrame:CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.navigationTabItem.size.height)];
        self.searchBar.alpha = 0;
        
        [UIView animateWithDuration:0.3 animations:^{
            [self.searchBar setFrame:CGRectMake(self.navigationTabItem.size.width - OneStageMovingLength, 0, self.searchBar.size.width, self.searchBar.size.height)];
            self.searchBar.alpha = 1;
            [self.searchTabItem.button setImage:[ImageHelper sfNamed:@"magnifyingglass" font:FCStyle.headline color:FCStyle.accent] forState:UIControlStateNormal];
        } completion:^(BOOL finished) {
            [self searchBarAppearSecondStage];
        }];
    }
}

- (void)searchBarAppearSecondStage{
    FCViewController *cer = [self topController];
    if ([cer.searchUpdating respondsToSelector:@selector(willBeginSearch)]){
        [cer.searchUpdating willBeginSearch];
    }
    self.searchBarShouldAppear = YES;
    self.searchBar.leftAccessory.hidden = NO;
    [self.searchBar.textFieldContainerLeading setActive:NO];
    self.searchBar.textFieldContainerLeading = [self.searchBar.textFieldContainer.leadingAnchor constraintEqualToAnchor:self.searchBar.leadingAnchor constant:15];
    [self.searchBar.textFieldContainerLeading setActive:YES];
    [self.navigationTabItem bringSubviewToFront:self.searchBar];
    
    if (cer){
        UIEdgeInsets safeEdgeInsets = cer.view.safeAreaInsets;
        UIView *bindView = cer.searchViewController ? cer.searchViewController.view : self.searchBlockView;
        bindView.alpha = 0;
        [cer.view addSubview:bindView];
        [NSLayoutConstraint deactivateConstraints:self.bindViewConstraints];
        self.bindViewConstraints = @[
            [bindView.leadingAnchor constraintEqualToAnchor:cer.view.leadingAnchor],
            [bindView.trailingAnchor constraintEqualToAnchor:cer.view.trailingAnchor],
            [bindView.topAnchor constraintEqualToAnchor:cer.view.topAnchor constant:safeEdgeInsets.top],
            [bindView.bottomAnchor constraintEqualToAnchor:cer.view.bottomAnchor constant:-safeEdgeInsets.bottom],
        ];
        [NSLayoutConstraint activateConstraints:self.bindViewConstraints];
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        if (cer.searchViewController){
            cer.searchViewController.view.alpha = 1;
        }
        else{
            self.searchBlockView.alpha = 0.3;
        }
        
        [self.navigationTabItem alphaSubItems:0];
        [self.searchBar setFrame:CGRectMake(0, 0, self.searchBar.size.width, self.searchBar.size.height)];
    } completion:^(BOOL finished) {
        if ([cer.searchUpdating respondsToSelector:@selector(willBeginSearch)]){
            [cer.searchUpdating didBeganSearch];
        }
        [self.searchBar.textField becomeFirstResponder];
    }];
}

- (FCViewController *)topController{
    FCViewController *cer = nil;
    if ([self.delegate isKindOfClass:[FCNavigationController class]]){
        cer = (FCViewController *)((FCNavigationController *)self.delegate).topViewController;
    }
    
    return cer;
}

- (void)cancelSearch{
    FCViewController *cer = [self topController];
    if ([cer.searchUpdating respondsToSelector:@selector(willEndSearch)]){
        [cer.searchUpdating willEndSearch];
    }
    [self.searchBar.textField resignFirstResponder];
    [self.searchBar.textFieldContainerLeading setActive:NO];
    self.searchBar.textFieldContainerLeading = [self.searchBar.textFieldContainer.leadingAnchor constraintEqualToAnchor:self.searchBar.leadingAnchor];
    [self.searchBar.textFieldContainerLeading setActive:YES];
    [self.navigationTabItem sendSubviewToBack:self.searchBar];
    self.searchTabItem.button.hidden = YES;
    [UIView animateWithDuration:0.5 animations:^{
        UIView *bindView = cer.searchViewController ? cer.searchViewController.view : self.searchBlockView;
        bindView.alpha = 0;
        [self.navigationTabItem alphaSubItems:1];
        [self.searchBar setFrame:CGRectMake(self.navigationTabItem.size.width - OneStageMovingLength, 0, self.searchBar.size.width, self.searchBar.size.height)];
    } completion:^(BOOL finished) {
        self.searchBar.leftAccessory.hidden = YES;
        if (cer.searchViewController){
            [cer.searchViewController.view removeFromSuperview];
        }
        else{
            [self.searchBlockView removeFromSuperview];
            self.searchBlockView = nil;
        }
       
        
        [UIView animateWithDuration:0.3 animations:^{
            [self.searchBar setFrame:CGRectMake(self.navigationTabItem.size.width, 0, self.searchBar.size.width, self.searchBar.size.height)];
            self.searchBar.alpha = 0;
            self.searchTabItem.button.hidden = NO;
            [self.searchTabItem.button setImage:[ImageHelper sfNamed:@"magnifyingglass" font:FCStyle.headline color:FCStyle.fcBlack] forState:UIControlStateNormal];
        } completion:^(BOOL finished) {
            self.searchBarShouldAppear = NO;
            if ([cer.searchUpdating respondsToSelector:@selector(didEndSearch)]){
                [cer.searchUpdating didEndSearch];
            }
        }];
    }];
}

- (void)searchBarDidClickCancel{
    [self cancelSearch];
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
    if (self.searchBarShouldAppear) return;
    CGFloat move =  MIN(OneStageMovingLength,offset/1.8);
    self.searchBar.alpha = move/OneStageMovingLength;
    [self.searchBar setFrame:CGRectMake(self.frame.size.width - move, 0, self.frame.size.width, self.navigationTabItem.size.height)];
    [self.searchTabItem.button setImage: [ImageHelper sfNamed:@"magnifyingglass" font:FCStyle.headline color: move == 50 ? FCStyle.accent : FCStyle.fcBlack] forState:UIControlStateNormal];
}

- (void)startSearch{
    if (self.searchBar.alpha == 1){
        [self searchBarAppearSecondStage];
    }
}

- (void)touched{
    [self searchBarDidClickCancel];
}

- (void)controlTextDidChange:(NSNotification *)obj{
    UITextField *searchField = (UITextField *)obj.object;
    if (searchField == self.searchBar.textField){
        FCViewController *cer = [self topController];
        if ([cer.searchUpdating respondsToSelector:@selector(searchTextDidChange:)]){
            [cer.searchUpdating searchTextDidChange:searchField.text];
        }
    }
}

- (FCSearchBar *)searchBar{
    if (nil == _searchBar){
        _searchBar = [[FCSearchBar alloc] init];
        _searchBar.delegate = self;
        _searchBar.textField.delegate = self;
        [self.navigationTabItem addSubview:self.searchBar];
        [self.navigationTabItem sendSubviewToBack:self.searchBar];
    }
    
    return _searchBar;
}

- (FCBlockView *)searchBlockView{
    if (nil == _searchBlockView){
        _searchBlockView = [[FCBlockView alloc] initWithAlpha:1];
        _searchBlockView.alpha = 0;
        _searchBlockView.delegate = self;
        _searchBlockView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    return _searchBlockView;
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
