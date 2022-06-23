//
//  EmptyViewController.m
//  Stay-Mac
//
//  Created by ris on 2022/6/22.
//

#import "EmptyViewController.h"
#import "FCStyle.h"

@interface EmptyViewController ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation EmptyViewController

- (void)navigateViewDidLoad {
    [super navigateViewDidLoad];
    self.view.backgroundColor = FCStyle.background;
    [self label];
    NSLog(@"EmptyViewController view %@",self.view);
}

- (void)navigateViewWillAppear:(BOOL)animated{
    [super navigateViewWillAppear:animated];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self.label setFrame:CGRectMake((self.view.frame.size.width - self.label.frame.size.width)/2, (self.view.frame.size.height - 18)/2, self.label.frame.size.width,18)];
}

- (UILabel *)label{
    if (nil == _label){
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height - 18)/2, self.view.frame.size.width, 18)];
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *appname = infoDictionary[@"CFBundleDisplayName"];
        NSString *appVersion = [NSString stringWithFormat:@" %@(%@)",infoDictionary[@"CFBundleShortVersionString"],infoDictionary[@"CFBundleVersion"]];
        NSMutableAttributedString *builder = [[NSMutableAttributedString alloc] init];
        [builder appendAttributedString:[[NSAttributedString alloc] initWithString:appname attributes:@{
            NSForegroundColorAttributeName:FCStyle.fcSecondaryBlack,
            NSFontAttributeName:FCStyle.headlineBold,
            NSObliquenessAttributeName:@(0.2)
            
        }]];
        
        [builder appendAttributedString:[[NSAttributedString alloc] initWithString:appVersion attributes:@{
            NSForegroundColorAttributeName:FCStyle.fcSecondaryBlack,
            NSFontAttributeName:FCStyle.body,
            NSObliquenessAttributeName:@(0.2)
            
        }]];
        
        _label.attributedText = builder;
        [_label sizeToFit];
        [_label setFrame:CGRectMake((self.view.frame.size.width - _label.frame.size.width)/2, (self.view.frame.size.height - 18)/2, _label.frame.size.width,18)];
        [self.view addSubview:_label];
    }
    
    return _label;
}



@end
