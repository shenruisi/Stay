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
@end

@implementation FCRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [super scrollEffectHandle:scrollView];
    
    if (self.enableSearchTabItem && self.navigationBarBaseLine > 0){
        FCNavigationBar *navigationBar = (FCNavigationBar *)self.navigationController.navigationBar;
        [navigationBar showSearchWithOffset:self.navigationController.navigationBar.height - self.navigationBarBaseLine];
    }
}



- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    if (self.enableSearchTabItem && self.navigationBarBaseLine > 0){
        FCNavigationBar *navigationBar = (FCNavigationBar *)self.navigationController.navigationBar;
        [navigationBar startSearch];
    }
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
    
    self.navigationItem.leftBarButtonItems = leftBarButtonItems;
}

- (void)setLeftTitle:(NSString *)leftTitle{
    if (leftTitle.length > 0){
        [self.leftTitleLabel setText:leftTitle];
        self.navigationItem.leftBarButtonItems = @[self.logoItem,self.proItem,self.titleItem];
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

@end
