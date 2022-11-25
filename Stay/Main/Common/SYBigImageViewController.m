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

    for(int i = 0; i < self.imageList.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, (self.view.width - 60), (self.view.width - 60) * 2)];
        [imageView sd_setImageWithURL:self.imageList[i]];
        imageView.layer.cornerRadius = 15;
        imageView.layer.borderWidth = 1;
        imageView.layer.borderColor = FCStyle.borderColor.CGColor;
        imageView.layer.masksToBounds = YES;
        imageView.left = imageleft;
        [self.scrollView addSubview:imageView];
        imageleft += 15 + self.view.width - 60;
    }
}

- (UIScrollView *)scrollView {
    if(_scrollView != nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0,60 +(self.view.width - 60)* self.imageList.count, (self.view.width - 60)* 2)];
        _scrollView.showsHorizontalScrollIndicator = false;
        _scrollView.pagingEnabled = true;
        
        
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
