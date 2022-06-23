//
//  LoadingStatusModalViewController.m
//  Stay
//
//  Created by ris on 2022/5/23.
//

#import "LoadingStatusModalViewController.h"
#import "FCStyle.h"

@interface LoadingStatusModalViewController()

@property (nonatomic, strong) UILabel *mainLabel;
@property (nonatomic, strong) UILabel *subLabel;
@end

@implementation LoadingStatusModalViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self mainLabel];
    [self subLabel];
}

- (void)updateMainText:(NSString *)text{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mainLabel.text = text;
    });
}

- (void)updateSubText:(NSString *)text{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.subLabel.text = text;
    });
}

- (UILabel *)mainLabel{
    if (nil == _mainLabel){
        _mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, self.view.frame.size.width, 17)];
        _mainLabel.textAlignment = NSTextAlignmentCenter;
        _mainLabel.text = self.originMainText;
        _mainLabel.font = FCStyle.headlineBold;
        _mainLabel.textColor = FCStyle.fcBlack;
        [self.view addSubview:_mainLabel];
    }
    
    return _mainLabel;
}

- (UILabel *)subLabel{
    if (nil == _subLabel){
        _subLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 55, self.view.frame.size.width, 16)];
        _subLabel.textAlignment = NSTextAlignmentCenter;
        _subLabel.text = self.originSubText;
        _subLabel.font = FCStyle.body;
        _subLabel.textColor = FCStyle.fcSecondaryBlack;
        [self.view addSubview:_subLabel];
    }
    
    return _subLabel;
}

- (CGSize)mainViewSize{
    CGFloat width = 300;
    CGFloat height = 100;
    return CGSizeMake(width, height);
}


@end
