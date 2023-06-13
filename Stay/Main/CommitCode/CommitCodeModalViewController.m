//
//  CommitCodeModalViewController.m
//  Stay
//
//  Created by ris on 2023/6/13.
//

#import "CommitCodeModalViewController.h"
#import "FCApp.h"


@interface CommitCodeModalViewController()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSArray<UITextField *> textFieldGroup;
@end

@implementation CommitCodeModalViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self imageView];
}

- (UIImageView *)imageView{
    if (nil == _imageView){
        _imageView = [[UIImageView alloc] init];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [_imageView setImage:[UIImage imageNamed:@"InviteBigIcon"]];
        [self.view addSubview:_imageView];
        [NSLayoutConstraint activateConstraints:@[
            [_imageView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
            [_imageView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:35],
            [_imageView.widthAnchor constraintEqualToConstant:100],
            [_imageView.heightAnchor constraintEqualToConstant:100]
        ]];
    }
    
    return _imageView;
}

- (CGSize)mainViewSize{
    return CGSizeMake(MIN(FCApp.keyWindow.frame.size.width - 30, 360), 550);
}
@end
