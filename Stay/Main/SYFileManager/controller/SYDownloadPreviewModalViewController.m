//
//  SYDownloadPreviewModalViewController.m
//  Stay
//
//  Created by zly on 2023/1/19.
//

#import "SYDownloadPreviewModalViewController.h"
#import "FCApp.h"
#import "FCStyle.h"
#import "FCStore.h"

@interface SYDownloadPreviewModalViewController()

@property (nonatomic, strong) UIScrollView *bannerView;

@end

@implementation SYDownloadPreviewModalViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationBar.hidden = NO;
    self.navigationBar.showCancel = NO;
    self.title = NSLocalizedString(@"DOWNLOADVIDEO", @"");
    
    NSArray *imageArray = @[@"DownloadPreview1",@"DownloadPreview2",@"DownloadPreview3"];
    
    NSArray *titleArray = @[NSLocalizedString(@"DOWNLOADPREVIEWTITLE1","Library"),NSLocalizedString(@"DOWNLOADPREVIEWTITLE2","Library")];

    NSArray *descArray = @[NSLocalizedString(@"DOWNLOADPREVIEWDESC1","Library"),NSLocalizedString(@"DOWNLOADPREVIEWDESC2","Library")];

    
    CGFloat left = 20;
    CGFloat top = 0;
    CGFloat width = 320;
        
    [self.view addSubview:self.bannerView];
    
    for(int i = 0; i < 3; i++) {
        UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(left, top, width,312)];
        imageView1.image = [UIImage imageNamed:imageArray[i]];
        imageView1.layer.cornerRadius = 5;
        imageView1.layer.borderColor = FCStyle.borderColor.CGColor;
        imageView1.layer.borderWidth = 1;
        imageView1.clipsToBounds = YES;
        [self.bannerView addSubview:imageView1];
        
        
        if(i < 2) {
            UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 15)];
            title.font = FCStyle.subHeadlineBold;
            title.text = titleArray[i];
            title.top = imageView1.bottom + 20;
            title.left = left;
            [self.bannerView addSubview:title];
            
            UILabel *desc = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 13)];
            desc.font = FCStyle.footnote;
            desc.text = descArray[i];
            desc.top = title.bottom + 10;
            desc.left = left;
            desc.textColor = FCStyle.fcSecondaryBlack;
            [self.bannerView addSubview:desc];
            
        }
        
        if(i == 2) {
            
            Boolean isPro = [[FCStore shared] getPlan:NO] == FCPlan.None?FALSE:TRUE;
            if(isPro) {
                UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 150, 43)];
                [btn setTitle:NSLocalizedString(@"TYRIT","") forState:UIControlStateNormal];
                btn.font = FCStyle.subHeadline;
                btn.layer.borderColor = FCStyle.borderColor.CGColor;
                btn.layer.borderWidth = 1;
                btn.layer.cornerRadius = 10;
                [btn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];

                btn.centerX = imageView1.centerX;
                [btn setTitleColor:FCStyle.titleGrayColor forState:UIControlStateNormal];
                btn.top = imageView1.bottom + 20;
                [self.bannerView addSubview:btn];
            } else {
                UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 150, 43)];
                [btn setTitle:NSLocalizedString(@"TYRITLATER","") forState:UIControlStateNormal];
                btn.layer.borderColor = FCStyle.borderColor.CGColor;
                btn.layer.borderWidth = 1;
                btn.layer.cornerRadius = 10;
                btn.top = imageView1.bottom + 20;
                btn.font = FCStyle.subHeadline;
                [btn setTitleColor:FCStyle.titleGrayColor forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];

                btn.left = left;
                [self.bannerView addSubview:btn];
                
                UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 150, 43)];
                [addButton setTitle:NSLocalizedString(@"UpgradeTo", @"") forState:UIControlStateNormal];
                addButton.layer.borderColor = FCStyle.borderGolden.CGColor;
                addButton.layer.borderWidth = 1;
                addButton.backgroundColor =  FCStyle.backgroundGolden;
                [addButton addTarget:self action:@selector(UpgradeTo) forControlEvents:UIControlEventTouchUpInside];
                [addButton setTitleColor:FCStyle.fcGolden forState:UIControlStateNormal];
                addButton.font = FCStyle.subHeadline;
                addButton.layer.cornerRadius = 10;
                addButton.top = imageView1.bottom + 20;
                addButton.right = imageView1.right;
                [self.bannerView addSubview:addButton];

            }
            
        }
        left = width + left + 10;
    }
    
    
}


- (void)UpgradeTo{
    [self.navigationController.slideController dismiss];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showUpgrade" object:nil];
}

- (void)close {
    [self.navigationController.slideController dismiss];

}

- (UIScrollView *)bannerView {
    if(_bannerView == nil) {
        _bannerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 15, 330 , 420)];
        _bannerView.contentSize = CGSizeMake(320 * 3 + 30, 420);
        _bannerView.scrollEnabled = true;
        _bannerView.pagingEnabled = true;
        _bannerView.clipsToBounds = NO;
        _bannerView.showsVerticalScrollIndicator = false;
        _bannerView.showsHorizontalScrollIndicator = false;
    }
    
    return _bannerView;
}

- (CGSize)mainViewSize{
    return CGSizeMake(MIN(FCApp.keyWindow.frame.size.width - 30, 360), 460);
}




@end
