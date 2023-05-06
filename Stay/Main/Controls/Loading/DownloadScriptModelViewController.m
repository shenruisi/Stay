//
//  DownloadScriptModelViewController.m
//  Stay
//
//  Created by zly on 2023/4/25.
//

#import "DownloadScriptModelViewController.h"
#import "FCStyle.h"
#import "UIImageView+WebCache.h"
#import "DefaultIcon.h"

@interface DownloadScriptModelViewController()

@property (nonatomic, strong) UILabel *mainLabel;
@property (nonatomic, strong) UILabel *downloadLabel;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UIView *imageBox;

@end
@implementation DownloadScriptModelViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    self.hideNavigationBar = NO;
    self.title = NSLocalizedString(@"Download Userscript", @"");
    [self mainLabel];
    [self iconView];
    self.mainLabel.top = self.imageBox.bottom + 12;
}

- (void)updateMainText:(NSString *)text{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mainLabel.text = text;
    });
}


- (UILabel *)mainLabel{
    if (nil == _mainLabel){
        _mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, self.view.frame.size.width, 19)];
        _mainLabel.textAlignment = NSTextAlignmentCenter;
        _mainLabel.text = self.originMainText;
        _mainLabel.font = FCStyle.body;
        _mainLabel.textColor = FCStyle.fcBlack;
        [self.view addSubview:_mainLabel];
    }
    
    return _mainLabel;
}

- (UILabel *)downloadLabel{
    if (nil == _downloadLabel){
        _downloadLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 16, self.view.frame.size.width, 21)];
        _downloadLabel.textAlignment = NSTextAlignmentLeft;
        _downloadLabel.text = NSLocalizedString(@"Download Userscript", @"");
        _downloadLabel.font = FCStyle.headlineBold;
        _downloadLabel.textColor = FCStyle.fcBlack;
        [self.view addSubview:_downloadLabel];
    }
    
    return _downloadLabel;
}

- (UIImageView *)iconView {
    if(nil == _iconView) {
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 26, 26)];
        if(self.iconUrl.length > 0) {
            [_iconView sd_setImageWithURL:[NSURL URLWithString: self.iconUrl]];
        } else {
            [_iconView setImage:[DefaultIcon iconWithTitle:self.originMainText size:CGSizeMake(26, 26)]];
        }
        _iconView.contentMode =  UIViewContentModeScaleAspectFit;
        _iconView.clipsToBounds = YES;
        _iconView.centerX = 24;
        _iconView.centerY = 24;
        [self.imageBox addSubview:_iconView];
        
    }
    return _iconView;
}

- (UIView *)imageBox {
    if(nil == _imageBox) {
        _imageBox = [[UIView alloc] initWithFrame:CGRectMake(15, 25, 48, 48)];
        _imageBox.layer.cornerRadius = 8;
        _imageBox.layer.borderWidth = 1;
        _imageBox.layer.borderColor = FCStyle.borderColor.CGColor;
        _imageBox.clipsToBounds = YES;
        _imageBox.centerX =  self.view.frame.size.width / 2;
        [self.view addSubview:_imageBox];
    }
    
    return _imageBox;
}

- (CGSize)mainViewSize{
    CGFloat width = 352;
    CGFloat height = 187;
    return CGSizeMake(width, height);
}
@end
