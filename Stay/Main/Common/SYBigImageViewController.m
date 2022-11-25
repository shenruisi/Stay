//
//  SYBigImageViewController.m
//  Stay
//
//  Created by zly on 2022/11/24.
//

#import "SYBigImageViewController.h"
#import "UIImageView+WebCache.h"
#import "FCStyle.h"
@interface SYBigImageViewController ()

@property(nonatomic, strong) UIScrollView *scrollView;

@end

@implementation SYBigImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGFloat imageleft = 30;
    self.view.backgroundColor = FCStyle.fcWhite;

        
    for(int i = 0; i < self.imageList.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, (self.view.width - 60), (self.view.width - 60) * 2.16)];
        [imageView sd_setImageWithURL:self.imageList[i]];
        imageView.layer.cornerRadius = 15;
        imageView.layer.borderWidth = 1;
        imageView.layer.borderColor = FCStyle.borderColor.CGColor;
        imageView.layer.masksToBounds = YES;
        imageView.clipsToBounds = YES;

        imageView.left = imageleft;
        
        imageView.centerY = self.view.height / 2 + 20;
    
        [self.scrollView addSubview:imageView];
        
        imageleft += 15 + self.view.width - 60;
    }
    
    self.scrollView.contentSize = CGSizeMake(imageleft + 15, (self.view.width - 60) * 2.16);
    self.scrollView.width = (imageleft + 15) / self.imageList.count - 45 / self.imageList.count;
    
    [self.view addSubview:self.scrollView];
    
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    [btn  setTitle:NSLocalizedString(@"GuidePage2ButtonFinished", @"") forState:UIControlStateNormal];
    btn.titleLabel.font = FCStyle.body;
    [btn setTitleColor:FCStyle.accent forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(closeFlash) forControlEvents:UIControlEventTouchUpInside];
    btn.top = 60;
    btn.right = self.view.width - 26;

    [self.view addSubview:btn];
}

- (void)closeFlash {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (UIScrollView *)scrollView {
    if(_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0,self.view.width - 30, (self.view.width - 60)* 2.16)];
        _scrollView.showsHorizontalScrollIndicator = false;
        _scrollView.pagingEnabled = true;
        _scrollView.clipsToBounds = NO;
                
    }
    return _scrollView;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
