//
//  FCTopToastModalViewController.m
//  Stay
//
//  Created by ris on 2022/11/25.
//

#import "FCTopToastModalViewController.h"

#import "FCStyle.h"

@interface FCTopToastModalViewController()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *mainLabel;
@property (nonatomic, strong) UILabel *secondaryLabel;
@property (nonatomic, strong) UIButton *closeButton;
@end

@implementation FCTopToastModalViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self iconImageView];
    [self mainLabel];
    [self secondaryLabel];
    [self closeButton];
}

- (void)viewWillAppear{
    [super viewWillAppear];
    
    if (self.icon){
        [self.iconImageView setImage:self.icon];
        [self.iconImageView setFrame:CGRectMake([self marginLeft]  - 10, (self.view.frame.size.height - 26)/2, 26, 26)];
    }
    else{
        [self.iconImageView setFrame:CGRectZero];
    }
    
    CGFloat titleMarginLeft = self.icon ? (self.iconImageView.frame.origin.x + self.iconImageView.frame.size.width) : [self marginLeft];
    CGFloat titleWidth = self.view.frame.size.width - 2 * titleMarginLeft;
    if (self.mainTitle.length > 0){
        [self.mainLabel setText:self.mainTitle];
        [self.mainLabel setFrame:CGRectMake(titleMarginLeft, 10, titleWidth, 16)];
    }
    else{
        [self.mainLabel setFrame:CGRectZero];
    }
    
    if (self.secondaryTitle.length > 0){
        [self.secondaryLabel setText:self.secondaryTitle];
        [self.secondaryLabel setFrame:CGRectMake(titleMarginLeft, self.mainLabel.frame.origin.y + self.mainLabel.frame.size.height + 5, titleWidth, 15)];
    }
    else{
        [self.secondaryLabel setFrame:CGRectZero];
    }
    
    [self.closeButton setFrame:CGRectMake(self.view.frame.size.width - 12-10, (self.view.frame.size.height - 12)/2, 12, 18)];
}

- (void)reload{
    [self.iconImageView setImage:self.icon];
    [self.mainLabel setText:self.mainTitle];
    [self.secondaryLabel setText:self.secondaryTitle];
}

- (UIImageView *)iconImageView{
    if (nil == _iconImageView){
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.view addSubview:_iconImageView];
    }
    
    return _iconImageView;
}

- (UILabel *)mainLabel{
    if (nil == _mainLabel){
        _mainLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _mainLabel.font = FCStyle.subHeadlineBold;
        _mainLabel.textColor = FCStyle.fcBlack;
        _mainLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_mainLabel];
    }
    
    return _mainLabel;
}

- (UILabel *)secondaryLabel{
    if (nil == _secondaryLabel){
        _secondaryLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _secondaryLabel.font = FCStyle.footnote;
        _secondaryLabel.textColor = FCStyle.fcSecondaryBlack;
        _secondaryLabel.textAlignment = NSTextAlignmentCenter;
        _secondaryLabel.numberOfLines = 2;
        [self.view addSubview:_secondaryLabel];
    }
    
    return _secondaryLabel;
}

- (UIButton *)closeButton{
    if (nil == _closeButton){
        _closeButton = [[UIButton alloc] initWithFrame:CGRectZero];
        UIImage *image = [UIImage systemImageNamed:@"xmark" withConfiguration:[UIImageSymbolConfiguration configurationWithFont:[UIFont systemFontOfSize:12]]];
        
        [_closeButton setImage:[image imageWithTintColor:FCStyle.fcSecondaryBlack renderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_closeButton];
        
    }

    return _closeButton;
}

- (void)closeAction:(id)sender{
    [self.navigationController.slideController dismiss];
}

- (CGSize)mainViewSize{
    CGFloat width = 250;
    CGFloat height = 10 + 15 + 5 + 15 + 10;
    return CGSizeMake(width, MAX(50,height));
}

- (CGFloat)marginLeft{
    return 25;
}

@end
