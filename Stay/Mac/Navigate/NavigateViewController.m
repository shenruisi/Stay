//
//  NavigateViewController.m
//  Stay-Mac
//
//  Created by ris on 2022/6/23.
//

#import "NavigateViewController.h"
#import "FCStyle.h"

static CGFloat kMacToolbar = 50.0;

@interface NavigateViewController ()

@property (nonatomic, strong) UIView *line;
@end

@implementation NavigateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)navigateViewDidLoad{
    [self line];
}
- (void)navigateViewWillAppear:(BOOL)animated{
    [self.line bringSubviewToFront:self.view];
}
- (void)navigateViewDidAppear:(BOOL)animated{}
- (void)navigateViewWillDisappear:(BOOL)animated{}
- (void)navigateViewDidDisappear:(BOOL)animated{}

- (UIView *)line{
    if (nil == _line){
        _line = [[UIView alloc] initWithFrame:CGRectMake(0, kMacToolbar - 1, self.view.frame.size.width, 1)];
        _line.backgroundColor = FCStyle.fcSeparator;
        [self.view addSubview:_line];
    }
    
    return _line;
}
@end
