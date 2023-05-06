//
//  FCRootViewController.m
//  Stay
//
//  Created by ris on 2023/3/14.
//

#import "FCRootViewController.h"
#import "FCStyle.h"
#import "FCStore.h"

@interface FCRootViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIBarButtonItem *logoItem;
@property (nonatomic, strong) UIBarButtonItem *titleItem;
@property (nonatomic, strong) UIBarButtonItem *proItem;
@property (nonatomic, strong) UILabel *leftTitleLabel;
@property (nonatomic, strong) UIBarButtonItem *indicatorItem;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@end

@implementation FCRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [super scrollEffectHandle:scrollView];
    [super searchEffectHanlde:scrollView];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    [super searchStartCheck:scrollView];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    NSMutableArray *leftBarButtonItems = [[NSMutableArray alloc] initWithObjects:self.logoItem, nil];
    if ([[FCStore shared] getPlan:NO] != FCPlan.None){
        [leftBarButtonItems addObject:self.proItem];
    }
    
    if (self.leftTitleLabel.text.length > 0){
        [leftBarButtonItems addObject:self.titleItem];
    }
    
    [leftBarButtonItems addObject:self.indicatorItem];
    self.navigationItem.leftBarButtonItems = leftBarButtonItems;
}

- (void)setLeftTitle:(NSString *)leftTitle{
    if (leftTitle.length > 0){
        [self.leftTitleLabel setText:leftTitle];
        CGRect rect = [leftTitle boundingRectWithSize:CGSizeMake(MAXFLOAT, 18) options:0 attributes:@{
            NSFontAttributeName : FCStyle.headlineBold
        } context:nil];
        [self.leftTitleLabel setFrame:CGRectMake(0, 0, rect.size.width, 18)];
        self.navigationItem.leftBarButtonItems = @[self.logoItem,self.proItem,self.titleItem,self.indicatorItem];
    }
}

- (UILabel *)leftTitleLabel{
    if (nil == _leftTitleLabel){
        _leftTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 18)];
        _leftTitleLabel.font = FCStyle.headlineBold;
        _leftTitleLabel.textColor = FCStyle.fcBlack;
        _leftTitleLabel.backgroundColor = UIColor.clearColor;
    }
    
    return _leftTitleLabel;
}

- (UIBarButtonItem *)logoItem{
    if (nil == _logoItem){
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 18, 18)];
        [imageView setImage:[UIImage imageNamed:@"NavIcon"]];
        _logoItem = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    }
    
    return _logoItem;
}

- (UIBarButtonItem *)proItem{
    if (nil == _proItem){
        UILabel *proLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 15)];
        proLabel.backgroundColor = FCStyle.backgroundGolden;
        proLabel.font = [UIFont boldSystemFontOfSize:10];
        proLabel.text = @"PRO";
        proLabel.layer.borderWidth = 1;
        proLabel.layer.borderColor = FCStyle.borderGolden.CGColor;
        proLabel.layer.cornerRadius = 5;
        proLabel.textAlignment = NSTextAlignmentCenter;
        proLabel.textColor = FCStyle.fcGolden;
        proLabel.clipsToBounds = YES;
        _proItem = [[UIBarButtonItem alloc] initWithCustomView:proLabel];
    }
    
    return _proItem;
}

- (UIBarButtonItem *)titleItem{
    if (nil == _titleItem){
        _titleItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftTitleLabel];
    }
    
    return _titleItem;
}

- (UIBarButtonItem *)indicatorItem{
    if (nil == _indicatorItem){
        _indicatorItem = [[UIBarButtonItem alloc] initWithCustomView:self.indicatorView];
    }
    
    return _indicatorItem;
}

- (UIActivityIndicatorView *)indicatorView{
    if (nil == _indicatorView){
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        _indicatorView.color = FCStyle.fcSecondaryBlack;
    }
    
    return _indicatorView;
}

- (void)startHeadLoading{
    [self.indicatorView startAnimating];
}

- (void)stopHeadLoading{
    [self.indicatorView stopAnimating];
}

@end
