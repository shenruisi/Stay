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
    NSDictionary *attributes = [self.currentAttributedTitle attributesAtIndex:0 effectiveRange:nil];
    self.savedTitle = self.currentAttributedTitle.string;
    [self setAttributedTitle:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@...",self.savedTitle] attributes:attributes] forState:UIControlStateNormal];
    self.savedBackgroundColor = self.backgroundColor;
    self.backgroundColor = FCStyle.fcSeparator;
    [self.loadingView startAnimating];
}

- (void)stopLoading{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *attributes = [self.currentAttributedTitle attributesAtIndex:0 effectiveRange:nil];
        [self setAttributedTitle:[[NSAttributedString alloc] initWithString:self.savedTitle
                                                                attributes:attributes] forState:UIControlStateNormal];
        self.backgroundColor = self.savedBackgroundColor;
        [self.loadingView stopAnimating];
    });
    
}

- (UIActivityIndicatorView *)loadingView{
    if (nil == _loadingView){
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        _loadingView.color = FCStyle.fcWhite;
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
