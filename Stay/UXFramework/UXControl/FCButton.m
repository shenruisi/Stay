//
//  FCButton.m
//  Stay
//
//  Created by ris on 2023/4/13.
//

#import "FCButton.h"
#import "FCStyle.h"

@interface FCButton()

@property (nonatomic, strong) UIColor *savedBackgroundColor;
@property (nonatomic, strong) UIColor *savedTitleColor;
@property (nonatomic, strong) UIColor *savedBorderColor;
@property (nonatomic, strong) NSString *savedTitle;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@end

@implementation FCButton

- (instancetype)init{
    if (self = [super init]){
        [self loadingView];
    }
    
    return self;
}

- (void)startLoading{
    self.savedTitle = self.currentAttributedTitle.string;
    self.savedBackgroundColor = self.backgroundColor;
    if (self.loadingTitleColor){
        self.savedTitleColor = [self.currentAttributedTitle attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:nil];
    }
    if (self.loadingBorderColor){
        self.savedBorderColor = [UIColor colorWithCGColor:self.layer.borderColor];
    }
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self.currentAttributedTitle attributesAtIndex:0 effectiveRange:nil]];
    self.savedTitle = self.currentAttributedTitle.string;
    if (self.loadingTitleColor){
        [attributes setObject:self.loadingTitleColor forKey:NSForegroundColorAttributeName];
    }
    [self setAttributedTitle:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@...",self.savedTitle] attributes:attributes] forState:UIControlStateNormal];
    self.backgroundColor = self.loadingBackgroundColor ? self.loadingBackgroundColor : UIColor.clearColor;
    if (self.loadingBorderColor){
        self.layer.borderColor = self.loadingBorderColor.CGColor;
    }
    
    [self.loadingView startAnimating];
}

- (void)stopLoading{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self.currentAttributedTitle attributesAtIndex:0 effectiveRange:nil]];
        if (self.loadingTitleColor){
            [attributes setObject:self.savedTitleColor forKey:NSForegroundColorAttributeName];
        }
        [self setAttributedTitle:[[NSAttributedString alloc] initWithString:self.savedTitle
                                                                attributes:attributes] forState:UIControlStateNormal];
        self.backgroundColor = self.savedBackgroundColor;
        if (self.loadingBorderColor){
            self.layer.borderColor = self.savedBorderColor.CGColor;
        }
        [self.loadingView stopAnimating];
    });
    
}

- (void)setLoadingViewColor:(UIColor *)loadingViewColor{
    if (_loadingView){
        _loadingView.color = loadingViewColor;
    }
}

- (UIActivityIndicatorView *)loadingView{
    if (nil == _loadingView){
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        _loadingView.color = self.loadingViewColor ? self.loadingViewColor : FCStyle.fcSecondaryBlack;
        _loadingView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_loadingView];
        
        [NSLayoutConstraint activateConstraints:@[
            [_loadingView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:15],
            [_loadingView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor]
        ]];
    }
    
    return _loadingView;
}

@end
