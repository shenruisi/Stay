//
//  SYProgress.m
//  Stay
//
//  Created by zly on 2022/12/10.
//

#import "SYProgress.h"
@interface SYProgress ()

@property (nonatomic, strong) UIView *progressView;

@end

@implementation SYProgress

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame BgViewBgColor:(UIColor *)bgViewBgColor BgViewBorderColor:(UIColor *)bgViewBorderColor ProgressViewColor:(UIColor *)progressViewColor {
      if (self = [super initWithFrame:frame]) {
//          self.layer.cornerRadius = self.bounds.size.height * 0.5;
          self.layer.masksToBounds = YES;
          self.backgroundColor = bgViewBgColor;
//          self.layer.borderColor = bgViewBorderColor.CGColor;
//          self.layer.borderWidth = 1;
  
          //进度
          self.progressView = [[UIView alloc] init];
          self.progressView.backgroundColor = progressViewColor;
//          self.progressView.layer.cornerRadius = (self.bounds.size.height - 2) * 0.5;
          self.progressView.layer.masksToBounds = YES;
          [self addSubview:self.progressView];
      }
      return self;
  }

  - (void)setProgress:(CGFloat)progress {
      _progress = progress;
      CGFloat width = self.bounds.size.width - 2;
      CGFloat heigth = self.bounds.size.height;
      _progressView.frame = CGRectMake(1, 0, width * progress / 100, heigth);
  }

@end
